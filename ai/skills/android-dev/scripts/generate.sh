#!/usr/bin/env bash
set -euo pipefail
set -o noclobber

# Generate a new module in an existing Android project.
#
# Usage:
#   ./generate.sh <type> [<name>] [--wear]
#
# Types:
#   app             Add :app module (phone/tablet)
#   wear            Add :wear module (Wear OS)
#   widget [--wear] Add :widget:common + :widget:app (and :widget:wear with --wear)
#   complications   Add :complications module (Wear OS data providers)
#   feature <name>  Add :features:<name>:app (and :wear with --wear)
#
# Examples:
#   ./generate.sh app
#   ./generate.sh wear
#   ./generate.sh feature dashboard
#   ./generate.sh feature dashboard --wear
#   ./generate.sh widget [--wear]

# --- Help / arg parsing ---

if [[ $# -lt 1 ]]; then
    cat <<USAGE
Usage: $0 <type> [<name>] [--wear]

Types:
  app              Add :app module (phone/tablet)
  wear             Add :wear module (Wear OS)
  widget [--wear]  Add :widget:common + :widget:app (and :widget:wear with --wear)
  complications    Add :complications module (Wear OS data providers)
  feature <name>   Add :features:<name>:app (and :wear with --wear)
USAGE
    exit 1
fi

TYPE="$1"
shift

# --- Project root validation ---

if [[ ! -f "gradle.properties" || ! -f "settings.gradle.kts" ]]; then
    echo "Error: not in an Android project root (missing gradle.properties or settings.gradle.kts)."
    echo "Run 'android create empty-activity --name=<Name> --output=./<dir>' then scripts/bootstrap.sh first."
    exit 1
fi

BASE_PACKAGE=$(grep '^android.basePackage=' gradle.properties | cut -d= -f2 || true)
if [[ -z "${BASE_PACKAGE:-}" ]]; then
    echo "Error: android.basePackage not found in gradle.properties."
    echo "This project may not have been bootstrapped. Run scripts/bootstrap.sh first."
    exit 1
fi

PACKAGE_PATH="${BASE_PACKAGE//.//}"

# --- Helpers ---

# Append `include(...)` to settings.gradle.kts only if not already present.
append_include() {
    local include_line="$1"
    if ! grep -qF "$include_line" settings.gradle.kts; then
        echo "" >> settings.gradle.kts
        echo "$include_line" >> settings.gradle.kts
        echo "Updated: settings.gradle.kts (added $include_line)"
    fi
}

# Append `implementation(project(...))` inside an existing dependencies block.
add_impl_dependency() {
    local gradle_file="$1"
    local project_path="$2"
    if [[ ! -f "$gradle_file" ]] || grep -qF "$project_path" "$gradle_file"; then
        return
    fi
    local dep_line="    implementation(project(\"$project_path\"))"
    awk -v dep="$dep_line" '
        /^dependencies \{/ { in_deps=1 }
        in_deps && /^\}/ { print dep; in_deps=0 }
        { print }
    ' "$gradle_file" > "${gradle_file}.tmp" && mv "${gradle_file}.tmp" "$gradle_file"
    echo "Updated: $gradle_file (added $project_path)"
}

# kebab-or-snake case → PascalCase
to_pascal() {
    echo "$1" | awk -F'[-_]' '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS=''
}

# kebab-or-snake case → camelCase
to_camel() {
    echo "$1" | awk -F'[-_]' '{for(i=2;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS=''
}

# Strip hyphens/underscores → lowercase package segment
to_pkg() {
    echo "$1" | tr -d '_-'
}

# --- Dispatch ---

case "$TYPE" in

# ============================================================
# :app — phone/tablet shell
# ============================================================
app)
    if [[ -e "app" ]]; then
        echo "Skipped: app/ already exists. To recreate, delete the directory first."
        exit 0
    fi

    APP_PKG_PATH="app/src/main/kotlin/$PACKAGE_PATH"
    mkdir -p "$APP_PKG_PATH/di" "$APP_PKG_PATH/navigation" "$APP_PKG_PATH/theme"

    cat > app/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
}

