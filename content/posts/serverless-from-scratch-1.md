+++
date = "2017-07-16T12:00:00-00:00"
draft = true
title = "Serverless from Scratch #1"
+++

Chapter 1: Introduction
-----------------------

This blog series is a walkthrough of the incremental development process of a serverless
application developed specifically for Amazon Web Services. I'm going to build a YouTube-like
site with the goal of having to maintain zero servers. The idea is to go from an empty directory
to a full-blown scalable serverless service, with all the bells and whistles like monitoring
and continuous deployment. The entire project will be documented both as a series of blog posts
and as [a Git repository](https://github.com/schlarpc/awstube), so you can follow along through
the development process. As a rule, this series will attempt to explain concepts as to the reader
as though they have little to no knowledge about AWS services. This will allow us to introduce a
wide range of services while explaining best practices to the reader as we develop the app.
We'll also be using the
[AWS Serverless Application Model](https://github.com/awslabs/serverless-application-model),
which helps us to easily deploy while using the latest AWS features.

To give you an idea of my experience level with AWS services and the perspective from which I'll
be building this application: I've been working at Amazon in the AWS Security organization for
about two and a half years, and have built several services that leverage AWS for different
purposes. My team has been an early adopter of the serverless trend - according to Git commits,
I committed our first serverless deployment framework just 2 months after the public release of
AWS Lambda. Of course, as a security engineer by title, this project will have a heavy
slant towards security best practices. There will likely be times when I spend what seems like
inordinate amounts of effort on making something slightly more secure, but that's just how I
like to design my systems.

Before getting started, I've made an AWS account just for this application.
Separating each service you operate into its own AWS account reduces the blast
radius should anything go wrong, either during deployments or during operation. I've used
[AWS Organizations](https://aws.amazon.com/organizations/)
to quickly create a new account with consolidated billing to my primary account,
but someone new to AWS will want to just create an account using the standard sign up
process. You can start this process by going to [the AWS main page](https://aws.amazon.com/)
and clicking "Create an AWS Account" or "Sign Up". We're going to attempt to stay mostly within the
free tier for a while, so your total bill should stay very close to zero. If and when we start
using services and features with no free tier, I'll make sure to leave a warning.

<aside>
    <img src="/images/serverless/01-01.png" alt="AWS main page" />
    <em>The AWS main landing page</em>
</aside>

Once you've created an account, you'll be presented with the AWS console. From the console, you have
access to a console for each service offered in AWS, and you can view and create resources from your
browser. In general, you should prefer to avoid the console for development tasks. It will seem
faster, but you lose reproducibility of your actions. Regardless, it can be invaluable
when getting started with AWS or evaluating a service to see if it meets your needs.

<aside>
    <img src="/images/serverless/01-02.png" alt="AWS console" />
    <em>The AWS console</em>
</aside>

Right now, what we want to use the console to do is create an "IAM user" so that our
development machine has access to this AWS account. IAM stands for "Identity and Access Management",
and it is the centralized authentication and permissions management system for AWS. IAM users are
entities within this system that have long-lived credentials. Type "IAM" into the search box and
click through to the IAM console.

<aside>
    <img src="/images/serverless/01-03.png" alt="IAM console" />
    <em>The IAM console</em>
</aside>

From here, we'll click "Users" on the left hand side of the screen to get to the Users page.
Click "Add user" to start the user creation wizard.

<aside>
    <img src="/images/serverless/01-04.png" alt="IAM console users page" />
    <em>The IAM console users page</em>
</aside>

The user creation wizard will ask for a user name, as well as the access type required.
The user name can be whatever you'd like, but I'm going to pick `awstube-deploy`. We're just
going to be using this user for development right now, so you should only choose
"Programmatic access" as your access type.

<aside>
    <img src="/images/serverless/01-05.png" alt="IAM user details" />
    <em>Configuring user details</em>
</aside>

On the next page, choose "Attach existing policies directly", then check the
`AdministratorAccess` managed policy. These are sets of permissions that are
curated and updated by Amazon to meet common business needs. In this case, we're not really
sure what needs we have yet, so we're going to attach a policy that gives access to everything.
In a later part of this series, we might revisit this choice while hardening our account
to give better security guarantees. Once you've selected the policy, click through
"Next: Review" and then "Create user" to finish.

<aside>
    <img src="/images/serverless/01-06.png" alt="IAM user permissions" />
    <em>Configuring user permissions</em>
</aside>

Our IAM user has been created! We're going to need the values on this page - the one starting with
AKIA and the one that's censored out by default. Leave this page open for now, we'll get to it real
soon.

<aside>
    <img src="/images/serverless/01-07.png" alt="IAM user credentials" />
    <em>Getting our IAM user credentials</em>
</aside>

Now that we've got some credentials, we need to set up the AWS command line client.
I'll defer to the AWS documentation on
[how to install it on your operating system](http://docs.aws.amazon.com/cli/latest/userguide/installing.html).
Note that this guide assumes the usage of `bash`, so a Unix-derived operating system is preferred.
Since I'm assuming a fresh install here, I'll be configuring our new IAM user as the default
credentials for the AWS CLI. If you're managing multiple AWS accounts, you'll likely want to
configure this part as a
[secondary profile in the configuration](http://docs.aws.amazon.com/cli/latest/userguide/cli-multiple-profiles.html).
I'm going to use the setup wizard for this part, by running `aws configure` in my terminal
and pasting in the values from our IAM user creation page:

```
$ aws configure
AWS Access Key ID [None]: AKIAFAKEFAKEFAKEFAKE
AWS Secret Access Key [None]: Ba5e64+Ba5e64+Ba5e64+Ba5e64+Ba5e64+Ba5e64
Default region name [None]: us-west-2
Default output format [None]:
```

Before we continue, a note about the confidentiality of various bits of data within AWS.
Your account ID and any access key IDs are not intended to be secret. I'm redacting
mine out of a sense of paranoia. Secret access keys, however, should _never_ be posted
publicly, including in a Git repository. If you accidentally leak a secret access key,
you should immediately rotate the credentials by creating a new key and disabling or revoking
the old one.

Additionally, you may have wondered where the choice of region (`us-west-2`) came from.
In AWS, regions are mostly siloed away from each other, with cross-region interaction being a very
intentional decision on the part of the AWS user. Most resource types exist in only one region,
so all of the resources for a service should be deployed into the same region.
I'm choosing the Oregon region, which is close to my geographic location and
[supports all of the services I care about](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/).
The [AWS Regions and Endpoints page](http://docs.aws.amazon.com/general/latest/gr/rande.html)
describes the mapping between each region's location (e.g. "US West (Oregon)") and its API name
(e.g. `us-west-2`). I generally recommend avoiding `us-east-1` if possible, as that
region is historically the least reliable of the USA regions. If you're paying close attention
at this point, you might object that we didn't choose a region when creating the IAM user earlier.
This is because IAM is a _regionless_ service, which means that changes are automatically propagated
through to every other AWS region.

At this point, our AWS CLI should be completely ready to go. To prove this, we'll run a
simple but invaluable command that tests our credentials and shows us our identity within
the AWS IAM system: `aws sts get-caller-identity`.

```
$ aws sts get-caller-identity
{
    "Account": "123412341234",
    "Arn": "arn:aws:iam::123412341234:user/awstube-deploy",
    "UserId": "AIDAFAKEFAKEFAKEFAKE"
}
```

In the next post, we'll actually deploy something to this AWS account using the AWS
Serverless Application Model. This will be something small that we'll build up into a real
application, piece-by-piece, with each blog post illustrating a new part of the process.

[Continue to chapter 2 &#xbb;](/posts/serverless-from-scratch-2/)
