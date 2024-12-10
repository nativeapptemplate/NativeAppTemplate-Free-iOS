# NativeAppTemplate-Free-iOS

NativeAppTemplate-Free-iOS is a modern, comprehensive, and production-ready native iOS app with user authentication.  
This iOS app is a free version of  [NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team).  

The Android version is available here: [NativeAppTemplate-Free-Android](https://github.com/nativeapptemplate/NativeAppTemplate-Free-Android).  

## Overview

NativeAppTemplate-Free-iOS is configured to connect to `api.nativeapptemplate.com`.  
You can purchase the source code for the backend server APIs that power `api.nativeapptemplate.com`:

- [NativeAppTemplate-API (Solo)](https://nativeapptemplate.com/products/api-solo)  
- [NativeAppTemplate-API (Team)](https://nativeapptemplate.com/products/api-team)

### Features

NativeAppTemplate-Free-iOS uses modern iOS development tools and practices, including:

- **100% Swift**
- **99% SwiftUI** (UIKit is only used for the contact email screen.)
- **[@Observable](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)** (iOS 17: streamlined Swift state management)
- **[SwiftLint](https://github.com/realm/SwiftLint)**
- Inspired by [emitron-iOS](https://github.com/razeware/emitron-iOS)

#### Included Features

- Onboarding
- Sign Up / Sign In / Sign Out
- Email Confirmation
- Forgot Password
- Input Validation
- CRUD Operations for Shops (Create/Read/Update/Delete)
- And more!

#### Not Included in the Free Version

The full versions ([NativeAppTemplate-iOS (Solo)](https://nativeapptemplate.com/products/ios-solo) and [NativeAppTemplate-iOS (Team)](https://nativeapptemplate.com/products/ios-team)) include additional advanced features:

- URL Path-Based Multitenancy (e.g., prepends `/:account_id/` to URLs)
- User Invitation to Organizations
- Role-Based Permissions and Access Control

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

## Contributing

If you have an improvement you'd like to share, create a fork of the repository and send us a pull request.
