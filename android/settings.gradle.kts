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
        // مستودع Flutter (لمنع البلغ-إن من إضافته لاحقاً على مستوى المشروع)
        maven(url = "https://storage.googleapis.com/download.flutter.io")
    }

    // تعريف نسخ البلغ-إن على مستوى المشروع
    plugins {
        id("com.android.application") version "8.7.3"
        id("org.jetbrains.kotlin.android") version "2.1.0"
        id("com.google.gms.google-services") version "4.4.2"
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    }
}

// حلّ التبعيات للمشاريع — اسمح بمستودعات المشروع لأن بلَغ-إن Flutter يضيف maven خاص
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS) // 👈 بدل FAIL_ON_PROJECT_REPOS
    repositories {
        google()
        mavenCentral()
        maven(url = "https://storage.googleapis.com/download.flutter.io") // 👈 مستودع Flutter
    }
}

// لا نطبّق أي بلَغ-إن هنا مباشرة؛ التطبيق يتم داخل :app
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0" apply false
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

rootProject.name = "android"
include(":app")
