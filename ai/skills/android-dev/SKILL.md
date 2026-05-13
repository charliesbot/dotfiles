---
name: android-dev
description: >
  Architecture and conventions for multi-module Android projects with Jetpack Compose, Wear OS,
  Koin DI, and Gradle. Use when the user works on Android, Kotlin, Compose, or Gradle —
  including :features:, :core:domain / :core:data / :core:strings,
  :app / :wear / :widget / :complications / :tiles modules, Wear tiles/complications,
  StateFlow/MVVM, Navigation 3, or Spotless/ktfmt.
---

You are working on a multi-platform Android project following this architecture and conventions. Read `references/ARCHITECTURE.md` for the full module structure and dependency rules before making architectural decisions.

## Before You Write Any Code

This skill ships two scripts in its `scripts/` directory:

- **New project:** `scripts/init.sh <name> <package>` — creates project root, `:core:domain`, `:core:data`, `:core:strings`. Run once per project.
- **New module:** `scripts/generate.sh <type> [<name>] [--wear]` — adds platform shells (`app`, `wear`), OS surfaces (`widget`, `complications`, `tiles`), or feature modules (`feature <name>`). Idempotent for shells/surfaces, errors on feature name collisions.

Run these from the project root. Do not copy them into the project — they live in the skill directory and the runtime resolves the path.

## Initializing a New Project

```bash
scripts/init.sh fasting com.charliesbot.fasting
```

Creates the project directory with `settings.gradle.kts`, root `build.gradle.kts`, `gradle.properties` (containing `android.basePackage` for later script invocations), and the three core modules. Errors hard if the target directory is non-empty or already initialized.

After init, add platform shells and modules with `generate.sh`.

## Generating Modules

```bash
cd <project-root>

scripts/generate.sh app                    # add :app module
scripts/generate.sh wear                   # add :wear module
scripts/generate.sh widget                 # add :widget (Glance home screen widget)
scripts/generate.sh complications          # add :complications (Wear OS data providers)
scripts/generate.sh tiles                  # add :tiles (Wear OS tile services)
scripts/generate.sh feature dashboard          # add :features:dashboard:app
scripts/generate.sh feature dashboard --wear   # add :features:dashboard:app + :wear
```

Each invocation does one thing. Re-running with the same type for an existing platform shell or OS surface skips with a notice (idempotent). Re-running with the same feature name errors hard — features are user-named so a collision is almost always a typo.

The script reads `android.basePackage` from `gradle.properties` so you never re-type the package after init.

## Core Principles

The architecture supports multiple Android platforms (`:app` for phone/tablet, `:wear`, optionally `:tv`, `:auto`) from a single codebase. Dependencies flow in one direction:

```
:app           → :features:*:app  → :core:domain + :core:strings
               → :core:data       → :core:domain
:wear          → :features:*:wear → :core:domain + :core:strings
               → :core:data       → :core:domain
:widget        → :core:data       → :core:domain
               + :core:strings
:complications → :core:domain
:tiles         → :core:domain
```

**Feature modules never depend on `:core:data`.** They only know `:core:domain` (and `:core:strings` for resources). Platform shells (`:app`, `:wear`) wire concrete data implementations into Koin and inject them into the use cases features depend on. This is dependency inversion at the module boundary — the feature compiles, tests, and reasons about behaviour without knowing which database, network library, or sync mechanism backs its use cases.

`:core:domain` uses the `kotlin("jvm")` plugin, not `android.library`. This makes it a pure Kotlin module — Android types (`Context`, `Uri`, anything from `android.*`) won't compile there. The boundary is enforced at build time, not by convention.

## Module Structure

