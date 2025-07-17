plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.mashrou3i_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        // 🚀 غير هذين السطرين ليصبحا Java 8
        sourceCompatibility = JavaVersion.VERSION_1_8 // <--- غير هذا السطر
        targetCompatibility = JavaVersion.VERSION_1_8 // <--- غير هذا السطر
        // 🚀 أضف هذا السطر لتفعيل Core Library Desugaring
        isCoreLibraryDesugaringEnabled = true // <--- أضف هذا السطر
    }

    kotlinOptions {
        // 🚀 غير هذا السطر ليصبح "1.8" ليتوافق مع Java 8
        jvmTarget = "1.8" // <--- غير هذا السطر
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.mashrou3i_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// 🚀 أضف هذا الـ Block الجديد في نهاية الملف بعد block الـ "flutter"
dependencies {
    // 🚀 أضف هذه المكتبة لتفعيل Desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") // <--- أضف هذا السطر
}