# Changelog

All notable changes to NativeAppTemplate will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Keychain items are written `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, so a backup restored onto another device does not carry the signed-in session; items written earlier move over on the next save. Found while building Orange Baton from the template (#115)
- The delete-account confirmation says that the shops and item tags are deleted with the account. Found while building Orange Baton from the template (#115)
- A form field's error stays hidden until the field is first edited (`untilEdited(_:)`), so new forms (shop, item tag, sign-up, password) no longer open in red. Found while building Orange Baton from the template (#115)
- Text can grow past AX1: the shop card and the onboarding title no longer cap Dynamic Type, and the onboarding art shrinks to make room. Icon-only buttons (+, trash, the shop settings gear) have accessibility labels; decorative images are hidden from VoiceOver. Tags are 13 pt (`uiFootnote`) instead of 10 pt. Found while building Orange Baton from the template (#115)
- The settings rows are value links (`SettingsDestination`), so screens pushed from them can push their own value links. The initial tab is named once (`MainTab.initial`). The onboarding background covers the whole screen. `Strings` is split into one extension per screen in `NativeAppTemplate/Strings/`. Found while building Orange Baton from the template (#115)
- List screens switch on `DataState.listContent(isEmpty:)`, where a reload with data on screen is the same `.list` case as loaded data instead of a `switch` branch of its own. A separate branch makes SwiftUI rebuild the list on every reload, re-register its `navigationDestination` and re-run its `.task`; in MyTurnTagCreator that turned a reload after each tag change into a loop that hit the API's rate limit. Nothing here reloads that way yet, so this removes the trap rather than a live bug (Shops, number tags)
- Error messages are localized (English and Japanese). A request that fails without the API's `error_message` shows "Something went wrong while communicating with the server. Please try again later." (`NATIVEAPPTEMPLATE-2001`); developer-only errors (`NATIVEAPPTEMPLATE-1001`, `2002`–`2008`, `4001`–`4004`) show "An unexpected error occurred." The API's `error_message` is shown without the " [Status: nnn]" suffix. Error codes are unchanged; status codes, field names and underlying errors go to the log (`CodedError.debugDescription`)

### Fixed
- The update screen shown when the API requires a newer version opened MyTurnTag Creator's App Store page from its **Update App** button (hardcoded in `Strings.appStoreUrl`). It now opens `https://apps.apple.com/app/id<APP_STORE_ID>`, where `APP_STORE_ID` is a build setting in the new `AppStore.xcconfig` (included by the new `Project.xcconfig`, the project-level base configuration of Debug and Release; override it in the gitignored `AppStore.local.xcconfig`), built into `Info.plist` as `AppStoreID`. It is empty as committed, which hides the button; the screen still asks users to install the new version. See README "App Store page"
- The Local Network permission prompt (`NSLocalNetworkUsageDescription`) had an article before the product name, which reads wrong after a rename. It now reads "Connects to the app's API server running on your local network during development."; the Japanese is unchanged. `LocalizationTest` now fails on "a" or "an" right before a word the agent renames in the English strings
- Rename safety in tests and comments: `JSONAPIDocumentTest` no longer uses `itemTag` as a type the app does not know (the agent renames `item_tag` and `itemTag` to the same word, so it became a known type in generated apps), and comments drop the article before domain words and say "the agent" instead of the agent's name
- The alert after resending confirmation instructions read "An email has been sent the email containing instructions for confirming your email address." It now reads "An email with instructions for confirming your email address has been sent.", as in NativeAppTemplate-Free-Android; the Japanese is unchanged
- The message bar no longer covers the tab bar and blocks tab taps until it is closed: with the tabs showing, it sits above the tab bar. Its close button is a labeled "Close" button (new string, Japanese 閉じる) with a 32 pt target (the symbol stays 16 pt); the tabs' accessibility label no longer replaces the message's labels
- VoiceOver read validation messages that weren't shown, e.g. "Name is required." under a filled-in name: a valid form keeps the message's space with a clear color, which still left it an accessibility element. The message is now also hidden from accessibility until it is shown (`validationMessage(isShown:)`, used by every form that hid its message this way: sign-up, profile, password, shop create/basic settings, item tag create/edit)
- A failed sign-in's error message stayed on screen after the next attempt signed in; a new attempt now dismisses it
- Debug builds lost the local API when launched other than from Xcode, e.g. from the Home Screen or when iOS relaunched the app after its language was changed in Settings: the endpoint came only from the scheme's environment variables, which only Xcode passes. It now comes from `API.xcconfig` (override it in the gitignored `API.local.xcconfig`) and is built into `Info.plist`; `NATIVEAPPTEMPLATE_API_*` environment variables still win. The scheme no longer sets them

