+++
date = "2017-07-16T13:00:00-00:00"
draft = false
title = "Serverless from Scratch #2"
+++

Chapter 2: Sam-I-Am
-------------------

It's time to get acquainted with the SAM: the [AWS Serverless Application Model](https://github.com/awslabs/serverless-application-model).
SAM gives us a couple different things which will be helpful in building our application.
One, it gives us a infrastructure description language built on top of AWS CloudFormation,
but with some nice shortcuts specifically created for serverless apps. AWS CloudFormation allows us
to create repeatable, templated deployments called "stacks" with well-defined rollback semantics
for when things go wrong. Two, it gives us a deployment tool in the form of the
`aws cloudformation package` and `aws cloudformation deploy` commands. We'll use this,
at least at first, as our way of pushing our code into AWS from the development machine.

We're going to use SAM in this post to create an Lambda function and an API Gateway to expose it
to a web browser. If you're not familiar, AWS Lambda allows you to create small bundles of code,
called "functions", which can be run in a low-latency, highly scalable fashion. Ours will be
configured to run code written for Python 3.6, letting us tap into a fairly rich
standard library before we're ready to worry about bundling third-party dependencies.
API Gateway allows you to define routes on an HTTPS endpoint which can do many different things -
proxy to another server, execute AWS API commands, transform requests, and, most importantly,
execute Lambda functions. This will eventually become the backend of our video streaming site,
handling requests for dynamic content without needing to maintain servers.

To start, I'm creating a new directory for this project and making a file called `template.yaml`.
This will be the file that describes our infrastructure. To start, we're going to make a very
simple template. It puts a single Lambda function at the root path of an API, and only responds to
HTTP GET requests. An "output" variable is used to resolve the resource attributes down into
an HTTPS URL using a CloudFormation "intrinsic function" which behaves similarly to Python's
`str.join`. That part is a little weird at first, but it's useful for extracting information
from your CloudFormation stacks.

```
AWSTemplateFormatVersion : '2010-09-09'
Transform: AWS::Serverless-2016-10-31
Resources:
  BackendLambdaFunction:
    Type: AWS::Serverless::Function
    Properties:
      Runtime: python3.6
      CodeUri: ./backend_lambda
      Handler: backend_lambda.handler
      Events:
        GetEvent:
          Type: Api
          Properties:
            Path: /
            Method: GET
Outputs:
  ApiUrl:
    Value: !Join
      - ''
      - - https://
        - !Ref ServerlessRestApi
        - '.execute-api.'
        - !Ref 'AWS::Region'
        - '.amazonaws.com/'
        - !Ref ServerlessRestApiProdStage
```

And we'll also create a directory to house our first Lambda function, `backend_lambda`.
A file inside that directory named `backend_lambda.py` contains a simple "Hello world!"-style
message in the appropriate data structure for API Gateway. We'll talk more about that later,
but you can take a peek now if you'd like:

```
def handler(event, context):
    return {'statusCode': 200, 'body': 'It works!'}
```

Now, let's deploy this template. First, we're going to make a deployment S3 bucket
using the AWS CLI. If you're not familiar with S3, it's an object storage service - we can put
files in and read them back out, sort of like a very stripped down filesystem.
Whenever we need to push files to AWS as part of our deployment process, they'll be uploaded here
first. We're also going to put a "lifecycle rule" on this bucket, which will delete old deployment
artifacts after a set time period. I'm putting this script into the git repo as
`create-deployment-bucket.sh`, but here's the commands it executes:

```
$ ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
$ REGION=$(aws configure get default.region)
$ DEPLOY_BUCKET=sam-deployment-$ACCOUNT_ID-$REGION
$ BUCKET_ARGS=$(if [ "$REGION" != "us-east-1" ]; then echo "--create-bucket-configuration LocationConstraint=$REGION"; fi)
$ aws s3api create-bucket --bucket $DEPLOY_BUCKET $BUCKET_ARGS
{
    "Location": "http://sam-deployment-123412341234-us-west-2.s3.amazonaws.com/"
}
$ aws s3api put-bucket-lifecycle-configuration --bucket $DEPLOY_BUCKET --lifecycle-configuration '{"Rules": [{"Expiration": {"Days": 3}, "Status": "Enabled", "Filter": {"Prefix": ""}}]}'
```

