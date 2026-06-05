---
name: android-dev
description: >
  Architecture and conventions for multi-module Android projects with Jetpack Compose, Wear OS,
  Koin DI, and Gradle. Use when the user works on Android, Kotlin, Compose, or Gradle —
  including :features:, :core:model / :core:domain / :core:data / :core:strings / :core:designsystem,
  :app / :wear / :widget / :complications modules, Wear widgets/complications,
  StateFlow/MVVM, Navigation 3, or Spotless/ktfmt.
---

You are working on a multi-platform Android project following this architecture and conventions. Read `references/ARCHITECTURE.md` for the full module structure and dependency rules before making architectural decisions.

**Tooling vs architecture.** This skill defines architecture and conventions. For Android CLI operations — SDK management, creating a base project (`android create`), emulator control, deploying APKs (`android run`), capturing screenshots, inspecting UI layouts — use the **android-cli** skill. Cross-references appear inline where workflows hand off between the two.

## Day 0: Modules, Not Packages

The architecture is enforced by **five Gradle modules**, not by folder names inside one `:core` module:

- `:core:model` (`kotlin("jvm")`)
- `:core:domain` (`kotlin("jvm")`)
- `:core:data` (`android.library`)
- `:core:strings` (`android.library`, strings only)
- `:core:designsystem:common` (`android.library`, non-string resources: drawables, color values, etc.)

Before writing any feature code, run `./gradlew projects` and confirm these five modules show up. If they don't, your first task is to bootstrap them — see the next section. **Do not fence by package inside one `:core` module as a substitute.** Package fencing doesn't give you `kotlin("jvm")` on model and domain, so `import androidx.room.*` would silently compile in code that's supposed to be Android-free. The build wall is the whole point.

## Before You Write Any Code

This skill ships two scripts in its `scripts/` directory:

- **Bootstrap a new project:** `scripts/bootstrap.sh` — run after `android create empty-activity ...` (see below). Adds the five `:core:*` modules.
- **Add modules:** `scripts/generate.sh <type> [<name>] [--wear]` — platform shells (`app`, `wear`), OS surfaces (`widget`, `complications`), or feature modules (`feature <name>`). Idempotent for shells/surfaces, errors on feature name collisions.

Run these from the project root. Do not copy them into the project — they live in the skill directory and the runtime resolves the path.

## Bootstrapping a Project

```bash
# Step 1: create the base Android project (android-cli skill)
android create empty-activity --name="MyApp" --output=./myapp
cd myapp

# Step 2: add the five :core:* modules (this skill)
<skill-path>/scripts/bootstrap.sh

# Step 3: merge the libs.versions.toml and root build.gradle.kts additions
# the script prints. Sync Gradle in Android Studio.

# Step 4: add platform shells and features
<skill-path>/scripts/generate.sh app
<skill-path>/scripts/generate.sh feature dashboard
```

`bootstrap.sh` reads the `:app` namespace, writes it as `android.basePackage` to `gradle.properties`, creates the five core modules with the right plugins, and updates `settings.gradle.kts`. It prints version-catalog and root-build additions to apply by hand — TOML and the plugins block are too risky to splice from a script, but an agent reading the output can merge them semantically. The script is idempotent (no-op when all five modules exist), refuses to run on partial states, and rejects a non-canonical single-`:core` layout.

## Generating Modules

```bash
cd <project-root>

scripts/generate.sh app                    # add :app module
scripts/generate.sh wear                   # add :wear module
scripts/generate.sh widget                 # add :widget (responsive Glance widget surfaces)
scripts/generate.sh complications          # add :complications (Wear OS data providers)
scripts/generate.sh feature dashboard          # add :features:dashboard:app
scripts/generate.sh feature dashboard --wear   # add :features:dashboard:app + :wear
```

Each invocation does one thing. Re-running with the same type for an existing platform shell or OS surface skips with a notice (idempotent). Re-running with the same feature name errors hard — features are user-named so a collision is almost always a typo.

The script reads `android.basePackage` from `gradle.properties` so you never re-type the package after bootstrap.

**About the bare `:app` from `android create`:** the `app/` module produced by `android create empty-activity` is a standalone Compose app — it doesn't depend on `:core:data` or feature modules and has no Koin setup. To get the skill's wired-up shell, delete the `app/` directory and run `scripts/generate.sh app`. That regenerates `:app` with `AppApplication` (Koin), `AppTheme`, navigation wiring, and dependencies on `:core:data`, `:core:strings`, and `:features:*:app`.

