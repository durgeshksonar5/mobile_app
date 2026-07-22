# Backend API Contracts & Requirements

The Flutter mobile application expects a Django REST Framework backend service running at `API_BASE_URL` with the following contracts:

1. `POST /api/v1/auth/login/` -> Accepts `{ phone_number: "+91...", password: "..." }`. Returns `{ access: "...", refresh: "...", user: {...} }`.
2. `POST /api/v1/auth/firebase-login/` -> Accepts `{ id_token: "...", name?: "...", password?: "...", is_register: true }`.
3. `GET /api/v1/results/live/` -> Returns array of live Satta Market objects.
4. `POST /api/v1/bets/` -> Accepts `{ market_name: "...", game_type: "...", session: "OPEN", selected_number: "...", amount: 100 }`.
5. `POST /api/v1/deposit-requests/` -> Accepts `{ amount: 500 }`.
6. `POST /api/v1/withdraw-requests/` -> Accepts `{ amount: 500 }`.
