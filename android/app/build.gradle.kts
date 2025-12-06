import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
file("../local.properties").inputStream().use { localProperties.load(it) }
val targetSdkVersion: Int = localProperties.getProperty("flutter.targetSdkVersion")?.toInt()
    ?: throw GradleException("flutter.targetSdkVersion not set in local.properties")
val minSdkVersion: Int = localProperties.getProperty("flutter.minSdkVersion")?.toInt()
    ?: throw GradleException("flutter.minSdkVersion not set in local.properties")
val yandexApiKey = localProperties.getProperty("YANDEX_API_KEY")
    ?: throw GradleException("YANDEX_API_KEY not set in local.properties")


android {
    namespace = "com.prokurs.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }

    sourceSets {
        getByName("main").java.srcDirs("src/main/kotlin")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.prokurs.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        buildConfigField("String", "YANDEX_API_KEY", "\"$yandexApiKey\"")
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

dependencies {
    implementation("com.yandex.android:maps.mobile:4.22.0-lite")
}
