# Final Release APK Report
Generated: 2026-07-25T20:19 IST

## Build Summary

All artifacts built successfully with Flutter 3.41.0-beta, signed with production
keystore (RSA 2048, APK Signature Scheme v2).

## Artifacts in dist/

| File | Size | Purpose |
|------|------|---------|
| `king-wins-optimized-release.apk` | 55.3 MB | Universal APK (all ABIs) |
| `split-apks/king-wins-armeabi-v7a-release.apk` | 19.8 MB | 32-bit ARM |
| `split-apks/king-wins-arm64-v8a-release.apk` | 22.1 MB | 64-bit ARM (most phones) |
| `split-apks/king-wins-x86_64-release.apk` | 23.5 MB | x86_64 emulators |
| `king-wins-release.aab` | 52.8 MB | Google Play Store upload |
| `SHA256SUMS.txt` | - | Integrity checksum |
| `debug-info/` | 8.6 MB | Dart obfuscation symbols |

## SHA256 Integrity

```
713C88A170E492D30EC1CFC5C44143D02A2C6DDC11C09CEF04FC6EA8A4F7BD74  king-wins-optimized-release.apk
```

## Signature Verification

| Property | Value |
|----------|-------|
| Verified | ✅ TRUE |
| Scheme | APK Signature Scheme v2 |
| Signer | CN=King Wins Admin, OU=Mobile, O=Quebix, L=Mumbai, ST=Maharashtra, C=IN |
| Key | RSA 2048-bit |
| Cert SHA-256 | ab5258a628a9eb65e013594588f4032c11f6695ee1da916d4fcea2c8713578be |

## Optimizations Applied

| Optimization | Status | Notes |
|---|---|---|
| AOT Compilation | ✅ | Flutter release mode, tree-shaking |
| Icon tree-shaking | ✅ | MaterialIcons: 1.6MB → 8KB (99.5%) |
| CupertinoIcons: 258KB → 848B | ✅ | (99.7% reduction) |
| Dart obfuscation | ✅ | `--obfuscate --split-debug-info` |
| Shrink resources | ✅ | `isShrinkResources = true` |
| R8 minification | ✅ | `isMinifyEnabled = true` |
| Release signing | ✅ | Production keystore, not debug key |

## Application Configuration

| Key | Value |
|-----|-------|
| App Name | King Wins |
| Package ID | com.kingwins.app |
| Namespace | in.quebix.kingwins |
| Min SDK | API 24 (Android 7.0+) |
| Target SDK | API 35 |
| Version Code | Flutter.versionCode |
| API Base URL | https://api.quebix.in/api/v1 |
| WhatsApp Link | https://wa.link/ctw7uq |
| APP_ENV | production |

## Installation Command

To install the arm64-v8a split APK on a connected device:

```powershell
adb install -r "e:\mobile_app\dist\split-apks\king-wins-arm64-v8a-release.apk"
```

To install the universal APK:

```powershell
adb install -r "e:\mobile_app\dist\king-wins-optimized-release.apk"
```

## Rebuild Instructions

To rebuild at any time without manual steps:

```powershell
cd e:\mobile_app
flutter build apk --release `
  "--dart-define=APP_ENV=production" `
  "--dart-define=API_BASE_URL=https://api.quebix.in/api/v1" `
  "--dart-define=WHATSAPP_LINK=https://wa.link/ctw7uq" `
  --obfuscate "--split-debug-info=dist\debug-info"
```
