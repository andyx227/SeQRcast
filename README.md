# SeQRcast Documentation

## Making QR codes more secure.

Team Ground Zero: Tony Woo, Andy Xue, Noshin Kamal, Manpreet Kang

### High-level Overview of the Application

Our iOS application provides security to QR codes by using modern encryption
standards. This allows users to share data securely via QR codes, which
traditional QR code generators do not provide out of the box. By doing so, users
can confidently share their private QR codes even in a public space; for
example, a user may publish a QR code for a private event that only certain
people may scan and retrieve the admission ticket. The owner of the QR code may
safely post this QR code in a public bulletin board (or some other public space)
and can rest assured that the confidentiality and integrity of the QR code will
be preserved.

### Basic Structure of the Application

Our application consists of four different screen. Upon opening the app, the
user will immediately see the main screen that displays the camera output. Via
this screen, user may begin scanning QR codes. (Note — for now, our
application can only recognize three different types of QR codes: URL, text, and
SeQRcast-generated QR codes).

To access the other three screens from the main screen, user may

1. **Swipe right**: this shows the "channel(s)" the user has subscribed to (more
to come about channels later).
    
    - In this view, user may view past messages that the channel has published,
and they can also unsubscribe from the said channel.

2. **Swipe left**: this shows the channels the user owns.
    
    - As the owner of a channel, user may publish their own messages, view
previously published messages, and share the channel with another SeQRcast
user.

3. **Swipe down**: this displays the QR code of the user's public key.

### Encryption Tools

We are using two types of encryption tools in our app:

1. RSA (2048 bits) public and private key pairs
2. AES-256-CBC for symmetric key encryption/decryption.

The libraries we are using for RSA is called `SwiftyRSA` and for AES we are
using `CryptoSwift`.

#### Using the RSA Public/Private Key Pairs

The unique RSA public and private keys pairs are generated and stored on the
user's phone. `Storage.swift` contains all the methods used to get/set the
user's public and private key. It also contains all the channel(s) the user is
subscribed to and owns. 

This key pair is used to securely send a channel's shared secret to a subscriber
of the channel. We first encrypt the shared secret with a (soon-to-be)
subscriber's public key, which will generate an encrypted QR code that the
subscriber can then scan with their phone and decrypt with their private key.
The decrypted content will be the channel's shared secret.

Additionally, this key pair is used to verify digital signatures when scanning a
QR code containing an encrpyted message. As usual, we sign the message with the
message publisher's (i.e. the owner of the channel that published the message)
private key, and verify the signature using their public key.

#### Using the AES-256-CBC Encryption

This is where the shared secret comes in. Every message is encrypted and
decrypted with the shared secret using AES-256, CBC mode. The shared secret is a
randomly generated string of 32 bytes. When we encrypt/decrypt the message, we
are specifically encrypting/decrypting the date and content of the message. 

While we understand that the initialization vector for AES should be unique and
random for every time we run the encryption method, for simplicity, we have
decided to hard code the IV for now. In production, we will ensure that the IV
is randomly generated. 

### Data Models

We have split up the logical components of our app in four ways:

- QR-Code (`QRCode.swift`)

- Channel (`Channel.swift`)

- Message (`Message.swift`)

- Database (`Database.swift`)

These data models are stored inside a folder in our project called "Model."

#### QR-Code Model

We are using native iOS support for scanning and generating QR codes. 

Our app generates app-specific QR codes that are used to subscribe to channels,
read secure messages, and display public keys. In order to differentiate between
these types of SeQRcast-generated QR codes, we make use of an eight-byte header
that we prepend to the QR content. Below are the different types of headers we
use and for what purpose we use them (these headers are defined in
`QRCode.swift`):

- `QR_TYPE_CHANNEL_SHARE`: QR codes that are used to share encrypted channel
data will contain this header. This header is needed for the channel
subscription process.

- `QR_TYPE_MESSAGE`: QR codes that contain an encrypted message will have this
header.

- `QR_TYPE_PUBLIC_KEY`: QR codes that contain a user's public key will have this
header.


#### Channel Model

In an earlier section, we have mentioned "channels." In our app, each QR code
lives in a logical container which we call a "channel." A channel may contain
one or more encrypted QR codes that only subscribers to that channel may
decrypt. Users outside this channel will not be able to access the secure
content of the QR code.

