# NativeAppTemplate-Free-iOS

NativeAppTemplate-Free-iOS is a modern, comprehensive, and production-ready native iOS app with user authentication and [background tag reading](https://developer.apple.com/documentation/corenfc/adding-support-for-background-tag-reading).  
This iOS app is a free version of  [NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team).  

The Android version is available here: [NativeAppTemplate-Free-Android](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android).  

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
- CRUD Operations for Shops' Nested Resource, Number Tags (ItemTags) (Create/Read/Update/Delete)
- Force App Version Update
- Force Privacy Policy Version Update
- Force Terms of Use Version Update
- Generate QR Code Image for Number Tags (ItemTags) with a Centered Number
- NFC features for Number Tags (ItemTags): Write Application Info to a Tag, Read a Tag, Background Tag Reading
- And more!

## NFC Tag Operations

<details>
<summary><strong>How NFC tag writing and background reading works</strong></summary>

### Overview  

![Screenshot showing Overview before](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/overview_before.png "Screenshot showing Overview before")

![Screenshot showing Overview after](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/overview_after.png "Screenshot showing Overview after")

The app replaces traditional paper tags with NFC tags to efficiently manage walk-in customer waitlists. It writes application-specific information onto your NFC cards (referred to as :red_circle: **Server Tag** and :large_blue_circle: **Customer Tag**).

**For Customers:**  
When a customer scans a :large_blue_circle: **Customer Tag**, they can view the :green_circle: **Number Tags Webpage** (a public webpage) on their mobile browser. This page displays completed Number Tags.

**For Staff:**  
By scanning a :red_circle: **Server Tag** paired with the :large_blue_circle: **Customer Tag**, staff can complete a Number Tag. Completed Number Tags automatically appear on the :green_circle: **Number Tags Webpage** for customer reference.

### How It Works  

![Screenshot showing Write Application Info to Tag screen, Scan Tag screen, and Shop Detail screen](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/screenshots_nfc.png "Screenshot showing Write Application Info to Tag screen, Scan Tag screen, and Shop Detail screen")

1. Write application info to pair **Number Tags** (Server Tag and Customer Tag) or a **Customer QR code**:  
   - Go to: **Shops > [Shop] > Shop Settings > Manage Number Tags > [Number Tag]**.  
2. Scan a **Server Tag** in the **Scan** tab.  
3. View the updated **Number Tags** status in the **Shop Detail** screen or on the **Number Tags Webpage** (see Background Tag Reading GIF below).  

### Recommended NFC Tags  
For best performance, use **NTAG215 (540 bytes)** tags.  
Example: [50pcs NFC Cards Ntag215](https://www.amazon.com/dp/B087FRYY8S) (Amazon USA).  

---

### Background Tag Reading  

![Gif showing Background Tag Reading](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/nfc.gif "Showing Background Tag Reading")  

1. Scan a **Server Tag**.  
2. View the updated **Number Tags** status in the **Shop Detail** screen or on the **Number Tags Webpage**.  

The **Number Tags Webpage** updates in real-time using Rails [Turbo](https://turbo.hotwired.dev).  
This functionality is part of the open-source [nativeapptemplateapi](https://github.com/nativeapptemplate/nativeapptemplateapi) backend.  

> **Note:**  
> The GIF above shows [MyTurnTag Creator for iOS](https://apps.apple.com/app/myturntag-creator/id1516198303) in action, which may behave slightly differently from **NativeAppTemplate-Free-iOS**.

### Associated Domains Requirement (iOS)  
For background tag reading to work correctly on **iOS**, you must configure **Associated Domains** in your app.  

To set up Associated Domains on iOS, follow these steps:  
1. Add your domain (e.g., `applinks:api.example.com`) to the **Associated Domains** section in Xcode under **Signing & Capabilities**.  
2. Configure the **apple-app-site-association (AASA)** file and host it on your server.
3. Verify that the **AASA** file is correctly configured and accessible by checking its contents at the following URL:  

   🔗 [https://app-site-association.cdn-apple.com/a/v1/api.example.com](https://app-site-association.cdn-apple.com/a/v1/api.example.com)  

4. Uninstall **NativeAppTemplate-Free-iOS**, reset your device, and then reinstall **NativeAppTemplate-Free-iOS** to ensure the changes take effect.

For detailed instructions, refer to Apple's official documentations:  
- [Adding Support for Background Tag Reading](https://developer.apple.com/documentation/corenfc/adding-support-for-background-tag-reading)  
- [Supporting Associated Domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains)  

</details>

## Not Included in the Free Version

![Gif showing Switching organization](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/organization.gif "Showing Switching organization")  

The full versions ([NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team)) include additional advanced features:

- URL Path-Based Multitenancy (prepends `/:account_id/` to URLs)
- User Invitation to Organizations
- Role-Based Permissions and Access Control
- Organization Switching UI

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
NATEMPLATE_API_SCHEME = http
NATEMPLATE_API_DOMAIN = <your-lan-ip>
NATEMPLATE_API_PORT   = 3000
```

Keep the scheme in `xcuserdata` (per-developer, gitignored), not `xcshareddata`. In Xcode, open **Product → Scheme → Manage Schemes…**, find `NativeAppTemplate`, and **uncheck "Shared"**. This moves the scheme (with your local env vars) to `xcuserdata/<user>.xcuserdatad/xcschemes/` so your API settings are not committed. If Xcode staged a deletion of the previously shared scheme, restore it with:

```bash
git restore --source=HEAD --staged --worktree NativeAppTemplate.xcodeproj/xcshareddata/xcschemes/NativeAppTemplate.xcscheme
```

Debug builds read these at launch via `ProcessInfo.processInfo.environment` in `Constants.swift`; when unset, they fall back to the production defaults (`https://api.nativeapptemplate.com`). Release builds always use the production defaults.

## SwiftLint

SwiftLint runs as part of the build process in Xcode, and errors/warnings are surfaced in Xcode as well. Please ensure that you run SwiftLint before submitting a pull request.

To install SwiftLint using homebrew:

```bash
$ brew install swiftlint
```

Xcode will automatically run SwiftLint if it is installed.

## Blogs

- [Key Differences in MVVM Architecture: iOS vs. Android](https://medium.com/@dadachix/key-differences-in-mvvm-architecture-ios-vs-android-e239d30b2ea7)
- [Cross-Platform Background NFC Tag Reading](https://medium.com/@dadachix/cross-platform-background-nfc-tag-reading-8a704f0cb6e9)

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on reporting issues, proposing changes, and submitting pull requests.

This project adheres to the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Security

If you discover a security vulnerability, please follow the disclosure process in [SECURITY.md](SECURITY.md). Do not open public issues for security concerns.

## License

This project is licensed under the MIT License — see [LICENSE](LICENSE) for details.