android {
    namespace = "$BASE_PACKAGE"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        applicationId = "$BASE_PACKAGE"
        minSdk = libs.versions.minSdk.get().toInt()
        targetSdk = libs.versions.compileSdk.get().toInt()
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.koin.android)
    implementation(libs.koin.androidx.compose)
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.runtime)
    implementation(libs.compose.ui)
    implementation(libs.compose.foundation)
    implementation(libs.compose.material3)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.androidx.navigation3.runtime)
    implementation(libs.androidx.navigation3.ui)
    implementation(libs.kotlinx.serialization.json)
    debugImplementation(libs.compose.ui.tooling)
}
EOF

    cat > app/src/main/AndroidManifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:name=".AppApplication"
        android:label="@string/app_name"
        android:theme="@android:style/Theme.Material.Light.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOF

    cat > "$APP_PKG_PATH/AppApplication.kt" <<EOF
package $BASE_PACKAGE

import android.app.Application
import $BASE_PACKAGE.data.di.coreDataModule
import $BASE_PACKAGE.di.appModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class AppApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@AppApplication)
            modules(coreDataModule, appModule)
        }
    }
}
EOF

    cat > "$APP_PKG_PATH/MainActivity.kt" <<EOF
package $BASE_PACKAGE

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import $BASE_PACKAGE.strings.R
import $BASE_PACKAGE.theme.AppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            AppTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    Greeting()
                }
            }
        }
    }
}

@Composable
private fun Greeting() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = stringResource(R.string.app_name))
    }
}

@Preview(showBackground = true)
@Composable
private fun GreetingPreview() {
    AppTheme {
        Greeting()
    }
}
EOF

    cat > "$APP_PKG_PATH/di/AppModule.kt" <<EOF
package $BASE_PACKAGE.di

import org.koin.dsl.module

val appModule = module {
    // Add feature DI modules here as you create them.
}
EOF

    cat > "$APP_PKG_PATH/navigation/AppNavigation.kt" <<EOF
package $BASE_PACKAGE.navigation

// AGENT: Wire Navigation 3 here.
// Define @Serializable NavKey objects for each screen and a NavDisplay that consumes them.
EOF

    cat > "$APP_PKG_PATH/theme/AppTheme.kt" <<EOF
package $BASE_PACKAGE.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext

@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val context = LocalContext.current
    val colorScheme = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    } else {
        if (darkTheme) androidx.compose.material3.darkColorScheme() else androidx.compose.material3.lightColorScheme()
    }
    MaterialTheme(colorScheme = colorScheme, content = content)
}
EOF

    append_include 'include(":app")'
    if [[ -f "widget/app/build.gradle.kts" ]]; then
        add_impl_dependency "app/build.gradle.kts" ":widget:app"
    fi
    echo "Created: app/"
    ;;

# ============================================================
# :wear — Wear OS shell
# ============================================================
wear)
    if [[ -e "wear" ]]; then
        echo "Skipped: wear/ already exists. To recreate, delete the directory first."
        exit 0
    fi

    WEAR_PKG_PATH="wear/src/main/kotlin/$PACKAGE_PATH/wear"
    mkdir -p "$WEAR_PKG_PATH/di" "$WEAR_PKG_PATH/navigation" "$WEAR_PKG_PATH/theme"

    cat > wear/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.kotlin.serialization)
}

android {
    namespace = "$BASE_PACKAGE.wear"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        applicationId = "$BASE_PACKAGE"
        minSdk = libs.versions.wearMinSdk.get().toInt()
        targetSdk = libs.versions.compileSdk.get().toInt()
        versionCode = 1
        versionName = "1.0"
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.koin.android)
    implementation(libs.koin.androidx.compose)
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.runtime)
    implementation(libs.compose.ui)
    implementation(libs.compose.foundation)
    implementation(libs.wear.compose.material3)
    implementation(libs.wear.compose.foundation)
    implementation(libs.androidx.navigation3.runtime)
    implementation(libs.androidx.navigation3.ui)
    implementation(libs.wear.compose.navigation3)
    implementation(libs.kotlinx.serialization.json)
    debugImplementation(libs.compose.ui.tooling)
    debugImplementation(libs.wear.tooling.preview)
}
EOF

    cat > wear/src/main/AndroidManifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-feature android:name="android.hardware.type.watch" />

    <application
        android:name=".WearAppApplication"
        android:label="@string/app_name"
        android:theme="@android:style/Theme.DeviceDefault">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOF

    cat > "$WEAR_PKG_PATH/WearAppApplication.kt" <<EOF
