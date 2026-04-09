---
name: android-dev
description: >
  Architecture guide for a multi-module Android project targeting phone, Wear OS, TV, and Auto from a
  single codebase. MUST use this skill whenever the user mentions: features/ or :features: module paths,
  :core module, :app/:wear/:widget/:complications modules, Koin DI wiring, scaffold-feature.sh or
  scaffold-usecase.sh scripts, Wear OS support (tiles, complications, watch UI), Navigation 3 or Wear
  Compose Navigation, StateFlow/MVVM patterns, Spotless/ktfmt formatting, or any question about where
  code belongs across modules. Also trigger on Android build errors (unresolved references, circular
  dependencies, Gradle sync failures) and when adding new features, use cases, widgets, or platform
  variants. If the user is working on ANY Android code in a multi-module project — scaffolding features,
  writing ViewModels/Composables, configuring Gradle/Room/Retrofit, running tests, or asking about
  architecture decisions — use this skill. When in doubt, use it.
---

You are working on a multi-platform Android project following this architecture and conventions. Read `references/ARCHITECTURE.md` for the full module structure and dependency rules before making architectural decisions.

## Before You Write Any Code

When creating a new feature or use case, **run the scaffold script first** — before creating any files, directories, or `build.gradle.kts` manually. The scripts are bundled in this skill's `scripts/` directory — do not copy them into the project. They enforce the correct module structure and save time:

- **New feature:** `${CLAUDE_SKILL_DIR}/scripts/scaffold-feature.sh <name> <package>` (add `--wear` for Wear OS support)
- **New use case:** `${CLAUDE_SKILL_DIR}/scripts/scaffold-usecase.sh <Name> <package> <Repository>` (add `--flow` for reactive streams)

Then fill in the generated TODOs. Details on post-scaffold steps are in the Scaffolding sections below.

## Core Principles

The architecture supports multiple Android platforms (mobile, Wear OS, TV, Auto) from a single codebase. Everything flows in one direction:

```
app           → features:*:app  → core
wear          → features:*:wear → core
widget        → core
complications → core
```

Features are **business capabilities** (auth, profile, cart), not individual screens — grouping by user journey keeps modules cohesive and avoids a proliferation of tiny modules that each cache poorly. A feature module contains only presentation logic — business logic lives in `:core` so it can be reused across platforms without duplication. Features never depend on each other, which Gradle enforces at compile time, preventing the codebase from devolving into a tangled dependency graph as it grows.

## Do Not

- **Add dependencies between feature modules** — features depend only on `:core`. If two features need the same type, move it to `:core`.
- **Add third-party libraries without asking** — the current stack covers most needs. Explain what's missing before adding anything.
- **Put business logic in feature modules** — repositories, use cases, and domain models belong in `:core`. Features are presentation only.
- **Create feature modules for single screens** — a feature is a complete user journey (e.g., `:features:auth` covers login, register, and forgot password).
- **Create flat feature modules** — always use platform submodules (`app/`, `wear/`), even for phone-only features.
- **Put widget or complication code inside `:app` or `:wear`** — they're standalone entry points and get their own root-level modules.
- **Use LiveData** — the entire codebase uses StateFlow + coroutines.
- **Skip writing tests** — follow red-green TDD. Write the failing test first.
- **Skip `@Preview`** — every `@Composable` needs one.
- **Manually create feature or use case boilerplate** — always use the bundled `scaffold-feature.sh` or `scaffold-usecase.sh` scripts from this skill's `scripts/` directory. They exist to prevent structural mistakes.

## Tech Stack

| Concern             | Choice                                               |
| ------------------- | ---------------------------------------------------- |
| UI                  | Jetpack Compose + Material 3                         |
| DI                  | Koin                                                 |
| Networking          | Retrofit + OkHttp                                    |
| Database            | Room                                                 |
| Serialization       | Kotlinx Serialization                                |
| Image loading       | Coil                                                 |
| Navigation (mobile) | Navigation 3 (`androidx.navigation3`)                |
| Navigation (wear)   | Wear Compose Navigation                              |
| State management    | StateFlow + MVVM                                     |
| Formatting          | Spotless                                             |
| Testing             | MockK                                                |
| Build               | Gradle KTS + version catalogs (`libs.versions.toml`) |

