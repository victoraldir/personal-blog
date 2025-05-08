+++
title = 'Api Gtw Lambda Authorizer'
date = 2023-12-17T17:33:19+01:00
draft = true
+++



# Takeaways

- When a client makes a request to an API method that has a custom authorizer, API Gateway calls your authorizer Lambda function, which takes the caller's identity as input and returns the an **IAM policy** as output.

- There are two type of Authorizers:
    1. __Token-based__: Received the caller's identity in a bearer token (Oauth or JWT token for example).
    2. __Request-based__: Received the caller's identity in the request parameters, headers, or query string parameters.
    
- Lambda authorizers expect the input and output highlighted below
    1. **Input:**
    ``` json
    {
      "type":"TOKEN",
      "authorizationToken":"{caller-supplied-token}",
      "methodArn":"arn:aws:execute-api:{regionId}:{accountId}:{apiId}/{stage}/{httpVerb}/[{resource}/[{child-resources}]]"
    }
    ```

    2. **Output:**
    ``` json
    {
        "principalId": "yyyyyyyy", // The principal user identification associated with the token sent by the client.
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
            {
                "Action": "execute-api:Invoke",
                "Effect": "Allow|Deny",
                "Resource": "arn:aws:execute-api:{regionId}:{accountId}:{apiId}/{stage}/{httpVerb}/[{resource}/[{child-resources}]]"
            }
            ]
        },
        "context": {
            "stringKey": "value",
            "numberKey": "1",
            "booleanKey": "true"
        },
        "usageIdentifierKey": "{api-key}"
    }
    ```

- An important point highlighted by AWS documentation is that: 
    > To enable caching, your authorizer must return a policy that is applicable to all methods across an API. To enforce method-specific policy, you can set the TTL value to zero to disable policy caching for the API.

    It means that in our case, if we 