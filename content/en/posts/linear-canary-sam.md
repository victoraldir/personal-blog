+++
title = 'Linear Canary Sam'
date = 2023-12-18T22:52:53+01:00
draft = true
+++

Today I wanted to talk about a very interesting topic related to deployments strategies when using SAM to create Serverless Applications. Through a solid strategy, we can achieve a very high level of confidence in our deployments, and we can also reduce the risk of breaking our production environment.

The best aspect of using SAM is that in order to enable such strategies, we don't need to provision each standalone resource via CloudFormation, but we can use unique AWS SAM properties to achieve the same result.

## DeploymentPreference settings

As part of the ```AWS::Serverless::Function``` resources, we can define a ```DeploymentPreference``` property, which allows us to define the following settings:

- ```Type```: Can be ```Linear``` or ```Canary```
- ```Alarms```: A list of CloudWatch alarms that will be used to monitor the deployment
- ```Hooks```: Validation Lambda functions that are run before and after traffic shifting.
- ```Role```: An IAM role ARN that CodeDeploy will use for traffic shifting
- ```TriggerConfigurations```: A list of trigger configurations that will be used to monitor the deployment. Used to notify an SNS topic on lifecycle events.
- ```PassthroughCondition```: If True, and if this deployment preference is enabled, the function's Condition will be passed through to the generated CodeDeploy resource. Generally, you should set this to True. Otherwise, the CodeDeploy resource would be created even if the function's Condition resolves to False.

In our example we will focus on the ```Type``` property, which can be set to ```Canary10Percent5Minutes``` and we are going to set one alarm in the ```Alarms``` property. This alarm will be used to monitor the deployment and it will be triggered if the ```Errors``` metric is greater than 0.
 
 Something like this:

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
```