package $BASE_PACKAGE.wear

import android.app.Application
import $BASE_PACKAGE.data.di.coreDataModule
import $BASE_PACKAGE.wear.di.wearAppModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class WearAppApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@WearAppApplication)
            modules(coreDataModule, wearAppModule)
        }
    }
}
EOF

    cat > "$WEAR_PKG_PATH/MainActivity.kt" <<EOF
package $BASE_PACKAGE.wear

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.wear.compose.material3.Text
import androidx.wear.tooling.preview.devices.WearDevices
import $BASE_PACKAGE.strings.R
import $BASE_PACKAGE.wear.theme.WearAppTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            WearAppTheme {
                Greeting()
            }
        }
    }
}

@Composable
private fun Greeting() {
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = stringResource(R.string.app_name))
    }
}

@Preview(device = WearDevices.SMALL_ROUND, showSystemUi = true)
@Composable
private fun GreetingPreview() {
    WearAppTheme {
        Greeting()
    }
}
EOF

    cat > "$WEAR_PKG_PATH/di/WearAppModule.kt" <<EOF
package $BASE_PACKAGE.wear.di

import org.koin.dsl.module

val wearAppModule = module {
    // Add feature DI modules here as you create them.
}
EOF

    cat > "$WEAR_PKG_PATH/navigation/WearNavigation.kt" <<EOF
package $BASE_PACKAGE.wear.navigation

// AGENT: Wire Wear Navigation 3 here.
// Define @Serializable NavKey objects, create a rememberNavBackStack(), and render a NavDisplay
// with rememberSwipeDismissableSceneStrategy() for Wear swipe-to-dismiss behavior.
EOF

    cat > "$WEAR_PKG_PATH/theme/WearAppTheme.kt" <<EOF
package $BASE_PACKAGE.wear.theme

import androidx.compose.runtime.Composable
import androidx.wear.compose.material3.MaterialTheme

@Composable
fun WearAppTheme(content: @Composable () -> Unit) {
    // Wear OS 6+ supports dynamic color via the system theme.
    MaterialTheme(content = content)
}
EOF

    append_include 'include(":wear")'
    if [[ -f "widget/wear/build.gradle.kts" ]]; then
        add_impl_dependency "wear/build.gradle.kts" ":widget:wear"
    fi
    echo "Created: wear/"
    ;;

# ============================================================
# widget [--wear] — :widget:common + :widget:app (+ :widget:wear)
# ============================================================
widget)
    WITH_WEAR=false
    if [[ "${1:-}" == "--wear" ]]; then
        WITH_WEAR=true
        shift
    fi

    if [[ -e "widget" ]]; then
        echo "Skipped: widget/ already exists. To recreate, delete the directory first."
        exit 0
    fi

    WIDGET_COMMON_PKG="widget/common/src/main/kotlin/$PACKAGE_PATH/widget/common"
    WIDGET_APP_PKG="widget/app/src/main/kotlin/$PACKAGE_PATH/widget"
    mkdir -p "$WIDGET_COMMON_PKG" "$WIDGET_APP_PKG" "widget/app/src/main/res/xml"

    # --- :widget:common — pure Kotlin shared widget state ---
    cat > widget/common/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.kotlin.jvm)
}

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}

dependencies {
    api(project(":core:model"))
    implementation(project(":core:domain"))
    implementation(libs.kotlinx.coroutines.core)
}
EOF

    cat > "$WIDGET_COMMON_PKG/WidgetDisplayState.kt" <<EOF
package $BASE_PACKAGE.widget.common

