// android/settings.gradle.kts

pluginManagement {
    // مسار Flutter SDK
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
        // مستودع Flutter
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }

    // تعاريف نسخ البلغ-إن
    plugins {
        id("com.android.application") version "8.7.3"
        id("org.jetbrains.kotlin.android") version "1.9.24"     // ثبّتنا كوتلن
        id("com.google.gms.google-services") version "4.4.2"
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    }
}

dependencyResolutionManagement {
    // اسمح بمستودعات المشروع (الـ Flutter plugin بيضيف maven خاص)
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }
}

// 👇 مهم: طبّق Flutter plugin loader (بدون apply false)
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
}

rootProject.name = "android"
include(":app")
