#!/usr/bin/env bash
set -euo pipefail
set -o noclobber

# Initialize a new multi-module Android project.
#
# Usage:
#   ./init.sh <name> <base-package>
#
# Examples:
#   ./init.sh fasting com.charliesbot.fasting
#
# Creates:
#   <name>/                         project root (or current dir if <name> is ".")
#   ├── settings.gradle.kts         platform includes + auto-discovery for :core:* and :features:*:*
#   ├── build.gradle.kts            plugin aliases, Spotless config
#   ├── gradle.properties           includes android.basePackage (read by generate.sh)
#   ├── core/domain/                pure Kotlin module (kotlin("jvm"))
#   ├── core/data/                  Android library (Room, DataStore, Koin) + empty CoreDataModule.kt
#   └── core/strings/               Android library, single strings.xml with app_name

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <name> <base-package>"
    echo "  e.g. $0 fasting com.charliesbot.fasting"
    exit 1
fi

NAME="$1"
BASE_PACKAGE="$2"

# Validate inputs
if ! [[ "$NAME" =~ ^[a-z][a-z0-9-]*$ || "$NAME" == "." ]]; then
    echo "Error: name must be lowercase, start with a letter, and contain only lowercase letters, numbers, and hyphens (or '.' for current dir)"
    echo "  valid:   fasting, my-app, app2, ."
    echo "  invalid: Fasting, -my-app, my_app"
    exit 1
fi

if ! [[ "$BASE_PACKAGE" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
    echo "Error: base package must be dot-separated lowercase identifier segments"
    echo "  valid:   com.myapp, com.example.app"
    echo "  invalid: com.MyApp, com, myapp"
    exit 1
fi

# Derive names
NAME_CLASS="$(echo "$NAME" | awk -F'-' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS='')"
PACKAGE_PATH="${BASE_PACKAGE//.//}"

# Determine project directory
if [[ "$NAME" == "." ]]; then
    PROJECT_DIR="$(pwd)"
else
    PROJECT_DIR="$NAME"
fi

# Preflight: target directory must be empty or non-existent
if [[ -d "$PROJECT_DIR" && -n "$(ls -A "$PROJECT_DIR" 2>/dev/null)" ]]; then
    echo "Error: $PROJECT_DIR already exists and is non-empty."
    echo "Init expects an empty or non-existent directory."
    echo "Use scripts/generate.sh to add modules to an existing project."
    exit 1
fi

# Create project directory if missing
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# --- Root files ---

cat > settings.gradle.kts <<EOF
rootProject.name = "$NAME"

pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

// Auto-discover :core:* sub-modules
file("core").listFiles()
    ?.filter { it.isDirectory && File(it, "build.gradle.kts").exists() }
    ?.forEach { include(":core:\${it.name}") }

// Auto-discover :features:*:* sub-modules
file("features").listFiles()?.filter { it.isDirectory }?.forEach { feature ->
    listOf("app", "wear", "tv", "auto").forEach { platform ->
        if (feature.resolve(platform).isDirectory) {
            include(":features:\${feature.name}:\$platform")
        }
    }
}
EOF

cat > build.gradle.kts <<EOF
// Top-level build file — common configuration for all sub-projects/modules.
plugins {
    alias(libs.plugins.android.application) apply false
    alias(libs.plugins.android.library) apply false
    alias(libs.plugins.kotlin.android) apply false
    alias(libs.plugins.kotlin.jvm) apply false
    alias(libs.plugins.kotlin.compose) apply false
    alias(libs.plugins.ksp) apply false
    alias(libs.plugins.spotless)
}

spotless {
    kotlin {
        target("**/*.kt")
        targetExclude("**/build/**/*.kt")
        ktfmt().googleStyle()
    }
    kotlinGradle {
        target("**/*.gradle.kts")
        ktfmt().googleStyle()
    }
}
EOF

cat > gradle.properties <<EOF
# Project-wide Gradle settings
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official

# Used by scripts/generate.sh — do not remove
android.basePackage=$BASE_PACKAGE
EOF

# --- :core:domain (pure Kotlin) ---

mkdir -p "core/domain/src/main/kotlin/$PACKAGE_PATH/domain"

cat > core/domain/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.kotlin.jvm)
}

dependencies {
    implementation(libs.kotlinx.coroutines.core)
}
EOF

# --- :core:data (Android library) ---

mkdir -p "core/data/src/main/kotlin/$PACKAGE_PATH/data/di"

cat > core/data/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.ksp)
}

android {
    namespace = "$BASE_PACKAGE.data"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }
}

dependencies {
    implementation(project(":core:domain"))
    implementation(libs.androidx.room.runtime)
    implementation(libs.androidx.room.ktx)
    ksp(libs.androidx.room.compiler)
    implementation(libs.androidx.datastore.preferences)
    implementation(libs.koin.android)
}
EOF

cat > core/data/src/main/AndroidManifest.xml <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" />
EOF

cat > "core/data/src/main/kotlin/$PACKAGE_PATH/data/di/CoreDataModule.kt" <<EOF
package $BASE_PACKAGE.data.di

import org.koin.dsl.module

val coreDataModule = module {
    // Add bindings here as you create repositories.
}
EOF

# --- :core:strings (Android library, resources only) ---

mkdir -p "core/strings/src/main/res/values"

cat > core/strings/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
}

android {
    namespace = "$BASE_PACKAGE.strings"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }
}
EOF

cat > core/strings/src/main/AndroidManifest.xml <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" />
EOF

cat > core/strings/src/main/res/values/strings.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$NAME_CLASS</string>
</resources>
EOF

echo "Initialized: $PROJECT_DIR"
echo ""
echo "Created:"
echo "  settings.gradle.kts"
echo "  build.gradle.kts"
echo "  gradle.properties"
echo "  core/domain/"
echo "  core/data/"
echo "  core/strings/"
echo ""
echo "Next steps:"
if [[ "$NAME" != "." ]]; then
    echo "  1. cd $PROJECT_DIR"
    echo "  2. scripts/generate.sh app    # add :app module"
    echo "  3. scripts/generate.sh wear   # add :wear module (optional)"
    echo "  4. Sync Gradle in Android Studio"
else
    echo "  1. scripts/generate.sh app    # add :app module"
    echo "  2. scripts/generate.sh wear   # add :wear module (optional)"
    echo "  3. Sync Gradle in Android Studio"
fi
