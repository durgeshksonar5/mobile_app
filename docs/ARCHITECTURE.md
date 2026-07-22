# Architecture & System Design Document

## 1. Overview
The **King Win Native Mobile Application** is built using Flutter and Dart targeting Android and iOS architectures. It reproduces the exact visual system, state management, route matrix, API integrations, and business functionality of the web frontend (`king_wins_app_frontend-main`).

---

## 2. Architectural Pattern: Feature-First MVVM

The project is structured according to **Feature-First Model-View-ViewModel (MVVM)**:

- **Views (Presentation / Screens & Widgets):** Pure UI widgets responsible for rendering state, handling gesture interactions, and firing view model commands.
- **View Models (Controllers / StateNotifier):** Encapsulate UI state logic, form validation, and reactive updates using Flutter Riverpod.
- **Repositories (Data Layer):** Act as single sources of truth. Merge API responses with local persistent storage (`SharedPreferences` & `FlutterSecureStorage`).
- **Services (Network & Storage Layer):** Low-level HTTP requests using `Dio` and encrypted token storage.

---

## 3. State & Dependency Injection Graph

```
[UI Widgets / Screens]
       │ (watch / read)
       ▼
[StateNotifierProvider / ViewModels]
       │
       ▼
[Repositories]
       │
       ├──► [Services (Dio API Client)] ──► Django REST API
       └──► [Storage Services] ──────────► Secure Storage & Preferences
```

---

## 4. Key Architectural Guarantees

1. **No Floating Point Money Errors:** Financial amounts are represented in integer minor units (paise) or integer rupee values.
2. **Zero WebView Usage:** Rebuilt 100% natively using Flutter widgets.
3. **Sound Null Safety:** Strict null checking enabled throughout the codebase.
4. **Offline Resilience:** Local storage fallbacks ensure user balance, profile, and bid records remain accessible even during network drops.
