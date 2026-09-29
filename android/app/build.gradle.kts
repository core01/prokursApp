import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    // Kotlin support is built into AGP 9 (android.builtInKotlin=true).
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

    buildFeatures {
        // Needed for BuildConfig.YANDEX_API_KEY (disabled by default since AGP 9).
        buildConfig = true
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

kotlin {
    compilerOptions {
        jvmTarget = JvmTarget.JVM_21
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Must match the native MapKit version pinned by the yandex_mapkit plugin.
    implementation("com.yandex.android:maps.mobile:4.39.1-lite")
}
