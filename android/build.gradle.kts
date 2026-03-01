allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }
    }
}

// Custom build directory logic (standard in some Flutter templates)
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

plugins {
    id("com.chaquo.python") version "17.0.0" apply false
}

subprojects {
    // This ensures the :app project is evaluated before plugins that depend on it
    project.evaluationDependsOn(":app")

}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
