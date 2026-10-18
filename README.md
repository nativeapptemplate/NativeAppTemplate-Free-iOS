# NativeAppTemplate-Free-iOS

NativeAppTemplate-Free-iOS is a modern, comprehensive, and production-ready native iOS app with user authentication and a full CRUD example.  
It is a complete, working app on its own, not a demo or a trimmed-down preview: build on it and ship it as is, under the MIT License.  
The paid editions, [NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team), are for apps in which several people work in a shared organization; they add the features listed in [Paid Edition Extras](#paid-edition-extras).  

The Android version is available here: [NativeAppTemplate-Free-Android](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android).  

Want this template adapted to your own domain? [nativeapptemplate-agent](https://github.com/nativeapptemplate/nativeapptemplate-agent) is a Claude Code agent that turns a one-sentence spec (e.g. *"a walk-in queue for a barbershop"*) into a coherent three-platform app — this SwiftUI iOS app, a matching [Rails 8.1 API](https://github.com/nativeapptemplate/nativeapptemplateapi), and a [Jetpack Compose Android app](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android) — renamed and adapted for you, with validation built in.

## Overview

NativeAppTemplate-Free-iOS connects to a Rails 8.1 API backend that **you run yourself**. The backend is open source (MIT) — run it locally on your Wi-Fi or deploy your own, then point the app at it (see [Running with the NativeAppTemplate-API on localhost](#running-with-the-nativeapptemplate-api-on-localhost)).

> **Note:** There is no shared hosted API. The app still ships with a built-in default of `https://api.nativeapptemplate.com`, but that endpoint has been shut down — you must run your own API server and point the app at it.

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
- English and Japanese Localization (String Catalogs)
- And more!

## NFC Tag Operations

NFC tag writing and background tag reading were part of v1 and have been removed from the current version. The full NFC implementation remains available in the [`v1-with-nfc`](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/tree/v1-with-nfc) branch.

## Paid Edition Extras

![Gif showing Switching organization](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/organization.gif "Showing Switching organization")  

The free version is complete for apps used by individuals. The paid editions ([NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team)) add what apps for teams need:

- URL Path-Based Multitenancy (prepends `/:account_id/` to URLs)
- User Invitation to Organizations
- Role-Based Permissions and Access Control
- Organization Switching UI
- Push Notifications via APNs
- Subscriptions via RevenueCat, off until you add an API key
- Crash and error monitoring via Sentry, off until you add a DSN

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

Debug builds take the API endpoint from `API.xcconfig`. Put your own values in `API.local.xcconfig` next to it (gitignored, so your LAN IP stays out of git):

```
NATIVEAPPTEMPLATE_API_SCHEME = http
NATIVEAPPTEMPLATE_API_DOMAIN = <your-lan-ip>
NATIVEAPPTEMPLATE_API_PORT   = 3000
```

Only the keys you set override `API.xcconfig`, whose committed values are examples (`http://192.168.1.21:3000`). They must match `HOST` / `PORT` in the API's `.env`.

> **Note:** Never use `127.0.0.1`, `localhost`, or `0.0.0.0` for `NATIVEAPPTEMPLATE_API_DOMAIN` — those resolve to the iOS Simulator/device itself, not your Mac. Use your Mac's LAN IP (e.g., `192.168.1.6`) so the simulator or a physical device can reach the API server.

The values are built into the app's `Info.plist`, so a Debug build reaches the same API however it is launched: from Xcode, from the Home Screen, on a device after Xcode disconnects, and after iOS relaunches the app because its language was changed in Settings. Environment variables with the same names (`NATIVEAPPTEMPLATE_API_*`, e.g. set by `simctl launch` via `SIMCTL_CHILD_*`) still take precedence; see `APIEndpoint` in `NativeAppTemplateEnvironment.swift`.

Release builds always use the code default (`https://api.nativeapptemplate.com`, which has been shut down), so change `APIEndpoint.production` to your own API server before shipping a Release build.

## App Store page

When the API says this version must be updated (an `AppVersion` with `forced_update`), the app shows the update screen, whose **Update App** button opens your app's App Store page. Set `APP_STORE_ID` in `AppStore.xcconfig` to your app's Apple ID, the number at the end of its App Store URL (App Store Connect → your app → **App Information** → **Apple ID**), or put it in `AppStore.local.xcconfig` next to it (gitignored):

```
APP_STORE_ID = 1234567890
```

It is empty as committed, which hides the button: the screen still asks users to install the new version, which they get from the App Store app. The ID is built into `Info.plist` as `AppStoreID` and read at launch (`Strings.appStoreUrl`, `https://apps.apple.com/app/id<Apple ID>`). A value that is not all digits also hides the button, and `InfoPlistTest` fails on it.

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
