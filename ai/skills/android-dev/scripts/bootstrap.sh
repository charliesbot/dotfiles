#!/usr/bin/env bash
set -euo pipefail
set -o noclobber

# Bootstrap the four core modules onto an existing single-module Android
# project (typically one created by `android create empty-activity`).
#
# Usage:
#   ./bootstrap.sh
#
# Run from the project root after `android create empty-activity ...`.
#
# Adds:
#   core/model/    :core:model    pure Kotlin (kotlin("jvm"))
#   core/domain/   :core:domain   pure Kotlin (kotlin("jvm"))
#   core/data/     :core:data     Android library (Room, DataStore, Koin)
#   core/strings/  :core:strings  Android library, resources only (en + es)
#
# Updates settings.gradle.kts (include lines) and gradle.properties
# (android.basePackage). Prints the additions you'll need to merge by hand
# into gradle/libs.versions.toml and the root build.gradle.kts — those files
# are too risky for a script to edit blindly, and an agent reading the
# output can apply the changes semantically.

# --- Project root validation ---

if [[ ! -f "settings.gradle.kts" || ! -f "build.gradle.kts" ]]; then
    echo "Error: not in an Android project root (missing settings.gradle.kts or build.gradle.kts)."
    echo "Run 'android create empty-activity --name=<Name> --output=./<dir>' first, then cd into the project."
    exit 1
fi

if [[ ! -f "app/build.gradle.kts" ]]; then
    echo "Error: no :app module found (app/build.gradle.kts missing)."
    echo "Bootstrap expects an :app module created by 'android create empty-activity'."
    exit 1
fi

# --- Non-canonical :core detection ---
# A single :core module (one Gradle module with packages inside) is the
# failure mode the skill is designed to prevent. Refuse to add modules
# alongside it — the user must restructure first.
if [[ -f "core/build.gradle.kts" ]]; then
    echo "Error: non-canonical :core module detected (core/build.gradle.kts exists)."
    echo "This script does not migrate single-module :core layouts."
    echo "Restructure manually: split core/ into core/model, core/domain, core/data, core/strings"
    echo "as separate Gradle modules, then re-run this script."
    exit 1
fi

# --- Partial-bootstrap detection ---
# Paths are relative to project root. Nested paths (e.g. designsystem/common)
# are allowed — the corresponding Gradle path is :core:designsystem:common.
core_modules=(model domain data strings designsystem/common)
existing=()
missing=()
for m in "${core_modules[@]}"; do
    if [[ -f "core/$m/build.gradle.kts" ]]; then
        existing+=("$m")
    else
        missing+=("$m")
    fi
done

