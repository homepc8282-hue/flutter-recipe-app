plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    // ✅ Yeh line add kiya (bina version ke)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.recipe_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.recipe_app"
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

dependencies {
    // ✅ Firebase BOM add kiya (Firebase ke liye zaroori hai)
    implementation(platform("com.google.firebase:firebase-bom:34.12.0"))
    // ✅ Firestore dependency add kiya
    implementation("com.google.firebase:firebase-firestore")
}

flutter {
    source = "../.."
}