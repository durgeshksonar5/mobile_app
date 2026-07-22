# Developer Setup & Operating Guide

## Prerequisites

1. **Flutter SDK:** Version `^3.41.0` (or stable 3.20+)
2. **Dart SDK:** Version `^3.11.0`
3. **Android Studio / SDK:** Android SDK Platform 34+ and build tools
4. **Git**

---

## Quick Start Commands

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static code analysis
flutter analyze

# 3. Execute unit & widget automated tests
flutter test

# 4. Launch development build on Android emulator or Windows target
flutter run --dart-define=APP_ENV=development --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# 5. Build debug APK
flutter build apk --debug
```

---

## Development Standards

- **State Management:** Always use `flutter_riverpod`.
- **Navigation:** Use `GoRouter` paths from `RoutePaths`.
- **API Requests:** Always place HTTP calls inside Services/Repositories, never in Widget build methods.
- **Formatting:** Run `dart format .` before committing changes.
