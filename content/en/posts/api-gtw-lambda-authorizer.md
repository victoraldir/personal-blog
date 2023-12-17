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
    