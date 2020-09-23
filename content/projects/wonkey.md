+++
date = "2016-06-26T00:00:00-00:00"
draft = false
title = "Wonkey"
+++

`wonkey` is a Python web service for image sharing with encryption at rest. I built it for use with
[ShareX](https://github.com/ShareX/ShareX), a very nice open source screenshot capture tool.
It uses the Fernet cryptosystem from the [cryptography](https://github.com/pyca/cryptography)
library to encrypt and decrypt stored data on the fly from a per-file key encoded in
each file's URL.

Check out [wonkey on GitHub](https://github.com/schlarpc/wonkey).

Here's an example of a file hosted on my personal installation of wonkey:

<aside>
    <a href="https://my.snuff.porn/Vj6wdv6xhwSeud4BK0ONmug2ZfB58nYPRyi1TjziGWM.gPMudn2mRW2KK-RgtSk6ng.jpg">
        <img src="https://my.snuff.porn/Vj6wdv6xhwSeud4BK0ONmug2ZfB58nYPRyi1TjziGWM.gPMudn2mRW2KK-RgtSk6ng.jpg" alt="Sample image" width="512" height="512" />
    </a>
</aside>