if [[ ${#existing[@]} -gt 0 && ${#missing[@]} -gt 0 ]]; then
    echo "Error: partial bootstrap detected."
    echo "  Present: ${existing[*]}"
    echo "  Missing: ${missing[*]}"
    echo "Resolve manually (either complete or remove the partial modules), then re-run."
    exit 1
fi

if [[ ${#missing[@]} -eq 0 ]]; then
    echo "All five :core:* modules already present. Nothing to do."
    exit 0
fi

# --- Extract base package from :app namespace ---

NAMESPACE=$(grep -E '^\s*namespace\s*=\s*"' app/build.gradle.kts | head -1 | sed -E 's/.*"([^"]+)".*/\1/')
if [[ -z "$NAMESPACE" ]]; then
    echo "Error: could not read namespace from app/build.gradle.kts."
    echo "Expected a line like: namespace = \"com.example.myapp\""
    exit 1
fi

BASE_PACKAGE="$NAMESPACE"
PACKAGE_PATH="${BASE_PACKAGE//.//}"

echo "Detected base package: $BASE_PACKAGE"

# --- Helpers ---

append_include() {
    local include_line="$1"
    if ! grep -qF "$include_line" settings.gradle.kts; then
        echo "" >> settings.gradle.kts
        echo "$include_line" >> settings.gradle.kts
        echo "Updated settings.gradle.kts: $include_line"
    fi
}

# --- gradle.properties: ensure android.basePackage is set ---

if ! grep -q '^android\.basePackage=' gradle.properties; then
    echo "" >> gradle.properties
    echo "# Used by scripts/generate.sh — do not remove" >> gradle.properties
    echo "android.basePackage=$BASE_PACKAGE" >> gradle.properties
    echo "Updated gradle.properties: android.basePackage=$BASE_PACKAGE"
fi

# --- :core:model (pure Kotlin) ---

if [[ ! -f "core/model/build.gradle.kts" ]]; then
    mkdir -p "core/model/src/main/kotlin/$PACKAGE_PATH/model"
    cat > core/model/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.kotlin.jvm)
}
EOF
    append_include 'include(":core:model")'
    echo "Created :core:model"
fi

# --- :core:domain (pure Kotlin) ---

if [[ ! -f "core/domain/build.gradle.kts" ]]; then
    mkdir -p "core/domain/src/main/kotlin/$PACKAGE_PATH/domain/repository"
    mkdir -p "core/domain/src/main/kotlin/$PACKAGE_PATH/domain/usecase"
    cat > core/domain/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.kotlin.jvm)
}

dependencies {
    implementation(project(":core:model"))
    implementation(libs.kotlinx.coroutines.core)
}
EOF
    append_include 'include(":core:domain")'
    echo "Created :core:domain"
fi

# --- :core:data (Android library) ---

if [[ ! -f "core/data/build.gradle.kts" ]]; then
    mkdir -p "core/data/src/main/kotlin/$PACKAGE_PATH/data/local"
    mkdir -p "core/data/src/main/kotlin/$PACKAGE_PATH/data/remote"
    mkdir -p "core/data/src/main/kotlin/$PACKAGE_PATH/data/repository"
    mkdir -p "core/data/src/main/kotlin/$PACKAGE_PATH/data/di"

    cat > core/data/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
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
    implementation(project(":core:model"))
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
    // Add bindings here as you create repositories and use cases.
}
EOF
    append_include 'include(":core:data")'
    echo "Created :core:data"
fi

# --- :core:strings (Android library, resources only) ---

if [[ ! -f "core/strings/build.gradle.kts" ]]; then
    mkdir -p "core/strings/src/main/res/values"
    mkdir -p "core/strings/src/main/res/values-es"

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

    cat > core/strings/src/main/res/values/strings.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
</resources>
EOF

    cat > core/strings/src/main/res/values-es/strings.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
</resources>
EOF
    append_include 'include(":core:strings")'
    echo "Created :core:strings (en + es resource folders)"
fi

# --- :core:designsystem:common (Android library, non-string resources) ---

if [[ ! -f "core/designsystem/common/build.gradle.kts" ]]; then
    mkdir -p "core/designsystem/common/src/main/res/drawable"
    mkdir -p "core/designsystem/common/src/main/res/values"

    cat > core/designsystem/common/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
}

android {
    namespace = "$BASE_PACKAGE.designsystem.common"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }
}
EOF

    cat > core/designsystem/common/src/main/AndroidManifest.xml <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" />
EOF

    cat > core/designsystem/common/src/main/res/values/colors.xml <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Brand color values referenced from XML (manifest theme, splash screen, etc.).
         Compose color tokens live in :core:designsystem:app or :core:designsystem:wear
         once those modules are promoted. -->
</resources>
EOF
    append_include 'include(":core:designsystem:common")'
    echo "Created :core:designsystem:common (drawable + values folders)"
fi

# --- Final report ---

cat <<EOF

Bootstrap complete. Five core modules created.

Next: merge the additions below into gradle/libs.versions.toml and the root
build.gradle.kts. The script does not edit these files automatically — TOML
and the plugins block are too risky to splice. An agent or developer can
apply the changes semantically.

# --- Add to gradle/libs.versions.toml under [versions] ---
# Use the latest stable versions compatible with your Kotlin and AGP versions.
# Check Maven Central / KSP release page if these need updating.
compileSdk = "36"
minSdk = "24"
wearMinSdk = "30"
room = "2.8.2"
koin = "4.1.0"
datastore = "1.1.7"
lifecycle = "<look-up-latest-lifecycle-version>"
navigation3 = "<look-up-latest-navigation3-version>"
wearCompose = "<look-up-latest-wear-compose-version>"
kotlinxSerialization = "<look-up-latest-kotlinx-serialization-version>"
ksp = "<look-up-latest-ksp-matching-your-kotlin-version>"  # e.g. "2.3.20-2.0.4" — verify on https://github.com/google/ksp/releases
spotless = "7.2.1"
# Add when generating widgets (see references/TOOLING.md):
# glanceAppwidget = "<latest>"
# glanceWear = "<latest>"
# remoteCompose = "<latest>"
# wearRemoteMaterial3 = "<latest>"