Do not add third-party dependencies without asking first — every dependency is a long-term maintenance commitment, and the chosen stack already covers most needs.

## Module Structure

- **`:core`** — business logic, data layer (Room, Retrofit, repositories), domain models, use cases, shared UI (theme, components), DI for core infrastructure, and all string resources (split by feature file for organization).
- **`:features:<name>:app`** — phone presentation: ViewModel, Composable screens (Material 3), feature-scoped DI module.
- **`:features:<name>:wear`** — wear presentation: ViewModel, Composable screens (Wear Material 3), feature-scoped DI module.
- **`:app`**, **`:wear`**, **`:tv`**, **`:auto`** — platform shells that wire navigation and load DI modules. Each platform uses its own navigation library.
- **`:widget`** — home screen widget (Glance or `AppWidgetProvider`). Depends only on `:core` because widgets are standalone OS entry points that need data but not app navigation or feature screens.
- **`:complications`** — Wear OS complication data providers. Depends only on `:core` for the same reason — the watch face calls them directly, outside of the app's UI.

Every feature always uses platform submodules (`app/`, `wear/`, etc.) — even if it only targets one platform today. This removes the "is this feature flat or nested?" guessing game and means adding a Wear or TV variant later is just adding a sibling submodule, not restructuring existing code.

Widgets and complications are **not** features — they're standalone entry points the OS launches independently. They sit at the same level as `:app` and `:wear`, depending directly on `:core` without going through feature modules.

New feature modules are auto-registered via wildcard include in `settings.gradle.kts`:

```kotlin
file("features").listFiles()?.filter { it.isDirectory }?.forEach {
    include(":features:${it.name}")
}
```

## ViewModel Pattern

Each platform submodule has its own ViewModel. ViewModels use StateFlow and live inside their platform submodule (e.g., `features/dashboard/app/` has `DashboardViewModel`, `features/dashboard/wear/` has `WearDashboardViewModel`).

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

Use cases live in `core/domain/usecase/` and encapsulate a single business operation. They use Kotlin's built-in `Result<T>` (from `kotlin.Result`) — not a custom wrapper. One-shot operations use `suspend` + `Result<T>`. Reactive streams use `Flow`.

```kotlin
// Suspend — one-shot fetch
class GetArticlesUseCase(
    private val articleRepository: ArticleRepository
) {
    suspend operator fun invoke(): Result<List<Article>> {
        return runCatching {
            articleRepository.getArticles().sortedByDescending { it.date }
        }
    }
}

// Flow — reactive stream
class ObserveAuthStateUseCase(
    private val authRepository: AuthRepository
) {
    operator fun invoke(): Flow<AuthState> {
        return authRepository.observeAuthState()
    }
}
```

Register in Koin: `factory { GetArticlesUseCase(get()) }`

## Data Layer

Repositories live in `core/data/repository/`, with interfaces in `core/domain/repository/`. Room entities and DAOs live in `core/data/local/`, Retrofit interfaces in `core/data/remote/`.

```kotlin
// core/domain/repository/ArticleRepository.kt
interface ArticleRepository {
    suspend fun getArticles(): List<Article>
}

// core/data/repository/ArticleRepositoryImpl.kt
class ArticleRepositoryImpl(
    private val articleDao: ArticleDao,
    private val articleApi: ArticleApi
) : ArticleRepository {
    override suspend fun getArticles(): List<Article> {
        return articleDao.getAll().map { it.toDomain() }
    }
}

// core/data/local/ArticleDao.kt
@Dao
interface ArticleDao {
    @Query("SELECT * FROM articles ORDER BY date DESC")
    suspend fun getAll(): List<ArticleEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(articles: List<ArticleEntity>)
}

// core/data/remote/ArticleApi.kt
interface ArticleApi {
    @GET("articles")
    suspend fun getArticles(): List<ArticleDto>
}
```

