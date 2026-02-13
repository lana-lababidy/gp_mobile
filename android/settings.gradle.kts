// android/settings.gradle.kts

pluginManagement {
    val flutterSdkPath = run {
        val props = java.util.Properties()
        file("local.properties").inputStream().use { props.load(it) }
        val p = props.getProperty("flutter.sdk")
        require(p != null) { "flutter.sdk not set in local.properties" }
        p
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }

    // ⬅️ ثبّت النسخ التالية
    plugins {
        id("com.android.application") version "8.5.2"
        id("org.jetbrains.kotlin.android") version "1.9.22"   // 👈 نزّلنا لـ 1.9.22 (مستقرة مع AGP 8.5.x)
        id("com.google.gms.google-services") version "4.4.2"
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

// طبّق Flutter plugin loader فقط
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

rootProject.name = "android"
include(":app")
