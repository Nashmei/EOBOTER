# EOBOTER iOS

Local-first iPhone architecture.

## Components
- SwiftUI application shell
- WKWebView for the official EO website
- EOBridge for on-device visible market-state extraction
- NVIDIA NIM client for bounded analysis
- iOS Keychain for the NVIDIA API key
- RiskManager gate
- ExecutionGateway abstraction
- Local logs/UI

## Security
No NVIDIA key, EO credential, cookie, or session is stored in this repository. NVIDIA keys are stored in iOS Keychain.

## Current execution status
Automatic EO order execution is intentionally disabled until the EO page structure and permitted interaction path are verified on a real iPhone session. The architecture is ready for an execution gateway without coupling it to AI or risk logic.

## Generate Xcode project
Install XcodeGen on macOS, then run:

xcodegen generate
open EOBOTER.xcodeproj

The deployment target is iOS 17.
