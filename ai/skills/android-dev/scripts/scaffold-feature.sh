#!/usr/bin/env bash
set -euo pipefail

# Scaffold a new feature module with platform submodules.
#
# Usage:
#   ./scaffold-feature.sh <feature-name> <package> [--wear]
#
# Examples:
#   ./scaffold-feature.sh auth com.myapp            # phone only
#   ./scaffold-feature.sh dashboard com.myapp --wear # phone + wear
#
# Creates:
#   features/<feature>/app/  — Phone submodule (always)
#   features/<feature>/wear/ — Wear submodule (with --wear flag)

if [[ $# -lt 2 ]]; then
    echo "Usage: $0 <feature-name> <base-package> [--wear]"
    echo "  e.g. $0 auth com.myapp"
    echo "  e.g. $0 dashboard com.myapp --wear"
    exit 1
fi

FEATURE="$1"
BASE_PACKAGE="$2"
WITH_WEAR=false
if [[ "${3:-}" == "--wear" ]]; then
    WITH_WEAR=true
fi

# Validate inputs
if ! [[ "$FEATURE" =~ ^[a-z][a-z0-9]*([-_][a-z0-9]+)*$ ]]; then
    echo "Error: feature name must be lowercase, start with a letter, and use only hyphens or underscores as separators"
    echo "  valid:   auth, fasting-timer, step_counter"
    echo "  invalid: Auth, fasting-Timer, -timer"
    exit 1
fi
if ! [[ "$BASE_PACKAGE" =~ ^[a-z][a-z0-9]*(\.[a-z][a-z0-9]*)+$ ]]; then
    echo "Error: base package must be dot-separated lowercase identifier segments"
    echo "  valid:   com.myapp, com.example.app"
    echo "  invalid: com.MyApp, com, myapp"
    exit 1
fi

# Derive names
FEATURE_SLUG="$FEATURE"
FEATURE_PACKAGE="$(printf '%s' "$FEATURE" | tr -d '_-')"
FEATURE_CLASS="$(echo "$FEATURE" | awk -F'[-_]' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS='')"
FEATURE_CAMEL="$(echo "$FEATURE" | awk -F'[-_]' '{for(i=2;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS='')"
PACKAGE_PATH="${BASE_PACKAGE//.//}"

FEATURES_DIR="features/${FEATURE_SLUG}"

# Overwrite guard
if [[ -e "$FEATURES_DIR" ]]; then
    echo "Error: $FEATURES_DIR already exists"
    exit 1
fi

# --- App submodule (always created) ---

APP_SRC="${FEATURES_DIR}/app/src/main/kotlin/${PACKAGE_PATH}/features/${FEATURE_PACKAGE}"

mkdir -p "${APP_SRC}/di"

cat >"${FEATURES_DIR}/app/build.gradle.kts" <<GRADLE
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "${BASE_PACKAGE}.features.${FEATURE_PACKAGE}"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core"))
    implementation(libs.androidx.lifecycle.viewmodel)
    implementation(libs.koin.androidx.compose)
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.runtime)
    implementation(libs.compose.ui)
    implementation(libs.compose.foundation)
    implementation(libs.compose.material3)
    implementation(libs.compose.ui.tooling.preview)
    debugImplementation(libs.compose.ui.tooling)
}
GRADLE

cat >"${APP_SRC}/${FEATURE_CLASS}ViewModel.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class ${FEATURE_CLASS}UiState(
    val isLoading: Boolean = false,
    val error: String? = null,
)

class ${FEATURE_CLASS}ViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(${FEATURE_CLASS}UiState())
    val uiState: StateFlow<${FEATURE_CLASS}UiState> = _uiState.asStateFlow()
}
KOTLIN

cat >"${APP_SRC}/${FEATURE_CLASS}Screen.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import org.koin.androidx.compose.koinViewModel

@Composable
fun ${FEATURE_CLASS}Screen(
    viewModel: ${FEATURE_CLASS}ViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    ${FEATURE_CLASS}Content(uiState = uiState)
}