## Composable Conventions

- Every `@Composable` function needs a `@Preview` — this catches layout issues early without needing to run the full app, which is especially valuable in a multi-platform project where you can't easily test every screen on every device.
- Use Material 3 components and the app's shared theme from `:core:ui:theme`.
- Wear screens use Wear Material 3 components in the `features/<name>/wear/` submodule.
- Platform modules call feature screens — features don't know which platform they're on.
- Feature-scoped components go in a `component/` package inside the platform submodule. If only the dashboard uses a `StatCard`, it lives in `features/dashboard/app/component/`, not in `:core`. Promote to `:core:ui:component` only when multiple features need it.
- The `app/` and `wear/` submodules within a feature do not share UI or ViewModels. They use different Compose toolkits and typically manage different UI state. The only shared code is in `:core` (use cases, repositories, domain models).

## Strings

All strings live in `:core` resources with both English and Spanish translations, organized into separate files per feature. This keeps translations in sync across platforms (phone, wear, TV) without refactoring when adding a new platform — `:core` is the only module all platform submodules share.

```
core/src/main/res/
├── values/
│   ├── strings.xml                # App-wide: "Cancel", "OK", "Error", app name
│   ├── strings_feed.xml           # Feed feature: "Feed", "No posts yet"
│   ├── strings_auth.xml           # Auth feature: "Log in", "Forgot password?"
│   └── strings_settings.xml       # Settings feature: "Dark mode", "Language"
└── values-es/
    ├── strings.xml
    ├── strings_feed.xml
    ├── strings_auth.xml
    └── strings_settings.xml
```

Android merges all `res/values/*.xml` files at build time, so splitting by feature is transparent to the build system. Each file stays small, and deleting a feature means deleting its string file.

Platform-only strings (e.g., a Wear-specific label that no other platform uses) can live in the platform submodule's own `res/values/`, but default to `:core` unless you're sure it's single-platform.

## Formatting

Spotless with ktfmt (Google style) enforces consistent formatting across all Kotlin and Gradle KTS files. It runs as a Gradle plugin — no IDE configuration needed.

- Run `./gradlew spotlessApply` to auto-format before committing. This is non-negotiable — CI will reject unformatted code.
- Run `./gradlew spotlessCheck` to verify formatting without modifying files (useful in CI).
- Spotless is configured in the root `build.gradle.kts` and applies to all modules automatically. Do not add per-module Spotless configuration.
- If Spotless reformats code you just wrote, accept the changes — do not fight the formatter.

## Testing

Follow red-green TDD: write failing tests first, then implement until they pass. Run tests after every change. Writing the test first forces you to think about the API before the implementation, and catching regressions immediately is far cheaper than debugging them later.

- Use MockK for mocking.
- Prefer module-scoped test commands (`./gradlew :features:dashboard:app:test`) over `./gradlew test` when working on a single feature — this leverages the modular architecture for faster feedback loops instead of recompiling and testing everything.

**Use case test example:**

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

**ViewModel test example:**

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

## Scaffolding a New Feature

**Always start by running the scaffold script** — do not manually create feature directories, `build.gradle.kts`, or boilerplate files. The script ensures the correct structure every time:

```bash
# Phone only
${CLAUDE_SKILL_DIR}/scripts/scaffold-feature.sh <feature-name> <base-package>

# Phone + Wear
${CLAUDE_SKILL_DIR}/scripts/scaffold-feature.sh <feature-name> <base-package> --wear
```

This creates the full directory structure with `build.gradle.kts`, ViewModel (StateFlow), Screen (Composable + Preview), and Koin DI module for each platform submodule — even for phone-only features (they still get the `app/` submodule).

After running the script:

1. Register the Koin module in the platform's DI setup.
2. Add navigation routes in the platform module.
3. Add strings in `:core` as `strings_<feature>.xml` (English + Spanish).
4. Write tests first, then implement.

