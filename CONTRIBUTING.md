# Contributing to NativeAppTemplate-Free-iOS

Thanks for your interest in contributing! This document explains how to report issues, propose changes, and submit pull requests.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold it.

## Reporting Bugs

Before opening an issue, please:

1. Search existing [issues](https://github.com/nativeapptemplate/NativeAppTemplate-Free-iOS/issues) to avoid duplicates.
2. Confirm the bug reproduces on the `main` branch with the latest Xcode.
3. Include:
   - iOS version and device model (or simulator)
   - Xcode version
   - Steps to reproduce
   - Expected vs actual behavior
   - Relevant console output or crash logs

## Reporting Security Vulnerabilities

**Do not open public issues for security vulnerabilities.** See [SECURITY.md](SECURITY.md) for the disclosure process.

## Proposing Changes

For non-trivial changes, please open an issue first to discuss the approach before investing implementation time.

## Pull Requests

1. Fork the repository and create a feature branch from `main`.
2. Make your changes with clear, focused commits.
3. Add or update tests (Swift Testing) for any behavioral changes.
4. Build and run the test suite in Xcode (`Cmd+U`).
5. Run SwiftLint and resolve any new warnings.
6. Push your branch and open a pull request against `main`.
7. In the PR description, explain *what* changed and *why*.

### Style

This project uses [SwiftLint](https://github.com/realm/SwiftLint) for code style. Please ensure it passes before submitting.

Architecture: Simple MVVM Layered Architecture with `@Observable` state management. Follow existing patterns for new screens and view models.

### Tests

- Tests use [Swift Testing](https://developer.apple.com/xcode/swift-testing/).
- Place new tests alongside existing ones mirroring the source structure.

## Development Setup

See [README.md](README.md) for full setup instructions.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
