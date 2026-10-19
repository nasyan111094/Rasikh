import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.rasikh.rasikh_smart"
    compileSdk = 36
    // NDK r28+: required for 16 KB page-size support (Play requirement).
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rasikh.rasikh_smart"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        // Play requires targetSdk 36+ for updates.
        targetSdk = 36
        // Version comes from pubspec.yaml (flutter.versionCode/versionName).
        // Keep them in sync there for every Play Store release.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Release keystore is used only when android/key.properties exists
        // with all keys; otherwise the build falls back to debug keys so it
        // doesn't crash at configuration time.
        if (keystorePropertiesFile.exists() &&
            keystoreProperties["storeFile"] != null &&
            keystoreProperties["keyAlias"] != null &&
            keystoreProperties["keyPassword"] != null &&
            keystoreProperties["storePassword"] != null
        ) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = keystoreProperties["storeFile"]?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    buildTypes {
        release {
            signingConfig = if (keystorePropertiesFile.exists() &&
                signingConfigs.findByName("release") != null
            ) {
                signingConfigs.getByName("release")
            } else {
                // TODO: Add your own signing config for the release build.
                // Signing with the debug keys for now,
                // so `flutter run --release` works.
                signingConfigs.getByName("debug")
            }
        }
    }
}

flutter {
    source = "../.."
}