- **`:core:domain`** — pure Kotlin (`kotlin("jvm")`): domain models, repository interfaces, use cases. No Android dependencies. Both `:features:*:app` and `:features:*:wear` depend on this.
- **`:core:data`** — Android library: Room database, DataStore, repository implementations, DI wiring. Platform shells (`:app`, `:wear`, `:widget`) depend on this to wire implementations.
- **`:core:strings`** — Android library, resources only: every user-facing string in the app. Both platform shells and feature modules depend on this.
- **`:features:<name>:app`** — `:app` presentation: ViewModel, Composable screens (Material 3), feature-scoped DI module, optional `component/` package for feature-local widgets.
- **`:features:<name>:wear`** — `:wear` presentation: ViewModel, Composable screens (Wear Material 3), feature-scoped DI module.
- **`:app`**, **`:wear`** — platform shells that wire navigation, theming, and DI. Each platform uses its own navigation library (Navigation 3 for `:app`, Wear Compose Navigation for `:wear`).
- **`:widget`** — home screen widget (Glance). Standalone OS entry point at root level.
- **`:complications`** — Wear OS complication data providers. Standalone OS entry points the watch face calls directly.
- **`:tiles`** — Wear OS tile services. Standalone OS entry points reachable via swipe.

Every feature uses platform submodules (`app/`, `wear/`, etc.) — even when it only targets one platform today. This removes the "is this feature flat or nested?" guessing game and means adding a Wear or TV variant later is just adding a sibling submodule.

Widgets, complications, and tiles are **not** features — they're standalone entry points the OS launches independently. They sit at the root level alongside platform shells.

`settings.gradle.kts` (created by `init.sh`) auto-discovers `:core:*` and `:features:*:*` so new modules don't need manual `include()` calls there. Platform shells and OS surfaces are added explicitly by `generate.sh`.

## Do Not

- **Make feature modules depend on `:core:data`** — features only know `:core:domain` and `:core:strings`. Data implementations are wired by platform shells via DI.
- **Put strings outside `:core:strings`** — every user-facing string lives there. The only exception is `app_name` in each platform shell's `res/values/titles.xml` when the launcher label needs to differ per surface.
- **Add Android types to `:core:domain`** — the `kotlin("jvm")` plugin will reject `Context`, `Uri`, etc. at compile time. If you need them, the logic belongs in `:core:data`.
- **Add dependencies between feature modules** — features depend only on `:core:domain` and `:core:strings`. If two features need the same type, move it to `:core:domain`.
- **Add third-party libraries without asking** — the current stack covers most needs. Explain what's missing before adding anything.
- **Create feature modules for single screens** — a feature is a complete user journey (e.g., `:features:auth` covers login, register, and forgot password).
- **Create flat feature modules** — always use platform submodules (`app/`, `wear/`), even for `:app`-only features.
- **Put widget, complication, or tile code inside `:app` or `:wear`** — they're standalone entry points and get their own root-level modules.
- **Use LiveData** — the entire codebase uses StateFlow + coroutines.
- **Skip writing tests** — follow red-green TDD. Write the failing test first.
- **Skip `@Preview`** — every `@Composable` needs one.
- **Manually create modules** — always use `init.sh` and `generate.sh`. They enforce structure.

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
| Navigation (`:wear`) | Wear Compose Navigation                              |
| State management     | StateFlow + MVVM                                     |
| Formatting           | Spotless + ktfmt (Google style)                      |
| Testing              | MockK                                                |
| Build                | Gradle KTS + version catalogs (`libs.versions.toml`) |

Do not add third-party dependencies without asking first.

## Required Version Catalog Aliases

The scripts generate `build.gradle.kts` files that reference these `libs.versions.toml` keys. Verify they exist in your catalog or adjust the generated files.

**Plugins:**

- `libs.plugins.android.application`
- `libs.plugins.android.library`
- `libs.plugins.kotlin.android`
- `libs.plugins.kotlin.jvm` (for `:core:domain`)
- `libs.plugins.kotlin.compose`
- `libs.plugins.ksp` (for `:core:data` Room)
- `libs.plugins.spotless`

**Versions:**

- `libs.versions.compileSdk`
- `libs.versions.minSdk`
- `libs.versions.wearMinSdk`

**`:core:domain` deps:**

- `libs.kotlinx.coroutines.core`

**`:core:data` deps:**

- `libs.androidx.room.runtime`, `libs.androidx.room.ktx`, `libs.androidx.room.compiler`
- `libs.androidx.datastore.preferences`
- `libs.koin.android`

