# Flutter Play Store Split Compat rules
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**

# Flutter engine keep rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Keep data models and JSON DTOs
-keep class king_wins_mobile_app.features.**.models.** { *; }
-keep class king_wins_mobile_app.features.**.dto.** { *; }
-keep class king_wins_mobile_app.features.**.entities.** { *; }

# Firebase & Push Notifications
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Serialization & Annotations
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Native plugins
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }
-keep class co.quis.flutter_contacts.** { *; }
