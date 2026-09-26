plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "ng.devstrike.one.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "ng.devstrike.one"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        resValues = true
    }

    // Flavours mirror config/<flavour>.json at the workspace root. Build with
    // `flutter build apk --flavor staging --dart-define-from-file=../../config/staging.json`.
    // Each flavour has its own application id and OIDC redirect scheme so
    // staging and production can be installed side by side.
    flavorDimensions += "environment"
    productFlavors {
        create("staging") {
            dimension = "environment"
            applicationIdSuffix = ".staging"
            resValue("string", "app_name", "One Staging")
            manifestPlaceholders["appAuthRedirectScheme"] = "ng.devstrike.one.staging"
        }
        create("production") {
            dimension = "environment"
            resValue("string", "app_name", "One")
            manifestPlaceholders["appAuthRedirectScheme"] = "ng.devstrike.one"
        }
    }

    buildTypes {
        release {
            // No upload key yet: release builds are signed with the debug key
            // until the Play upload key is provisioned (README, open items).
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
