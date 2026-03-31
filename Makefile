.PHONY: lint format

lint:
	swiftlint lint --strict NativeAppTemplate
	swiftformat --lint NativeAppTemplate

format:
	swiftformat NativeAppTemplate
