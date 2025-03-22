buildscript {
    
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.3.0") // Chuyển vào buildscript
        
    }
}

plugins {
    id("com.google.gms.google-services") version "4.4.2" apply false
   
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")

    if (project.name == "path_provider_android") {
        project.layout.buildDirectory.set(file("D:/UTH/HK6/Android/mangadive/build/path_provider_android"))
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