# --- Add to gradle/libs.versions.toml under [libraries] ---
kotlinx-coroutines-core = { module = "org.jetbrains.kotlinx:kotlinx-coroutines-core", version.ref = "coroutines" }
androidx-room-runtime = { module = "androidx.room:room-runtime", version.ref = "room" }
androidx-room-ktx = { module = "androidx.room:room-ktx", version.ref = "room" }
androidx-room-compiler = { module = "androidx.room:room-compiler", version.ref = "room" }
androidx-datastore-preferences = { module = "androidx.datastore:datastore-preferences", version.ref = "datastore" }
androidx-navigation3-runtime = { module = "androidx.navigation3:navigation3-runtime", version.ref = "navigation3" }
androidx-navigation3-ui = { module = "androidx.navigation3:navigation3-ui", version.ref = "navigation3" }
wear-compose-navigation3 = { module = "androidx.wear.compose:compose-navigation3", version.ref = "wearCompose" }
androidx-lifecycle-viewmodel-navigation3 = { module = "androidx.lifecycle:lifecycle-viewmodel-navigation3", version.ref = "lifecycle" }
kotlinx-serialization-json = { module = "org.jetbrains.kotlinx:kotlinx-serialization-json", version.ref = "kotlinxSerialization" }
koin-android = { module = "io.insert-koin:koin-android", version.ref = "koin" }
koin-androidx-compose = { module = "io.insert-koin:koin-androidx-compose", version.ref = "koin" }
# Widget libraries (add when running generate.sh widget — see references/TOOLING.md):
# androidx-glance-appwidget = { module = "androidx.glance:glance-appwidget", version.ref = "glanceAppwidget" }
# androidx-glance-wear = { module = "androidx.glance.wear:wear", version.ref = "glanceWear" }
# androidx-glance-wear-core = { module = "androidx.glance.wear:wear-core", version.ref = "glanceWear" }
# androidx-remote-core = { module = "androidx.compose.remote:remote-core", version.ref = "remoteCompose" }
# androidx-remote-creation-compose = { module = "androidx.compose.remote:remote-creation-compose", version.ref = "remoteCompose" }
# wear-remote-material3 = { module = "androidx.wear.compose:compose-remote-material3", version.ref = "wearRemoteMaterial3" }

# --- Add to gradle/libs.versions.toml under [plugins] ---
# Note: AGP 9.0+ bundles Kotlin support, so we don't add `kotlin-android` — it would
# conflict. `:core:data` uses only `android.library` + `ksp`. The pure Kotlin modules
# use `kotlin.jvm`.
#
# If `compose-compiler` already exists in your catalog (`android create` adds it),
# add `kotlin-compose` as a sibling alias pointing to the same plugin id so the
# rest of the skill's generated files (which reference `libs.plugins.kotlin.compose`)
# resolve. Both aliases can coexist.
android-library = { id = "com.android.library", version.ref = "androidGradlePlugin" }
kotlin-jvm = { id = "org.jetbrains.kotlin.jvm", version.ref = "kotlin" }
kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
spotless = { id = "com.diffplug.spotless", version.ref = "spotless" }

# --- Add to the root build.gradle.kts plugins block ---
alias(libs.plugins.android.library) apply false
alias(libs.plugins.kotlin.jvm) apply false
alias(libs.plugins.kotlin.serialization) apply false
alias(libs.plugins.ksp) apply false
alias(libs.plugins.spotless)

# --- Add to the root build.gradle.kts (after the plugins block) ---
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

Then in Android Studio: File → Sync Project with Gradle Files.

If the sync fails because KSP rejects a Kotlin source-set DSL call under AGP 9,
add this line to gradle.properties:
  android.disallowKotlinSourceSets=false

After sync, the bare :app from 'android create' is still a standalone Compose
app — it doesn't depend on :core:data or any feature module. To replace it
with the skill's wired-up shell:
  rm -rf app
  scripts/generate.sh app

Then add features:
  scripts/generate.sh feature dashboard
EOF
