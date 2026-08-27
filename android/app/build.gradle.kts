plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.chronos"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.chronos"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---- AJOUT : configuration de signature release ----
    // Les valeurs sont lues depuis des variables d'environnement.
    // En CI (GitHub Actions), elles sont injectées à partir des Secrets.
    // En local, si ces variables n'existent pas, ça retombe sur la
    // signature "debug" par défaut (donc ça ne casse rien si vous
    // buildez en release sur votre PC sans avoir tout configuré).
    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("CHRONOS_KEYSTORE_PATH")
            if (keystorePath != null) {
                storeFile = file(keystorePath)
                storePassword = System.getenv("CHRONOS_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("CHRONOS_KEY_ALIAS")
                keyPassword = System.getenv("CHRONOS_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Si la variable d'environnement du keystore existe (donc en CI),
            // on utilise la vraie signature "release".
            // Sinon (en local, sans rien configurer), on garde "debug"
            // pour que vous puissiez toujours builder facilement sur votre PC.
            signingConfig = if (System.getenv("CHRONOS_KEYSTORE_PATH") != null) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}