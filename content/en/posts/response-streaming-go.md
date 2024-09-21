+++
title = 'Response Streaming Go'
date = 2024-09-21T23:28:16+02:00
draft = true
+++

Hey there! It's been a while since I last wrote a post, I hope I can keep up with the pace now. Today I wanted to talk about a very interesting topic related to response streaming in Go. This is a very powerful feature that allows us to send data to the client in chunks, instead of waiting for the entire response to be ready (buffered). This expands the limit of lambdas to a whole new level, allowing us to process large amounts of data without worrying about the very tiny limit of 6MB for the response payload with buffered responses.

## My motivation to explore this feature

I have been trying to make myvideohunter.com to be able to download videos from reddit. However, this time I needed to transcode the video from a playlist file (m3u8) to a single video file (mp4). As you know, the whole backbone of myvidehunter.com is serverless, so I needed to build a "transcoder" lambda that would be able to transcode the video and send the response back to the client in chunks.

Then I stumbled in the very first limitation of buffered responses: **the 6MB limit**. I was not able to send the entire video back to the client in a single response, so I needed to find a way to send the video in chunks. That's when I found out about response streaming technique that AWS Lambda supports.

## Response streaming in Go

In [this blog post written by Julian Wood](https://aws.amazon.com/blogs/compute/introducing-aws-lambda-response-streaming/) you will find the announcement of AWS Lambda response streaming support. This new feature impacts positively on application that needs to send large payloads back to the client, which is the case of myvidehunter.com. 

Writing a response stream in Go is very simple. You just need to make sure your handler function returns a `*events.LambdaFunctionURLStreamingResponse` object. This response type requires compiling with `-tags lambda.norpc`, or choosing the `provided` or `provided.al2` runtime. In the example I am providing in this post, I am using the `provided.al2023` runtime, which is the new [Amazon Linux 2023 runtime for AWS Lambda](https://aws.amazon.com/blogs/compute/introducing-the-amazon-linux-2023-runtime-for-aws-lambda/).

Your handler fuction will look something like this:

```go
func lambdaHandler(request *events.LambdaFunctionURLRequest) (*events.LambdaFunctionURLStreamingResponse, error) {
    
    // Your code here

    return &events.LambdaFunctionURLStreamingResponse{
		StatusCode: http.StatusOK,
		Headers: map[string]string{
			"Content-Type":        "video/mp4",
			"Content-Disposition": "attachment; filename=myfile.mp4",
		},
		Body: r, // r is a reader.
	}, nil
}
```

Now you can send the response back to the client in chunks in a different go routine. 

> [!IMPORTANT]  
> You can not use Amazon API Gateway and Application Load Balancer to progressively stream response payloads. You have to stream response payloads through [Lambda function URLs](https://docs.aws.amazon.com/lambda/latest/dg/urls-configuration.html), including as an Amazon CloudFront origin.

## Sample project

I have created a sample project that you can find in my [GitHub repository](https://github.com/victoraldir/response-streaming-go). This project is a simple API that returns a video file in chunks. In fact, it will return any kind of binary you request, but in the example I am returning a MP4 video file. 

The scope if very simple:

1. The client sends a GET request to the CloudFront URL providing a URL containing the video file.

2. The lambda will instantiate a new HTTP client, request the video file from the URL provided and pipe the client response to the response writer back to the client in a different go routine.

3. The client will receive the video file in chunks.


## Limitations

There are some limitations that you need to be aware of when using response streaming in Go:

- The maximum response payload size is 20MB. It is soft limit, and you can request a limit increase.
- The maximum execution time is 15 minutes. This is a hard limit and you can not request a limit increase.
- You can not use Amazon API Gateway and Application Load Balancer to progressively stream response payloads.

## Conclusion

Response streaming in Go is a very powerful feature that allows us to send data to the client in chunks. It opens a whole new world of possibilities for serverless applications, and in my case, it allowed me to implement a transcoding layer for myvidehunter.com fully serverless. 

