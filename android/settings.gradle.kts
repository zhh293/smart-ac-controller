pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localPropertiesFile = file("local.properties")
            if (localPropertiesFile.exists()) {
                localPropertiesFile.inputStream().use { properties.load(it) }
            }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            // If flutter.sdk is not in local.properties, try to get it from the environment variable FLUTTER_ROOT
            // which is often set in CI environments.
            if (flutterSdkPath == null) {
                val envFlutterRoot = System.getenv("FLUTTER_ROOT")
                if (envFlutterRoot != null) {
                    return@run envFlutterRoot
                }
            }
            
            // If still null, and we are not in a CI environment where we expect it to be injected or handled differently,
            // we might just return null or a placeholder, but the includeBuild below will fail.
            // However, modern Flutter builds inject the necessary plugins via the flutter-gradle-plugin.
            // The manual includeBuild is legacy or specific to some setups.
            
            flutterSdkPath
        }

    if (flutterSdkPath != null) {
        includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    }

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