/** Platform-agnostic presentation state shared by :widget:app and :widget:wear. */
data class WidgetDisplayState(
    val primaryText: String,
    val secondaryText: String = "",
)
EOF

    append_include 'include(":widget:common")'
    echo "Created: widget/common/"

    # --- :widget:app — phone home-screen Glance widget ---
    cat > widget/app/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "$BASE_PACKAGE.widget"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(project(":widget:common"))
    implementation(libs.androidx.glance.appwidget)
    implementation(libs.koin.android)
}
EOF

    cat > widget/app/src/main/AndroidManifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application>
        <receiver
            android:name=".AppWidgetReceiver"
            android:exported="true">
            <intent-filter>
                <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            </intent-filter>
            <meta-data
                android:name="android.appwidget.provider"
                android:resource="@xml/app_widget_info" />
        </receiver>
    </application>

</manifest>
EOF

    cat > widget/app/src/main/res/xml/app_widget_info.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<appwidget-provider xmlns:android="http://schemas.android.com/apk/res/android"
    android:initialLayout="@layout/glance_default_loading_layout"
    android:minWidth="40dp"
    android:minHeight="40dp"
    android:resizeMode="horizontal|vertical"
    android:updatePeriodMillis="0"
    android:widgetCategory="home_screen" />
EOF

    cat > "$WIDGET_APP_PKG/AppWidgetReceiver.kt" <<EOF
package $BASE_PACKAGE.widget

import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class AppWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = AppWidget()
}
EOF

    cat > "$WIDGET_APP_PKG/AppWidget.kt" <<EOF
package $BASE_PACKAGE.widget

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.fillMaxSize
import androidx.glance.text.Text
import $BASE_PACKAGE.strings.R
import $BASE_PACKAGE.widget.common.WidgetDisplayState

class AppWidget : GlanceAppWidget() {
    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // AGENT: Map domain data to WidgetDisplayState in :widget:common, then render.
            WidgetContent(
                state = WidgetDisplayState(primaryText = context.getString(R.string.app_name)),
            )
        }
    }
}

@Composable
private fun WidgetContent(state: WidgetDisplayState) {
    Box(modifier = GlanceModifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = state.primaryText)
    }
}
EOF

    append_include 'include(":widget:app")'
    echo "Created: widget/app/"
    add_impl_dependency "app/build.gradle.kts" ":widget:app"

    # --- :widget:wear — Glance Wear Widget (not Tiles API) ---
    if [[ "$WITH_WEAR" == true ]]; then
        WIDGET_WEAR_PKG="widget/wear/src/main/kotlin/$PACKAGE_PATH/widget/wear"
        mkdir -p "$WIDGET_WEAR_PKG" "widget/wear/src/main/res/xml"

        cat > widget/wear/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "$BASE_PACKAGE.widget.wear"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.wearMinSdk.get().toInt()
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(project(":widget:common"))
    implementation(libs.androidx.glance.wear)
    implementation(libs.androidx.glance.wear.core)
    implementation(libs.androidx.remote.core)
    implementation(libs.androidx.remote.creation.compose)
    implementation(libs.wear.remote.material3)
    implementation(libs.koin.android)
}
EOF

        cat > widget/wear/src/main/AndroidManifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application>
        <service
            android:name=".WearAppWidgetService"
            android:exported="true"
            android:label="@string/app_name">
            <intent-filter>
                <action android:name="androidx.glance.wear.action.BIND_WIDGET_PROVIDER" />
            </intent-filter>
            <meta-data
                android:name="androidx.glance.wear.widget.provider"
                android:resource="@xml/wear_app_widget_info" />
        </service>
    </application>

</manifest>
EOF

        cat > widget/wear/src/main/res/xml/wear_app_widget_info.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<wearwidget-provider
    description="@string/app_name"
    label="@string/app_name"
    preferredType="SMALL">
    <container
        type="SMALL"
        previewImage="@android:drawable/sym_def_app_icon" />
</wearwidget-provider>
EOF

        cat > "$WIDGET_WEAR_PKG/WearAppWidgetService.kt" <<EOF
package $BASE_PACKAGE.widget.wear

import androidx.glance.wear.GlanceWearWidget
import androidx.glance.wear.GlanceWearWidgetService

