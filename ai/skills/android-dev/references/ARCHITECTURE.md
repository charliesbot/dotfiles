# Simple Multi-Platform Architecture

## Overview

Multi-platform Android app architecture with **1 shared module**, **feature modules**, and **multiple platform modules**.

**Shared module:**

- `:core` - Business logic, data, shared UI

**Feature modules:**

- `:features:dashboard` - Dashboard / today screen
- `:features:profile` - User profile and fasting history
- `:features:settings` - App settings

**Platform modules:**

- `:app` - Mobile Android
- `:wear` - WearOS
- `:tv` - Android TV (optional)
- `:auto` - Android Auto (optional)

**Standalone entry point modules:**

- `:widget` - Home screen widget (Glance or AppWidgetProvider)
- `:complications` - Wear OS complication data providers

## What is a Feature?

A **feature** is a complete user journey or business capability, not just a single screen. This distinction is crucial for creating a clean and maintainable structure.

### Good Features (Business Capabilities)

- **auth**: The entire authentication flow (login, register, forgot password).
- **profile**: User profile management (view, edit, settings).
- **cart**: The complete shopping cart and checkout process.

### Poor Features (Just Screens)

- **login-screen**: Too granular. This should be part of the `auth` feature.
- **settings-screen**: Should be part of the `profile` feature.

Each feature is its own Gradle module under `features/`. Features enforce compile-time boundaries — they cannot depend on each other, only on `:core`.

## Module Structure

Every feature always uses platform submodules (`app/`, `wear/`, etc.) for consistency — even if it only targets one platform today. This keeps the structure predictable and makes adding a new platform variant trivial.

```
android-dojo/
├── app/                      # Mobile Android app module
│   └── src/main/kotlin/com/yourpackage/
│       ├── MainActivity.kt
│       ├── di/
│       │   └── AppModule.kt          # Loads all DI modules (core + features)
│       └── navigation/           # Navigation 3 setup
│           ├── AppNavigation.kt      # NavDisplay, entryProvider, sceneStrategy
│           ├── NavigationRoutes.kt   # Defines all serializable NavKey objects
│           └── scenes/
│               └── DashboardScene.kt
│
├── wear/                     # WearOS app module
│   └── src/main/kotlin/com/yourpackage/wear/
│       ├── MainActivity.kt
│       ├── di/
│       │   └── WearAppModule.kt      # Loads DI modules for wear platform
│       └── navigation/           # WearOS-specific navigation (Wear Compose Navigation)
│           ├── WearNavigation.kt     # Contains SwipeDismissableNavHost
│           └── WearRoutes.kt         # Sealed class routes for type safety
│
├── core/                     # SINGLE unified core module
│   └── src/main/kotlin/com/yourpackage/core/
│       ├── common/           # Pure Kotlin utilities, Result class, extensions
│       ├── data/             # ALL repositories, DAOs, network APIs, Room/Retrofit setup
│       │   ├── local/        # Room database, DAOs, entities
│       │   ├── remote/       # Retrofit APIs, DTOs, network layer
│       │   └── repository/   # Repository implementations
│       ├── domain/           # ALL domain models and use cases
│       │   ├── model/        # Business models (User, etc.)
│       │   ├── repository/   # Repository interfaces
│       │   └── usecase/      # Use cases
│       ├── ui/               # Shared design system
│       │   ├── theme/        # App theme, colors, typography
│       │   ├── component/    # Reusable UI components
│       │   └── util/         # UI utilities
│       └── di/               # Core infrastructure DI (repositories, network, database)
│
└── features/                 # Parent directory for feature modules
    ├── dashboard/            # :features:dashboard
    │   ├── app/              # :features:dashboard:app — Phone UI (Material 3)
    │   │   └── src/main/kotlin/com/yourpackage/features/dashboard/
    │   │       ├── di/
    │   │       │   └── DashboardModule.kt
    │   │       ├── component/        # Feature-scoped composables (not shared with :core)
    │   │       │   └── StatCard.kt
    │   │       ├── DashboardViewModel.kt
    │   │       └── DashboardScreen.kt
    │   │
    │   └── wear/             # :features:dashboard:wear — Wear UI (Wear Material 3)
    │       └── src/main/kotlin/com/yourpackage/features/dashboard/wear/
    │           ├── di/
    │           │   └── WearDashboardModule.kt
    │           ├── component/        # Wear-specific feature components
    │           │   └── WearStatChip.kt
    │           ├── WearDashboardViewModel.kt
    │           └── WearDashboardScreen.kt
    │
    ├── profile/              # :features:profile (phone-only today, but still uses app/ submodule)
    │   └── app/              # :features:profile:app
    │       └── src/main/kotlin/com/yourpackage/features/profile/
    │           ├── di/
    │           │   └── ProfileModule.kt
    │           ├── component/        # Feature-scoped composables
    │           │   └── ProfileHeader.kt
    │           ├── ProfileViewModel.kt
    │           └── ProfileScreen.kt
    │
    └── settings/             # :features:settings
        └── app/              # :features:settings:app
            └── src/main/kotlin/com/yourpackage/features/settings/
                ├── di/
                │   └── SettingsModule.kt
                ├── SettingsViewModel.kt
                └── SettingsScreen.kt
```

## Feature-Scoped Components

Features can have their own composables in a `component/` package inside the platform submodule. Use this for UI elements that are specific to a single feature — e.g., a `StatCard` composable used only on the dashboard. If multiple features need the same component, promote it to `:core:ui:component`.

