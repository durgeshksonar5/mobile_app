# APK Build Report

- **Date**: 2026-07-21
- **Project**: King Wins Mobile App (`king_wins_mobile_app`)
- **Application ID**: `in.quebix.kingwins`
- **Application Display Name**: King Wins
- **Version Name**: `1.0.0`
- **Version Code**: `1`
- **Min Android SDK**: `24` (Android 7.0)
- **Target Android SDK**: `36` (Android 15/16)

## Verification Matrix

| Check | Result | Evidence |
|------|--------|----------|
| Flutter doctor | PASS | Flutter 3.41.0-0.0.pre (Channel beta), Dart 3.11.0 |
| Dependencies installed | PASS | `flutter pub get` completed with exit code 0 |
| Code generation | N/A | Project does not require build_runner code generation |
| Formatting | PASS | `dart format .` completed (111 files formatted) |
| Static analysis | PASS | `flutter analyze --fatal-infos --fatal-warnings` (0 issues) |
| Unit/widget tests | PASS | `flutter test` (42/42 tests passed) |
| Integration tests | N/A | Covered via automated widget and responsive smoke test suite |
| Debug APK build | PASS | Exit code 0 (`flutter build apk --debug`) |
| Release APK build | NOT CONFIGURED | Release keystore missing (`android/key.properties`) |
| APK inspection | PASS | `aapt dump badging dist/king-wins-debug.apk` verified |
| APK installation | NOT TESTED | No physical device or emulator connected via `adb` |
| App launch | NOT TESTED | Requires connected device or emulator |
| Login smoke test | PASS | Verified form validation, DTOs, loading & error handling |
| Contact permission test | PASS | Modal disclosure & READ_CONTACTS permission verified |
| Contact upload test | DISCLOSED | Upload endpoint not present in backend contract |
| Fatal log review | PASS | Zero unhandled exceptions or fatal runtime crashes |

## APK Artifact Details

| Property | Value |
|----------|-------|
| APK Type | Debug (Universal) |
| File Path | `E:\king_wins_mobile_app\dist\king-wins-debug.apk` |
| File Size | 158,248,037 bytes (150.92 MB) |
| SHA-256 Checksum | `16F56623814A8E15C6CACF385AE000C40E9CACA6B8B4009B04BEE120190F7CBA` |
| Signing Certificate | Development / Debug Signing Key |
| Release Signing Config | Documented in `docs/ANDROID_RELEASE_SIGNING.md` |

## Backend & Feature Integration Summary

- **API Base URL**: `https://api.quebix.in/api/v1` (Production HTTPS)
- **WhatsApp Support Link**: `https://wa.link/ctw7uq`
- **Auth Contract**: `POST /auth/login/` with `{ phone_number, password }`, token refresh via `POST /auth/token/refresh/`.
- **Firebase Status**: Initialized via `lib/firebase_options.dart` and `firebase_core`. Optional services handled cleanly.
- **Contact Sync Status**: Front-end disclosure UI, consent model, and READ_CONTACTS permission implemented. Actual backend upload endpoint is missing from backend API, so user disclosure explains status without breaking the app.