## Core Principles

The architecture supports multiple Android platforms (`:app` for phone/tablet, `:wear`, optionally `:tv`, `:auto`) from a single codebase. Dependencies flow in one direction:

```
:core:model              (no deps — pure Kotlin)
:core:domain             → :core:model
:core:data               → :core:domain (→ :core:model)
:core:strings            (leaf — Android lib, strings only)
:core:designsystem:common (leaf — Android lib, drawables + non-string resources)

:features:*:*     → :core:domain + :core:strings + :core:designsystem:common
:app, :wear       → :core:data + :core:strings + :core:designsystem:common + :features:*:*
:widget           → :core:data + :core:strings + :core:designsystem:common
:complications    → :core:domain    (no Room/Ktor on classpath)
```

**Feature modules never depend on `:core:data`.** They only know `:core:domain` (and `:core:strings` for resources, plus `:core:model` transitively). Platform shells (`:app`, `:wear`) wire concrete data implementations into Koin and inject them into the use cases features depend on. This is dependency inversion at the module boundary — the feature compiles, tests, and reasons about behaviour without knowing which database, network library, or sync mechanism backs its use cases.

`:core:model` and `:core:domain` use the `kotlin("jvm")` plugin, not `android.library`. They're pure Kotlin modules — Android types (`Context`, `Uri`, anything from `android.*`) won't compile there. The boundary is enforced at build time, not by convention. Models live in `:core:model` (consumable from everywhere); repository interfaces and use cases live in `:core:domain`.

## Module Structure

