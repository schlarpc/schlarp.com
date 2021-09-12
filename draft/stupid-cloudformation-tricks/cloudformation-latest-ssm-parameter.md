# Stupid CloudFormation Tricks: Referencing the latest revision of SSM parameters

    I work for AWS, but this article is my own opinion as an avid CloudFormation user.
    I don't work on the CloudFormation team, and I have no insight into their roadmap or operations.

[SSM Parameter Store](https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html)
is an excellent tool in the AWS suite; if you're not familiar with it,
you can think of it as a low-throughput versioned key-value store intended for configuration
data. It's frequently used to store per-environment data, and can be consumed within
CloudFormation with two separate features:
[dynamic references](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/dynamic-references.html#dynamic-references-ssm-secure-strings)
and
[SSM template parameter types](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/parameters-section-structure.html#aws-ssm-parameter-types).

You may have noticed that there's a name collision between two related concepts here, so I'm
going to specifically disambiguate them here:
* "SSM parameters" are a resource in the SSM Parameter Store service.
* "Template parameters" are an element of a CloudFormation template that allows for user input
  before stack creation.
* "SSM template parameters" are a specific type of template parameters, where the user provides
  an SSM parameter name (the "key" in the key-value store). CloudFormation retrieves the
  referenced SSM parameter's value as the effective value for the template parameter during
  stack creation.

## Dynamic references

On first glance, dynamic references seem really compelling for complex deployments. They allow
you to retrieve configuration data on a per-account-per-region basis, and incorporate it into your
infrastructure deployments. Unlike another CloudFormation feature, `Fn::ImportValue`, the
configuration data can come from sources besides another CloudFormation stack: it could be
provisioned as part of account creation, pushed by an engineer using the AWS CLI, or provided
by AWS as a
[public parameter](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters.html).

However, dynamic references have a massive drawback that makes them inappropriate for many uses:
the SSM parameter version must be explicitly specified as an integer. This makes it impossible to
use dynamic references to retrieve the most recent configuration stored in an SSM parameter.
This restriction makes dynamic references mostly useless from my perspective, as versions may not
be in sync across environments nor is real dynamic configuration possible.

## SSM template parameter types



## The best of both worlds with nested stacks

- nested stacks
  - always update