class WearAppWidgetService : GlanceWearWidgetService() {
    override val widget: GlanceWearWidget = WearAppWidget()
}
EOF

        cat > "$WIDGET_WEAR_PKG/WearAppWidget.kt" <<EOF
package $BASE_PACKAGE.widget.wear

import android.content.Context
import androidx.compose.remote.creation.compose.layout.RemoteAlignment
import androidx.compose.remote.creation.compose.layout.RemoteBox
import androidx.compose.remote.creation.compose.layout.RemoteComposable
import androidx.compose.remote.creation.compose.modifier.RemoteModifier
import androidx.compose.remote.creation.compose.modifier.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.tooling.preview.Preview
import androidx.glance.wear.GlanceWearWidget
import androidx.glance.wear.WearWidgetBrush
import androidx.glance.wear.WearWidgetData
import androidx.glance.wear.WearWidgetDocument
import androidx.glance.wear.core.WearWidgetParams
import androidx.wear.compose.remote.material3.RemoteMaterialTheme
import androidx.wear.compose.remote.material3.RemoteText
import $BASE_PACKAGE.widget.common.WidgetDisplayState

class WearAppWidget : GlanceWearWidget() {
    override suspend fun provideWidgetData(
        context: Context,
        params: WearWidgetParams,
    ): WearWidgetData {
        // AGENT: Read domain data via Koin-injected repository or use case.
        val state = WidgetDisplayState(primaryText = context.getString($BASE_PACKAGE.strings.R.string.app_name))
        return WearWidgetDocument(background = WearWidgetBrush) {
            WearWidgetContent(state = state)
        }
    }
}

@RemoteComposable
@Composable
private fun WearWidgetContent(state: WidgetDisplayState) {
    RemoteMaterialTheme {
        RemoteBox(
            modifier = RemoteModifier.fillMaxSize(),
            contentAlignment = RemoteAlignment.Center,
        ) {
            RemoteText(
                text = androidx.compose.remote.creation.compose.state.RemoteString(state.primaryText),
                textAlign = TextAlign.Center,
                maxLines = 1,
            )
        }
    }
}

@Preview
@Composable
private fun WearAppWidgetPreview() {
    WearWidgetContent(state = WidgetDisplayState(primaryText = "Preview"))
}
EOF

        append_include 'include(":widget:wear")'
        echo "Created: widget/wear/"
        add_impl_dependency "wear/build.gradle.kts" ":widget:wear"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Add Glance / Glance Wear library aliases to gradle/libs.versions.toml (see references/TOOLING.md)"
    echo "  2. Platform shells (:app, :wear) start Koin with coreDataModule so widgets can inject repositories"
    if [[ "$WITH_WEAR" == false ]]; then
        echo "  3. For Wear widgets, re-run: scripts/generate.sh widget --wear (after deleting widget/ if needed)"
    fi
    echo "  4. Do not use the legacy Wear Tiles API (androidx.wear.tiles) — use Glance Wear Widgets instead"
    ;;

# ============================================================
# :complications — Wear OS data providers
# ============================================================
complications)
    if [[ -e "complications" ]]; then
        echo "Skipped: complications/ already exists. To recreate, delete the directory first."
        exit 0
    fi

    COMP_PKG_PATH="complications/src/main/kotlin/$PACKAGE_PATH/complications"
    mkdir -p "$COMP_PKG_PATH"

    cat > complications/build.gradle.kts <<EOF
plugins {
    alias(libs.plugins.android.library)
}

android {
    namespace = "$BASE_PACKAGE.complications"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.wearMinSdk.get().toInt()
    }
}

dependencies {
    implementation(project(":core:domain"))
    implementation(libs.androidx.wear.watchface.complications.data.source.ktx)
    implementation(libs.koin.android)
}
EOF

    cat > complications/src/main/AndroidManifest.xml <<EOF
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application>
        <service
            android:name=".AppComplicationService"
            android:exported="true"
            android:permission="com.google.android.wearable.permission.BIND_COMPLICATION_PROVIDER">
            <intent-filter>
                <action android:name="android.support.wearable.complications.ACTION_COMPLICATION_UPDATE_REQUEST" />
            </intent-filter>
            <meta-data
                android:name="android.support.wearable.complications.SUPPORTED_TYPES"
                android:value="SHORT_TEXT" />
            <meta-data
                android:name="android.support.wearable.complications.UPDATE_PERIOD_SECONDS"
                android:value="600" />
        </service>
    </application>

