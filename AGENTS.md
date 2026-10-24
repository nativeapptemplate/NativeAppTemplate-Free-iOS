# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Codex, etc.) when working with code in this repository.

## Build, Test, and Development Commands

### Building the Project
```bash
# Build for Debug
xcodebuild -project NativeAppTemplate.xcodeproj \
  -scheme "NativeAppTemplate" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build

# Build for Release
xcodebuild -project NativeAppTemplate.xcodeproj \
  -scheme "NativeAppTemplate" \
  -configuration Release \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  build
```

### Running Tests
```bash
# Run all tests
xcodebuild -project NativeAppTemplate.xcodeproj \
  -scheme "NativeAppTemplate" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

### Linting
```bash
# Run SwiftLint (must be installed via: brew install swiftlint)
swiftlint

# Run SwiftLint with strict mode (as in CI)
swiftlint --strict
```

### Linting and Formatting
Always run `make lint` before pushing to verify SwiftLint and SwiftFormat checks pass. Use `make format` to auto-fix SwiftFormat issues. After lint passes, ask the user to verify tests in Xcode (Cmd+U) before pushing.

### Formatting
```bash
# Run SwiftFormat (must be installed via: brew install swiftformat)
swiftformat .
```

## Architecture Overview

### MVVM with Observable Pattern
The app uses iOS 17's `@Observable` macro for state management with clean separation between:
- **Views**: SwiftUI views
- **ViewModels**: Observable state containers that bridge views and data
- **Models**: Domain objects and data structures
- **Repositories**: Data access layer implementing CRUD operations

### Core Components

**Data Flow Architecture**:
1. **SessionController** (`/Sessions/SessionController.swift`): Manages authentication state and user sessions
2. **DataManager** (`/Data/DataManager.swift`): Central orchestrator that manages all repositories
3. **Repositories**: Each entity has its own repository (e.g., `ShopRepository`, `ItemTagRepository`)
4. **Services**: Network layer abstraction with protocol-based design
5. **MessageBus** (`/MessageBus.swift`): Event communication system for decoupled components

**Networking Architecture**:
- JSON API format with custom adapters (`/Networking/Adapters/`)
- Service layer pattern (`/Networking/Services/`)
- Request/Response models (`/Networking/Requests/`, `/Networking/Responses/`)
- Error handling with typed errors (`/Models/AppError.swift`)

### Key Features Implementation

**Offline Support**:
- Network monitoring (`/Networking/NetworkMonitor.swift`)
- Keychain storage for secure data persistence

**Configuration**:
- Central configuration in `Constants.swift`; the app's text in `Strings/`, one extension per screen
- API endpoints, UI strings, and app constants
- Environment-specific settings (scheme, domain, port)

### Project Structure
```
NativeAppTemplate/
├── App.swift                 # App entry point
├── MainView.swift           # Root view
├── Data/                    # Data layer (repositories, ViewModels)
├── Models/                  # Domain models
├── Networking/              # API layer
├── UI/                      # SwiftUI views by feature
├── Sessions/                # Authentication
├── Persistence/             # Keychain storage
└── Utilities/               # Helpers and extensions
```

### Error Handling (CodedError System)
All errors use the `CodedError` protocol in `NativeAppTemplate/Common/Errors/`. Error codes share the `NATIVEAPPTEMPLATE-XXXX` prefix across iOS and Android.

| Range | Type | File |
|-------|------|------|
| NATIVEAPPTEMPLATE-1xxx | App/general errors | `AppError.swift` |
| NATIVEAPPTEMPLATE-2xxx | API/network errors | `NativeAppTemplateAPIError.swift`, `EntityAdapterError.swift` |
| NATIVEAPPTEMPLATE-4xxx | Persistence/Keychain errors | `KeychainStoreError.swift` |

- New error types must conform to `CodedError` and be placed in `Common/Errors/`
- Use `error.codedDescription` (not `error.localizedDescription`) in all error messages
- `errorDescription` is what the user sees, so it is localized (`String(localized:)` in `Strings/Strings+Errors.swift`): the API's `error_message` as is, or a generic text ("Something went wrong while communicating with the server. Please try again later." when a request fails without one, "An unexpected error occurred." for developer-only errors such as malformed responses or Keychain failures). Developer details (status codes, field names, underlying errors) go to `debugDescription`; log errors with `error.debugCodedDescription`, never show it
- Use `Message(error: error)` convenience to post errors to `MessageBus`
- Error code numbers must match across iOS and Android

### Dependencies
- No third-party Swift packages. Keychain access goes through `Persistence/KeychainStore/Keychain.swift`, a small wrapper over the Security framework

### Project file
Both targets are folder-synchronized groups: a file added under `NativeAppTemplate/` or `NativeAppTemplateTests/` joins its target without touching `project.pbxproj`. `Info.plist` is the app folder's exception (the build settings point at it; it is not copied into the app).

### Testing
Uses Swift Testing framework with `@Test` attribute. Tests are organized by component type (models, adapters, networking).

## Localization (English + Japanese)

The app ships in English (development language) and Japanese. **Every new user-facing string needs a Japanese translation**; `NativeAppTemplateTests/App/LocalizationTest.swift` fails otherwise.

- Put shared text in `Strings` as `static let x = String(localized: "...")`: a screen's text in its extension in `Strings/` (`Strings+Shops.swift` and so on; a new screen gets a new file), text used across screens in `Constants.swift`. A literal in `Text("...")`, `Button("...")`, `Label("...", systemImage:)` etc. is localized automatically, but a `String` variable passed to `Text(_:)` is shown verbatim, so build it with `String(localized:)`. Never build a sentence with `+`; interpolate inside one localized literal (`String(localized: "Welcome to \(appName)")`) so the translation can reorder it.
- Keep the keys in English: nativeapptemplate-agent renames the English nouns in code and catalog keys together.
- After building, Xcode adds new keys to `NativeAppTemplate/Localizable.xcstrings`; from the command line, `make strings` does the same (it builds into `build/strings` and syncs the catalog with that build's `.stringsdata`). Add the `ja` value with state `translated`, keeping every `%@`/`%lld` (use `%1$@`, `%2$@` to reorder). Permission prompts go in `InfoPlist.xcstrings`.
- Use the API's terms (`config/locales/ja.yml`), the same as the paid NativeAppTemplate-iOS: Shop is **店舗** (never ショップ/店/お店), ItemTag is **アイテムタグ** in full (never タグ or アイテム alone; the agent renames these Japanese nouns as substrings), Idled/Completed 未完了/完了. Don't translate the product name.
- User-facing error text is localized, like any other UI text (`CodedError.errorDescription`); developer details go to logs (`debugDescription`).
- Keep untranslated: product names, URLs, `NATIVEAPPTEMPLATE-xxxx` error codes, log messages, the API's `error_message` (already localized by the server), and text the user typed.
- Tests run in English (the scheme's test action sets `language = "en"`).
- The app's language is set in iOS Settings, not in the app. Edit Profile shows it read-only; `SessionController` keeps `shopkeepers.locale` in step with it so emails match.

## Testing Policy

- **Bug fixes start with a failing test that reproduces the bug. No exceptions.** Every fix commit must include that reproduction test.
- **Record where each expected value comes from.** Cite the relevant part of the spec, a hand calculation, or a known oracle. Never paste the value the implementation happens to produce as the expected value.

  ```swift
  // floor(10000 * 31 / 71) = 4366   ← state the derivation like this
  ```

- **See it go red at least once before calling it done.** For every new test — especially guards and configuration checks — deliberately break the code under test and confirm the test fails. A test that cannot fail verifies nothing.
- **Passing tests alone do not mean done.** Launch the app and actually exercise the change.
- **Implementation and tests go in the same commit.** "I'll write the tests later" never happens.