Each channel contains the following information:

- `name` of the channel, given by the user

- `id` of the channel (a unique identifier)

- `key` of the channel, used to encrypt/decrypt the channel's QR codes (shared
secret)

- `publicKey` of the owner of the channel (for digital signature verification)

- `createDate` of the channel

##### Sharing a Channel

To share a channel, the channel owner scans the public key of the soon-to-be
subscriber. Then, our `encrypt(with publicKey: String)` method (defined in a
subclass called `MyChannel`) will encrypt the **channel's shared secret**, id,
and name with the scanned public key. Afterwards, a QR code will be generated
that contains this encrypted data along with the QR code header
(`QR_TYPE_CHANNEL_SHARE` — see QR-Code Model) and the channel owner's public
key. The other person can then scan this QR code in the main screen with their
phone to extract the data from this QR code and decrypt the encrypted content
with their private key.

The `subscribe(with data: String)` function will take care of deconstructing the
`data` into the QR code header, channel owner's public key, and the encrypted
content. It will ultimately subscribe the user to the channel if decryption of
the encrypted content is successful. Subscribing to a channel implies that the
subscriber will have the shared secret that can be used to decrypt any messages
that the channel owner publishes in that channel.

Note that the shared secret is a 32-byte string that is randomly generated. The
channel id is generated the same way. We encapsulate the random-bytes generation
in a function called `getRandom32Bytes()`.

#### Message Model

This is where we handle encryption and decryption of messages. At the moment, we
can only handle QR codes that contain text and URLs, but we can easily extend
this to handle QR codes that contain other types of content as well, such as
contact info and location.

A message contains the following information:

- `type` of the message (either text or URL)

- `expirationDate` of the message (user will get a warning when trying to read
an expired message)

- `content` of the message

- `channel` in which the message is published (contains the shared secret for
encrypting/decrypting messages and the owner's public key, needed for digital
signature verification)

For encrypting messages, we call the `encryptedString()` function, which does
the following:

- Creates a digital signature from channel name, date, and message content. This
plain text will be hashed with **SHA256** first, and then it will be signed with
the channel owner's private key.

- Encrypts the `body` of the message, which contains the date and content of the
message, using the shared secret via **AES-256-CBC**.

- It will return the QR code header (`QR_TYPE_MESSAGE`), channel id, digital
signature, and the encrypted content as one string, which will then be passed
into `encrypt()`. This latter function will finally generate the secure QR code,
ready to be scanned and decrypted by the channel's subscriber(s).

As with subscribing to a channel, user will use the main screen to scan the QR
code containing the encrypted message. Only users that have the shared secret of
the channel that published the message can decrypt the QR code and see the
content. The function `decrypt(data: String)` will deconstruct the `data` into
the QR code header, channel id, digital signature, and the encrypted content; it
will then attempt to decrypt the encrypted content with the shared secret.
Additionally, the function will also verify the digital signature of the message
using the channel owner's public key to ensure that the integrity of the message
has been preserved. If all is successful, the decrypted message content will be
displayed.

##### Special Note for QR Codes Containing URLs

For detection of malicious URLs, we are using the **Google Safe Browsing API**,
which can detect threats such as malware, social engineering, and applications
that are potentially harmful. If the API raises a red flag, our application will
still allow the user to access the website (in case it is a false positive), but
will warn the user that the site is potentially malicious and should proceed
with caution.

We understand that the API is not foolproof so it will at times give false
positive and false negatives, but we are *assuming*, given the mass amount of
data Google collects, that their API will return reliable results.

#### Database Model

We are using SQLite for our database model in our app. Please note that we do
not use a server, so the database lives within each user's phone. Every time a
channel owner publishes a message, that message will be stored in the database
(local to their own phone). Similarly, any subscriber who successfully scans a
QR code containing an encrypted message will have that QR code stored in the
database, also local to their phone.

The database contains the following information:

- Channel ID

- Message Type (either text or URL)

- Expiration Date

- Message Generation Date

- Message Content

- Latitude (for saving the location where user scanned the QR code)

- Longitude (for saving the location where user scanned the QR code)

- Encoded Message Content (for generating encrypted message QR code)

Saving the latitude and longitude information implies that the user can see on
their map where they scanned that QR code, given that our app has permission
from the user to view their location.
