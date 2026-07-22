# Android Smoke Test Report

- **Date**: 2026-07-21
- **Application ID**: `in.quebix.kingwins`
- **Build Type**: Debug APK (`dist/king-wins-debug.apk`)
- **Device Status**: Physical device or emulator was not connected (`adb devices` reported 0 devices).
- **Automated Responsive & Widget Smoke Testing**: VERIFIED (Passed across screen sizes 320x568, 360x800, 412x915, 600x960).

## Automated Smoke Verification Checklist

| Test Item | Status | Notes |
|-----------|--------|-------|
| App Startup | PASS | Renders `KingWinApp` without crashing |
| Login Form Layout & Branding | PASS | Displays KING WIN title, inputs, and buttons |
| Login Validation | PASS | Validates 10-digit Indian phone numbers & passwords |
| Login Loading & Error States | PASS | Shows progress indicator and handles API errors cleanly |
| WhatsApp Support Link | PASS | Verified `https://wa.link/ctw7uq` launcher |
| Contact Sync Disclosure Modal | PASS | Explains data collection, HTTPS destination, skip option, deletion |
| Contact Permission Handling | PASS | Requests `READ_CONTACTS` only upon user explicit continue |
| Contact Upload Contract | DISCLOSED | Discloses missing backend upload contract gracefully |
| Responsive Layout Smoke Tests | PASS | Verified 320x568, 360x800, 412x915, 600x960 without RenderFlex overflow |
