.PHONY: lint format strings

lint:
	swiftlint lint --strict NativeAppTemplate
	swiftformat --lint NativeAppTemplate

format:
	swiftformat NativeAppTemplate

# Adds the strings the app's code uses to Localizable.xcstrings, as building in Xcode
# does: builds into build/strings, then syncs the catalog with that build's
# .stringsdata. New keys still need their ja value (AGENTS.md "Localization").
STRINGS_DERIVED_DATA := build/strings
strings:
	xcodebuild -project NativeAppTemplate.xcodeproj -scheme NativeAppTemplate \
		-sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
		-derivedDataPath $(STRINGS_DERIVED_DATA) -quiet build
	find $(STRINGS_DERIVED_DATA)/Build/Intermediates.noindex/NativeAppTemplate.build \
		-path '*/NativeAppTemplate.build/*/NativeAppTemplate.build/*' -name '*.stringsdata' \
		| sed 's/^/--stringsdata /' | xargs xcrun xcstringstool sync NativeAppTemplate/Localizable.xcstrings