**Platform shell (`:app`, `:wear`) deps:**

- `libs.androidx.core.ktx`, `libs.androidx.activity.compose`, `libs.androidx.lifecycle.viewmodel.compose`
- `libs.koin.android`, `libs.koin.androidx.compose`
- `libs.compose.bom`, `libs.compose.runtime`, `libs.compose.ui`, `libs.compose.foundation`, `libs.compose.ui.tooling.preview`, `libs.compose.ui.tooling`
- `:app`: `libs.compose.material3`, `libs.androidx.navigation3`
- `:wear`: `libs.wear.compose.material3`, `libs.wear.compose.foundation`, `libs.wear.compose.navigation`, `libs.wear.tooling.preview`

**Feature module deps** (same for `app/` and `wear/` submodules):

- `libs.androidx.lifecycle.viewmodel`
- `libs.koin.androidx.compose`
- Compose BOM + runtime/ui/foundation
- `app/` adds `libs.compose.material3`, `libs.compose.ui.tooling.preview`, `libs.compose.ui.tooling`
- `wear/` adds `libs.wear.compose.material3`, `libs.wear.compose.foundation`, `libs.wear.tooling.preview`

## ViewModel Pattern

Each platform submodule has its own ViewModel. ViewModels use StateFlow and live in their platform submodule (e.g., `features/dashboard/app/` has `DashboardViewModel`, `features/dashboard/wear/` has `WearDashboardViewModel`).

```kotlin
class DashboardViewModel(
    private val getDashboardUseCase: GetDashboardUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow(DashboardUiState())
    val uiState: StateFlow<DashboardUiState> = _uiState.asStateFlow()

    fun onRefresh() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            getDashboardUseCase()
                .onSuccess { data -> _uiState.update { it.copy(data = data, isLoading = false) } }
                .onFailure { error -> _uiState.update { it.copy(error = error.message, isLoading = false) } }
        }
    }
}
```

## Use Case Pattern

Use cases live in `:core:domain` under `domain/usecase/` and encapsulate a single business operation. They use Kotlin's built-in `Result<T>` (from `kotlin.Result`) — not a custom wrapper. One-shot operations use `suspend` + `Result<T>`. Reactive streams use `Flow`.

There's no scaffold script for use cases — they're a single Kotlin file you copy and adapt. Full file template (suspend variant):

```kotlin
package com.myapp.domain.usecase

import com.myapp.domain.repository.ArticleRepository

class GetArticlesUseCase(
    private val articleRepository: ArticleRepository,
) {
    suspend operator fun invoke(): Result<List<Article>> = runCatching {
        articleRepository.getArticles().sortedByDescending { it.date }
    }
}
```

Flow variant:

```kotlin
package com.myapp.domain.usecase

import com.myapp.domain.repository.AuthRepository
import kotlinx.coroutines.flow.Flow

class ObserveAuthStateUseCase(
    private val authRepository: AuthRepository,
) {
    operator fun invoke(): Flow<AuthState> = authRepository.observeAuthState()
}
```

Register in the `:core:data` Koin module (`core/data/src/main/kotlin/<package>/data/di/CoreDataModule.kt`):

```kotlin
val coreDataModule = module {
    factory { GetArticlesUseCase(get()) }
    factory { ObserveAuthStateUseCase(get()) }
    // ... repositories and other use cases
}
```

## Data Layer

Repository **interfaces** live in `:core:domain` under `domain/repository/`. Repository **implementations** live in `:core:data` under `data/repository/`. Room entities and DAOs live in `:core:data` under `data/local/`. Retrofit interfaces live in `:core:data` under `data/remote/`.

