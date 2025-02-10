# Dart
.PHONY: format

format:
	dart format .

# Publishing
.PHONY: dry_run publish

dry_run:
	dart pub publish --dry-run

publish:
	dart pub publish

# Localization
.PHONY: gen_l10n

gen_l10n:
	flutter gen-l10n
