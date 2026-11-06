allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    plugins.withId("com.android.library") {
        val androidExtension = project.extensions.findByName("android")
        if (androidExtension is com.android.build.gradle.BaseExtension && androidExtension.namespace == null) {
            androidExtension.namespace = if (project.name == "isar_flutter_libs") {
                "dev.isar.isar_flutter_libs"
            } else {
                "com.marky.thirdparty.${project.name.replace('-', '_')}"
            }
        }
    }
}
subprojects {
    afterEvaluate {
        if (project.extensions.findByName("android") != null) {
            @Suppress("UNCHECKED_CAST")
            val androidExtension = project.extensions["android"] as com.android.build.gradle.BaseExtension
            androidExtension.compileSdkVersion(36)
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
