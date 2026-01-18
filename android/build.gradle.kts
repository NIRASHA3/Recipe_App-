 plugins {
    // ...
    id("com.google.gms.google-services") version "4.4.0" apply false
    // Also add this for Firebase Crashlytics if you use it:
    // id("com.google.firebase.crashlytics") version "2.9.9" apply false
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Remove the custom build directory settings as they might cause issues:
// val newBuildDir: Directory = ...
// rootProject.layout.buildDirectory.value(newBuildDir)

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}