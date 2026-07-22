# Firebase Configuration & Security Protocol

## 1. Overview
Firebase is utilized exclusively for **Firebase Phone SMS Authentication** (`firebase_auth`). Client configuration values are loaded via `DefaultFirebaseOptions.currentPlatform` in `lib/firebase_options.dart`.

---

## 2. Security Requirements Compliance

- **No Secret Key Storage:** Firebase API Keys in `DefaultFirebaseOptions` are treated as public client identifiers. Backend API authentication relies exclusively on JWT bearer tokens issued by the Django REST API (`/api/v1/auth/login/` or `/api/v1/auth/firebase-login/`).
- **No FCM Server Keys or Admin Credentials:** No Firebase Admin SDK JSON credentials, private keys, or FCM server keys are embedded in the Flutter client code.
- **Token Logging Restriction:** Firebase ID tokens and phone SMS verification codes are never logged to console, disk, or analytics.
- **No Contact Data Leaks:** Address book contacts are never transmitted to Firebase Analytics or Crashlytics.
