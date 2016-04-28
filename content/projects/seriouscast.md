+++
date = "2014-01-01T00:00:00-00:00"
draft = false
title = "SeriousCast"
+++

_(Note: SeriousCast was broken by a SiriusXM backend update in November 2015. It has not been
updated to work with the new backend.)_

SeriousCast is a client for SiriusXM Internet Radio which
rebroadcasts the radio streams through the SHOUTcast protocol. It contains
a working implementation of the authentication and encryption protocols
used by the SiriusXM web player with the aim of providing interoperability
with standard internet radio streaming clients. SeriousCast does <em>not</em>
bypass SiriusXM's login protocols, so you will need valid credentials to use
this application.

SeriousCast exposes a web interface which allows you to browse all channels
available on SiriusXM, stream in the browser using the VLC browser plugin,
and download PLS files to load into any internet radio client that supports
SHOUTcast. It also allows the user to "time-shift" a few hours back into
the channel's history, as seen in the official SiriusXM web client.

<aside>
    <img src="/images/seriouscast.png" alt="Screenshot" width="529" height="375" />
</aside>

[SeriousCast on GitHub](https://github.com/schlarpc/SeriousCast)
