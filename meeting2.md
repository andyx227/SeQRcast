# Ground Zero — Week Two Meeting

**Trello Link:** https://trello.com/b/dxiFYIrj

## What We Did Last Week

We ironed out the app architecture, making sure that it can handle encryption/decryption of QR codes and use digitial signatures to verify the integrity of the messages. 

Additionally, we added the ability to generate plain QR codes (i.e. no encryption yet) as the next step of our project, as well as writing some UI/UX related code. For the cryptography part of the app, we will decided to use the library `CryptoSwift` as it seems easy to use and has a big community behind the project, along with the native crypto support from Swift.

## What We Plan To Do This Week

We will begin to encrypt, decrypt, and add digital signatures to QR codes by applying the architecture we have developed. We will also continue to work on the UI/UX, particularly ensuring that the screen transitions are working as we intend.

## What Issues We Are Having

As QR codes can only hold so much data (for example, a 101x101 QR code with a high correction level can hold 406 bytes of data), we need to pick out an encryption method that can provide strong security while still leaving out enough space to store the actual data (e.g. a url link).

## Commits To GitHub

- [Implemented signing/verifying digital signatures](https://github.com/andyx227/QRGuard/commit/490ea6e9375a7afc81f035b2fcd18c0cb6a105a3?diff=unified) (Noshin Kamal)
- [Added ability to detect swipe actions for screen transitions](https://github.com/andyx227/QRGuard/commit/3a1983d342569683d5d2a5d929b1cf372f497718) (Manpreet Kang)
- [Generating QR codes](https://github.com/andyx227/QRGuard/commit/eab4f00256f107a719fb36bb24e92746e8ef3045#diff-af94153025f93b83d9f91800846e5252) (Andy Xue)
- [Implemented asymmetric encryption of shared secret](https://github.com/andyx227/QRGuard/commit/2cebbbeec9deb20e895aa9d67e5963c6e4d94850) (Tony Woo)
- [Implemented encryption of messages](https://github.com/andyx227/QRGuard/commit/3fa1618167b6afc91b37144f43be3662806c1b32) (Tony Woo)
