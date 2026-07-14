# Multi-Platform Tiered Core Architecture

## Overview

Multi-module Android architecture targeting `:app` (phone/tablet), Wear OS, and optionally TV/Auto from a single codebase. The core layer is split into five sub-modules so feature modules don't pull in the full data layer, business logic can be tested as pure Kotlin, shared models can be consumed from anywhere (including standalone OS surfaces like widgets and `:complications`) without dragging Android types onto their classpath, and resources have explicit homes.

**Core sub-modules:**

- `:core:model` — pure Kotlin (`kotlin("jvm")`): domain models and value types. No dependencies.
- `:core:domain` — pure Kotlin (`kotlin("jvm")`): repository interfaces and use cases. Depends on `:core:model`. No Android dependencies.
- `:core:data` — Android library: Room, DataStore, network, security, repository implementations, DI wiring.
- `:core:strings` — Android library, strings only: every user-facing string with per-locale translations.
- `:core:designsystem:common` — Android library, non-string resources: drawables, color values, typography, shape values. Platform-specific Compose design-system siblings are lazy promotions.

**Platform shells:**

- `:app` — Android phone/tablet
- `:wear` — Wear OS
- `:tv` — Android TV (optional)
- `:auto` — Android Auto (optional)

**Standalone OS entry points:**

- `:widget:common`, `:widget:app`, `:widget:wear` — Glance widgets (phone + Wear)
- `:complications` — Wear OS complication data providers

**Feature modules:**

- `:features:<name>:app` — `:app` presentation
- `:features:<name>:wear` — `:wear` presentation

## What is a Feature?

A **feature** is a complete user journey or business capability, not just a single screen.

### Good Features (Business Capabilities)

- **auth** — login, register, forgot password
- **profile** — view, edit, settings
- **cart** — shopping cart and checkout

### Poor Features (Just Screens)

- **login-screen** — too granular, belongs in `auth`
- **settings-screen** — belongs in `profile`

Each feature is its own Gradle module under `features/<name>/<platform>/`. Features cannot depend on each other — only on `:core:domain` and `:core:strings`. Gradle enforces this at compile time.

## Module Structure

Every feature uses platform submodules (`app/`, `wear/`, etc.) — even when it only targets one platform today. Adding a new platform variant later is just adding a sibling submodule.

