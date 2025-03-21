# NativeAppTemplate-Free-iOS

NativeAppTemplate-Free-iOS is a modern, comprehensive, and production-ready native iOS app with user authentication and [background tag reading](https://developer.apple.com/documentation/corenfc/adding-support-for-background-tag-reading).  
This iOS app is a free version of  [NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team).  

The Android version is available here: [NativeAppTemplate-Free-Android](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android).  

## Overview

NativeAppTemplate-Free-iOS is configured to connect to `api.nativeapptemplate.com`.  
You can purchase the source code for the backend server APIs, made with Ruby on Rails, that power `api.nativeapptemplate.com`:

- [NativeAppTemplate-API (Solo)](https://nativeapptemplate.com/products/api-solo)  
- [NativeAppTemplate-API (Team)](https://nativeapptemplate.com/products/api-team)

### Screenshots

![Screenshot showing Sign in screen, Shops screen and Settings screen](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/screenshots.png "Screenshot showing Sign in screen, Shops screen and Settings screen")

### Features

NativeAppTemplate-Free-iOS uses modern iOS development tools and practices, including:

- **100% Swift**
- **99% SwiftUI** (UIKit is only used for the contact email screen.)
- **[@Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)** (iOS 17: streamlined Swift state management)
- **[SwiftLint](https://github.com/realm/SwiftLint)**
- **Test** (Swift Testing)
- Inspired by [emitron-iOS](https://github.com/razeware/emitron-iOS)

#### Included Features

- Onboarding
- Sign Up / Sign In / Sign Out
- Email Confirmation
- Forgot Password
- Input Validation
- CRUD Operations for Shops (Create/Read/Update/Delete)
- CRUD Operations for Shops’ Nested Resource, Number Tags (ItemTags) (Create/Read/Update/Delete)
- Generate QR Code Image for Number Tags (ItemTags) with a Centered Number
- NFC features for Number Tags (ItemTags): Write Application Info to a Tag, Read a Tag, Background Tag Reading
- And more!

## NFC Tag Operations

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
   - Go to: **Shops > [Shop] > Shop Settings > Manage Number Tags > [Manage Number Tag]**.  
2. Scan a **Server Tag** in the **Scan** tab.  
3. View the updated **Number Tags** status in the **Shop Detail** screen or on the **Number Tags Webpage** (see Background Tag Reading GIF below).  

### Recommended NFC Tags  
For best performance, use **NTAG215 (540 bytes)** tags.  
Example: [50pcs NFC Cards Ntag215](https://www.amazon.com/dp/B087FRYY8S) (Amazon USA).  

---

## Background Tag Reading  

![Gif showing Background Tag Reading](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/nfc.gif "Showing Background Tag Reading")  

### How It Works  
1. Scan a **Server Tag**.  
2. View the updated **Number Tags** status in the **Shop Detail** screen or on the **Number Tags Webpage**.  

The **Number Tags Webpage** updates in real-time using Rails [Turbo](https://turbo.hotwired.dev).  
This functionality is available in:  
- [NativeAppTemplate-API (Solo)](https://nativeapptemplate.com/products/api-solo)  
- [NativeAppTemplate-API (Team)](https://nativeapptemplate.com/products/api-team)  

> **Note:**  
> The GIF above shows [MyTurnTag Creator for iOS](https://apps.apple.com/app/myturntag-creator/id1516198303) in action, which may behave slightly differently from **NativeAppTemplate-Free-iOS**.

#### Associated Domains Requirement (iOS)  
For background tag reading to work correctly on **iOS**, you must configure **Associated Domains** in your app.  

To set up Associated Domains on iOS, follow these steps:  
1. Add your domain (e.g., `applinks:api.example.com`) to the **Associated Domains** section in Xcode under **Signing & Capabilities**.  
2. Configure the **apple-app-site-association (AASA)** file and host it on your server.
3. Verify that the **AASA** file is correctly configured and accessible by checking its contents at the following URL:  

   🔗 [https://app-site-association.cdn-apple.com/a/v1/api.example.com](https://app-site-association.cdn-apple.com/a/v1/api.example.com)  

4. Uninstall **NativeAppTemplate-Free-iOS**, reset your device, and then reinstall **NativeAppTemplate-Free-iOS** to ensure the changes take effect.

For detailed instructions, refer to Apple’s official documentations:  
- [Adding Support for Background Tag Reading](https://developer.apple.com/documentation/corenfc/adding-support-for-background-tag-reading)  
- [Supporting Associated Domains](https://developer.apple.com/documentation/xcode/supporting-associated-domains)  

## Not Included in the Free Version

![Gif showing Switching organization](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/blob/main/docs/images/organization.gif "Showing Switching organization")  

The full versions ([NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team)) include additional advanced features:

- URL Path-Based Multitenancy (prepends `/:account_id/` to URLs)
- User Invitation to Organizations
- Role-Based Permissions and Access Control

## Supported Devices

- **iPhone**  
  - SDK: iOS  
  - Orientation: Portrait mode only  
  - Screen: Requires full screen  

- **iPad**  
  - SDK: iOS  
  - Orientation: Portrait mode only  
  - Screen: Requires full screen  

- **Mac**  
  - SDK: iOS  
  - Orientation: Portrait mode only  
  - Screen: Requires full screen  
  - Notes: Designed for iPad  

## Getting Started

To get started, clone this repository:

```bash
git clone https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS.git
```

## Requirements

To run this app successfully, ensure you have:

- An iOS device or emulator with iOS version 17.6 or higher

## Running with the NativeAppTemplate-API on localhost

To connect to a local API server, update the following configuration in in Constants.swift:

```swift
static let scheme: String = "http"
static let domain: String = "192.168.1.21"
static let port: String = "3000"
```

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

If you have an improvement you'd like to share, create a fork of the repository and send us a pull request.
