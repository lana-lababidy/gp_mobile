// android/build.gradle.kts
// ملف مشروع أندرويد العلوي — نخليه بسيط بدون تخصيص buildDirectory أو repositories
// المستودعات والتعريفات موجودة في settings.gradle.kts

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
