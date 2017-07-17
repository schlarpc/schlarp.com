+++
date = "2017-07-16T14:00:00-00:00"
draft = false
title = "Serverless from Scratch #3"
+++

Chapter 3: S3's Super Speedy Static Site Serving
------------------------------------------------

In the last chapter, we set up the infrastructure for a serverless backend, running Python code
in AWS Lambda. While we could use this to host an entire site, rendering HTML pages from our
Python code, it's a bit of a waste. It's slower, more error-prone, and costlier than just
using static site hosting. Luckily for us, S3 has features catered directly towards serving static
websites. However, we're not going to use S3 alone. While you can use S3 as a standalone service
to host your website, you miss out on important features like HTTPS and are required to use a
specific bucket naming scheme. Instead, we're going to put CloudFront, a content distribution
service, in front of our S3 bucket. This will give us caching, worldwide geographic distribution,
and a bunch of other cool features over the offering we get with S3 alone.

We'll start out by making a very lame `index.html`, which I'm going to put into the `frontend`
directory:

```
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>AWStube</title>
  </head>
  <body>
	<h1>This also works!</h1>
  </body>
</html>
```

Now we're going to add a few resources to our `template.yaml`. First, we need an S3 bucket.
We made one of these before using the AWS CLI for our deployments, but now we're going to make
one using CloudFormation. This time, however, we can leave the naming up to CloudFormation instead
of going to great pains to make sure it's a unique name. For many resource types, CloudFormation
will automatically generate pseudo-random names. Since we can reference those names using
CloudFormations intrinsics and outputs, we don't have to be explicit in our template.

```
Resources:
  FrontendS3Bucket:
    Type: AWS::S3::Bucket
    Properties:
      WebsiteConfiguration:
        IndexDocument: index.html

Outputs:
  FrontendBucketName:
    Value: !Ref FrontendS3Bucket
```

We've configured our bucket with a "website configuration", which basically lets us slightly
change S3's response pattern for certain requests. Now, if a request is issued to the bucket for
an object that does not exist _but would exist_ if `/index.html` were appended to the request path,
S3 will silently return that `index.html` object. This is the way people are used to web servers
working when dealing with static files, and makes S3 a bit better suited for static site hosting.

At this point, you might be wondering how exactly we know how to configure a given resource in our
template. The answer is, of course,
[the AWS manual](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket.html),
which has an exhaustive list of all of the resource types which can be constructed out-of-the-box
using CloudFormation. Many of the properties require digging into the associated service's
documentation to fully understand their effects, but they're typically well linked from the
CloudFormation documentation.

We could now use S3 directly to host our frontend - we'd use the bucket's name, append
`.s3-website-us-west-2.amazonaws.com` to the end, and done. But this has some major drawbacks;
for one, if we wanted to use a custom domain (and we do) then the bucket _must_ be named
exactly the same as the domain name. This includes subdomains - we'd need to make two buckets, one
for `www.ourdomain.com` and one for `ourdomain.com`, and hope that nobody else has taken those
bucket names in the shared S3 namespace. Secondly, HTTPS won't work with a custom domain name, as
the servers only present certificates for the S3 domain. And finally, we wouldn't have a good way
to deploy new revisions of our frontend; since we have to update files one at a time, a user could
get inconsistent versions of our frontend during a deployment.

Instead, we're going to put CloudFront in front of our S3 bucket. CloudFront is a content
delivery network - a collection of geographically distributed "points of presence" that act
as an optimized caching proxy for your website. Let's jump right in to the configuration, and
we'll talk about what it means afterwards:

