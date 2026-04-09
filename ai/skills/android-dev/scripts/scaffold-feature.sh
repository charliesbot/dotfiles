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

# Derive names
FEATURE_LOWER="${FEATURE}"
FEATURE_CAPITALIZED="$(echo "${FEATURE:0:1}" | tr '[:lower:]' '[:upper:]')${FEATURE:1}"
PACKAGE_PATH="${BASE_PACKAGE//.//}"

FEATURES_DIR="features/${FEATURE_LOWER}"

# --- App submodule (always created) ---

APP_SRC="${FEATURES_DIR}/app/src/main/kotlin/${PACKAGE_PATH}/features/${FEATURE_LOWER}"

mkdir -p "${APP_SRC}/di"

cat >"${FEATURES_DIR}/app/build.gradle.kts" <<GRADLE
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "${BASE_PACKAGE}.features.${FEATURE_LOWER}"
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
}
GRADLE

cat >"${APP_SRC}/${FEATURE_CAPITALIZED}ViewModel.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_LOWER}

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class ${FEATURE_CAPITALIZED}UiState(
    val isLoading: Boolean = false,
    val error: String? = null,
)

class ${FEATURE_CAPITALIZED}ViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(${FEATURE_CAPITALIZED}UiState())
    val uiState: StateFlow<${FEATURE_CAPITALIZED}UiState> = _uiState.asStateFlow()
}
KOTLIN

cat >"${APP_SRC}/${FEATURE_CAPITALIZED}Screen.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_LOWER}

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
fun ${FEATURE_CAPITALIZED}Screen(
    viewModel: ${FEATURE_CAPITALIZED}ViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    ${FEATURE_CAPITALIZED}Content(uiState = uiState)
}

@Composable
private fun ${FEATURE_CAPITALIZED}Content(uiState: ${FEATURE_CAPITALIZED}UiState) {
    Box(
        modifier = Modifier.fillMaxSize(),
        contentAlignment = Alignment.Center,
    ) {
        Text(text = "${FEATURE_CAPITALIZED}")
    }
}

@Preview(showBackground = true)
@Composable
private fun ${FEATURE_CAPITALIZED}ScreenPreview() {
    ${FEATURE_CAPITALIZED}Content(uiState = ${FEATURE_CAPITALIZED}UiState())
}
KOTLIN

cat >"${APP_SRC}/di/${FEATURE_CAPITALIZED}Module.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_LOWER}.di

import ${BASE_PACKAGE}.features.${FEATURE_LOWER}.${FEATURE_CAPITALIZED}ViewModel
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

val ${FEATURE_LOWER}Module = module {
    viewModel { ${FEATURE_CAPITALIZED}ViewModel() }
}
KOTLIN

echo "Created: ${FEATURES_DIR}/app/"

# --- Wear submodule (optional) ---

if [[ "${WITH_WEAR}" == true ]]; then
    WEAR_SRC="${FEATURES_DIR}/wear/src/main/kotlin/${PACKAGE_PATH}/features/${FEATURE_LOWER}/wear"

    mkdir -p "${WEAR_SRC}/di"

    cat >"${FEATURES_DIR}/wear/build.gradle.kts" <<GRADLE
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "${BASE_PACKAGE}.features.${FEATURE_LOWER}.wear"
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
}
GRADLE

    cat >"${WEAR_SRC}/Wear${FEATURE_CAPITALIZED}ViewModel.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_LOWER}.wear

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class Wear${FEATURE_CAPITALIZED}UiState(
    val isLoading: Boolean = false,
    val error: String? = null,
)

class Wear${FEATURE_CAPITALIZED}ViewModel : ViewModel() {

    private val _uiState = MutableStateFlow(Wear${FEATURE_CAPITALIZED}UiState())
    val uiState: StateFlow<Wear${FEATURE_CAPITALIZED}UiState> = _uiState.asStateFlow()
}
KOTLIN

    cat >"${WEAR_SRC}/Wear${FEATURE_CAPITALIZED}Screen.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_LOWER}.wear

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
fun Wear${FEATURE_CAPITALIZED}Screen(
    viewModel: Wear${FEATURE_CAPITALIZED}ViewModel = koinViewModel(),
) {
    val uiState by viewModel.uiState.collectAsState()
    Wear${FEATURE_CAPITALIZED}Content(uiState = uiState)
}

@Composable
private fun Wear${FEATURE_CAPITALIZED}Content(uiState: Wear${FEATURE_CAPITALIZED}UiState) {
    ScalingLazyColumn(
        modifier = Modifier,
    ) {
        item {
            Text(text = "${FEATURE_CAPITALIZED}")
        }
    }
}

@Preview(device = WearDevices.SMALL_ROUND, showSystemUi = true)
@Composable
private fun Wear${FEATURE_CAPITALIZED}ScreenPreview() {
    Wear${FEATURE_CAPITALIZED}Content(uiState = Wear${FEATURE_CAPITALIZED}UiState())
}
KOTLIN

    cat >"${WEAR_SRC}/di/Wear${FEATURE_CAPITALIZED}Module.kt" <<KOTLIN
package ${BASE_PACKAGE}.features.${FEATURE_LOWER}.wear.di

import ${BASE_PACKAGE}.features.${FEATURE_LOWER}.wear.Wear${FEATURE_CAPITALIZED}ViewModel
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

val wear${FEATURE_CAPITALIZED}Module = module {
    viewModel { Wear${FEATURE_CAPITALIZED}ViewModel() }
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
