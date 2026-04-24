# Phase 2 Pre-step: Rename "Number Tag" Labels to "Item Tag" (iOS Paid)

**Repo:** `~/pg/iphone/NativeAppTemplate`
**Branch:** `main` only (NOT `v1-with-nfc`)
**Goal:** Align UI labels with the `ItemTag` identifier, so the agent's humanize-based string-literal rename logic (Phase 6) can rewrite them consistently alongside the identifier.

## Context

The Rails API substrate (Phase 1) renamed `queue_number` → `name` at the data layer. The iOS client still shows "Number Tag" and "Tag Number" labels in its UI, which do not align with the `ItemTag` identifier. For the agent to rename UI strings automatically by applying humanize/pluralize rules to the identifier, the UI label must match:

- Identifier: `ItemTag` → humanized: `"Item Tag"` (singular) / `"Item Tags"` (plural)
- Identifier: `itemTag.name` → UI label: `"Name"`

## Scope

**In scope** (rename in this commit):
- Generic "Number Tag" labels that describe the ItemTag entity itself
- The field label "Tag Number" that corresponds to `itemTag.name`

**Out of scope** (keep as-is; will be deleted in Phase 2 Part A alongside NFC/scan removal):
- Queue-flow specific messages ("Swipe a number tag below", "Server Number Tags Webpage", etc.)
- Onboarding descriptions explaining the queue flow
- Scan-related strings ("Read a NFC Number Tag...")
- Reset-related strings ("Reset Number Tags", "All number tags reset")

The rationale: queue-specific strings will be removed entirely when the corresponding NFC/scan/reset code is deleted in Phase 2. Renaming them now would be churn.

## v1-with-nfc branch

**Do NOT modify.** The `v1-with-nfc` branch is preserved as an immutable queue-template snapshot for potential future use. Queue-specific "Number Tag" labels are semantically correct in that context.

---

## Execution Steps

### Step 1: Baseline check

```bash
cd ~/pg/iphone/NativeAppTemplate

# Confirm on main and clean
git branch --show-current
git status

# Confirm baseline build is green
xcodebuild build -scheme NativeAppTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' 2>&1 | tail -3
```

Expected: `** BUILD SUCCEEDED **`

### Step 2: Pre-check grep

Find all occurrences of "Number Tag" labels and the `tagNumber*` identifiers in the codebase (NOT just Constants.swift). This reveals if any Swift file uses these strings directly, bypassing the Constants.swift pattern.

```bash
# Swift files using "Number Tag" as string literal
grep -rn "Number Tag" --include="*.swift" . | grep -v "\.build\|DerivedData"

# Swift files using "Tag Number" or "tag number" as string literal
grep -rn "Tag Number\|tag number" --include="*.swift" . | grep -v "\.build\|DerivedData"

# Identifier usage
grep -rn "shopSettingsManageNumberTagsLabel\|tagNumber\b\|addTagDescription\b\|tagNumberIsInvalid\b" \
  --include="*.swift" . | grep -v "\.build\|DerivedData"
```

Save the output for reference. The rename in later steps must cover every match from these greps (except those in out-of-scope Constants.swift entries).

### Step 3: Edit Constants.swift (Category B — in-scope labels only)

In `NativeAppTemplate/Constants.swift`, apply these exact changes:

**Line 176** (identifier + value):
```swift
// BEFORE
static let shopSettingsManageNumberTagsLabel = "Manage Number Tags"

// AFTER
static let shopSettingsManageItemTagsLabel = "Manage Item Tags"
```

**Line 188** (value only — identifier stays as `tagNumber` for now to minimize churn; will be reconsidered if needed):
```swift
// BEFORE
static let tagNumber = "Tag Number"

// AFTER — value only changes; identifier may be updated if it doesn't break too many references
static let tagNumber = "Name"
```

**Note on line 188 identifier**: Renaming the identifier `tagNumber` → something else (e.g. `itemTagName`) would cascade into many files. Keeping the identifier and changing only the displayed string is safer for this small commit. The identifier rename can be tackled as a follow-up commit or during Phase 2 Part A's ItemTag refactor. Document this decision as a comment or in the commit message.

**Line 191** (value only):
```swift
// BEFORE
static let addTagDescription = "Add a new number tag and start changing the tag status."

// AFTER
static let addTagDescription = "Add a new item tag and start changing the tag status."
```

**Line 194** (value only):
```swift
// BEFORE
static let tagNumberIsInvalid = "Tag number is invalid."

// AFTER
static let tagNumberIsInvalid = "Item tag name is invalid."
```

**Do NOT change these** (Category A — out of scope, will be deleted in Phase 2):
- Line 166: `swipeNumberTagBelow`
- Line 168: `serverNumberTagsWebpageWillBeUpdated`
- Line 170: `serverNumberTagsWebpage`
- Line 177: `shopSettingsNumberTagsWebpageLabel`
- Line 178: `resetNumberTagsDescription`
- Line 179: `resetNumberTags`
- Line 181: `// MARK: Number Tags Web Pages` (comment — delete with section in Phase 2)
- Line 209: `completeScanHelp`
- Line 210: `showTagInfoScanHelp`
- Line 296: `shopReset`
- Line 297: `shopResetError`
- Line 396, 403, 404, 406: `onboardingDescription*` (queue flow)