```
Parameters:
  FrontendOriginPath:
    Type: String

Resources:
  FrontendCloudFrontDistribution:
    Type: AWS::CloudFront::Distribution
    Properties:
      DistributionConfig:
        Enabled: 'true'
        HttpVersion: http2
        Origins:
        - DomainName: !Select [2, !Split ["/", !GetAtt FrontendS3Bucket.WebsiteURL]]
          Id: S3Bucket
          OriginPath: !Join
            - ''
            - - /
              - !Ref FrontendOriginPath
          CustomOriginConfig:
            HTTPPort: 80
            HTTPSPort: 443
            OriginProtocolPolicy: http-only
        DefaultCacheBehavior:
          Compress: 'true'
          MinTTL: 0
          DefaultTTL: 2592000
          MaxTTL: 2592000
          TargetOriginId: S3Bucket
          ViewerProtocolPolicy: redirect-to-https
          ForwardedValues:
            QueryString: 'false'
            Cookies:
              Forward: none

Outputs:
  FrontendUrl:
    Value: !Join
      - ''
      - - https://
        - !GetAtt FrontendCloudFrontDistribution.DomainName
```

Okay, that one was a bit more complex than the previous stuff we've done. But it's pretty
straightforward when you break it down. We made a CloudFront "distribution" that serves our content,
and enabled support for HTTP/2. We configured an "origin", which is where our
content comes from, with the S3 bucket's "website URL". Unfortunately, CloudFront wants a domain
name while all we have is a full URL, so we split the string on "/" and take the second
element using the `Split` and `Select` CloudFormation intrinsics. Additionally, we had to use
HTTP (not HTTPS) to connect to our origin, because the S3 website endpoints don't support
HTTPS (seriously?). The caching behavior we specified is _aggresive_, with a month-long expiration
time and ignoring the user-provided query string and cookies. This is because we'll be completely
changing our origin every time we deploy, using the `FrontendOriginPath` parameter. This is a
developer-defined input to the CloudFormation template, and we'll update our deploy scripts to
give this a sane value. After each deploy, we'll issue an invalidation to CloudFront, which will
drop any cached copies of the old version of the site. While this will cause more cache
invalidations than are strictly necessary, it's a good starting point until we put together a more
comprehensive versioning and caching strategy.