```
my-app/
├── settings.gradle.kts          # auto-discovers :core:* and :features:*:*
├── build.gradle.kts             # plugin aliases, Spotless config
├── gradle.properties            # includes android.basePackage (read by generate.sh)
│
├── app/                         # :app — phone/tablet shell
│   └── src/main/kotlin/com/myapp/
│       ├── AppApplication.kt        # Koin Application class
│       ├── MainActivity.kt          # ComponentActivity, Compose entry point
│       ├── di/
│       │   └── AppModule.kt         # loads coreDataModule + feature DI modules
│       ├── navigation/              # Navigation 3 setup
│       │   └── AppNavigation.kt
│       └── theme/
│           └── AppTheme.kt          # MaterialTheme + dynamic colors
│
├── wear/                        # :wear — Wear OS shell
│   └── src/main/kotlin/com/myapp/wear/
│       ├── WearAppApplication.kt
│       ├── MainActivity.kt          # uses WearAppTheme
│       ├── di/
│       │   └── WearAppModule.kt
│       ├── navigation/              # Navigation 3 + SwipeDismissableSceneStrategy
│       │   └── WearNavigation.kt
│       └── theme/
│           └── WearAppTheme.kt      # Wear MaterialTheme
│
├── core/
│   ├── model/                   # :core:model — pure Kotlin (kotlin("jvm"))
│   │   └── src/main/kotlin/com/myapp/model/
│   │       ├── User.kt              # domain models
│   │       ├── Article.kt
│   │       └── ...
│   │
│   ├── domain/                  # :core:domain — pure Kotlin (kotlin("jvm"))
│   │   └── src/main/kotlin/com/myapp/domain/
│   │       ├── repository/          # repository interfaces (depend on :core:model)
│   │       └── usecase/             # use cases, grouped by capability
│   │           ├── library/
│   │           └── reader/
│   │
│   ├── data/                    # :core:data — Android library
│   │   └── src/main/kotlin/com/myapp/data/
│   │       ├── local/               # Room database, DAOs, entities
│   │       ├── remote/              # Retrofit/Ktor interfaces, DTOs (when needed)
│   │       ├── repository/          # repository implementations
│   │       └── di/
│   │           └── CoreDataModule.kt    # Koin bindings for repositories + use cases
│   │
│   ├── strings/                 # :core:strings — Android library, strings only
│   │   └── src/main/res/
│   │       ├── values/strings.xml       # all user-facing strings (English)
│   │       └── values-es/strings.xml    # Spanish translations
│   │
│   └── designsystem/
│       └── common/              # :core:designsystem:common — Android library, non-string resources
│           └── src/main/res/
│               ├── drawable/            # vector drawables (app logo, icons, illustrations)
│               ├── values/colors.xml    # color VALUES used from XML (manifest, splash)
│               ├── values/dimens.xml    # shared dimens (optional)
│               └── font/                # custom fonts (optional)
│
├── features/
│   └── dashboard/
│       ├── app/                 # :features:dashboard:app
│       │   └── src/main/kotlin/com/myapp/features/dashboard/
│       │       ├── DashboardViewModel.kt
│       │       ├── DashboardScreen.kt
│       │       ├── component/        # feature-local widgets (lazy-promote later)
│       │       └── di/
│       │           └── DashboardModule.kt
│       │
│       └── wear/                # :features:dashboard:wear
│           └── src/main/kotlin/com/myapp/features/dashboard/wear/
│               ├── WearDashboardViewModel.kt
│               ├── WearDashboardScreen.kt
│               ├── component/
│               └── di/
│                   └── WearDashboardModule.kt
│
├── widget/                      # widget modules (optional) — OS glanceable surfaces
│   ├── common/                  # :widget:common — pure Kotlin shared widget state
│   │   └── src/main/kotlin/com/myapp/widget/common/
│   │       └── WidgetDisplayState.kt
│   ├── app/                     # :widget:app — phone home-screen Glance widget
│   │   └── src/main/kotlin/com/myapp/widget/
│   │       ├── AppWidgetReceiver.kt
│   │       └── AppWidget.kt
│   └── wear/                    # :widget:wear — Glance Wear Widget (Remote Compose)
│       └── src/main/kotlin/com/myapp/widget/wear/
│           ├── WearAppWidgetService.kt
│           └── WearAppWidget.kt
│
└── complications/               # :complications (optional) — Wear OS data providers
    └── src/main/kotlin/com/myapp/complications/
        └── AppComplicationService.kt
```

## Dependency Flow

The dependency direction is strictly enforced. This diagram describes allowed dependency flow when modules exist; bootstrap creates only the five starter core modules. Do not infer target platforms: if the user asks for a feature, screen, shell, or UI work without naming the target surface, ask before generating modules or writing platform UI.

```
:core:model              (no deps — pure Kotlin)
:core:domain             ──→ :core:model
:core:data               ──→ :core:domain (→ :core:model)
:core:strings            (leaf — Android library, strings only)
:core:designsystem:common (leaf — Android library, drawables + non-string resources)

:app             ──→ :core:data + :core:strings + :core:designsystem:common
                 ──→ :features:*:app   ──→ :core:domain + :core:strings + :core:designsystem:common
                 ──→ :widget:app (optional)

:wear            ──→ :core:data + :core:strings + :core:designsystem:common
                 ──→ :features:*:wear  ──→ :core:domain + :core:strings + :core:designsystem:common
                 ──→ :widget:wear (optional)

:widget:common   ──→ :core:model + :core:domain
:widget:app      ──→ :widget:common + :core:domain + :core:strings + :core:designsystem:common
:widget:wear     ──→ :widget:common + :core:domain + :core:strings + :core:designsystem:common

:complications   ──→ :core:domain      (no Room/Ktor on classpath)
```

After a lazy-promotion trigger, a platform feature may also depend on its matching promoted design-system module:

```
:features:*:<platform> ──→ optionally :core:designsystem:<platform>
```

**Key rules:**

1. **Feature modules never depend on `:core:data`.** They depend only on `:core:domain` (for use cases and interfaces) and `:core:strings` (for resources). Models come in transitively via `:core:domain → :core:model`. Concrete data implementations are wired by platform shells via Koin.