```kotlin
// :core:domain — domain/repository/ArticleRepository.kt
package com.myapp.domain.repository

interface ArticleRepository {
    suspend fun getArticles(): List<Article>
}

// :core:data — data/repository/ArticleRepositoryImpl.kt
package com.myapp.data.repository

class ArticleRepositoryImpl(
    private val articleDao: ArticleDao,
    private val articleApi: ArticleApi,
) : ArticleRepository {
    override suspend fun getArticles(): List<Article> =
        articleDao.getAll().map { it.toDomain() }
}

// :core:data — data/local/ArticleDao.kt
@Dao
interface ArticleDao {
    @Query("SELECT * FROM articles ORDER BY date DESC")
    suspend fun getAll(): List<ArticleEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(articles: List<ArticleEntity>)
}

// :core:data — data/remote/ArticleApi.kt
interface ArticleApi {
    @GET("articles")
    suspend fun getArticles(): List<ArticleDto>
}
```

Wire the implementation in `coreDataModule`:

```kotlin
val coreDataModule = module {
    single<ArticleRepository> { ArticleRepositoryImpl(get(), get()) }
    // Room database, DAOs, Retrofit instances bound here too
}
```

## Composable Conventions

- Every `@Composable` function needs a `@Preview`. Catches layout issues without launching the app.
- Use Material 3 components in `:app` features; Wear Material 3 in `:wear` features.
- Platform shells call feature screens — features don't know which platform they're on.
- **Feature-scoped components live in a `component/` package inside the platform submodule** (e.g., `features/dashboard/app/component/StatCard.kt`). Promote to a shared `:core:ui:app` module only when a _second_ feature needs the same component (lazy promotion, see below).
- The `app/` and `wear/` submodules within a feature do not share UI or ViewModels. Different Compose toolkits, different UI shape, different state. The shared code is in `:core:domain` (use cases, repositories, models).

## Strings

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

There's no shared `:core:designsystem` module by default. If your project ever needs custom brand tokens (specific colors, custom typography, semantic palette overrides) shared across platforms, create a `:core:designsystem` module then. Until then, the trivial duplication of a few hex values across platform shells is cheaper than the module.

## Lazy Widget Promotion

Feature-local widgets start in `features/<name>/<platform>/component/`. When a _second_ feature needs the same component, promote it to a shared module:

- For `:app` widgets: promote to `:core:ui:app` (Material 3, depends on `:core:domain`)
- For `:wear` widgets: promote to `:core:ui:wear` (Wear Material 3, depends on `:core:domain`)

These modules don't exist at project init — create them by hand when you actually need them. Strings tied to a promoted widget come along with it (move them out of `:core:strings` into the new `:core:ui:*` module's `res/values/strings.xml` only when they're inseparable from the widget).

Don't create empty `:core:ui:*` modules on speculation. The point of lazy promotion is that the module's existence is justified by real reuse.

## Formatting

Spotless with ktfmt (Google style) enforces consistent formatting across all Kotlin and Gradle KTS files. Configured in the root `build.gradle.kts` and applies to all modules automatically.

- Run `./gradlew spotlessApply` to auto-format before committing. Non-negotiable — CI will reject unformatted code.
- Run `./gradlew spotlessCheck` to verify formatting without modifying files.
- Do not add per-module Spotless configuration.
- If Spotless reformats code you just wrote, accept the changes — do not fight the formatter.

## Testing

Follow red-green TDD: write failing tests first, then implement until they pass. Run tests after every change.

- Use MockK for mocking.
- Prefer module-scoped test commands (`./gradlew :features:dashboard:app:test`) over `./gradlew test` when working on a single feature — leverages the modular architecture for faster feedback.
- `:core:domain` tests run as plain JVM tests (no Android dependencies, no instrumentation) — instant feedback.

**Use case test:**

```kotlin
class GetArticlesUseCaseTest {

    private val repository: ArticleRepository = mockk()
    private val useCase = GetArticlesUseCase(repository)

    @Test
    fun `returns articles sorted by date`() = runTest {
        val articles = listOf(
            Article(id = "1", title = "Old", date = LocalDateTime.of(2026, 1, 1, 0, 0)),
            Article(id = "2", title = "New", date = LocalDateTime.of(2026, 3, 1, 0, 0)),
        )
        coEvery { repository.getArticles() } returns articles

        val result = useCase()

        assertTrue(result.isSuccess)
        assertEquals("2", result.getOrThrow().first().id)
    }

    @Test
    fun `returns failure when repository throws`() = runTest {
        coEvery { repository.getArticles() } throws RuntimeException("Network error")

        val result = useCase()

        assertTrue(result.isFailure)
    }
}
```

