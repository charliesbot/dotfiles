# Multi-Platform Tiered Core Architecture

## Overview

Multi-module Android architecture targeting `:app` (phone/tablet), Wear OS, and optionally TV/Auto from a single codebase. The core layer is split into three sub-modules so feature modules don't pull in the full data layer, and so business logic can be tested as pure Kotlin.

**Core sub-modules:**

- `:core:domain` — pure Kotlin (`kotlin("jvm")`): domain models, repository interfaces, use cases. No Android dependencies.
- `:core:data` — Android library: Room, DataStore, repository implementations, DI wiring.
- `:core:strings` — Android library, resources only: every user-facing string.

**Platform shells:**

- `:app` — Android phone/tablet
- `:wear` — Wear OS
- `:tv` — Android TV (optional)
- `:auto` — Android Auto (optional)

**Standalone OS entry points:**

- `:widget` — home screen widget (Glance)
- `:complications` — Wear OS data providers
- `:tiles` — Wear OS tile services

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
│       ├── navigation/              # Wear Compose Navigation (SwipeDismissableNavHost)
│       │   └── WearNavigation.kt
│       └── theme/
│           └── WearAppTheme.kt      # Wear MaterialTheme
│
├── core/
│   ├── domain/                  # :core:domain — pure Kotlin (kotlin("jvm"))
│   │   └── src/main/kotlin/com/myapp/domain/
│   │       ├── model/               # domain models (User, Article, etc.)
│   │       ├── repository/          # repository interfaces
│   │       └── usecase/             # use cases
│   │
│   ├── data/                    # :core:data — Android library
│   │   └── src/main/kotlin/com/myapp/data/
│   │       ├── local/               # Room database, DAOs, entities
│   │       ├── remote/              # Retrofit interfaces, DTOs (when needed)
│   │       ├── repository/          # repository implementations
│   │       └── di/
│   │           └── CoreDataModule.kt    # Koin bindings for repositories, Room, DataStore
│   │
│   └── strings/                 # :core:strings — Android library, resources only
│       └── src/main/res/
│           ├── values/strings.xml       # all user-facing strings
│           └── values-es/strings.xml    # translations (per locale folder)
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
├── widget/                      # :widget (optional) — Glance home screen widget
│   └── src/main/kotlin/com/myapp/widget/
│       ├── AppWidgetReceiver.kt
│       └── AppWidget.kt
│
├── complications/               # :complications (optional) — Wear OS data providers
│   └── src/main/kotlin/com/myapp/complications/
│       └── AppComplicationService.kt
│
└── tiles/                       # :tiles (optional) — Wear OS tile services
    └── src/main/kotlin/com/myapp/tiles/
        └── AppTileService.kt
```

## Dependency Flow

The dependency direction is strictly enforced:

```
:app             ──→ :core:data        ──→ :core:domain
                 ──→ :core:strings
                 ──→ :features:*:app   ──→ :core:domain + :core:strings

:wear            ──→ :core:data        ──→ :core:domain
                 ──→ :core:strings
                 ──→ :features:*:wear  ──→ :core:domain + :core:strings

:widget          ──→ :core:data        ──→ :core:domain
                 ──→ :core:strings

