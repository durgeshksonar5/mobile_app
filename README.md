# King Win Native Flutter Mobile Application

Production-quality native Flutter mobile application reproducing the complete authorized web application (`king_wins_app_frontend-main`) visual design, color palette, typography, navigation, API integrations, and business functionality.

## Features

- **Design Parity:** Gold brand palette (`#D3A745`), dark modes, custom marquee announcement ticker, action buttons grid, responsive cards.
- **Full Route Hierarchy:** Login, Register (Two-Step SMS OTP), Account Blocked Notice, Home Live Markets, Passbook, My Bids, Funds, Game Rates, Charts, Settings.
- **Satta Matka Betting Engine (11 Modes):** Single, Jodi, Single Panna, Double Panna, Triple Panna, SP Motor, DP Motor, SP DP TP, Family Panel, Half Sangam, Full Sangam.
- **API Networking:** Dio HTTP client with JWT Bearer token interceptor, automatic token refresh queue, and offline fallback caching.
- **State Management:** Riverpod feature-first MVVM architecture.

---

## Setup & Running

```bash
# Get dependencies
flutter pub get

# Run static code analysis
flutter analyze

# Run unit and widget tests
flutter test

# Run application locally
flutter run

# Build Android Debug APK
flutter build apk --debug
```