**ViewModel test:**

```kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class DashboardViewModelTest {

    private val testDispatcher = StandardTestDispatcher()
    private val getDashboardUseCase: GetDashboardUseCase = mockk()

    @Before
    fun setup() { Dispatchers.setMain(testDispatcher) }

    @After
    fun tearDown() { Dispatchers.resetMain() }

    @Test
    fun `loads data on refresh`() = runTest {
        coEvery { getDashboardUseCase() } returns Result.success(DashboardData(/* ... */))

        val viewModel = DashboardViewModel(getDashboardUseCase)
        viewModel.onRefresh()
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertNotNull(state.data)
    }
}
```

## Common Commands

```bash
./gradlew build                            # Build all modules
./gradlew :app:installDebug                # Install :app
./gradlew :wear:installDebug               # Install :wear
./gradlew test                             # Run all tests
./gradlew :features:<name>:app:test        # Run single feature tests
./gradlew :core:domain:test                # Run pure-Kotlin domain tests (fast)
./gradlew spotlessApply                    # Format code
```

## Common Scenarios

**"I need to share a data class between two features"**
Move it to `:core:domain/domain/model/`. Features only depend on `:core:domain`, so any shared type must live there. Do not add a dependency between features — Gradle will reject it, and even if it didn't, it would break the isolation that keeps builds fast.

**"Where should I put this new screen?"**
First decide which feature (business capability) it belongs to. A "forgot password" screen belongs in `:features:auth`, not a new `:features:forgot-password` module. Then place it in the appropriate platform submodule (`app/` or `wear/`).

**"I want to add a Wear version of an existing feature"**
Create a `wear/` submodule alongside the existing `app/` submodule under that feature. Easiest path: delete the feature directory, then run `scripts/generate.sh feature <name> --wear`. Or manually mirror the `app/` structure with Wear Material 3 imports. The business logic in `:core:domain` is already shared — no changes needed there.

**"Should I use LiveData or StateFlow?"**
StateFlow. The entire codebase uses StateFlow + coroutines for reactive state. LiveData is not part of this stack.

**"Can I add library X?"**
Ask first. The current stack covers most needs. If you think something is missing, explain what problem it solves and why the existing stack can't handle it.

**"I need to add a home screen widget"**
Run `scripts/generate.sh widget`. Creates `:widget` at the root with a Glance-based receiver and an example widget Composable. Depends on `:core:data` + `:core:strings`.

**"I need to add a Wear OS complication"**
Run `scripts/generate.sh complications`. Creates `:complications` with a `SuspendingComplicationDataSourceService` skeleton. Depends only on `:core:domain`.

**"I need to add a Wear OS tile"**
Run `scripts/generate.sh tiles`. Creates `:tiles` with a `TileService` skeleton. Depends only on `:core:domain`.

**"I need Wearable Data Layer sync between :app and :wear"**
Add `implementation(libs.play.services.wearable)` to both `:app/build.gradle.kts` and `:wear/build.gradle.kts`. The Data Layer client (`Wearable.getDataClient(context)`) and listener services live in `:core:data` so both platforms share the sync logic.

**"I'm getting unresolved reference errors across modules"**
Check the dependency flow:

- A feature module trying to use Room/DataStore directly → wrong, those live in `:core:data` and only platform shells touch them
- A feature module trying to use a type from another feature → wrong, move the type to `:core:domain`
- A platform shell can't find a feature → check `settings.gradle.kts` auto-discovery and the shell's `build.gradle.kts` includes the right `:features:<name>:<platform>` dependency

**"I need a string used by a single feature"**
Add it to `:core:strings/src/main/res/values/strings.xml`. The feature module already depends on `:core:strings` — reference it as `R.string.<name>` (where `R` is `<package>.strings.R`).

## Reference

For the full module structure, dependency rules, and rationale, read `references/ARCHITECTURE.md`.
