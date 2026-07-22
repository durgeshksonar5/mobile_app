# Contact Consent & Onboarding Flow Protocol

```
[Successful Authentication] ──► [Home Dashboard Rendered]
                                        │
                                        ▼
                           [Check User Consent Record]
                                        │
                         ┌──────────────┴──────────────┐
                         ▼                             ▼
                 (Already Decided)              (Not Asked)
                         │                             │
                 [Skip Disclosure]          [Show Custom Disclosure]
                                            "Sync your contacts?"
                                                       │
                                        ┌──────────────┴──────────────┐
                                        ▼                             ▼
                                   [Tap Not Now]               [Tap Continue]
                                        │                             │
                              [Save Status: Declined]     [Request OS Permission]
                                        │                             │
                              [Normal App Access]         ┌───────────┴───────────┐
                                                          ▼                       ▼
                                                     (Granted)             (Denied)
                                                         │                        │
                                                 [Review Screen]        [Show Card / Settings]
                                                         │
                                                 [Confirm & Upload]
```