- **`:core:model`** — pure Kotlin (`kotlin("jvm")`): domain models and value types (data classes, enums, sealed hierarchies). No logic, no dependencies. Consumable from everywhere — domain, data, features, and platform shells all transitively pick it up.
- **`:core:domain`** — pure Kotlin (`kotlin("jvm")`): repository interfaces and use cases. Depends on `:core:model`. No Android dependencies. Both `:features:*:app` and `:features:*:wear` depend on this.
- **`:core:data`** — Android library: Room database, Retrofit/Ktor, DataStore, repository implementations, network/connectivity, credential storage, DI wiring (`CoreDataModule`). Platform shells (`:app`, `:wear`, `:widget`) depend on this to wire implementations.
- **`:core:strings`** — Android library, resources only: every user-facing string in the app, with translations per locale (`values/`, `values-es/`, etc.). Both platform shells and feature modules depend on this.
- **`:core:designsystem:common`** — Android library, non-string resources: drawables (vector icons, illustrations, app logo), color values (XML-referenced from manifest theme, splash screen), typography and shape values. Platform shells, feature modules, and `:widget` all depend on this. Two carve-outs: launcher icons (`mipmap/`) live in platform shells (manifest requirement), notification icons live in `:core:data` (the data layer code references them and shouldn't depend on `:core:designsystem:common`).
- **`:features:<name>:app`** — `:app` presentation: ViewModel, Composable screens (Material 3), feature-scoped DI module, optional `component/` package for feature-local widgets.
- **`:features:<name>:wear`** — `:wear` presentation: ViewModel, Composable screens (Wear Material 3), feature-scoped DI module.
- **`:app`**, **`:wear`** — platform shells that wire navigation, theming, and DI. Both use Navigation 3; `:wear` adds the Wear-specific `SwipeDismissableSceneStrategy` from `androidx.wear.compose:compose-navigation3`.
- **`:widget`** — responsive Glance widget surfaces. Standalone OS entry point at root level.
- **`:complications`** — Wear OS complication data providers. Standalone OS entry points the watch face calls directly.

Every feature uses platform submodules (`app/`, `wear/`, etc.) — even when it only targets one platform today. This removes the "is this feature flat or nested?" guessing game and means adding a Wear or TV variant later is just adding a sibling submodule.

Widgets and complications are **not** features — they're standalone entry points the OS launches independently. They sit at the root level alongside platform shells.

Widgets are the preferred glanceable surface for Wear OS, Auto, home screen, and future surfaces. Widget UI **must be responsive**: never assume a fixed watch, phone launcher, or car display size. Use size-aware Glance/Remote Compose layouts, concise content, and surface-specific receivers or services inside `:widget` while keeping the shared presentation adaptable.

**What `core/` is not:**

- Not a home for capability slices. `library`, `reader`, `auth`, `cart` are features (`:features:<name>:<platform>`), not core. If a directory name reads like a user-facing thing, it's a feature.
- Not a place for concern-named sibling packages. No top-level `core/network/`, `core/security/`, `core/connection/` as siblings of `model/`/`domain/`/`data/`. Network plumbing lives inside `:core:data`. Credential storage lives inside `:core:data`. Pure policy/rules can live in `:core:domain`.
- Not a substitute for module boundaries. If you find yourself making `core/<x>/` folders to "organize" code, ask whether `<x>` is really a feature, or whether the code belongs _inside_ one of the four core modules.

## Do Not

- **Fence by package inside one `:core` module instead of using the four modules** — `:core:model` / `:core:domain` / `:core:data` / `:core:strings` are the enforcement. A single `:core` with `model/`, `domain/`, `data/`, `strings/` subpackages looks similar but has no compile-time wall and lets Android types leak into domain code.
- **Put capability-named directories under `core/`** (`core/library/`, `core/reader/`, `core/auth/`) — capabilities are sliced via `:features:<name>:<platform>`. If a name reads like a user-facing thing, it's a feature, not core.
- **Make feature modules depend on `:core:data`** — features only know `:core:domain` and `:core:strings` (and `:core:model` transitively). Data implementations are wired by platform shells via DI.
- **Put strings outside `:core:strings`** — every user-facing string lives there. The only exception is `app_name` in each platform shell's `res/values/titles.xml` when the launcher label needs to differ per surface.
- **Add Android types to `:core:model` or `:core:domain`** — the `kotlin("jvm")` plugin will reject `Context`, `Uri`, etc. at compile time. If you need them, the logic belongs in `:core:data`.
- **Put models inside `:core:domain`** — models live in `:core:model`. Domain holds repository interfaces and use cases that depend on those models. Keeping them split means a `:complications` module or a widget surface that just reads pre-computed state can depend on `:core:model` alone.
- **Add dependencies between feature modules** — features depend only on `:core:domain` and `:core:strings`. If two features need the same type, move it to `:core:model`.
- **Add third-party libraries without asking** — the current stack covers most needs. Explain what's missing before adding anything.
- **Create feature modules for single screens** — a feature is a complete user journey (e.g., `:features:auth` covers login, register, and forgot password).
- **Create flat feature modules** — always use platform submodules (`app/`, `wear/`), even for `:app`-only features.
- **Put widget or complication code inside `:app` or `:wear`** — they're standalone entry points and get their own root-level modules.
- **Use LiveData** — the entire codebase uses StateFlow + coroutines.
- **Skip writing tests** — follow red-green TDD. Write the failing test first.
- **Skip `@Preview`** — every `@Composable` needs one.
- **Manually create modules** — always use `bootstrap.sh` and `generate.sh`. They enforce structure.

## Tech Stack

| Concern              | Choice                                               |
| -------------------- | ---------------------------------------------------- |
| UI                   | Jetpack Compose + Material 3                         |
| DI                   | Koin                                                 |
| Networking           | Retrofit + OkHttp (add to `:core:data` when needed)  |
| Database             | Room                                                 |
| Serialization        | Kotlinx Serialization                                |
| Image loading        | Coil                                                 |
| Navigation (`:app`)  | Navigation 3 (`androidx.navigation3`)                |
| Navigation (`:wear`) | Navigation 3 + Wear `SwipeDismissableSceneStrategy`  |
| State management     | StateFlow + MVVM                                     |
| Formatting           | Spotless + ktfmt (Google style)                      |
| Testing              | MockK                                                |
| Build                | Gradle KTS + version catalogs (`libs.versions.toml`) |

Do not add third-party dependencies without asking first.

## Version Catalog & Build Plumbing

`bootstrap.sh` and `generate.sh` generate `build.gradle.kts` files that reference specific `libs.versions.toml` keys. AGP 9.0+ bundles Kotlin support, so `libs.plugins.kotlin.android` is **not** applied alongside `android.application` or `android.library` (it triggers a build error). The pure-Kotlin modules (`:core:model`, `:core:domain`) still use `kotlin.jvm`.

For the full list of required plugin aliases, version keys, and per-module dependency requirements, read `references/TOOLING.md`.

## Implementation Patterns

ViewModels live in their platform submodule and use StateFlow. Use cases live in `:core:domain/usecase/<capability>/`, return `Result<T>` (or `Flow<T>`), and group by capability. Repository interfaces live in `:core:domain/repository/`; implementations in `:core:data/repository/`. Models live in `:core:model`. Koin bindings (repositories + use cases) go in `:core:data/di/CoreDataModule.kt`.

For full templates and copy-paste examples (ViewModel, Use Case, Data Layer, Koin wiring), read `references/PATTERNS.md` before writing code in any of these layers.

## Composable Conventions

- Every `@Composable` function needs a `@Preview`. Catches layout issues without launching the app.
- Use Material 3 components in `:app` features; Wear Material 3 in `:wear` features.
- Platform shells call feature screens — features don't know which platform they're on.
- **Feature-scoped components live in a `component/` package inside the platform submodule** (e.g., `features/dashboard/app/component/StatCard.kt`). Promote to `:core:designsystem:app` only when a concrete lazy-promotion trigger fires (e.g., a second app feature needs the same component, you build brand-flavored Material primitives worth sharing, or the app theme should move out of the `:app` shell).
- The `app/` and `wear/` submodules within a feature do not share UI or ViewModels. Different Compose toolkits, different UI shape, different state. The shared code is in `:core:domain` (use cases, repositories, models).

## Resources

Two leaf modules hold every shared resource: **`:core:strings`** for user-facing text, **`:core:designsystem:common`** for everything else (drawables, color values, typography, dimens, shape values, raw assets). The split exists because strings change frequently and have heavy translation needs, while drawables and value resources are more stable. Combining them would mean every string edit invalidates the build cache for designsystem consumers.

### Strings

All strings live in `:core:strings/src/main/res/values/strings.xml`. Translations go in sibling locale folders (`values-es/`, `values-ja/`, etc.). One file, one place to look.

```
core/strings/src/main/res/
├── values/
│   └── strings.xml         # all strings: app_name, action labels, feature copy, errors
└── values-es/
    └── strings.xml         # Spanish translations
```

This is the Pocket Casts pattern: every module that needs strings (platform shells, feature modules, widget) depends on `:core:strings`. Resource shrinking strips unused strings from each APK at build time.

**Per-platform overrides** — when the launcher label or a specific string genuinely needs to differ between `:app` and `:wear` (e.g., longer wording on phone, abbreviated on watch), use a `titles.xml` in the platform shell:

```
app/src/main/res/values/titles.xml      → <string name="app_name">Fasting Tracker</string>
wear/src/main/res/values/titles.xml     → <string name="app_name">Fasting</string>
```

The platform shell's resource overrides the value from `:core:strings` for that surface only.

**For generic action words** — prefer the system's built-in resources before adding to `:core:strings`:

- `android.R.string.cancel`, `android.R.string.ok`, `android.R.string.yes`, `android.R.string.no`
- Material 3 ships its own translated strings for many component-internal labels

### Drawables and other resources

Everything non-string goes in `:core:designsystem:common`:

```
core/designsystem/common/src/main/res/
├── drawable/                # vector drawables — app logo, brand icons, illustrations
├── values/colors.xml        # color VALUES referenced from XML (manifest theme, splash)
├── values/dimens.xml        # shared dimens (optional)
└── font/                    # custom font families (when you have any)
```

Drawables are vector XML (Android's SVG equivalent) — one file renders correctly on phone, tablet, and wear at any size. No need for density-specific folders.

**Carve-outs that don't live in `:core:designsystem:common`:**

- **Launcher icons (`mipmap/`)** → platform shells (`:app/src/main/res/mipmap-*/`, `:wear/src/main/res/mipmap-*/`). The manifest references them, they're adaptive icons with foreground/background layers, and they often differ per platform.
- **Notification icons** → `:core:data/src/main/res/drawable/`. The notification code in the data layer references them; keeping them in `:core:data` avoids inverting the dependency direction (data shouldn't depend on designsystem).

**Prefer Material Icons over custom drawables** when possible. `androidx.compose.material.icons.*` ships hundreds of vector icons that are theme-aware and free. Only reach for `:core:designsystem:common/res/drawable/` when you need a brand-specific or app-specific drawable that doesn't exist in Material Symbols.

## Theme

Each platform shell defines its own theme that wraps `MaterialTheme` with dynamic colors. Generated by `generate.sh` for each platform.

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

By default each platform shell defines its own theme — `:core:designsystem:common` is resources only and doesn't ship Compose components. When you want themes to live in shared code instead of duplicated in shells, promote (see below).

## Lazy Module Promotions

`bootstrap.sh` creates five core modules. Two more can be added later when a concrete trigger fires — never on speculation.

**`:core:designsystem:app`** — sibling of `:core:designsystem:common`. Holds the phone-side Material 3 layer: `AppTheme.kt`, brand-flavored Material primitives (`KanshuButton`, `KanshuTopBar`), and shared composables that know domain types (e.g., `BookCard(book: Book)`, `ChapterListItem(chapter: Chapter)`). Depends on `:core:designsystem:common` + `:core:model`. **Trigger:** any one of — you build a brand-flavored Material primitive worth sharing, OR a second feature needs the same domain-aware composable, OR you want the theme out of `:app/`'s code. Until then, theme lives inline in `:app/`, and feature-local composables live in `features/<name>/app/component/`.

**`:core:designsystem:wear`** — same scope but for Wear Material 3. Trigger and contents mirror `:app`. Can't share code with `:designsystem:app` because the two Compose toolkits are different libraries.

The reason these aren't starters: a project on stock Material with no brand-specific composables doesn't need them. Adding them on speculation creates near-empty modules.

## Formatting

Spotless with ktfmt (Google style) enforces consistent formatting across all Kotlin and Gradle KTS files. Configured in the root `build.gradle.kts` and applies to all modules automatically.

- Run `./gradlew spotlessApply` to auto-format before committing. Non-negotiable — CI will reject unformatted code.
- Run `./gradlew spotlessCheck` to verify formatting without modifying files.
- Do not add per-module Spotless configuration.
- If Spotless reformats code you just wrote, accept the changes — do not fight the formatter.

## Testing

Follow red-green TDD: write failing tests first, then implement until they pass. Run tests after every change. Use MockK. Prefer module-scoped test commands (`./gradlew :features:dashboard:app:test`) over `./gradlew test` when working on a single feature. `:core:model` and `:core:domain` tests run as plain JVM tests — instant feedback.

For use case and ViewModel test templates (MockK setup, coroutine dispatchers, assertions), read `references/TESTING.md`.

## Inspecting the Project

When you need to know something about the build — library versions, what a module depends on, where a transitive dependency comes from, what classes a library exposes — read the build files or ask Gradle. The Gradle cache is not part of the investigation.

- **Library versions:** read `gradle/libs.versions.toml`.
- **Module dependencies:** read the module's `build.gradle.kts`.
- **Resolved dependency tree:** `./gradlew :<module>:dependencies` (narrow with `--configuration releaseRuntimeClasspath` when noisy).
- **Why a specific dependency is on the classpath:** `./gradlew :<module>:dependencyInsight --dependency <name>`.
- **Third-party class or API:** use the IDE's "Go to declaration" or the library's public docs and source repo.

**Stay out of `~/.gradle/caches/` entirely.** No `find`, no `ls`, no `grep`. The cache is a machine-wide artifact pool shared across every project and branch on the machine. It holds many versions of the same library side by side, so anything you see there is downstream evidence about what has been downloaded at some point, not what the current build resolves or ships. Going in there to "just check" is the start of the unzip workflow and answers the wrong question regardless. Ask Gradle through the tasks above instead.

**Never unzip a JAR or AAR.** Not to read versions, not to find classes, not to debug. The information is always available from the build files, Gradle tasks, or upstream docs. Unpacking archives is slow, produces enormous output, and there is no scenario in this project where it is the right move.

## Common Commands

```bash
./gradlew build                            # Build all modules
./gradlew :app:installDebug                # Install :app (or use `android run` from android-cli)
./gradlew :wear:installDebug               # Install :wear
./gradlew test                             # Run all tests
./gradlew :features:<name>:app:test        # Run single feature tests
./gradlew :core:domain:test                # Run pure-Kotlin domain tests (fast)
./gradlew :core:model:test                 # Run pure-Kotlin model tests (fast)
./gradlew spotlessApply                    # Format code
```

For deploying APKs, capturing screenshots, inspecting layouts, or managing emulators, prefer the `android` CLI (see the android-cli skill) over raw ADB or Gradle install tasks — it's the standard tooling layer in this environment.

## Common Scenarios

**"I need to share a data class between two features"**
Move it to `:core:model`. Features depend on `:core:domain`, which depends on `:core:model`, so the shared type is reachable. Do not add a dependency between features — Gradle will reject it, and even if it didn't, it would break the isolation that keeps builds fast.

**"Where should I put this new screen?"**
First decide which feature (business capability) it belongs to. A "forgot password" screen belongs in `:features:auth`, not a new `:features:forgot-password` module. Then place it in the appropriate platform submodule (`app/` or `wear/`).

**"I want to add a Wear version of an existing feature"**
Create a `wear/` submodule alongside the existing `app/` submodule under that feature. Easiest path: delete the feature directory, then run `scripts/generate.sh feature <name> --wear`. Or manually mirror the `app/` structure with Wear Material 3 imports. The business logic in `:core:domain` is already shared — no changes needed there.

**"Should I use LiveData or StateFlow?"**
StateFlow. The entire codebase uses StateFlow + coroutines for reactive state. LiveData is not part of this stack.

**"Can I add library X?"**
Ask first. The current stack covers most needs. If you think something is missing, explain what problem it solves and why the existing stack can't handle it.

**"I need to add a home screen widget"**
Run `scripts/generate.sh widget`. Creates `:widget` at the root with a Glance-based receiver and an example widget Composable. Depends on `:core:data` + `:core:strings` + `:core:designsystem:common`. Widget UI must be responsive because the same module owns glanceable surfaces for home screen, Wear OS, Auto, and future surfaces.

**"I need to add a Wear OS complication"**
Run `scripts/generate.sh complications`. Creates `:complications` with a `SuspendingComplicationDataSourceService` skeleton. Depends only on `:core:domain`.

**"I need Wearable Data Layer sync between :app and :wear"**
Add `implementation(libs.play.services.wearable)` to both `:app/build.gradle.kts` and `:wear/build.gradle.kts`. The Data Layer client (`Wearable.getDataClient(context)`) and listener services live in `:core:data` so both platforms share the sync logic.

**"I'm getting unresolved reference errors across modules"**
Check the dependency flow:

- A feature module trying to use Room/DataStore directly → wrong, those live in `:core:data` and only platform shells touch them
- A feature module trying to use a type from another feature → wrong, move the type to `:core:model`
- An Android type (`Context`, `Uri`, etc.) referenced in `:core:model` or `:core:domain` → wrong, those modules are `kotlin("jvm")`. Move the code to `:core:data` or to a platform shell
- A platform shell can't find a feature → check `settings.gradle.kts` includes the right `:features:<name>:<platform>` module

**"I need a string used by a single feature"**
Add it to `:core:strings/src/main/res/values/strings.xml`. The feature module already depends on `:core:strings` — reference it as `R.string.<name>` (where `R` is `<package>.strings.R`).

**"Where should this drawable go?"**
- A vector icon or illustration referenced from a Composable → `:core:designsystem:common/src/main/res/drawable/`. Every consumer (features, shells, widget) already depends on this module.
- A launcher icon → platform shell (`:app/src/main/res/mipmap-*/`, etc.). Manifest reference, must live there.
- A notification icon (referenced from code in `:core:data`) → `:core:data/src/main/res/drawable/`. Keeps the dependency direction clean.
- Before adding a custom vector, check `androidx.compose.material.icons.Icons.Default.*` — hundreds of vectors come free.

## Reference Files

Load on demand — these aren't pulled into context automatically:

- `references/ARCHITECTURE.md` — full module structure, dependency rules, and rationale (including "Why split model from domain"). Read before architectural decisions.
- `references/PATTERNS.md` — copy-paste templates for ViewModels, use cases, repositories, DAOs, and Koin wiring. Read before writing code in `:features:`, `:core:domain`, or `:core:data`.
- `references/TESTING.md` — MockK + TDD templates for use case tests and ViewModel tests. Read before adding or modifying tests.
- `references/TOOLING.md` — required `libs.versions.toml` plugin aliases, version keys, and per-module dependency lists. Read when troubleshooting Gradle sync or adjusting the catalog.
