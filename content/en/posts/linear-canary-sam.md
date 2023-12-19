+++
title = 'Preventing downtime with deployment strategies in AWS SAM'
featured_image= "/images/linear-canary-sam/canary.png"
date = 2023-12-19T22:52:53+01:00
draft = false
+++

Today I wanted to talk about a very interesting topic related to deployments strategies when using SAM to create Serverless Applications. By choosing a solid deployment strategy for our business need, we can achieve a very high level of confidence in our deployments, and we can also reduce the risk of breaking our production environment at scale. The adoption of a good deployment strategy favors the adoption of Continuous Delivery and Continuous Deployment practices, which are key to achieve a high level of agility in our teams.

AWS SAM makes the implementation of deployment strategies very easy for serverless applications. In this post, we are going to focus on the ```Linear``` and ```Canary``` strategies, which are the most common ones. We are going to see how to implement them in our serverless applications using AWS SAM in a sample application. Hope you enjoy it!

## Sample API - Birthday countdown API

Our sample application will be a simple API that returns the number of days until your next birthday. The API will be composed of two Lambda functions, one to get the date of birth and another one to calculate the number of days until the next birthday. Those lambdas will be event sourced by API Gateway with the operations below:

- **GET** /hello/{name}
- **POST** /hello/{name} with body ```{ "dateOfBirth": "YYYY-MM-DD" }```

## Architecture

The application will be composed by two Lambdas, one DynamoDB table and one API Gateway. The DynamoDB table will be used to store the date of birth of the user, and the API Gateway will be used to expose the two endpoints mentioned above. The architecture will look like this:

![Architecture](/images/linear-canary-sam/diagram.png)

## DeploymentPreference settings

As part of the ```AWS::Serverless::Function``` SAM resource, we have the [DeploymentPreference](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-property-function-deploymentpreference.html) property. This is a built-in property that provides a way to configure CodeDeploy for your Lambda fuction.

The ```DeploymentPreference``` property has the following properties:

- ```Type```: Can be ```Linear``` or ```Canary```
- ```Alarms```: A list of CloudWatch alarms that will be used to monitor the deployment
- ```Hooks```: Validation Lambda functions that are run before and after traffic shifting.
- ```Role```: An IAM role ARN that CodeDeploy will use for traffic shifting
- ```TriggerConfigurations```: A list of trigger configurations that will be used to monitor the deployment. Used to notify an SNS topic on lifecycle events.
- ```PassthroughCondition```: If True, and if this deployment preference is enabled, the function's Condition will be passed through to the generated CodeDeploy resource. Generally, you should set this to True. Otherwise, the CodeDeploy resource would be created even if the function's Condition resolves to False.

In our example we will focus on the ```Type``` property, which will be set as ```Canary10Percent5Minutes``` and we are going to set one alarm in the ```Alarms``` property. This alarm will be used to monitor the deployment and it will be triggered if the ```Errors``` metric is greater than 0.
 
 Our configuration for each function will look something like this:

```yaml
  GetBirthdayFunction:
    Type: AWS::Serverless::Function
    Properties:
        ...
      DeploymentPreference:
        Type: Canary10Percent5Minutes # This is our strategy
        Alarms:
          # A list of alarms that you want to monitor
          - !Ref ErrorMetricGreaterThanZeroGetBirthdayAlarm

  PutBirthdayFunction:
    Type: AWS::Serverless::Function
    Properties:
        ...
      DeploymentPreference:
        Type: Canary10Percent5Minutes
        Alarms:
          # A list of alarms that you want to monitor
          - !Ref ErrorMetricGreaterThanZeroPutBirthdayAlarm
```

Now we need to define the alarms that we are going to use to monitor the deployment. We will use the [AWS::CloudWatch::Alarm](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cw-alarm.html) resource to define the alarms. The alarms will be triggered if the ```Errors``` metric is greater than 0. If during the deployment the metric is greater than 0, the deployment will be rolled back. The configuration will look like this:

```yaml
  ErrorMetricGreaterThanZeroPutBirthdayAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmDescription: "Alarm if errors greater than zero for PutBirthdayFunction"
      Namespace: "AWS/Lambda"
      MetricName: "Errors"
      Dimensions:
        - Name: FunctionName
          Value: !Ref PutBirthdayFunction
      Statistic: "Sum"
      Period: 60
      EvaluationPeriods: 1
      Threshold: 0
      ComparisonOperator: "GreaterThanThreshold"

  ErrorMetricGreaterThanZeroGetBirthdayAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmDescription: "Alarm if errors greater than zero for GetBirthdayFunction"
      Namespace: "AWS/Lambda"
      MetricName: "Errors"
      Dimensions:
        - Name: FunctionName
          Value: !Ref GetBirthdayFunction
      Statistic: "Sum"
      Period: 60
      EvaluationPeriods: 1
      Threshold: 0
      ComparisonOperator: "GreaterThanThreshold"
```

## What's the difference between Linear and Canary?

The difference between the two strategies is the way the traffic is shifted between the two versions of the Lambda function. In the case of the ```Linear``` strategy, the traffic is shifted in a linear way, meaning that the traffic is shifted in equal increments until the new version is fully deployed. For example, the type ```Linear10PercentEvery10Minutes``` means that the traffic is shifted in 10% increments every 10 minutes, until the new version is fully deployed. Thus, the total time for the deployment is 100 minutes, if the deployment is successful.

In the case of the ```Canary``` strategy, the traffic is shifted in a canary way, meaning that the traffic is shifted in two increments, first 10% and then 100%. For example, the type ```Canary10Percent10Minutes``` means that the traffic is shifted in 10% increments every 10 minutes, until the new version is fully deployed. Thus, the total time for the deployment is 20 minutes, if the deployment is successful.

Important to mention there's the ```AllAtOnce``` strategy, which shifts all traffic from the old version to the new version at once. This strategy is not recommended for production environments, but it's useful for testing purposes, as it's the fastest way to deploy a new version.

As we can see the tradeoff between the two strategies is the time it takes to deploy a new version. The more cautious we are, the more time it will take to deploy a new version.

## Let's see it in action

Once you have your application ready and deployed, you make a change to the code. Let's change the message that is returned by the ```GetBirthdayFunction``` to ```Hello {name}, your birthday is in {days} days! V2```. The return value of the functions XXX will look like this:

```go
return &GetBirthdayResponse{
  Message: fmt.Sprintf("Hello, %s! Your birthday is in %d day(s). V2", username, daysUntil),
}, nil
```

Now we can deploy the new version of the application by running the following command:

```bash
make deploy

## which is equivalent to
sam deploy --stack-name ${STACK_NAME} --region ${REGION} --no-confirm-changeset;
```

Now that's when the magic happens. You'll notice from your CodeDeploy console that a new deployment kicked in. The deployment will be in progress for 5 minutes, and after that, the traffic will be shifted to the new version. If you repeatedly call the API, you'll notice that in 10% of the calls you'll be served with the new version of the function. After 5 minutes, the traffic will be shifted to the new version, and you'll be served with the new version in 100% of the calls. 

From your console you'll see something like this:

![Deployment](/images/linear-canary-sam/canary.png)

## Github repository

You can find the code for this example in the following Github repository: [Birthday countdown API](https://github.com/victoraldir/sam-go-api). The repository contains a Makefile to make things more convenient. The app has been developed using Go, but you can use any other language supported by AWS Lambda.