2. **`:core:model` and `:core:domain` are pure Kotlin.** Use `kotlin("jvm")` plugin, not `android.library`. Cannot import Android types — enforced at compile time. Splitting model from domain means a `:complications` module or a simple widget surface that only reads pre-computed state can depend on `:core:model` (or `:core:domain` for use cases) without ever pulling in Room/Ktor.

3. **`:core:data`, `:core:strings`, and `:core:designsystem:common` are Android libraries** with no dependencies on each other. `:core:data` depends on `:core:domain` (and transitively `:core:model`). `:core:strings` is a leaf module containing only `res/values/strings.xml` with per-locale folders. `:core:designsystem:common` is a leaf module holding everything resource-y that isn't a string — drawables, color values, typography, shapes.

4. **Platform shells (`:app`, `:wear`) own DI wiring.** They load `coreDataModule` (from `:core:data`) plus their feature modules' Koin modules to provide concrete implementations to the use cases features depend on. This is dependency inversion at the module boundary.

5. **Widgets and complications are OS entry points, not features.** Widget code uses platform submodules under `widget/` (`common/`, `app/`, `wear/`) — the same pattern as features. Widget library modules merge into `:app` and `:wear` APKs; platform shells own Koin wiring so widgets can inject repositories from `:core:data` without depending on it at compile time.

6. **Wear glanceable surfaces use Glance Wear Widgets, not Tiles.** `:widget:wear` uses `GlanceWearWidget` + Remote Compose. Do not add `androidx.wear.tiles` or `BIND_TILE_PROVIDER` — the Tiles API is legacy.

7. **Widgets must be responsive.** Phone widgets use size-aware Glance App Widget layouts (`:widget:app`). Wear widgets use Remote Compose with container-size params (`:widget:wear`). Shared presentation state lives in `:widget:common`; platform UI stays in each submodule.

## Why kotlin("jvm") for :core:model and :core:domain

The single most important compile-time barrier in this architecture is making both `:core:model` and `:core:domain` pure Kotlin modules. Consequences:

- **No `Context`, no `Uri`, no `R` class.** If you need them, the logic doesn't belong in model or domain.
- **Tests run as plain JVM tests.** No Robolectric, no instrumentation, no emulator. Milliseconds per test.
- **Multi-platform reuse.** A pure Kotlin model + domain layer can later move to a `commonMain` source set if you ever go Compose Multiplatform.
- **Lean watch-side surfaces.** `:complications` and simple widget surfaces reading pre-computed state can depend on `:core:model` (or `:core:domain` for use cases) and skip Room/Ktor entirely.

If these were `android.library`, an agent (or a careless dev) could `import android.content.Context` and the architecture would silently leak Android into the supposed-pure layer. With `kotlin("jvm")` the build fails immediately.

## Why Split Model from Domain

The split mirrors what reference Android projects do (NowInAndroid, Tivi, DroidKaigi conference app all separate `model` from `domain`). Concrete benefits:

- **Stable consumability.** Models (data classes, enums) change less often than use cases and interfaces. Putting them in their own module means a use-case change doesn't invalidate every consumer's compilation.
- **Capabilities without business logic.** A standalone surface (`:complications`, a widget showing a static value) might only need types like `Book` or `DownloadState` — not the use cases that produce them. `:core:model` is what they actually need.
- **Domain stays focused.** When `:core:domain` only holds interfaces + use cases (not models), its role is unambiguous: it's the contract layer. Models support the contract but live separately.

## Why Centralized Strings (Pocket Casts Pattern)

All user-facing strings live in `:core:strings`, a leaf Android library that platform shells, feature modules, and OS surfaces all depend on. This is the same pattern Pocket Casts uses (their `:modules:services:localization` module).

Trade-offs:

