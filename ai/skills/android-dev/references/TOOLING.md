# Tooling: Version Catalog & Build Plumbing

The `bootstrap.sh` and `generate.sh` scripts generate `build.gradle.kts` files that reference these `libs.versions.toml` keys. Verify they exist in your catalog or adjust the generated files.

## Plugins

- `libs.plugins.android.application`
- `libs.plugins.android.library`
- `libs.plugins.kotlin.jvm` (for `:core:model` and `:core:domain`)
- `libs.plugins.kotlin.compose`
- `libs.plugins.kotlin.serialization` (for Navigation 3 `@Serializable` keys in platform shells)
- `libs.plugins.ksp` (for `:core:data` Room)
- `libs.plugins.spotless`

AGP 9.0+ bundles Kotlin support, so `libs.plugins.kotlin.android` is **not** applied alongside `android.application` or `android.library` — adding it triggers a build error. The pure-Kotlin modules (`:core:model`, `:core:domain`) still use `kotlin.jvm`.

## Versions

- `libs.versions.compileSdk`
- `libs.versions.minSdk`
- `libs.versions.wearMinSdk`
- `libs.versions.navigation3`
- `libs.versions.wearCompose`
- `libs.versions.kotlinxSerialization`
- `libs.versions.lifecycle`
- `libs.versions.glanceAppwidget` (when generating widgets)
- `libs.versions.glanceWear` (when generating widgets)
- `libs.versions.remoteCompose` (when generating widgets)
- `libs.versions.wearRemoteMaterial3` (when generating widgets)

## Module-by-module dependency requirements

**`:core:model` deps:** none (pure Kotlin, no dependencies).

**`:core:domain` deps:**

- `libs.kotlinx.coroutines.core`

**`:core:data` deps:**

- `libs.androidx.room.runtime`, `libs.androidx.room.ktx`, `libs.androidx.room.compiler`
- `libs.androidx.datastore.preferences`
- `libs.koin.android`

**`:core:strings` deps:** none (resources-only Android library, leaf module).

**`:core:designsystem:common` deps:** none (resources-only Android library, leaf module).

**Platform shell (`:app`, `:wear`) deps:**

- `libs.androidx.core.ktx`, `libs.androidx.activity.compose`, `libs.androidx.lifecycle.viewmodel.compose`
- `libs.koin.android`, `libs.koin.androidx.compose`
- `libs.compose.bom`, `libs.compose.runtime`, `libs.compose.ui`, `libs.compose.foundation`, `libs.compose.ui.tooling.preview`, `libs.compose.ui.tooling`
- Navigation 3: `libs.androidx.navigation3.runtime`, `libs.androidx.navigation3.ui`, `libs.kotlinx.serialization.json`
- Optional destination-scoped ViewModels: `libs.androidx.lifecycle.viewmodel.navigation3`
- `:app`: `libs.compose.material3`
- `:wear`: `libs.wear.compose.material3`, `libs.wear.compose.foundation`, `libs.wear.compose.navigation3`, `libs.wear.tooling.preview`

**Feature module deps** (same for `app/` and `wear/` submodules):

- `libs.androidx.lifecycle.viewmodel`
- `libs.koin.androidx.compose`
- Compose BOM + runtime/ui/foundation
- `app/` adds `libs.compose.material3`, `libs.compose.ui.tooling.preview`, `libs.compose.ui.tooling`
- `wear/` adds `libs.wear.compose.material3`, `libs.wear.compose.foundation`, `libs.wear.tooling.preview`

Feature modules and platform shells (and `:widget:app` / `:widget:wear`) also depend on `project(":core:designsystem:common")` for shared drawables and resource values. The script-generated `build.gradle.kts` files already include this; only adjust if you delete or rename the module.

When a lazy-promoted `:core:designsystem:<platform>` module exists, matching feature modules may add `project(":core:designsystem:<platform>")`; see `ARCHITECTURE.md` for promotion triggers.

**`:widget:common` deps:**

- `api(project(":core:model"))`
- `implementation(project(":core:domain"))`
- `libs.kotlinx.coroutines.core`

**`:widget:app` deps:**

- `libs.androidx.glance.appwidget`
- `libs.koin.android`
- Same core deps as feature modules (`:core:domain`, `:core:strings`, `:core:designsystem:common`, `:widget:common`)
- **No** `:core:data`

**`:widget:wear` deps:**

- `libs.androidx.glance.wear`, `libs.androidx.glance.wear.core`
- `libs.androidx.remote.core`, `libs.androidx.remote.creation.compose`
- `libs.wear.remote.material3`
- `libs.koin.android`
- Same core deps as `:widget:app`
- **No** `:core:data`, **no** `androidx.wear.tiles`

Add the version refs and library aliases above to `gradle/libs.versions.toml` when generating widgets. See the commented hints in `bootstrap.sh` output for TOML shape.
