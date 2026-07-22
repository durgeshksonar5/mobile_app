# Discovered Login API Contract Matrix

| Item | Discovered Value | Source File | Evidence | Flutter Mapping |
|---|---|---|---|---|
| **Login endpoint** | `/auth/login/` | `src/api/auth.api.ts:9` | `api.post('/auth/login/', credentials)` | `AuthApiService.login` |
| **HTTP method** | `POST` | `src/api/auth.api.ts:10` | `api.post('/auth/login/', credentials)` | `POST` request via Dio |
| **Phone field** | `phone_number` | `src/api/auth.api.ts:9` | `{ phone_number: string; password: string }` | `LoginRequestDto.phoneNumber` |
| **Password field** | `password` | `src/api/auth.api.ts:9` | `{ phone_number: string; password: string }` | `LoginRequestDto.password` |
| **Access Token field** | `access` | `src/api/axios.ts:111` | `const { access, refresh } = response.data` | `LoginResponseDto.access` |
| **Refresh Token field** | `refresh` | `src/api/axios.ts:111` | `const { access, refresh } = response.data` | `LoginResponseDto.refresh` |
| **Refresh endpoint** | `/auth/token/refresh/` | `src/api/axios.ts:110` | `axios.post('/auth/token/refresh/', { refresh })` | `AuthApiService.refreshToken` |
| **User profile endpoint** | `/auth/me/` | `src/api/auth.api.ts:15` | `api.get('/auth/me/')` | `AuthApiService.getProfile` |
| **Logout endpoint** | `/auth/logout/` | `src/api/auth.api.ts:25` | `api.post('/auth/logout/', { refresh })` | `AuthApiService.logout` |
| **Firebase Login endpoint** | `/auth/firebase-login/` | `src/api/auth.api.ts:5` | `api.post('/auth/firebase-login/', data)` | `AuthApiService.firebaseLogin` |
