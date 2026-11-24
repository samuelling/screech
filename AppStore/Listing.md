# Screech: App Store listing (1.0)

Everything that goes into App Store Connect for version 1.0, in one place.

## Identity

| | |
|---|---|
| **Name** | Screech: Secret Notes |
| **Subtitle** (30) | Encrypted notes sent as sound |
| **Bundle ID** | com.samuelling.screech |
| **Primary category** | Utilities |
| **Secondary category** | Entertainment |
| **Price** | Free |
| **Copyright** | 2026 Samuel Ling |
| **Privacy policy** | https://linglab.org/screech/privacy.html |
| **Support URL** | https://linglab.org/screech/support.html |
| **Marketing URL** | https://linglab.org/screech/ |

## Promotional text (170)

Type a note and your iPhone screeches it like a dial-up modem. The phone beside it listens and decodes. With a shared passphrase, nobody else can read it.

## Description

Screech passes notes between devices as sound.

Type a note and tap SEND. Your iPhone plays it as a burst of modem tones. Another phone listening nearby hears the tones through its microphone and turns them back into your note. No Wi-Fi, no Bluetooth, no cell signal, no account, no server. Just a speaker, a microphone and the air in between.

SECRET BY PASSPHRASE
Agree on a passphrase in person and type it into both phones. Screech encrypts the note with AES-256 before it ever becomes sound, using a key made from your passphrase. Anyone can record the screech, but without the passphrase it is only noise, and a note that has been tampered with will not open. Leave the passphrase empty and you send an open note that any Screech can read.

PHOTOS, THE OLD WAY
Send a tiny photo, 64 to 128 pixels across, and watch it paint in from the top on the other phone, one stripe at a time, the way pictures loaded on a 1990s modem. It takes from half a minute to a few minutes. With a passphrase, every stripe is encrypted.

THREE SPEEDS
• Sturdy: slow chiming tones that get through in a noisy room.
• Quick: twice as fast, for quieter places.
• Classic: the real 300-baud modem screech.
The receiver listens for all three at once. An optional fake dial-up handshake plays first, for the full effect.

BUILT LIKE A REAL MODEM
Error correction repairs a note even if someone coughs in the middle of it. A live line monitor shows the tones as they arrive, and four front-panel lights (MR, CD, RD, SD) do what they did on the modems of old.

NOTES AS SOUND FILES
Save any note or photo as a sound file and send it however you like. The other person opens it in Screech to decode it.

FOR FRIENDS WITHOUT AN IPHONE
Screech also runs free in any browser at linglab.org/screech. The app and the web version speak the same protocol and understand each other.

PRIVATE BY DESIGN
Screech collects nothing. The microphone is used only while you are listening, and audio is never recorded or saved. Received notes disappear when you close the app. Your passphrase never leaves your phone.

Works best with the two devices a few inches to a couple of feet apart.

## Keywords (100)

modem,dial-up,encrypted,secret,message,sound,audio,retro,passphrase,offline,cipher,spy,acoustic,data

## What's New

First release.

## Screenshots (6.9", 1320×2868)

Made by `.github/workflows/screenshots.yml` (raw captures) and `AppStore/frame.py` (captions).

1. `1-send`: Type a note. Send it as sound.
2. `2-listen`: The other phone hears it and decodes it.
3. `3-photo-send`: Photos travel too, slowly.
4. `4-photo-receive`: They paint in from the top, like 1996.
5. `5-locked`: Without the passphrase, it's just noise.
6. `6-help`: Real encryption. No internet. No account.

## App privacy

**Data Not Collected.** The app makes no network connections. Microphone audio is analysed on the device and discarded; nothing is recorded. (`Screech/PrivacyInfo.xcprivacy` declares the same.)

## Export compliance

`ITSAppUsesNonExemptEncryption = NO` in `Screech-Info.plist`. Screech encrypts with AES-256-GCM (CryptoKit) and derives keys with PBKDF2 (CommonCrypto): standard algorithms, used only through the encryption built into iOS. No proprietary or self-implemented cryptography. In App Store Connect's wording: "None of the algorithms mentioned above."

## Age rating

No objectionable content of any kind. No web access, no purchases, no advertising, no accounts. Notes go only to a device within earshot.

## Review notes

Screech sends short notes and tiny photos between devices as sound. It needs no account and no network.

To try it with ONE iPhone and a computer:
1. On a Mac or PC, open https://linglab.org/screech/ (the free web version; same protocol).
2. On the iPhone, open Screech, go to LISTEN and tap LISTEN (allow the microphone).
3. On the computer, type a note and press SEND with the volume up, holding the iPhone near the speakers. The note appears on the iPhone under RECEIVED. It also works the other way round.
4. To see encryption: type the same passphrase (for example "test123") into KEY> on both, and send again. The note arrives marked "✓ SECRET". Change the passphrase on the iPhone and it shows "✗ WRONG PASSPHRASE".

To try it with one iPhone and nothing else:
1. SEND tab: type a note, tap SAVE AS SOUND, then "Save to Files".
2. LISTEN tab: tap DECODE A SOUND FILE and choose that file. The note appears under RECEIVED.

Microphone: used only while LISTEN is on, to hear incoming tones. Audio is processed in memory and never recorded, saved or transmitted.
Photo library: the system photo picker is used to choose a photo to send; "Save Image" in the share sheet saves a received photo only when the user chooses it.
Encryption: AES-256-GCM via Apple's CryptoKit, key from PBKDF2 via CommonCrypto. Standard algorithms from the OS only.
