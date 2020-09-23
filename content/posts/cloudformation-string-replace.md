+++
date = "2020-09-23T12:00:00-00:00"
draft = false
title = "Stupid CloudFormation Tricks #1: String replacement and changing case"
+++

_(Note: I work for AWS, but this article is my own opinion as an avid CloudFormation user.
I don't work on the CloudFormation team, and I have no insight into their roadmap or operations.)_

A commonly supported operation in general-purpose programming languages is "string replacement",
in which all occurrences of a given substring are replaced with another.
For example, string replacement in Python looks like this:

```
>>> 'tart'.replace('t', 'b')
'barb'
```

String replacement without macros
---------------------------------

CloudFormation isn't a general-purpose programming language and doesn't offer this functionality,
even though we might want it on occasion. One situation where it could be useful is when a
resource property has restrictions on its input, like only allowing alphanumeric characters.
If we try to pass a string like `"hello-world"` into that property, our template would be invalid
and fail to create the resource.

The
[CloudFormation docs](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-macros.html)
encourage using the "macros" feature to
[implement this functionality](https://github.com/awslabs/aws-cloudformation-templates/blob/f29315e9d7752e5be0994616f83490596bea0c82/aws/services/CloudFormation/MacrosExamples/StringFunctions/string.yaml#L46),
but macros have several drawbacks that make them undesirable for simple uses like string manipulation:
* Macros can't be defined in the same template that they're consumed in, complicating deployments
* Macros can't have dynamic names, potentially leading to name collisions of incompatible macro implementations
* Macros execute arbitrary code in your account, impeding static analysis of templates and introducing additional failure points

Luckily, we can create this functionality in native CloudFormation by combining two different
built-in features: `Fn::Split` and `Fn::Join`. These two "intrinsic functions" allow us to _split_
a string into a list of strings using a given delimiter, and then _join_ a list of strings into a
single string using another given delimiter. To call back to our earlier examples, this will
evaluate to `"barb"` in CloudFormation:

```
{
    "Fn::Join": [
        "t",
        {
            "Fn::Split": [
                "b",
                "barb"
            ]
        }
    ]
}
```

And this will remove that pesky hyphen, yielding `"helloworld"`:

```
{
    "Fn::Join": [
        "",
        {
            "Fn::Split": [
                "-",
                "hello-world"
            ]
        }
    ]
}
```

Case conversion with nested replacements
----------------------------------------

You can also nest `Fn::Split` and `Fn::Join` pairs repeatedly to replace multiple substrings
within the same input. For example, you can change uppercase to lowercase with _only_ 52 nested
functions, although I'd suggest using a template synthesis library like
[troposphere](https://github.com/cloudtools/troposphere) so that you can do this in a `for` loop
instead of by hand:

```
{
    "Fn::Join": [
        "a",
        {
            "Fn::Split": [
                "A",
                {
                    "Fn::Join": [
                        "b",
                        {
                            "Fn::Split": [
                                "B",
                                {
                                    "Fn::Join": [
                                        "c",
                                        {
                                            "Fn::Split": [
                                                "C",
                                                ...
                                            ]
                                        }
                                    ]
                                }
                            ]
                        }
                    ]
                }
            ]
        }
    ]
}
```

This looks absurd when rendered out all the way, but it can genuinely be useful.
`AWS::S3::Bucket` dictates that `BucketName` must "contain only lowercase letters, numbers,
periods (.), and dashes (-)", and there's similar restrictions on other resource properties
throughout CloudFormation. These techniques can hopefully help you meet those requirements when
dealing with dynamic input - without needing to break out the Lambda escape hatch.
