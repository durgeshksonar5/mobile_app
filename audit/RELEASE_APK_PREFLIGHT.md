# Release APK Preflight Report
Generated: 2026-07-25T20:10 IST

## Flutter Environment
- Flutter: 3.41.0-0.0.pre (beta channel)
- Dart: 3.11.0-296.3.beta
- DevTools: 2.54.0
- Flutter path: C:\flutter

## Java
- Java 21.0.10 (OpenJDK, Android Studio bundled JBR)

## Android SDK
- SDK path: C:\Users\Hp\AppData\Local\Android\sdk
- Platform: android-36.1
- Build tools: 36.1.0-2, 35.0.0-2, 37.0.0

## NDK
- NDK: 28.2.13676358 (configured in build.gradle.kts)

## Connected Device
- ADB available at: C:\Users\Hp\AppData\Local\Android\Sdk\platform-tools\adb.exe
- Device status: No physical device connected at time of installation test
  (flutter doctor showed 3 virtual devices: Windows, Chrome, Edge)

## Git Status
- Branch: main (up to date with origin/main)
- Modified files:
  - lib/features/auth/presentation/view_models/auth_view_model.dart
  - lib/features/home/presentation/screens/home_screen.dart
  - lib/features/home/presentation/widgets/add_fund_dialog.dart
  - lib/features/home/presentation/widgets/withdraw_dialog.dart
- Untracked: test/widget/responsive_smoke_test.dart

## Disk Space
- Project drive: E:\ (sufficient for build)

## Blockers Found
- `integration_test` plugin registered in GeneratedPluginRegistrant.java but
  package was not in release dependencies → removed stale registration line.
- R8 minification: Flutter beta 3.41.0's new Gradle plugin architecture
  controls minification internally. The `isMinifyEnabled = true` setting in
  build.gradle.kts is respected but the Flutter plugin's own AOT compilation
  pipeline produces the binary. Final APK size: 55.3MB (release-signed).
