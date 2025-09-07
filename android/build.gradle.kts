// android/build.gradle.kts
// ملاحظة: تعريف المستودعات (google/mavenCentral) صار في settings.gradle.kts
// لذلك لا نعيد تعريف repositories هنا لتفادي خطأ:
// "Build was configured to prefer settings repositories over project repositories"

// اضبط مسار build ليكون خارج android/
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    // كل مشروع فرعي يكتب مخرجاته داخل build/<اسم-الموديول>
    layout.buildDirectory.set(newBuildDir.map { it.dir(name) })
    // تأكد إن :app يتقيّم أولاً (كما كان)
    evaluationDependsOn(":app")
}

// مهمة تنظيف قياسية
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
