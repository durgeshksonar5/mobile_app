# Firebase Product Audit & Usage Report

## Audit Summary

An audit of the web frontend source code (`king_wins_app_frontend-main/src/firebase.ts`) was performed to identify confirmed Firebase dependencies.

| Firebase Product | Status in Source | Mobile Implementation |
| --- | --- | --- |
| **Firebase Authentication** | **CONFIRMED** | SMS OTP verification for registration & login |
| **Cloud Messaging (FCM)** | NOT USED | Web push handled via VAPID service worker |
| **Cloud Firestore** | NOT USED | Excluded from pubspec.yaml |
| **Realtime Database** | NOT USED | Excluded from pubspec.yaml |
| **Firebase Storage** | NOT USED | Excluded from pubspec.yaml |
| **Remote Config** | NOT USED | Excluded from pubspec.yaml |
| **Firebase Crashlytics** | NOT USED | Excluded from pubspec.yaml |