:complications   ──→ :core:domain
:tiles           ──→ :core:domain
```

**Key rules:**

1. **Feature modules never depend on `:core:data`.** They depend only on `:core:domain` (for use cases and interfaces) and `:core:strings` (for resources). Concrete data implementations are wired by platform shells via Koin.

2. **`:core:domain` is pure Kotlin.** Uses `kotlin("jvm")` plugin, not `android.library`. Cannot import Android types — this is enforced at compile time, not by convention.

3. **`:core:data` and `:core:strings` are Android libraries**, but they don't depend on each other. `:core:data` depends on `:core:domain`. `:core:strings` is a leaf module containing only `res/values/strings.xml`.

4. **Platform shells (`:app`, `:wear`) own DI wiring.** They load `coreDataModule` (from `:core:data`) plus their feature modules' Koin modules to provide concrete implementations to the use cases features depend on. This is dependency inversion at the module boundary.

5. **Widgets, complications, and tiles are sibling root modules**, not features. The OS launches them independently of the main app. They depend only on the core layer they need.

## Why kotlin("jvm") for :core:domain

The single most important compile-time barrier in this architecture is making `:core:domain` a pure Kotlin module. Consequences:

- **No `Context`, no `Uri`, no `R` class.** If you need them, the logic doesn't belong in domain.
- **Tests run as plain JVM tests.** No Robolectric, no instrumentation, no emulator. Milliseconds per test.
- **Multi-platform reuse.** A pure Kotlin domain layer can later move to a `commonMain` source set if you ever go Compose Multiplatform.

If `:core:domain` were `android.library`, an agent (or a careless dev) could `import android.content.Context` and the architecture would silently leak Android into the supposed-pure layer. With `kotlin("jvm")` the build fails immediately.

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

## Lazy Widget Promotion

Feature-local Composable widgets start in `features/<name>/<platform>/component/`. When a *second* feature needs the same widget, promote it to a shared module:

- For `:app` widgets: create `:core:ui:app` (Material 3, depends on `:core:domain`)
- For `:wear` widgets: create `:core:ui:wear` (Wear Material 3, depends on `:core:domain`)

These modules don't exist at project init — create them by hand when actually needed. The point of lazy promotion is that the module's existence is justified by real reuse.

Strings tied to a promoted widget can move out of `:core:strings` into the new `:core:ui:*` module's resources only when they're inseparable from the widget. Most stay in `:core:strings`.

## Platform-Specific Navigation

A key strength of this architecture is how it isolates platform-specific implementations. Navigation is a perfect example.

- **`:app`** uses Navigation 3 (`androidx.navigation3`) — adaptive layouts with scenes, savable back stack with keys, central `NavDisplay`.
- **`:wear`** uses Wear Compose Navigation (`androidx.wear.compose:compose-navigation`) — `SwipeDismissableNavHost` and watch-tailored components.

Feature modules just provide `@Composable` screens. Platform shells call those screens using their own navigation library. Features don't know which platform they're on.

## Theme

Each platform shell defines its own theme that wraps `MaterialTheme` with dynamic colors. There's no shared `:core:designsystem` module by default — for a project using vanilla Material 3 + dynamic colors, designsystem would be a "ghost" module containing nothing.

If a project ever needs custom brand tokens (specific colors, custom typography, semantic palette overrides) shared across platforms, create a `:core:designsystem` module then. Until that point, trivial duplication of a few hex values across platform shells is cheaper than the module.

## Example Module Dependencies

```kotlin
// app/build.gradle.kts
dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    implementation(project(":features:dashboard:app"))
    implementation(project(":features:profile:app"))
    // Compose, Koin, Navigation 3, etc.
}

// wear/build.gradle.kts
dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    implementation(project(":features:dashboard:wear"))
    // Wear Compose, Koin, Wear Compose Navigation, etc.
}

// features/dashboard/app/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    // NO :core:data
    // NO dependency on app/, wear/, or other feature modules
    // Compose, Koin Compose, ViewModel
}

// features/dashboard/wear/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    implementation(project(":core:strings"))
    // Wear Compose, Koin Compose, ViewModel
}

// widget/build.gradle.kts
dependencies {
    implementation(project(":core:data"))
    implementation(project(":core:strings"))
    // Glance
}

// complications/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    // androidx.wear.watchface.complications
}

// core/data/build.gradle.kts
dependencies {
    implementation(project(":core:domain"))
    // Room, DataStore, Koin
}

// core/domain/build.gradle.kts
dependencies {
    implementation(libs.kotlinx.coroutines.core)
    // No project dependencies. Pure Kotlin.
}

// core/strings/build.gradle.kts
dependencies {
    // No dependencies. Just resources.
}
```

## Tech Stack

- **Dependency Injection:** Koin
- **Database:** Room
- **DataStore Preferences:** for simple key-value storage
- **Networking:** Retrofit (add to `:core:data` when needed)
- **Serialization:** Kotlinx Serialization
- **Image Loading:** Coil
- **Navigation:** Navigation 3 (`:app`), Wear Compose Navigation (`:wear`)
- **State Management:** StateFlow + MVVM
- **Formatting:** Spotless + ktfmt (Google style)
- **Testing:** MockK
- **Build:** Gradle KTS + version catalogs

## Benefits

- **Compile-time architecture enforcement.** Pure-Kotlin domain layer can't accidentally import Android. Feature modules can't accidentally depend on the data layer.
- **Watch APK isn't bloated.** Wear pulls in `:core:data` (Room, etc.) but not the feature modules' Material 3 phone widgets, and not `:app` shell code.
- **Tests run instantly.** Domain layer is JVM-only — no Robolectric, no instrumentation.
- **Single source of truth for strings.** Pocket Casts pattern. One file to localize.
- **Multi-platform from day one.** Adding `:wear` after building `:app`-only is one `generate.sh wear` call.
- **No premature abstraction.** No `:core:ui:*`, no `:core:designsystem` until real reuse demands them.

## Getting Started

1. **Initialize:** `scripts/init.sh <name> <package>` — creates root + `:core:domain` + `:core:data` + `:core:strings`.
2. **Add platform shells:** `scripts/generate.sh app` and/or `scripts/generate.sh wear`.
3. **Add features:** `scripts/generate.sh feature dashboard --wear`.
4. **Add OS surfaces as needed:** `scripts/generate.sh widget` / `complications` / `tiles`.
5. **Iterate:** generate more features and modules as needed.
