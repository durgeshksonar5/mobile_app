# Authentication & Token Refresh Flow

## 1. Authentication Mechanisms

The web application supports two primary login paths:
1. **Direct Phone + Password Login:**
   - User inputs 10-digit phone number and password.
   - Phone is normalized with country code `+91` if 10 digits.
   - API `POST /auth/login/` returns JWT `access` & `refresh` tokens and `user` profile.
   - Tokens stored in `localStorage` under `access_token`, `refresh_token`, `auth_user`.

2. **Firebase Phone SMS OTP Registration:**
   - Step 1: User enters Name, Phone number, and Password.
   - Recaptcha verifier generates Firebase SMS OTP confirmation.
   - Step 2: User enters 6-digit OTP code.
   - Firebase verifies OTP and returns Firebase `idToken`.
   - Frontend calls `POST /auth/firebase-login/` passing `idToken`, `name`, `password`, `is_register: true`.
   - Backend exchanges Firebase token for King Win JWT session.

---

## 2. JWT Interceptor & Refresh Queue

- **Request Interceptor:** Attaches `Authorization: Bearer <access_token>` header to all outgoing requests.
- **Response Interceptor:**
  - Auto-unpacks Django REST Framework response envelopes (`response.data.results` or `response.data.data` -> `response.data`).
  - Catches `401 Unauthorized`.
  - If a refresh request is already pending, queues parallel requests in `failedQueue`.
  - Sends `POST /auth/token/refresh/` with `refresh_token`.
  - On success: updates `access_token` in secure storage and retries queued requests.
  - On failure or missing refresh token: clears tokens, triggers session expiry listener, and redirects user to `/login`.