- **Pro:** Single source of truth. Adding a translation means editing one file. No "where does this string go?" decision tree.
- **Pro:** Resource shrinking strips unused strings from each APK (Wear APK doesn't ship strings only used by phone features).
- **Pro:** Wear and `:app` naturally share identical text without ceremony. Per-platform overrides via `titles.xml` only when wording must differ.
- **Con:** Changing one string invalidates the build cache for every consumer. Acceptable for solo projects where strings change far less often than code.

The alternative pattern (per-feature strings, NiA-style) gives finer build cache invalidation but spreads strings across many `strings.xml` files. For a solo developer, centralization wins on ergonomics.

## What Platform Submodules Do NOT Share

The `app/` and `wear/` submodules within a feature are intentionally isolated from each other. They share `:core:domain` (use cases, models) and `:core:strings` (resources) but nothing else:

- **No shared UI** — `:app` uses `androidx.compose.material3`, `:wear` uses `androidx.wear.compose.material3`. Different libraries with different components (a `Button` on phone is a `Chip` on Wear). Sharing composables would mean pulling in both toolkits.
- **No shared ViewModels** — even when two ViewModels call the same use case, the UI state they manage is typically different. A phone dashboard might show charts in a grid; a Wear dashboard shows three items in a `ScalingLazyColumn`. Different shape = different state = different ViewModel. The duplication is minimal (a thin class with a StateFlow) and not worth a shared module.

## Lazy Design-System Promotions

Platform-specific siblings of `:core:designsystem:common` can be added when a concrete trigger fires:

- **`:core:designsystem:app`** — Material 3 layer for phone/tablet. Holds `AppTheme.kt`, brand-flavored Material primitives (e.g., `KanshuButton`, `KanshuTopBar`), and shared Composables that take domain types (e.g., `BookCard(book: Book)`). Depends on `:core:designsystem:common` + `:core:model`.
- **`:core:designsystem:wear`** — Wear Material 3 layer for watch. Same scope but with the Wear Compose toolkit. Can't share Composable code with `:designsystem:app` — the two libraries have incompatible APIs.

Triggers (any one is sufficient):

- You build a brand-flavored Material primitive worth sharing.
- A *second* feature needs the same Composable that takes a domain model.
- You want the theme out of the platform shell's code (e.g., to share between `:app` and a second phone surface).

Pre-promotion: themes live inline in platform shells (`:app/theme/AppTheme.kt`), feature-local Composables live in `features/<name>/<platform>/component/`. The module's existence has to be justified by real reuse — don't create empty `:core:designsystem:app` or `:core:designsystem:wear` modules on speculation.

## Platform-Specific Navigation

A key strength of this architecture is how it isolates platform-specific implementations. Navigation is a perfect example.

- **`:app`** uses Navigation 3 (`androidx.navigation3`) — adaptive layouts with scenes, savable back stack with keys, central `NavDisplay`.
- **`:wear`** uses Navigation 3 plus `androidx.wear.compose:compose-navigation3` — `NavKey`, `rememberNavBackStack`, `NavDisplay`, and the Wear-specific `SwipeDismissableSceneStrategy`.

Feature modules just provide `@Composable` screens. Platform shells call those screens using their own navigation library. Features don't know which platform they're on.

## Theme

By default each platform shell defines its own theme that wraps `MaterialTheme` with dynamic colors. `:core:designsystem:common` is resources only (drawables + value resources), not Compose code — so themes don't live there.

`:app` theme uses Material 3 + `dynamicLightColorScheme()` / `dynamicDarkColorScheme()`:

```kotlin
@Composable
fun AppTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit,
) {
    val context = LocalContext.current
    val colorScheme = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
        if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
    } else {
        if (darkTheme) darkColorScheme() else lightColorScheme()
    }
    MaterialTheme(colorScheme = colorScheme, content = content)
}
```

`:wear` theme uses Wear Material 3 (Wear OS 6+ supports dynamic color via the system theme):

```kotlin
@Composable
fun WearAppTheme(content: @Composable () -> Unit) {
    androidx.wear.compose.material3.MaterialTheme(content = content)
}
```

Move themes into shared code only through the Lazy Design-System Promotions rules above.

## Example Module Dependencies

```kotlin
// app/build.gradle.kts
dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(project(":features:dashboard:app"))
    implementation(project(":features:profile:app"))
    implementation(project(":widget:app"))
    // Compose, Koin, Navigation 3, etc.
}

// wear/build.gradle.kts
dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(project(":features:dashboard:wear"))
    implementation(project(":widget:wear"))
    // Wear Compose, Koin, Navigation 3, Wear swipe-dismiss scene strategy, etc.
}

// features/dashboard/app/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    // NO :core:data
    // NO dependency on app/, wear/, or other feature modules
    // Compose, Koin Compose, ViewModel
}

// features/dashboard/wear/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    // Wear Compose, Koin Compose, ViewModel
}

// widget/common/build.gradle.kts
dependencies {
    api(project(":core:model"))
    implementation(project(":core:domain"))
    // Pure Kotlin — shared widget presentation state and mappers
}

// widget/app/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(project(":widget:common"))
    // Glance App Widget, Koin
    // NO :core:data
}

// widget/wear/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    implementation(project(":core:designsystem:common"))
    implementation(project(":widget:common"))
    // Glance Wear Widget, Remote Compose, Koin
    // NO :core:data, NO androidx.wear.tiles
}

// complications/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    // androidx.wear.watchface.complications
}

// core/data/build.gradle.kts
dependencies {
    implementation(project(":core:model"))
    implementation(project(":core:domain"))
    // Room, DataStore, Koin
}

// core/domain/build.gradle.kts
dependencies {
    implementation(project(":core:model"))
    implementation(libs.kotlinx.coroutines.core)
    // No Android dependencies. Pure Kotlin.
}

// core/model/build.gradle.kts
dependencies {
    // No dependencies. Pure Kotlin data classes and value types.
}

// core/strings/build.gradle.kts
dependencies {
    // No dependencies. Just strings.
}

// core/designsystem/common/build.gradle.kts
dependencies {
    // No dependencies. Just non-string resources (drawables, color values, etc.).
}
```

## Tech Stack

- **Dependency Injection:** Koin
- **Database:** Room
- **DataStore Preferences:** for simple key-value storage
- **Networking:** Retrofit (add to `:core:data` when needed)
- **Serialization:** Kotlinx Serialization
- **Image Loading:** Coil
- **Navigation:** Navigation 3 for both `:app` and `:wear`; Wear adds `SwipeDismissableSceneStrategy`.
- **State Management:** StateFlow + MVVM
- **Formatting:** Spotless + ktfmt (Google style)
- **Testing:** MockK
- **Build:** Gradle KTS + version catalogs

## Benefits

- **Compile-time architecture enforcement.** Pure-Kotlin model and domain layers can't accidentally import Android. Feature modules can't accidentally depend on the data layer.
- **Watch APK isn't bloated.** Wear pulls in `:core:data` (Room, etc.) but not the feature modules' Material 3 phone widgets, and not `:app` shell code.
- **Widget and complication classpaths stay intentional.** Simple widget surfaces and `:complications` can depend on `:core:domain` (or `:core:model` for the simplest cases) without loading more of the stack than they need.
- **Tests run instantly.** Model and domain layers are JVM-only — no Robolectric, no instrumentation.
- **Single source of truth for strings.** Pocket Casts pattern. One file to localize.
- **Multi-platform ready.** Adding `:wear` after building `:app`-only is one `generate.sh wear` call, but only do it when the target platform is clear.
- **No premature abstraction.** Add platform Compose design-system modules (`:core:designsystem:app` / `:core:designsystem:wear`) only when real reuse demands them.

## Getting Started

1. **Create base project:** `android create empty-activity --name="<Name>" --output=./<dir>` (android-cli skill).
2. **Bootstrap core modules:** `scripts/bootstrap.sh` — adds `:core:model` + `:core:domain` + `:core:data` + `:core:strings` + `:core:designsystem:common`. Merge the printed `libs.versions.toml` and root `build.gradle.kts` additions, sync Gradle.
3. **Replace bare `:app`:** delete `app/` and run `scripts/generate.sh app` to get the skill's wired-up shell (or manually add `:core:data` + `:core:strings` deps + Koin setup to the bare `:app`).
4. **Add Wear shell if needed:** `scripts/generate.sh wear`.
5. **Add features:** `scripts/generate.sh feature dashboard --wear`.
6. **Add OS surfaces as needed:** `scripts/generate.sh widget` / `scripts/generate.sh widget --wear` / `complications`.
7. **Iterate:** generate more features and modules as needed.
