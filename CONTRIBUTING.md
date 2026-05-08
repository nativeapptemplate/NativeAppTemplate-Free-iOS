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

## Rename safety

This substrate is consumed by [`nativeapptemplate-agent`](https://github.com/nativeapptemplate/nativeapptemplate-agent), which mechanically renames `Shop`, `Shopkeeper`, and `ItemTag` (and all their case forms — PascalCase, snake_case, camelCase, flat, UPPER_SNAKE, humanized lower/title/sentence × singular/plural) to user-chosen target words. Some patterns that read fine in this repo break when renamed.

Before merging changes that touch user-facing strings, test descriptors, or comments mentioning domain entities, read the [substrate rename-safety contract](https://github.com/nativeapptemplate/nativeapptemplate-agent/blob/main/docs/SUBSTRATE-CONTRACT.md).

**Quick rule of thumb:** avoid `"a"` / `"an"` directly preceding `Shop`, `Shopkeeper`, or `ItemTag` (or their humanized forms) — write self-contained or article-free phrasings instead.

**Failure mode this prevents:** a string like `"Swipe an item tag to ..."` reads correctly here but produces `"Swipe an patient to ..."` after the rename pipeline substitutes a consonant-starting word like `Patient`.

## Development Setup

See [README.md](README.md) for full setup instructions.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).