## What Platform Submodules Do NOT Share

The `app/` and `wear/` submodules within a feature are intentionally isolated from each other. They share `:core` (use cases, repositories, domain models) but nothing else:

- **No shared UI** — phone uses `androidx.compose.material3`, Wear uses `androidx.wear.compose.material3`. These are different libraries with different components (a `Button` on phone is a `Chip` on Wear). Sharing composables would mean pulling in both toolkits.
- **No shared ViewModels** — even when two ViewModels call the same use case, the UI state they manage is typically different. A phone dashboard might show charts in a grid; a Wear dashboard shows 3 items in a `ScalingLazyColumn`. Different screen shape = different state = different ViewModel. The duplication is minimal (a thin class with a StateFlow) and not worth a shared module.

The only thing platform submodules share is `:core`. That's where the real reuse happens.

## Platform-Specific Navigation

A key strength of this architecture is how it isolates platform-specific implementations. Navigation is a perfect example of this.

**`:app` Module**: Uses the Navigation 3 library (`androidx.navigation3`) to handle adaptive layouts with scenes, a savable back stack with keys, and a central `NavDisplay`.

**`:wear` Module**: Uses the specialized Wear Compose Navigation library (`androidx.wear.compose:compose-navigation`), which provides components tailored for watches, like the `SwipeDismissableNavHost`.

The feature modules simply provide the `@Composable` screens. The `:app` and `:wear` modules are independently responsible for calling those screens using the correct navigation library for their platform.

## Why This Works

**Build Cache Isolation**: Each feature module is compiled independently. Changing one feature doesn't recompile the others.

**Compile-Time Boundaries**: Features cannot depend on each other — only on `:core`. This is enforced by Gradle, not just convention.

**Multi-platform Ready**: All platform modules (`:app`, `:wear`, `:tv`, `:auto`, etc.) can share feature code from day one without any additional setup.

**Keeps Clean Dependencies**: Feature modules cannot depend on each other, only on `:core`. This prevents your project from becoming a "ball of mud."

**Easy to Add Features**: Adding a new feature means creating a new module under `features/` with a `build.gradle.kts`. Auto-discovery in `settings.gradle.kts` picks it up automatically.

**Consistent Structure**: Every feature always uses platform submodules (`app/`, `wear/`, etc.), even if it only targets one platform. No guessing whether a feature is flat or nested — it's always nested. Adding a Wear variant later is just adding a `wear/` submodule.

## Dependency Flow

The dependency direction is strictly enforced:

```
app           ──→ features:dashboard:app  ──→ core
              ──→ features:profile:app    ──→ core
              ──→ features:settings:app   ──→ core

wear          ──→ features:dashboard:wear ──→ core
              ──→ core

widget        ──→ core
complications ──→ core
```

Widgets and complications are standalone OS entry points — the system launches them independently of the app. They depend only on `:core` for data access (use cases, repositories) and never go through feature modules or platform navigation.

## Example Module Dependencies

```kotlin
// In app/build.gradle.kts
dependencies {
    implementation(project(":core"))
    implementation(project(":features:dashboard:app"))
    implementation(project(":features:profile:app"))
    implementation(project(":features:settings:app"))
}

// In wear/build.gradle.kts
dependencies {
    implementation(project(":core"))
    implementation(project(":features:dashboard:wear"))
}

// In features/dashboard/app/build.gradle.kts (same pattern for all features)
dependencies {
    // Feature modules depend ONLY on the core module
    implementation(project(":core"))

    // NO dependency on app/wear modules allowed!
    // NO dependency on other feature modules allowed!
}

// In widget/build.gradle.kts
dependencies {
    implementation(project(":core"))
    // NO dependency on :app, :wear, or feature modules
}

// In complications/build.gradle.kts
dependencies {
    implementation(project(":core"))
    // NO dependency on :wear or feature modules
}

// In core/build.gradle.kts
dependencies {
    // Core has no dependency on other project modules
    // Only external libraries (Retrofit, Room, etc.)
}
```

## Tech Stack

- **Dependency Injection**: Koin
- **Networking**: Retrofit
- **Database**: Room
- **Serialization**: Kotlinx Serialization
- **Image Loading**: Coil
- **Navigation**:
  - Mobile: Navigation 3 (`androidx.navigation3`)
  - WearOS: Wear Compose Navigation (`androidx.wear.compose:compose-navigation`)
- **State Management**: StateFlow + MVVM
- **Formatting**: Spotless
- **Testing**: MockK
- **Build**: Gradle KTS + version catalogs (`libs.versions.toml`)
- **Platforms**: Mobile Android + WearOS (+ TV, Auto optional)

## Benefits

- **Solo Development Optimized**: Minimal overhead while maintaining architectural benefits
- **Multi-platform Code Sharing**: Features work across all platforms (mobile, wear, TV, auto) from day one
- **Faster Builds**: Gradle caches unchanged modules independently
- **Platform Flexibility**: Each platform uses optimal navigation solution
- **Feature Isolation**: Each feature is a separate module with compile-time boundary enforcement

## Getting Started

1. **Create unified core**: Build single `:core` module with all shared logic
2. **Create first feature module**: Create `features/dashboard/app/` with its own `build.gradle.kts`
3. **Add auto-discovery**: Use `settings.gradle.kts` to auto-discover feature modules
4. **Platform setup**: Implement platform modules (`:app`, `:wear`, `:tv`, etc.) with appropriate navigation, depending on feature modules
5. **Iterate**: Add more feature modules as needed, each containing only presentation layer
