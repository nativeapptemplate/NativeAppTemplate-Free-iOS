# Changelog

All notable changes to NativeAppTemplate will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- SwiftFormat for code formatting (with `--maxwidth 120`)
- `@preconcurrency import CoreNFC` and `nonisolated(unsafe)` for Sendable fixes

### Changed
- Moved `.swiftlint.yml` to repository root with updated rules
- Applied SwiftFormat across all source files
- Fixed all SwiftLint violations (line length, cyclomatic complexity, etc.)

### Security
- Prevent sensitive data from leaking to iOS console in Release builds
- Replace `#if DEBUG print()` with `os.Logger` for structured, privacy-aware logging
- Add TLS certificate pinning for API connections
- Remove backdoor authentication bypass

### Fixed
- Fix typo `startSesstion` → `startSession` in NFCManager
- Fix typo `prmissionsResponse` → `permissionsResponse` in SessionController
- Fix `Event.refresh` ignoring `action` parameter and hardcoding `"Refresh"`
- Fix data race warning when sending `NFCNDEFMessage` across isolation boundaries
- Remove unused `navigationPathStats` state variable from `AppTabView`

### Other
- Refine `.claude` gitignore rules for granular control

## [1.1.0] - 2025-07-26

### Changed
- Updated for iOS 18 support
- Bug fixes

## [1.0.0] - 2024-10-30

### Added
- Initial release of NativeAppTemplate
- 100% Swift, 99% SwiftUI (UIKit only for email screen via MessageUI)
- `@Observable` macro (iOS 17+) for state management
- MVVM architecture with repository pattern
- Onboarding flow
- Sign Up / Sign In / Sign Out
- Email Confirmation
- Forgot Password
- Input Validation
- CRUD operations for Shops
- URL path-based multitenancy
- User invitation to organizations
- Role-based permissions and access control
- NFC tag reading and writing
- SwiftLint integration
- Swift Testing framework for unit tests
- GitHub Actions CI for automated testing

### Technical
- Protocol-oriented repository pattern for testability
- DataManager as central dependency injection container
- Token-based authentication with automatic refresh
- NavigationStack with path-based routing
- JSON:API adapter layer