### Step 4: Update callers of `shopSettingsManageNumberTagsLabel`

Since this identifier changed, all callers need updating. Grep and replace:

```bash
grep -rn "shopSettingsManageNumberTagsLabel" --include="*.swift" . | grep -v "\.build\|DerivedData"
```

For each match, replace `shopSettingsManageNumberTagsLabel` with `shopSettingsManageItemTagsLabel`.

Typical places to check:
- `NativeAppTemplate/UI/Shop Settings/` (multiple Swift files likely reference this)
- Any test files under `NativeAppTemplateTests/UI/Shop Settings/`

### Step 5: Verify no other "Number Tag" or "Tag Number" direct literals in scope

```bash
# Any Swift file still contains "Number Tag" outside of Constants.swift's intentional kept strings
grep -rn "Number Tag" --include="*.swift" . | grep -v "\.build\|DerivedData" | grep -v "Constants.swift"

# Any Swift file still contains "Tag Number" as a literal
grep -rn "Tag Number" --include="*.swift" . | grep -v "\.build\|DerivedData"
```

If matches are found, evaluate each:
- If the context is queue-specific (scan flow, reset flow, NFC) → leave it (out of scope)
- If the context is generic (ItemTag management) → update to "Item Tag" or "Name"

### Step 6: Build green

```bash
xcodebuild build -scheme NativeAppTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' 2>&1 | tail -10
```

Expected: `** BUILD SUCCEEDED **`

If build fails, most likely cause is an unresolved reference to the renamed identifier. Re-run Step 4's grep and fix missed callers.

### Step 7: Test green

```bash
xcodebuild test -scheme NativeAppTemplate \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' 2>&1 | tail -20
```

Expected: all tests pass. If any test asserts the old string values (e.g. `#expect(label == "Manage Number Tags")`), update the test to assert `"Manage Item Tags"`.

### Step 8: Commit

```bash
git add -A
git diff --cached --stat   # Verify scope is what you expect
git commit -m "Rename Number Tag labels to Item Tag for identifier alignment

- 'Manage Number Tags' → 'Manage Item Tags'
- 'Tag Number' → 'Name' (aligns with ItemTag.name field after Phase 1 API refactor)
- 'Add a new number tag...' → 'Add a new item tag...'
- 'Tag number is invalid.' → 'Item tag name is invalid.'
- Identifier: shopSettingsManageNumberTagsLabel → shopSettingsManageItemTagsLabel

Queue-specific strings (swipeNumberTagBelow, serverNumberTagsWebpage*,
resetNumberTags*, onboardingDescription*) are intentionally kept for now;
they will be deleted alongside NFC/scan/reset code in Phase 2 Part A."
```

### Step 9: create PR

create PR

### Step 10: Verify v1-with-nfc is untouched

```bash
git log v1-with-nfc --oneline -3
```

The v1-with-nfc branch should NOT have this rename commit. Confirmed by the output showing only the original queue-template commits.

---

## Completion Checklist

- [ ] Baseline build was green before changes
- [ ] Constants.swift: 4 values updated, 1 identifier renamed
- [ ] All callers of `shopSettingsManageNumberTagsLabel` updated to new name
- [ ] `grep -rn "Number Tag" --include="*.swift"` in main app code returns only out-of-scope Constants entries
- [ ] `grep -rn "Tag Number" --include="*.swift"` returns only the `tagNumber` identifier (not string literals)
- [ ] Build green after changes (`** BUILD SUCCEEDED **`)
- [ ] Tests green
- [ ] 1 commit to `main` with descriptive message
- [ ] Pushed to `origin/main`
- [ ] `v1-with-nfc` branch unchanged

---

## Common Pitfalls

### 1. Forgetting to update test fixtures

If any test file hard-codes `"Manage Number Tags"` as an expected label, the test will fail after the Constants value change. Update these to `"Manage Item Tags"`.

### 2. String catalog (.xcstrings) files

The audit showed no `.xcstrings` or `Localizable.strings` files in this repo — strings are directly in Constants.swift. If these are discovered during grep (e.g., in build artifacts), ignore them.

### 3. Identifier rename cascades

The Swift compiler will catch missed references immediately via build errors. If build fails after Step 4, read the error location and update that caller. Do not revert the change — fix forward.

### 4. Commit message length

The commit message above is descriptive. Feel free to shorten if preferred — but keeping the "Queue-specific strings kept for Phase 2" note helps future readers understand why some "Number Tag" strings remain.

### 5. Accidentally changing v1-with-nfc

If at any point you're unsure which branch you're on, run `git branch --show-current`. All work for this checklist must happen on `main`. Never run `git push origin v1-with-nfc` during this work.

---

## After this Pre-step

Proceed to Phase 2 Part A (to be written after this is merged):
- Delete NFCManager.swift, QRCodeGenerator.swift, ScanView, ScanViewModel
- Refactor ItemTag model (remove queueNumber, scanState, customerReadAt, alreadyCompleted; add description, position)
- Remove NFC entries from Info.plist and entitlements
- Remove queue-specific Constants entries (the Category A ones kept in this pre-step)
- Update ItemTag UI to use new schema
