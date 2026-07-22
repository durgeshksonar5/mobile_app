# Authentication Token Lifecycle & Security Report

## 1. Storage & Encryption
- **Access Token (`access`):** Encrypted in `FlutterSecureStorage` (Android Keystore / iOS Keychain).
- **Refresh Token (`refresh`):** Encrypted in `FlutterSecureStorage`.
- **Password Security:** Passwords are never saved in local storage, preferences, or logs.

---

## 2. Interceptor & Refresh Flow

```
[HTTP Request] ──► Attach `Authorization: Bearer <access_token>`
                        │
                        ▼
                 [Backend Server]
                        │
                  (401 Unauthorized)
                        │
                        ▼
         [AuthInterceptor Queue Locks]
                        │
                        ▼
          [POST /auth/token/refresh/]
             { "refresh": "<token>" }
                        │
             ┌──────────┴──────────┐
             ▼                     ▼
     (200 OK Token)        (401 / Invalid Refresh)
             │                     │
   [Update Storage]         [Clear Storage]
             │                     │
   [Retry Failed Queue]     [Session Expired Guard]
```
