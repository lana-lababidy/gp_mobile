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
    }

    // 👇 تعريف نسخ البلغ-إن على مستوى المشروع (مهم لـ com.google.gms.google-services)
    plugins {
        id("com.android.application") version "8.7.3"
        id("org.jetbrains.kotlin.android") version "2.1.0"
        id("com.google.gms.google-services") version "4.4.2"   // ✅ المهم
        id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    }
}

// مستودعات لحل تبعيات المكتبات أثناء البناء
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    // إبقاء البلغ-إن الخاص بفلتر هنا (لا يطبّق على أي مشروع فرعي مباشرة)
    id("dev.flutter.flutter-plugin-loader") version "1.0.0" apply false
    // هدول معرفين فوق في pluginManagement.plugins؛ ما في داعي نكرّرهم هون
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    // ملاحظة: ما منطبّق google-services هون؛ بيتطبّق داخل :app
}

rootProject.name = "android"
include(":app")