Once that's rolled out - and that might take a while, CloudFormation distributions update slowly -
you might be tempted to try loading that `FrontendUrl` output we defined. Well, that won't work
quite yet. For one, we haven't pushed our files into S3 yet, which will require a change to our
deployment script. But, more importantly, our S3 bucket is still completely private! Since we want
this to be a public website, we're going to apply a "bucket policy" to make it world-readable.
These policies are written in a format common across all AWS services:
[the IAM policy language](http://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html).
IAM policies alone could take an entire blog post to explain in detail, but this one is pretty
simple:

```
Resources:
  FrontendS3BucketPolicy:
    Type: AWS::S3::BucketPolicy
    Properties:
      Bucket: !Ref FrontendS3Bucket
      PolicyDocument:
        Statement:
          -
            Effect: "Allow"
            Action:
              - "s3:GetObject"
            Principal: "*"
            Resource:
              !Join
              - ""
              - - "arn:aws:s3:::"
                - !Ref FrontendS3Bucket
                - "/*"
```

In this resource, we've linked an IAM policy to the bucket we created earlier. A policy
consists of one or more "statements", each of which have several parts: `Action`, `Effect`,
`Resource`, and `Principal`. The `Effect` is always either `Allow` or `Deny` and specifies whether
this statement is intended to allow or deny access to a resource. Since the default is `Deny` for
all resources, policies usually consist mostly of `Allow` statements. The `Action` indicates what
interactions are allowed against the resource, and the format of these varies by service. Consult
the documentation for each service to learn the full list of `Action`s supported. `Principal` refers
to the identity of the requester - this can get pretty complex on its own, but for now we're just
allowing everyone, so `*` is used as a wildcard. Finally, `Resource` indicates what resources this
statement should apply to. `Resource` entries are typically specified in the "Amazon Resource Name",
or "ARN", format. This is a standardized and unambiguous way of referring to many resources within
AWS.

As a security-paranoid aside, this configuration does mean that if someone were to discover the
name of our S3 bucket, they could access it directly, bypassing the CloudFront distribution.
Unfortunately, CloudFront doesn't support access control in combination with S3 when we use the
`WebsiteConfiguration` option on our S3 bucket. However, the exposure here is quite minimal:
a determined attacker might be able to get individual objects from the bucket directly, but
they won't be able to list the objects in the bucket, and the content itself was public in the
first place.

And now for the last part of this post, we're going to modify our deployment scripts to upload
our frontend files to S3. I've added a convenience script called `get-output.sh` that pulls an
output variable from our CloudFormation stack so that we can determine the frontend S3 bucket's
name. We've also hit an interesting chicken-and-egg problem: we can't upload the files to the bucket
until it exists, but we can't create the bucket without making the CloudFront distribution at the
same time. But then we're pointing to resources that don't exist from our distribution, which isn't
what we want. This only really affects the first deployment, so for now we'll punt on the problem
and just add some extra logic to the deployment script. Oh well. Here's what we've got now:

```
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get default.region)
DEPLOY_BUCKET=sam-deployment-$ACCOUNT_ID-$REGION
FRONTEND_PATH=$(head -c16 < <(tr -dc 'a-z' < /dev/urandom))

if FRONTEND_BUCKET=$(./get-output.sh FrontendBucketName); then
    INITIAL_DEPLOY=false
    aws s3 sync ./frontend s3://$FRONTEND_BUCKET/$FRONTEND_PATH
else
    INITIAL_DEPLOY=true
fi

aws cloudformation package --template-file template.yaml --s3-bucket $DEPLOY_BUCKET > template-packaged.yaml
aws cloudformation deploy --template-file template-packaged.yaml --stack-name awstube --capabilities CAPABILITY_IAM \
    --parameter-overrides FrontendOriginPath=$FRONTEND_PATH

if [ "$INITIAL_DEPLOY" = "true" ];
    FRONTEND_BUCKET=$(./get-output.sh FrontendBucketName)
    aws s3 sync ./frontend s3://$FRONTEND_BUCKET/$FRONTEND_PATH
fi

aws configure set preview.cloudfront true
aws cloudfront create-invalidation --distribution-id $(./get-output.sh FrontendDistributionId) --paths '/*'
```

For each deployment, we create a new path in our frontend bucket. Like I mentioned before,
proper file versioning would make this somewhat unnecessary, but I've done this in the interest of
avoiding eventual consistency woes with S3 and not having to set up a frontend build pipeline.
We should also keep in mind that we've created something that puts an unbounded amount of data into
S3, which means the cost, although small, will keep increasing. Regardless, we use the AWS
CLI to copy the files into the bucket using the `aws s3 sync` command, and update the origin in
CloudFront by passing the new path with `--parameter-overrides` to our CloudFormation stack.
A call to `aws cloudfront create-invalidation` ensures that our distribution returns the latest
files from our S3 bucket after the deployment is complete.

We're done! Once we've run a deployment with this updated script, we can use `get-output.sh` to
see our distribution's URL:

```
$ ./get-output.sh FrontendUrl
++ aws cloudformation describe-stacks --stack-name awstube --query 'Stacks[0].Outputs[?OutputKey==`FrontendUrl`] | [0].OutputValue' --output text
+ RESULT=https://d3e4f5e6f7e8f9.cloudfront.net
+ '[' https://d3e4f5e6f7e8f9.cloudfront.net = None ']'
+ echo https://d3e4f5e6f7e8f9.cloudfront.net
https://d3e4f5e6f7e8f9.cloudfront.net
$ curl https://d3e4f5e6f7e8f9.cloudfront.net
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>AWStube</title>
  </head>
  <body>
        <h1>This also works!</h1>
  </body>
</html>
```

Well, that's all for this post. Next time, we're going to circle back onto _operational excellence_
in our application before we get in too deep. As before, the repository has been
[tagged with `chapter3`](https://github.com/schlarpc/awstube/releases/tag/chapter3)
for the current state of our application if you'd like to play with it.

Chapter 4 coming soon!