@Composable
private fun ${FEATURE_CLASS}Content(uiState: ${FEATURE_CLASS}UiState) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Text(text = "${FEATURE_CLASS}")
    }
}

@Preview(showBackground = true)
@Composable
private fun ${FEATURE_CLASS}ScreenPreview() {
    ${FEATURE_CLASS}Content(uiState = ${FEATURE_CLASS}UiState())
}
KOTLIN

cat >"${APP_SRC}/di/${FEATURE_CLASS}Module.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.di

import ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.${FEATURE_CLASS}ViewModel
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

val ${FEATURE_CAMEL}Module = module {
    // Add get() arguments here when the ViewModel takes use cases.
    viewModel { ${FEATURE_CLASS}ViewModel() }
}
KOTLIN

echo "Created: ${FEATURES_DIR}/app/"

# --- Wear submodule (optional) ---

if [[ "${WITH_WEAR}" == true ]]; then
    WEAR_SRC="${FEATURES_DIR}/wear/src/main/kotlin/${PACKAGE_PATH}/features/${FEATURE_PACKAGE}/wear"

    mkdir -p "${WEAR_SRC}/di"

    cat >"${FEATURES_DIR}/wear/build.gradle.kts" <<GRADLE
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.wear"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.wearMinSdk.get().toInt()
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core"))
    implementation(libs.androidx.lifecycle.viewmodel)
    implementation(libs.koin.androidx.compose)
    implementation(libs.wear.compose.material3)
    implementation(libs.wear.compose.foundation)
    implementation(libs.compose.ui.tooling.preview)
    debugImplementation(libs.compose.ui.tooling)
    debugImplementation(libs.wear.tooling.preview)
}
GRADLE

    cat >"${WEAR_SRC}/Wear${FEATURE_CLASS}ViewModel.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.wear

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class Wear${FEATURE_CLASS}UiState(
    val isLoading: Boolean = false,
    val error: String? = null,
)

class Wear${FEATURE_CLASS}ViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(Wear${FEATURE_CLASS}UiState())
    val uiState: StateFlow<Wear${FEATURE_CLASS}UiState> = _uiState.asStateFlow()
}
KOTLIN

    cat >"${WEAR_SRC}/Wear${FEATURE_CLASS}Screen.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.wear

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.wear.compose.material3.Text
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.tooling.preview.devices.WearDevices
import org.koin.androidx.compose.koinViewModel

@Composable
fun Wear${FEATURE_CLASS}Screen(
    viewModel: Wear${FEATURE_CLASS}ViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    Wear${FEATURE_CLASS}Content(uiState = uiState)
}

@Composable
private fun Wear${FEATURE_CLASS}Content(uiState: Wear${FEATURE_CLASS}UiState) {
    ScalingLazyColumn(
        modifier = Modifier,
    ) {
        item {
            Text(text = "${FEATURE_CLASS}")
        }
    }
}

@Preview(device = WearDevices.SMALL_ROUND, showSystemUi = true)
@Composable
private fun Wear${FEATURE_CLASS}ScreenPreview() {
    Wear${FEATURE_CLASS}Content(uiState = Wear${FEATURE_CLASS}UiState())
}
KOTLIN

    cat >"${WEAR_SRC}/di/Wear${FEATURE_CLASS}Module.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.wear.di

import ${BASE_PACKAGE}.features.${FEATURE_PACKAGE}.wear.Wear${FEATURE_CLASS}ViewModel
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

val wear${FEATURE_CLASS}Module = module {
    // Add get() arguments here when the ViewModel takes use cases.
    viewModel { Wear${FEATURE_CLASS}ViewModel() }
}
KOTLIN

    echo "Created: ${FEATURES_DIR}/wear/"
fi

echo ""
echo "Next steps:"
echo "  1. Register Koin module in the platform's DI setup"
echo "  2. Add navigation routes in the platform module"
echo "  3. Add strings in :core (English + Spanish)"
echo "  4. Write tests first, then implement"
