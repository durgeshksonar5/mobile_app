# Dependency Decisions Rationale

| Package | Purpose | Why Selected over Alternatives |
| --- | --- | --- |
| `flutter_riverpod` | State management & DI | Recommended in Section 14. Provides compile-safe dependency injection without `BuildContext` leaks. |
| `go_router` | Routing & deep linking | Declarative route parameters, guards, and shell navigation matching React Router v7 routes. |
| `dio` | HTTP Networking | Supports interceptors, automatic JWT refresh queue, and request cancellation. |
| `flutter_secure_storage` | Encrypted token storage | Stores JWT tokens securely in Android Keystore / iOS Keychain. |
| `shared_preferences` | Non-sensitive preferences | Caches user profile and offline bids mirror for instant load time. |
| `intl` | Formatting | Indian Currency (`₹`) formatting and date parsing. |
| `lucide_icons` | Vector icons | Exact 1:1 match for `lucide-react` icons used in web frontend. |