## Scaffolding a Use Case

Use the bundled script to generate a use case in `:core`:

```bash
# Suspend function returning Result<T>
${CLAUDE_SKILL_DIR}/scripts/scaffold-usecase.sh <UseCaseName> <base-package> <RepositoryName>

# Flow-based (reactive, non-suspend)
${CLAUDE_SKILL_DIR}/scripts/scaffold-usecase.sh <UseCaseName> <base-package> <RepositoryName> --flow
```

Examples:

```bash
${CLAUDE_SKILL_DIR}/scripts/scaffold-usecase.sh GetArticles com.myapp FeedRepository
${CLAUDE_SKILL_DIR}/scripts/scaffold-usecase.sh ObserveAuthState com.myapp AuthRepository --flow
```

After running the script:

1. Replace the `TODO` placeholders with the actual return type and repository call.
2. Register in the Koin core DI module: `factory { GetArticlesUseCase(get()) }`
3. Write a test for the use case.

## Scaffolding a New Platform Module

When adding a new platform (e.g., `:tv`):

1. Create the directory at root level: `tv/`
2. Set up `build.gradle.kts` as an application module depending on `:core` and relevant `:features:*:<platform>`
3. Implement platform-appropriate navigation
4. Create a DI module that loads core + feature modules
5. Add to `settings.gradle.kts` with `include(":tv")`

## Common Commands

```bash
./gradlew build                          # Build all modules
./gradlew :app:installDebug              # Install mobile app
./gradlew test                           # Run all tests
./gradlew :features:<name>:app:test       # Run single feature tests
./gradlew :core:test                     # Run core tests
./gradlew spotlessApply                  # Format code
```

## Common Scenarios

**"I need to share a data class between two features"**
Move it to `:core:domain:model`. Features only depend on `:core`, so any shared type must live there. Do not add a dependency between features — Gradle will reject it, and even if it didn't, it would break the isolation that keeps builds fast.

**"Where should I put this new screen?"**
First decide which feature (business capability) it belongs to. A "forgot password" screen belongs in `:features:auth`, not a new `:features:forgot-password` module. Then place it in the appropriate platform submodule (`app/` or `wear/`).

**"I want to add a Wear version of an existing feature"**
Create a `wear/` submodule alongside the existing `app/` submodule under that feature. The Wear submodule gets its own ViewModel, DI module, and Composable screens using Wear Material 3. Wire the navigation in the `:wear` platform module. The business logic in `:core` is already shared — no changes needed there.

**"Should I use LiveData or StateFlow?"**
StateFlow. The entire codebase uses StateFlow + coroutines for reactive state. LiveData is not part of this stack.

**"Can I add library X?"**
Ask first. The current stack (Koin, Retrofit, Room, Coil, Kotlinx Serialization, MockK) covers most needs. If you think something is missing, explain what problem it solves and why the existing stack can't handle it.

**"I need to add a home screen widget"**
Create a `:widget` module at root level. It depends only on `:core` — widgets are standalone OS entry points that need data (use cases, repositories) but not app navigation or feature screens. Use Glance for Compose-based widgets or `AppWidgetProvider` for traditional ones. Do not put widget code inside `:app`.

**"I need to add a Wear OS complication"**
Create a `:complications` module at root level. It depends only on `:core` — complications are data providers the watch face calls directly, outside of the app's UI. They use `SuspendingComplicationDataSourceService` to serve data. Do not put complication code inside `:wear`.

**"I'm getting unresolved reference errors across modules"**
Check the dependency flow: `app/wear → features:*:app/wear → core`. If a feature can't see something, it probably lives in another feature (not allowed) or hasn't been added to `:core` yet. If a platform module can't see a feature, check that `build.gradle.kts` includes the right `:features:<name>:<platform>` dependency.

## Reference

For the full module structure, dependency rules, and rationale, read `references/ARCHITECTURE.md`.
