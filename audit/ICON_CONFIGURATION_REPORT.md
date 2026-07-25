# Icon Configuration Report
## King Wins Flutter Mobile App — Pre-Implementation Audit

**Date:** 2026-07-25
**Project:** e:\mobile_app (king_wins_mobile_app)

---

## 1. Official Source Logo

| Field | Value |
|---|---|
| **Path** | assets/images/king-win-logo-transferent-crop.png |
| **Size** | 1,198,143 bytes (1.14 MB) |
| **Format** | PNG, RGBA (transparent background) |
| **Content** | Gold crown, black shield, Ace playing cards fan, KING WINS text |

---

## 2. Launcher Icons — Pre-Implementation State

| Density | File | Old Size | Status |
|---|---|---|---|
| mipmap-mdpi | ic_launcher.png | 442 bytes | DEFAULT Flutter logo |
| mipmap-hdpi | ic_launcher.png | 544 bytes | DEFAULT Flutter logo |
| mipmap-xhdpi | ic_launcher.png | 721 bytes | DEFAULT Flutter logo |
| mipmap-xxhdpi | ic_launcher.png | 1031 bytes | DEFAULT Flutter logo |
| mipmap-xxxhdpi | ic_launcher.png | 1443 bytes | DEFAULT Flutter logo |
| mipmap-anydpi-v26/ | — | N/A | DID NOT EXIST |

flutter_launcher_icons installed: NO
flutter_launcher_icons configured: NO

---

## 3. Notification Icon — Pre-Implementation State

| Resource | Status |
|---|---|
| drawable/ic_stat_king_wins.xml | DID NOT EXIST |
| drawable/king_wins_notification_large.png | DID NOT EXIST |

---

## 4. AndroidManifest.xml — Pre-Implementation

- android:icon present: YES (@mipmap/ic_launcher, wrong content)
- android:roundIcon: MISSING
- POST_NOTIFICATIONS permission: MISSING
- FCM default_notification_icon: MISSING
- FCM default_notification_color: MISSING

---

## 5. Notification Stack

| Plugin | Status |
|---|---|
| firebase_messaging | PRESENT (v15.2.10) |
| flutter_local_notifications | NOT USED |
| AndroidNotificationDetails | NOT USED |

Notification architecture: Pure FCM — display handled natively by Android.
The FCM manifest metadata is the only control point for the default notification icon.

---

## 6. Hard-Coded Icon References in Source Code

| File | Reference | Type |
|---|---|---|
| AndroidManifest.xml line 7 | @mipmap/ic_launcher | App launcher (correct ref, wrong content) |

No other hard-coded icon references found in Dart source.
