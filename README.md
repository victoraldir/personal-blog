# How does it work?

This blog is built with [Hugo](https://gohugo.io/). Hugo is a static site generator written in Go. It is very fast and easy to use. You can find more information about Hugo on [https://gohugo.io/](https://gohugo.io/).

# How to run it locally?

You can run this blog locally with the following command:

```bash
make run-local
```

This will start a server on port 1313. You can open your browser and go to [http://localhost:52709/](http://localhost:52709/) to see your blog.

# How to publish a new post?

Whatever you write in the content/posts directory will be published on the blog. You can create a new post with the following command:

```bash
hugo new posts/creating-blog-hugo.md
```

This will create a new file in the content/posts directory. You can edit this file with your favorite editor. I will use [Visual Studio Code](https://code.visualstudio.com/) for this blog.

# How to publish the blog?

This project uses Github Actions to publish the blog. You can find the workflow file in the .github/workflows directory. This file contains the following steps:

1. Build the blog with Hugo
2. Deploy the blog to AWS S3
3. Invalidate the CloudFront cache
