buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.7.0")  // Sesuaikan dengan plugin version
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.0.21")  // Sama dengan settings
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// Mengatur build output ke luar direktori android/
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)  // Gunakan .set() bukan .value()

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)  // Gunakan .set()
    evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}