// Configuration optimisée pour résoudre l'erreur Kotlin compile daemon
// Utilisation de SDK 36 et JVM target 1.8 pour une meilleure compatibilité
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.ger_ton_argent"
    compileSdk = 36

    // 🔹 Forcer la bonne version NDK (selon l'erreur que tu avais)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        // 🔹 Activation de la désugration pour API Java 8+
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "1.8"
        freeCompilerArgs += listOf(
            "-Xjvm-default=all",
            "-Xopt-in=kotlin.RequiresOptIn"
        )
    }

    defaultConfig {
        applicationId = "com.example.ger_ton_argent"
        minSdk = maxOf(flutter.minSdkVersion, 24) // Android 7.0+ pour une meilleure compatibilité
        targetSdk = 36 // Android 14
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Optimisations pour éviter les problèmes de mémoire
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
    
    // Optimisations de build
    buildFeatures {
        buildConfig = true
    }
    
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔹 Ajout pour corriger flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    
    // Support pour MultiDex
    implementation("androidx.multidex:multidex:2.0.1")
}