So, we first queried for our account ID and region so that we could name our bucket uniquely.
To retrieve the account ID, we used the
[powerful `--query` argument](http://docs.aws.amazon.com/cli/latest/userguide/controlling-output.html#controlling-output-filter)
to retrieve only the field we need. S3 buckets share a global namespace, so names have to
be unique across all regions and customers. By using those two elements as part of the bucket
name, we have reasonable confidence that nobody else will be using that bucket name. Additionally,
we have to specify the region we want the bucket's data to reside in using the unwieldy
`--create-bucket-configuration` flag. If we're in `us-east-1`, though, the location is implicit
and passing that flag would cause an error; so, we do a little bit of conditional logic to create
the needed argument. The last part is a again a bit complicated, but essentially we've told S3
to delete our deployment artifacts 3 days after they're uploaded. This gives us sufficient time
to deploy and potentially do some manual inspection if things go wrong, but we won't grow our
S3 usage (and spending) unbounded.

With a deployment bucket in hand, we can move on to pushing our app to AWS. First, we'll use the
`aws cloudformation package` command, which parses our template and pushes any local artifacts
into S3. First, we'll run the command alone to get an idea of how it mutates our template:

```
$ aws cloudformation package --template-file template.yaml --s3-bucket $DEPLOY_BUCKET
...
  BackendLambdaFunction:
    Properties:
      CodeUri: s3://sam-deployment-123412341234-us-west-2/349dd65b31f324f9cf53439e8ca58a9a
      Handler: backend_lambda.handler
      Runtime: python3.6
      Events:
        GetEvent:
          Properties:
            Method: get
            Path: /
          Type: Api
    Type: AWS::Serverless::Function
...
```

So, beyond shuffling the items around a bit, the `package` command has replaced the `CodeUri`
we specified in `template.yaml`. It's now a reference to an object in S3, which the AWS CLI
has created and uploaded for us. You don't need to follow along for this next command, but
if we were to take a look at that object, we can see that it's a ZIP file containing the
contents of the `backend_lambda` directory:

```
$ aws s3 cp s3://sam-deployment-123412341234-us-west-2/349dd65b31f324f9cf53439e8ca58a9a temp.zip
download: s3://sam-deployment-123412341234-us-west-2/349dd65b31f324f9cf53439e8ca58a9a to ./temp.zip
$ unzip -l temp.zip
Archive:  temp.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
       83  2017-07-15 19:30   backend_lambda.py
---------                     -------
       83                     1 file
$ rm temp.zip
```

Next is the actual deployment of our infrastructure, using `aws cloudformation deploy`.
We need to give this command the output of the `package` command as its template file, so
we'll write it to a temporary file for now - I'm calling it `template-packaged.yaml`, and I've
added it to my `.gitignore` so that it doesn't get pulled into source control. We also have to
name the CloudFormation stack at this point, so we'll call it `awstube`. There's another flag
we have to pass, `--capabilities`, which allows CloudFormation to create IAM resources on our
behalf. I'll explain a little bit about that role after our first deployment is done.
role in the background. This role dictates the permissions which our Lambda function will execute
with, so it's pretty important! If you're not keen on copying and pasting, this set of commands
is available in the repository as the script `deploy-template.sh`.

```
$ aws cloudformation package --template-file template.yaml --s3-bucket $DEPLOY_BUCKET > template-packaged.yaml
$ aws cloudformation deploy --template-file template-packaged.yaml --stack-name awstube --capabilities CAPABILITY_IAM
Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - awstube
```

After a little bit of waiting, you'll be told that your stack creation is complete. We can now
take a look at the resources that were created with another AWS CLI command:

```
$ aws cloudformation describe-resources --stack-name awstube
```

Huh? Our stack has a lot more stuff in it than we defined! Basically, SAM is a _transformation_
on top of CloudFormation, which means that we were saved the effort of writing out all of those
resources in our template. This includes an IAM role, which dictates the permissions our Lambda
function is granted, and various pieces of API Gateway configuration. Eventually, we'll probably
end up defining these more explicitly when we run into limitations of SAM, but it's a good way to
start.

Our deployment is now complete! Since I'm sure you're dying to see the fruits of our labor, let's
get the API URL from the CloudFormation API. You might remember that our template defined a
funky-looking "Output", where we joined together a bunch of strings. We can now retrieve that
variable with all of the references resolved, making a working URL. I'm going to use a `--query`
again for this, but feel free to remove that from the command to see what information AWS has
about your CloudFormation stack.

```
$ aws cloudformation describe-stacks --stack-name awstube --query 'Stacks[0].Outputs[?OutputKey==`ApiUrl`] | [0].OutputValue' --output text
https://a5b4c3d2e1.execute-api.us-west-2.amazonaws.com/Prod
$ curl https://a5b4c3d2e1.execute-api.us-west-2.amazonaws.com/Prod
It works!
```

You can, of course, open that URL in a web browser too - it's just some plain text, not even HTML,
but it's the first step into the serverless world. If you'd like to play with the code as it stands,
the Git repository [has been tagged `chapter2`](https://github.com/schlarpc/awstube/releases/tag/chapter2)
at the current state of the project. In the next post, we'll set up the static part of our site -
the HTML frontend which we'll build our user-facing features in. Note that I'm not a frontend
developer, so you shouldn't expect much in the way of design or best practices in that space. We're
shooting for functionality and reliability here, not aesthetics. &#x1f609;

[Continue to chapter 3 &#xbb;](/posts/serverless-from-scratch-3/)
