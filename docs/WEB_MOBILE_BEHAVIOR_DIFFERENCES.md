# Web vs. Mobile Behavior Differences

| Web Feature | Mobile Equivalent | Rationale & User Experience |
| --- | --- | --- |
| Browser hover state | Active touch scale feedback (`active:scale-[0.99]`) | Mobile touchscreens do not have cursor hover states. Touch feedback uses subtle press scaling. |
| Desktop drawer toggle | Slide-out Drawer widget (`Scaffold.drawer`) | Native drawer pattern suitable for mobile screens. |
| Web Recaptcha container | Firebase Phone Auth SMS / Native Verification | Native Android/iOS native SMS verification flows. |
| Browser alert popups | Material `SnackBar` and `Dialog` modals | Provides cleaner, native mobile feedback toasts instead of blocking browser popups. |
| Fixed max-w-md container | Responsive `ConstrainedBox` & `SafeArea` | Fluid expansion on foldables and tablets while enforcing centered readability on large devices. |
