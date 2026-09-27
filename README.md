# EOBOTER for iPhone

Local-first SwiftUI project that hosts the official EO web experience in `WKWebView` and keeps the bot components on the iPhone.

## Architecture

`EO WKWebView -> visible market snapshot -> NVIDIA NIM analysis -> Risk Manager -> UP / DOWN / SKIP -> ExecutionGateway`

## Included
- SwiftUI iOS shell and tabs
- Persistent WebKit website data store for the user's normal EO web session
- EO bridge for reading visible on-page market state
- NVIDIA NIM chat-completions client
- NVIDIA API key stored in iOS Keychain
- Risk gate and bounded decisions
- Bot status/settings/log screens
- Execution gateway abstraction
- XcodeGen `project.yml`
- Fork/setup guide

## Important current state
Automatic EO order execution is disabled by default. The real on-device EO page structure must be validated on an iPhone before wiring any UI execution. No private EO protocol or reverse-engineered API is included.

## Secrets
Never commit NVIDIA keys, EO credentials, cookies, session exports, signing keys, or provisioning secrets. The app stores the NVIDIA API key in Keychain.

## Build later
No build has been performed as part of repository preparation. See `FORK_SETUP.md` after forking.

The earlier Python prototype remains in Git history; the iOS app is the active direction.
