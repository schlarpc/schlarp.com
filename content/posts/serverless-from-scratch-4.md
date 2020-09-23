+++
date = "2017-07-16T14:00:00-00:00"
draft = true
title = "Serverless from Scratch #3"
+++

Chapter 4: Log, from Blammo
---------------------------

Now that we've got a few different public facing resources kicking around, let's circle back
and make sure we're doing things in an operationally sound way. In this entry, we're going to
make sure we've got logs of everything that happens within our account. Specifically,
I'm referring to CloudTrail logs, S3 bucket access logs, API Gateway access logs,
CloudFront access logs, and AWS Lambda execution logs. Whew, that's a lot of different things
already! Let's go through these one by one and we'll get it all straightened out.

CloudTrail is a service which records actions taken within your AWS account. It's
primarily concerned with "management events", which you might also know as "control plane" events.
These are actions that _act on_ the resources within an AWS account. For example, creating or
deleting an S3 bucket would qualify as a management event. This is in contrast to "data events",
which deal with object-level data access. While many services have data events, only one specific
type is able to be captured by CloudTrail: read and write actions against S3 objects. Using this
configuration adds a small extra cost over the S3 service's bucket logging mechanisms,
but we're going to use it anyway. I'll cover the configuration for the other type of S3 bucket
logging later for the price sensitive, but it won't be how our service operates.
