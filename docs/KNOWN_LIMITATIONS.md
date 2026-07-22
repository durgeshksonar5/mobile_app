# Known Limitations Report

1. **Firebase Recaptcha Container:** Web Recaptcha DOM containers (`recaptcha-container`) are replaced by native mobile SMS OTP verification.
2. **iOS Signing:** Building iOS release IPAs requires an active Apple Developer Team signing certificate and Xcode on macOS host.
3. **Web Push VAPID:** Web push service worker subscriptions (`public/sw.js`) are handled natively on mobile via standard push notifications.