### Added
- Japanese localization, ported from NativeAppTemplate-iOS #102 with the same Japanese for every shared string. Every user-facing string goes through `Localizable.xcstrings` (`String(localized:)` in `Constants.swift`), with Japanese for all keys using the API's terms (店舗, アイテムタグ). `InfoPlist.xcstrings` keeps the app name as is. `LocalizationTest` fails on a key without Japanese, a translation with different format specifiers, ショップ, or ItemTag not written as アイテムタグ in full
- "App Language" on Edit Profile shows the language the app is shown in, with a button to change it in iOS Settings; emails follow it. Sign-up sends that language as `locale`, and after permissions are fetched (every launch and sign-in) the app sends `PATCH /shopkeeper_auth {locale}` when `shopkeepers.locale` differs (nativeapptemplateapi #150)
- `Shopkeeper.locale`, read from the sign-in, sign-up and profile responses and kept with the saved session. A session saved by an earlier version reads as `en`, the API's default

### Removed
- `PermissionsRequest` no longer requires `shop_limit_count`; `SessionController` used it only as the "permissions loaded" mark, which is `didFetchPermissions` now. Unused `Spacing.xxxxl` and `uiUppercaseTag`. Found while building Orange Baton from the template (#115)
- TLS certificate pinning for the API. `URLSession.api` (formerly `URLSession.pinned`) relies on the system's default trust evaluation; the leaf pin had gone stale, and any CA or intermediate change risked an outage. Session headers are still dropped on redirects that leave the API host

### Changed
- The scheme's test action runs in English, so tests compare against English strings on a Japanese simulator
- Unit tests launch a blank host app instead of the full app, so they no longer read the keychain, start `NWPathMonitor`, or set up TipKit before every run

## [3.2.5] - 2026-10-04

### Changed
- Move agent instructions from `CLAUDE.md` to `AGENTS.md` so Claude Code, Codex, and other agents share one file. `CLAUDE.md` now only imports it (`@AGENTS.md`)
- Replace `.aspectRatio(contentMode: .fit)` with `.scaledToFit()` (SwiftLint `legacy_swiftui_aspect_ratio`)
- Handle errors inside fire-and-forget `Task`s (Swift `NoUseUnstructuredThrowingTask` warning). `MainViewModel.logout()` now posts a logout failure to `MessageBus`; other call sites use `try?` because `SessionController.logout()` already logs the failure and resets session state before rethrowing
- Add a Testing Policy section to `AGENTS.md`

### Removed
- `swift-collections` dependency. `timeZones` was its only user (`OrderedDictionary`); it is now a plain `[(key: String, value: String)]` array with the same order, and the time zone pickers no longer force-unwrap
- `KeychainAccess` dependency — the app now has no third-party Swift packages. A small `Keychain` wrapper over the Security framework replaces it and uses the same item attributes KeychainAccess v4.2.2 used (generic password keyed by service + account, `kSecAttrAccessibleAfterFirstUnlock`, not synchronizable), so the signed-in session written by earlier versions keeps working after the update

## [3.2.4] - 2026-06-10

### Fixed
- List views (`ShopListView`, `ItemTagListView`) no longer blink a full-screen `LoadingView` over already-loaded data when they re-appear (returning to a tab, popping back from a detail). The `.loading` state now keeps existing content on screen and only shows `LoadingView` on a true cold start (`.initial`, or `.loading` with no data yet)

## [3.2.3] - 2026-05-08

### Fixed
- `EntityAdapterError` (JSON:API parsing) now conforms to `CodedError` so failures — including login against an invalid server — surface with `[NATIVEAPPTEMPLATE-2006..2008]` prefixes instead of opaque descriptions
- `KeychainStoreError` now conforms to `CodedError` with new `[NATIVEAPPTEMPLATE-4001..4004]` codes for persistence failures

## [3.2.2] - 2026-05-04

### Changed
- Slim onboarding to a single welcome screen using the `sparkles` SF Symbol
- Replace logo and hero imagesets on sign-up/sign-in with `Strings.appName` text and `sparkles`
- Introduce `Strings.appName` ("Native App Template") as the single source of truth for the in-app product name
- Set `CFBundleDisplayName` to "Native App Template"
- Refresh AppIcon to the upstream `nativeapptemplate-icon-composer-foreground` artwork

### Removed
- `Onboarding` model, repository/protocol, view model, and related tests
- Onboarding 1–4 imagesets, `hero` imageset, and `Logo` imageset

## [3.2.1] - 2026-05-02

### Changed
- Clarify Shop list card tag labels as "completed item tags" / "all item tags"

## [3.2.0] - 2026-05-02

### Removed
- NFC, QR code, and Scan functionality (Phase 2A-2)
- `tagsScanned` count and `howToUse` fields from ItemTag
- `maximum_name_length` from server permissions; moved to client `Constants`
- Onboarding reload ceremony
- Dead code: `ImageSaver`, `composited()`, unused colors and fonts, dead `Date` helper

### Changed
- Renamed "Number Tag" to "Item Tag" across labels and identifiers
- Ported ItemTag schema and generic CRUD UI from paid iOS (Phase 2A-1, 2A-3)
- Display `completedAt` as `yyyy/MM/dd HH:mm` regardless of locale
- Added client-side length caps and truncation for Shop name/description
- Wrapped String constants in `enum Strings` namespace
- Slimmed onboarding to 4 slides; introduced `ImageOrientation` enum
- Tightened ItemTag labels and silenced success toasts on complete/idle
- Read API endpoint from env vars in Debug builds
- Renamed error code prefix `NATI-` to `NATIVEAPPTEMPLATE-` and env var prefix `NATEMPLATE_API_` to `NATIVEAPPTEMPLATE_API_`
- Swiftier String predicates; replaced custom helpers with stdlib equivalents

### Added
- Unit tests for previously untested Models and `Date` extension
- `CONTRIBUTING.md` and `CODE_OF_CONDUCT.md`

### Fixed
- Onboarding flow and asset cleanup
- README: dropped stale NFC/QR feature lines and updated env var references

## [3.1.1] - 2026-04-06

### Changed
- Replace PNG-based app icon with SVG-based `.icon` format
- Move `Assets.xcassets` into `Resources/` directory

## [3.1.0] - 2026-04-05

### Added
- Pagination support for item tags list
- CodedError system with `NATIVEAPPTEMPLATE-XXXX` prefixed error codes
- App version display in settings
- Design system constants (spacing, animation, glass, layout, corner radius)
- GlassButtonStyle and GlassCard components with glassmorphism styling
- Explicit Sendable conformance to model structs
- SwiftFormat for code formatting (with `--maxwidth 120`)
- SwiftFormat lint check to CI
- `@preconcurrency import CoreNFC` and `nonisolated(unsafe)` for Sendable fixes
- Model tests for ItemTagType, ItemTagState, and ScanState
- Tests for TabViewModel, MessageBus, Utility, and String extensions

### Changed
- Update to iOS 26 and remove deprecated `UIRequiresFullScreen`
- Replace asset catalog colors with palette-based color system
- Replace Inter font with Apple system font
- Replace `confirmationDialog` with `alert` for consistent centered presentation
- Replace hardcoded spacing and corner radius values with `NativeAppTemplateConstants`
- Apply ultraThinMaterial backgrounds to scan views and ItemTagDetailView
- Use semi-transparent card background for list rows
- Update Lock toggle to button style in ItemTagDetailView
- Reorganize settings sections
- Clean up Settings: remove Discussions, update contact, remove dead code
- Remove SwiftyJSON dependency, use `JSONSerialization`
- Moved `.swiftlint.yml` to repository root with updated rules
- Applied SwiftFormat across all source files
- Fixed all SwiftLint violations (line length, cyclomatic complexity, etc.)

### Security
- Prevent sensitive data from leaking to iOS console in Release builds
- Replace `#if DEBUG print()` with `os.Logger` for structured, privacy-aware logging
- Add TLS certificate pinning for API connections
- Remove backdoor authentication bypass

### Fixed
- Fix accept privacy/terms views not displaying
- Fix typo `startSesstion` → `startSession` in NFCManager
- Fix typo `prmissionsResponse` → `permissionsResponse` in SessionController
- Fix `Event.refresh` ignoring `action` parameter and hardcoding `"Refresh"`
- Fix data race warning when sending `NFCNDEFMessage` across isolation boundaries
- Remove unused `navigationPathStats` state variable from `AppTabView`
- Remove hardcoded toolbar background from ScanView

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
