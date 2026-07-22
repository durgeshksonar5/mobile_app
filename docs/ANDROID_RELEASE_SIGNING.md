# Android Release Signing Instructions

This document explains the required keystore and configuration needed to generate a production signed release APK (`dist/king-wins-release.apk`) for King Wins.

## 1. Keystore Creation

To generate a production signing key, execute the following command:

```bash
keytool -genkey -v -keystore android/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

## 2. Environment / Configuration Setup

Create an `android/key.properties` file containing:

```properties
storePassword=<YOUR_KEYSTORE_PASSWORD>
keyPassword=<YOUR_KEY_PASSWORD>
keyAlias=upload
storeFile=../upload-keystore.jks
```

> **IMPORTANT**: Never commit `key.properties` or `*.jks` keystores to Git. These paths are ignored in `.gitignore`.

## 3. Gradle Signing Configuration

In `android/app/build.gradle.kts`, load `key.properties` and add to `signingConfigs`:

```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

## 4. Build Command

Once release signing is configured:

```bash
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL=https://api.quebix.in/api/v1 \
  --dart-define=WHATSAPP_LINK=https://wa.link/ctw7uq
```