</manifest>
EOF

    cat > "$COMP_PKG_PATH/AppComplicationService.kt" <<EOF
package $BASE_PACKAGE.complications

import androidx.wear.watchface.complications.data.ComplicationData
import androidx.wear.watchface.complications.data.ComplicationType
import androidx.wear.watchface.complications.data.PlainComplicationText
import androidx.wear.watchface.complications.data.ShortTextComplicationData
import androidx.wear.watchface.complications.datasource.ComplicationRequest
import androidx.wear.watchface.complications.datasource.SuspendingComplicationDataSourceService

class AppComplicationService : SuspendingComplicationDataSourceService() {

    override fun getPreviewData(type: ComplicationType): ComplicationData? {
        if (type != ComplicationType.SHORT_TEXT) return null
        return shortText("--")
    }

    override suspend fun onComplicationRequest(request: ComplicationRequest): ComplicationData? {
        // AGENT: Read data via a use case from :core:domain.
        return shortText("--")
    }

    private fun shortText(value: String): ShortTextComplicationData =
        ShortTextComplicationData.Builder(
            text = PlainComplicationText.Builder(value).build(),
            contentDescription = PlainComplicationText.Builder(value).build(),
        ).build()
}
EOF

    append_include 'include(":complications")'
    echo "Created: complications/"
    ;;

# ============================================================
# feature <name> [--wear]
# ============================================================
feature)
    if [[ $# -lt 1 ]]; then
        echo "Error: feature type requires a name."
        echo "  e.g. $0 feature dashboard [--wear]"
        exit 1
    fi

    FEATURE="$1"
    shift
    WITH_WEAR=false
    if [[ "${1:-}" == "--wear" ]]; then
        WITH_WEAR=true
    fi

    # Validate feature name
    if ! [[ "$FEATURE" =~ ^[a-z][a-z0-9]*([-_][a-z0-9]+)*$ ]]; then
        echo "Error: feature name must be lowercase, start with a letter, and use only hyphens or underscores as separators"
        echo "  valid:   auth, fasting-timer, step_counter"
        echo "  invalid: Auth, fasting-Timer, -timer"
        exit 1
    fi

    if [[ -e "features/$FEATURE" ]]; then
        echo "Error: features/$FEATURE/ already exists."
        echo "Pick a different feature name or delete the existing directory."
        exit 1
    fi

    FEATURE_SLUG="$FEATURE"
    FEATURE_PKG="$(to_pkg "$FEATURE")"
    FEATURE_CLASS="$(to_pascal "$FEATURE")"
    FEATURE_CAMEL="$(to_camel "$FEATURE")"

    # --- Feature :app submodule ---
    APP_SRC="features/$FEATURE_SLUG/app/src/main/kotlin/$PACKAGE_PATH/features/$FEATURE_PKG"
    mkdir -p "$APP_SRC/component" "$APP_SRC/di"
    touch "$APP_SRC/component/.gitkeep"

    cat > "features/$FEATURE_SLUG/app/build.gradle.kts" <<EOF
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "$BASE_PACKAGE.features.$FEATURE_PKG"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.minSdk.get().toInt()
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
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
EOF

    cat > "features/$FEATURE_SLUG/app/src/main/AndroidManifest.xml" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" />
EOF

    cat > "$APP_SRC/${FEATURE_CLASS}ViewModel.kt" <<EOF
package $BASE_PACKAGE.features.$FEATURE_PKG

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
EOF

    cat > "$APP_SRC/${FEATURE_CLASS}Screen.kt" <<EOF
package $BASE_PACKAGE.features.$FEATURE_PKG

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
    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        Text(text = "${FEATURE_CLASS}")
    }
}

@Preview(showBackground = true)
@Composable
private fun ${FEATURE_CLASS}ScreenPreview() {
    ${FEATURE_CLASS}Content(uiState = ${FEATURE_CLASS}UiState())
}
EOF

    cat > "$APP_SRC/di/${FEATURE_CLASS}Module.kt" <<EOF
