# Complete Presentation Layer Audit and Fix Plan

This plan details the systemic sweep across the presentation layer to ensure flawless RTL/LTR support and complete English/Arabic localization.

## User Review Required

- **Hardcoded Data:** Currently, screens like `ProfileScreen`, `OrdersScreen`, and `ParcelsScreen` use hardcoded Arabic mock data (e.g., mock names like 'محمد العتيبي', fake addresses, or static order IDs). I will move these mock strings to the localization files for now so the UI can dynamically switch languages, but eventually, these should come from the API payload. Please confirm if you want mock data localized or if we should leave mock names as is and only localize static UI labels.
- **Language Switcher Logic:** I will add the language toggle specifically to the `ProfileSettingsList`. I will utilize the existing `LocaleCubit` to handle the actual language switching.

## Proposed Changes

### 1. Localization (i18n) Extraction

Extract all remaining hardcoded Arabic strings from the UI screens and move them to our localization infrastructure.

#### [MODIFY] `lang/ar.json` & `lang/en.json`
- Add keys for all hardcoded text found in the UI.
- Provide accurate English translations for `en.json` and keep the Arabic text in `ar.json`.

#### [MODIFY] `lib/core/utils/values/strings.dart`
- Add getters for all the newly extracted localization keys.

#### [MODIFY] All affected UI Files
- Replace hardcoded Arabic text with calls to `Strings.[key]`. This will impact files across `orders`, `parcels`, `profile`, `earnings`, and `subscriptions` features.

### 2. Icon Mirroring

Ensure directional icons automatically flip based on the locale's directionality (LTR for English, RTL for Arabic).

#### [MODIFY] `lib/features/profile/presentation/widgets/profile_settings_list.dart`
- Add `matchTextDirection: true` to `Icons.chevron_left_rounded`.

#### [MODIFY] `lib/features/orders/presentation/screens/order_trip_screen.dart`
- Add `matchTextDirection: true` to `Icons.chevron_right_rounded`.

#### [MODIFY] `lib/core/widgets/back_button.dart` (and any other header files)
- Add `matchTextDirection: true` to back arrows (`Icons.arrow_back` / `Icons.arrow_back_ios_new_outlined`).

### 3. Strict Language Toggle Placement

Ensure the language toggle is exclusively located in the Profile screen settings.

#### [MODIFY] `lib/features/profile/presentation/screens/profile_screen.dart`
- Add the language toggle switch item to the `ProfileSettingsList` widget using `LocaleCubit` to handle the state change between Arabic and English.

#### [VERIFIED] Other Screens
- Verified that no stray language toggles exist in `AuthScaffold`, `HomeScreen`, or AppBars.

### 4. Directional Layouts Verification

- **Status:** I have verified that `Positioned.directional` and `AlignmentDirectional` are largely being used correctly in the newer widgets (like `earnings_hero_card.dart`).
- During the localization pass, I will actively scan and fix any straggler instances of `EdgeInsets.only(left/right)` or `Alignment.centerLeft` if they appear in any of the modified files.

## Verification Plan

- Toggle the language from the Profile screen and verify that all text updates to English.
- Verify that the layout flips perfectly (RTL to LTR).
- Verify that back arrows and chevrons correctly face the opposite direction.
- Verify that `AuthScaffold` and `HomeScreen` remain clean of any language toggles.
