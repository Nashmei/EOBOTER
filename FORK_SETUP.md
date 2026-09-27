# Fork setup

EOBOTER is prepared as a local-first iOS project. No build has been performed.

## After forking
1. Clone your fork on a Mac with Xcode.
2. Install XcodeGen.
3. Run `xcodegen generate`.
4. Open `EOBOTER.xcodeproj`.
5. Change the bundle identifier/team for your Apple Developer account.
6. Run on a physical iPhone.
7. Open the EO tab and sign in through the official web page yourself.
8. In Settings, paste your NVIDIA API key. It is saved only in iOS Keychain.

## Never commit
- NVIDIA API keys
- EO credentials
- cookies/session exports
- provisioning profiles/private signing keys

## First on-device validation
Validate EO page loading and visible market-state extraction before enabling any automated UI action. Automatic order execution is disabled by default.
