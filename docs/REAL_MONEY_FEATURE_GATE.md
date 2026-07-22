# Real-Money & Financial Operations Feature Gate

- **Floating-point Rule:** All financial calculations in Dart code avoid floating point numbers, using integer rupee values or minor units (`MoneyFormatter.toPaise`).
- **Confirmation Flow:** Deposit and Withdrawal forms require explicit user confirmation before sending request payloads.
- **Verification Gate:** Withdrawal requests require verified IFSC code, Bank name, Account number, UPI ID, and UPI Phone number.
- **Safety Policy:** No real production financial money transfers are executed during automated test runs.
