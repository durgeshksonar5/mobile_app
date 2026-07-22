# Folder Structure Guide

```text
king_wins_mobile_app/
├── android/                         # Native Android project configuration
├── ios/                             # Native iOS project structure
├── assets/
│   ├── animations/
│   ├── fonts/
│   ├── icons/
│   └── images/                      # Assets (under_maintance.png, logos)
├── audit/                           # Phase 1 complete audit reports
│   ├── API_ENDPOINT_MATRIX.md
│   ├── AUTHENTICATION_FLOW.md
│   ├── DESIGN_SYSTEM.md
│   ├── DESIGN_TOKENS.json
│   ├── PROJECT_INVENTORY.md
│   ├── ROUTE_SCREEN_MATRIX.md
│   ├── TRACEABILITY_MATRIX.md
│   └── WEB_STACK_REPORT.md
├── docs/                            # Architectural & developer guides
│   ├── API_INTEGRATION_STATUS.md
│   ├── ARCHITECTURE.md
│   ├── ASSET_MIGRATION.md
│   ├── CONFIGURATION.md
│   ├── DEPENDENCY_DECISIONS.md
│   ├── DEVELOPER_GUIDE.md
│   ├── FOLDER_STRUCTURE.md
│   ├── KNOWN_LIMITATIONS.md
│   ├── MOCK_MODE.md
│   ├── REAL_MONEY_FEATURE_GATE.md
│   └── WEB_MOBILE_BEHAVIOR_DIFFERENCES.md
├── lib/
│   ├── main.dart                    # Application entry point
│   ├── bootstrap.dart               # App initialization wrapper
│   ├── app/
│   │   ├── app.dart                 # MaterialApp root setup
│   │   ├── dependency_injection/    # Riverpod provider definitions
│   │   ├── router/                  # GoRouter paths & guards
│   │   └── theme/                   # Gold design system tokens & Material theme
│   ├── core/
│   │   ├── config/                  # App environment constants
│   │   ├── errors/                  # App exceptions & failure models
│   │   ├── network/                 # Dio client & auth refresh interceptor
│   │   ├── storage/                 # Secure storage & preferences
│   │   ├── utils/                   # Panna generator & money formatters
│   │   ├── validation/              # Phone, OTP, password validators
│   │   └── widgets/                 # Reusable loading, empty, marquee widgets
│   └── features/
│       ├── auth/                    # Login, Register, Account Blocked features
│       ├── home/                    # Dashboard, Passbook, My Bids, Funds, Rates, Charts
│       └── play_market/             # Satta Matka betting engine (11 modes)
├── test/
│   ├── unit/                        # Unit tests for validators, panna engine, money
│   └── widget/                      # Widget tests for screens
├── integration_test/                # End-to-end integration test flow
└── pubspec.yaml                     # Dependencies and asset declarations
```
