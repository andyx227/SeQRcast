# Ground Zero — Week One Meeting

**Trello Link:** https://trello.com/b/dxiFYIrj

## What We Did Last Week

We came up with project ideas. Our original project idea was to provide a
defense against Android OS stack canary vulnerability, but the project scope was
too big. We have since decided to provide defense against vulnerabilities in QR
codes.

## What We Plan To Do This Week

For the first week, we have implemented basic features to our QR code
application (iOS). In particular, our app is capable of scanning QR codes
containing a URL, and by using the Google Safe Browsing API, our app can detect
and alert the user whether that URL is malicious.

Additionally, we want to provide the ability to encrypt QR codes so that any
user can add confidentiality to a message they want to send to another user. A
use case for this could be transferring money via QR codes, which may contain
critical bank information that should be kept secret.

## What Issues We Are Having

We need to come up with an architecture that can support encrypting/decrypting
messages and also to verify the integrity of the message. We also need to figure
out how to allow users to share encrypted QR codes to multiple users.

## Commits To GitHub

- [Adding capability to scan QR codes](https://github.com/andyx227/QRGuard/commit/7a8fbb139b6db9176ccbf88a4a9ec99b17fdda98#diff-deb6eb84778ba1a4a836b436063c5f86) (Andy Xue)
- [Implementing Google Safe Browsing API](https://github.com/andyx227/QRGuard/commit/d98ae82e79efaf48c978f34df735d0684e46a76e#diff-deb6eb84778ba1a4a836b436063c5f86) (Andy Xue)