package $BASE_PACKAGE.features.$FEATURE_PKG.di

import $BASE_PACKAGE.features.$FEATURE_PKG.${FEATURE_CLASS}ViewModel
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

val ${FEATURE_CAMEL}Module = module {
    // Add get() arguments here when the ViewModel takes use cases.
    viewModel { ${FEATURE_CLASS}ViewModel() }
}
EOF

    echo "Created: features/$FEATURE_SLUG/app/"

    # --- Feature :wear submodule (optional) ---
    if [[ "$WITH_WEAR" == true ]]; then
        WEAR_SRC="features/$FEATURE_SLUG/wear/src/main/kotlin/$PACKAGE_PATH/features/$FEATURE_PKG/wear"
        mkdir -p "$WEAR_SRC/component" "$WEAR_SRC/di"
        touch "$WEAR_SRC/component/.gitkeep"

        cat > "features/$FEATURE_SLUG/wear/build.gradle.kts" <<EOF
plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.compose)
}

android {
    namespace = "$BASE_PACKAGE.features.$FEATURE_PKG.wear"
    compileSdk = libs.versions.compileSdk.get().toInt()

    defaultConfig {
        minSdk = libs.versions.wearMinSdk.get().toInt()
    }

    buildFeatures {
        compose = true
    }
}

dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(libs.androidx.lifecycle.viewmodel)
    implementation(libs.koin.androidx.compose)
    implementation(libs.wear.compose.material3)
    implementation(libs.wear.compose.foundation)
    debugImplementation(libs.wear.tooling.preview)
}
EOF

        cat > "features/$FEATURE_SLUG/wear/src/main/AndroidManifest.xml" <<EOF
<manifest xmlns:android="http://schemas.android.com/apk/res/android" />
EOF

        cat > "$WEAR_SRC/Wear${FEATURE_CLASS}ViewModel.kt" <<EOF
package $BASE_PACKAGE.features.$FEATURE_PKG.wear

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
EOF

        cat > "$WEAR_SRC/Wear${FEATURE_CLASS}Screen.kt" <<EOF
package $BASE_PACKAGE.features.$FEATURE_PKG.wear

import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.wear.compose.foundation.lazy.ScalingLazyColumn
import androidx.wear.compose.material3.Text
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
    ScalingLazyColumn(modifier = Modifier) {
        item { Text(text = "${FEATURE_CLASS}") }
    }
}

@Preview(device = WearDevices.SMALL_ROUND, showSystemUi = true)
@Composable
private fun Wear${FEATURE_CLASS}ScreenPreview() {
    Wear${FEATURE_CLASS}Content(uiState = Wear${FEATURE_CLASS}UiState())
}
EOF

        cat > "$WEAR_SRC/di/Wear${FEATURE_CLASS}Module.kt" <<EOF
package $BASE_PACKAGE.features.$FEATURE_PKG.wear.di

import $BASE_PACKAGE.features.$FEATURE_PKG.wear.Wear${FEATURE_CLASS}ViewModel
import org.koin.core.module.dsl.viewModel
import org.koin.dsl.module

val wear${FEATURE_CLASS}Module = module {
    // Add get() arguments here when the ViewModel takes use cases.
    viewModel { Wear${FEATURE_CLASS}ViewModel() }
}
EOF

        echo "Created: features/$FEATURE_SLUG/wear/"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Register Koin module(s) in the platform shell's AppModule.kt:"
    echo "     - app/.../di/AppModule.kt → load ${FEATURE_CAMEL}Module"
    if [[ "$WITH_WEAR" == true ]]; then
        echo "     - wear/.../di/WearAppModule.kt → load wear${FEATURE_CLASS}Module"
    fi
    echo "  2. Add navigation routes in the platform module(s)"
    echo "  3. Add feature strings to core/strings/src/main/res/values/strings.xml"
    echo "  4. Write tests, then implement"
    ;;

# ============================================================
*)
    echo "Error: unknown type '$TYPE'"
    echo "Valid types: app, wear, widget, complications, feature"
    exit 1
    ;;

esac
