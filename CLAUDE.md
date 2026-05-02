# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build, Test, and Development Commands

### Building the Project
```bash
# Build for Debug
xcodebuild -project NativeAppTemplate.xcodeproj \
  -scheme "NativeAppTemplate" \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' \
  build

# Build for Release
xcodebuild -project NativeAppTemplate.xcodeproj \
  -scheme "NativeAppTemplate" \
  -configuration Release \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' \
  build
```

### Running Tests
```bash
# Run all tests
xcodebuild -project NativeAppTemplate.xcodeproj \
  -scheme "NativeAppTemplate" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.2' \
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

**NFC Support**:
- Tag reading/writing capabilities (`/NFC/`)
- Background tag reading support
- Application-specific tag data format

**Offline Support**:
- Network monitoring (`/Networking/NetworkMonitor.swift`)
- Keychain storage for secure data persistence

**Configuration**:
- Central configuration in `Constants.swift`
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
├── Utilities/               # Helpers and extensions
└── NFC/                     # NFC functionality
```

### Error Handling (CodedError System)
All errors use the `CodedError` protocol in `NativeAppTemplate/Common/Errors/`. Error codes share the `NATIVEAPPTEMPLATE-XXXX` prefix across iOS and Android.

| Range | Type | File |
|-------|------|------|
| NATIVEAPPTEMPLATE-1xxx | App/general errors | `AppError.swift` |
| NATIVEAPPTEMPLATE-2xxx | API/network errors | `NativeAppTemplateAPIError.swift` |

- New error types must conform to `CodedError` and be placed in `Common/Errors/`
- Use `error.codedDescription` (not `error.localizedDescription`) in all error messages
- Use `Message(error: error)` convenience to post errors to `MessageBus`
- Error code numbers must match across iOS and Android

### Dependencies (Swift Package Manager)
- KeychainAccess (4.2.2) - Secure credential storage
- Swift Collections (1.1.4) - Additional data structures

### Testing
Uses Swift Testing framework with `@Test` attribute. Tests are organized by component type (models, adapters, networking).