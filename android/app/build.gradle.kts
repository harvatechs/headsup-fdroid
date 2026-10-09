plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.kora.headsup"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    flavorDimensions += "distribution"

    productFlavors {
        create("foss") {
            dimension = "distribution"
            applicationId = "com.kora.headsup"
            manifestPlaceholders["appLabel"] = "Heads Up"
        }
        create("play") {
            dimension = "distribution"
            applicationId = "com.kora.headsup"
            manifestPlaceholders["appLabel"] = "Heads Up"
        }
    }

    defaultConfig {
        applicationId = "com.kora.headsup"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Apply Google Services plugin only for Play flavor or when not building FOSS
val isFossBuild = gradle.startParameter.taskNames.any { it.contains("foss", ignoreCase = true) }
if (!isFossBuild && file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
}

flutter {
    source = "../.."
}

