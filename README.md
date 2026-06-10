# NativeAppTemplate-Free-iOS

NativeAppTemplate-Free-iOS is a modern, comprehensive, and production-ready native iOS app with user authentication and a full CRUD example.  
This iOS app is a free version of  [NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team).  

The Android version is available here: [NativeAppTemplate-Free-Android](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android).  

Want this template adapted to your own domain? [nativeapptemplate-agent](https://github.com/nativeapptemplate/nativeapptemplate-agent) is a Claude Code agent that turns a one-sentence spec (e.g. *"a walk-in queue for a barbershop"*) into a coherent three-platform app — this SwiftUI iOS app, a matching [Rails 8.1 API](https://github.com/nativeapptemplate/nativeapptemplateapi), and a [Jetpack Compose Android app](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android) — renamed and adapted for you, with validation built in.

## Overview

NativeAppTemplate-Free-iOS is configured to connect to `api.nativeapptemplate.com`.  
The Rails 8.1 API backend that powers `api.nativeapptemplate.com` is open source (MIT):

- [nativeapptemplateapi](https://github.com/nativeapptemplate/nativeapptemplateapi) &middot; [API Docs](https://nativeapptemplate.com/api-docs/index.html)

### Screenshots

![Screenshot showing Sign in screen, Shops screen and Settings screen](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/screenshots.png "Screenshot showing Sign in screen, Shops screen and Settings screen")

### Features

NativeAppTemplate-Free-iOS uses modern iOS development tools and practices, including:

- **100% Swift**
- **100% SwiftUI**
- **[@Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)** (iOS 17: streamlined Swift state management)
- **[SwiftLint](https://github.com/realm/SwiftLint)**
- **[Simple MVVM Layered Architecture](https://medium.com/@dadachix/key-differences-in-mvvm-architecture-ios-vs-android-e239d30b2ea7)**
- **Test** (Swift Testing)
- Inspired by [emitron-iOS](https://github.com/razeware/emitron-iOS)

#### Included Features

- Onboarding
- Sign Up / Sign In / Sign Out
- Email Confirmation
- Forgot Password
- CRUD Operations for Shops (Create/Read/Update/Delete)
- CRUD Operations for Shops' Nested Resource, Item Tags (Create/Read/Update/Delete)
- Force App Version Update
- Force Privacy Policy Version Update
- Force Terms of Use Version Update
- And more!

## NFC Tag Operations

NFC tag writing and background tag reading were part of v1 and have been removed from the current version. The full NFC implementation remains available in the [`v1-with-nfc`](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/tree/v1-with-nfc) branch.

## Not Included in the Free Version

![Gif showing Switching organization](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/organization.gif "Showing Switching organization")  

The full versions ([NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team)) include additional advanced features:

- URL Path-Based Multitenancy (prepends `/:account_id/` to URLs)
- User Invitation to Organizations
- Role-Based Permissions and Access Control
- Organization Switching UI
- Push Notifications via APNs

## Supported Devices

- **iPhone** — iOS 26.2+, Portrait mode, Full screen
- **iPad** — iOS 26.2+, Portrait mode, Full screen
- **Mac** — Designed for iPad

## Getting Started

To get started, clone this repository:

```bash
git clone https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS.git
```

## Requirements

To run this app successfully, ensure you have:

- An iOS device or emulator with iOS version 26.2 or higher

## Running with the NativeAppTemplate-API on localhost

To connect to a local API server, set these env vars on the Xcode scheme (Edit Scheme → Run → Arguments → Environment Variables):

```
NATIVEAPPTEMPLATE_API_SCHEME = http
NATIVEAPPTEMPLATE_API_DOMAIN = <your-lan-ip>
NATIVEAPPTEMPLATE_API_PORT   = 3000
```

> **Note:** Never use `127.0.0.1`, `localhost`, or `0.0.0.0` for `NATIVEAPPTEMPLATE_API_DOMAIN` — those resolve to the iOS Simulator/device itself, not your Mac. Use your Mac's LAN IP (e.g., `192.168.1.6`) so the simulator or a physical device can reach the API server.

The `NativeAppTemplate` scheme is **shared** (committed at `NativeAppTemplate.xcodeproj/xcshareddata/xcschemes/NativeAppTemplate.xcscheme`) so fresh clones and generated copies open with these env vars already wired — without it, Xcode's auto-created default omits the injection and Debug builds silently fall back to `https://api.nativeapptemplate.com`. The committed `NATIVEAPPTEMPLATE_API_DOMAIN` is just an example value (`192.168.1.21`); edit it to your own Mac's LAN IP.

Because the scheme is committed, keep your personal LAN IP out of git. After editing the value locally, tell git to ignore your changes to the file:

```bash
git update-index --skip-worktree NativeAppTemplate.xcodeproj/xcshareddata/xcschemes/NativeAppTemplate.xcscheme
```

To resume tracking it (e.g. before intentionally committing a scheme change), run `git update-index --no-skip-worktree <same path>`.

Debug builds read these at launch via `ProcessInfo.processInfo.environment` in `Constants.swift`; when unset, they fall back to the production defaults (`https://api.nativeapptemplate.com`). Release builds always use the production defaults.

In practice, only Xcode injects these env vars (via the scheme), so a Debug build launched any other way — tapped from the Home Screen (SpringBoard), opened on a physical device after Xcode disconnects, etc. — sees them unset and falls through to the production defaults. The hardcoded fallbacks are what keep the app working without Xcode in the loop.

## SwiftLint

SwiftLint runs as part of the build process in Xcode, and errors/warnings are surfaced in Xcode as well. Please ensure that you run SwiftLint before submitting a pull request.

To install SwiftLint using homebrew:

```bash
$ brew install swiftlint
```

Xcode will automatically run SwiftLint if it is installed.

## Blogs

- [Key Differences in MVVM Architecture: iOS vs. Android](https://medium.com/@dadachix/key-differences-in-mvvm-architecture-ios-vs-android-e239d30b2ea7)

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting issues, proposing changes, and submitting pull requests.

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Security

If you discover a security vulnerability, please follow the disclosure process in [SECURITY.md](SECURITY.md). Do not open public issues for security concerns.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
