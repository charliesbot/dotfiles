# Implementation Patterns

Code templates for the three layers an agent touches most: ViewModels in features, use cases and repository interfaces in `:core:domain`, repository implementations + DAOs + APIs in `:core:data`. Models live in `:core:model`. Read this file when you're about to write or modify one of these.

## ViewModel Pattern

Each platform submodule has its own ViewModel. ViewModels use StateFlow and live in their platform submodule (e.g., `features/dashboard/app/` has `DashboardViewModel`, `features/dashboard/wear/` has `WearDashboardViewModel`). The two ViewModels don't share code — they manage different UI states for different toolkits. The shared logic is the use case they both call.

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

### Koin: `koinViewModel()` vs `get()`

A common confusion: in Compose, **always use `koinViewModel()` for ViewModels** — not `get()`. The two functions look interchangeable but have different lifecycle semantics:

- `koinViewModel<T>()` — Compose-aware, scopes the instance to the nearest `ViewModelStoreOwner`. Without Navigation 3's ViewModel decorators, that owner is usually the host Activity. Survives configuration changes. Use this in every `@Composable` screen.
- `get<T>()` — gives you a new instance each call (for `factory`) or the singleton (for `single`). Does **not** participate in the ViewModel lifecycle. Using `get()` for a ViewModel re-creates it on every recomposition and loses state on rotation.

Register the ViewModel in the feature's Koin module with `viewModel { ... }` (not `factory` or `single`):

```kotlin
// features/dashboard/app/src/main/kotlin/.../di/DashboardModule.kt
val dashboardModule = module {
    viewModel { DashboardViewModel(get()) }   // get() resolves GetDashboardUseCase from coreDataModule
}
```

Inject in a Composable screen:

```kotlin
@Composable
fun DashboardScreen(
    viewModel: DashboardViewModel = koinViewModel(),   // not get()
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    // ...
}
```

Wire the module in the `:app` shell's Application class:

```kotlin
class AppApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidContext(this@AppApplication)
            modules(coreDataModule, dashboardModule, /* ...other feature modules */)
        }
    }
}
```

The same pattern works in Navigation 3, but destination scoping is not automatic. If a route needs a ViewModel cleared when its `NavEntry` is popped, add `androidx.lifecycle:lifecycle-viewmodel-navigation3` and provide Navigation 3 entry decorators such as `rememberSaveableStateHolderNavEntryDecorator()` and `rememberViewModelStoreNavEntryDecorator()` to `NavDisplay`. Then each route's `NavEntry` content block can call `koinViewModel()` against that entry's `ViewModelStoreOwner`. Use `get()` only for non-ViewModel injections (e.g., a logger or repository inside a `LaunchedEffect`).

## Navigation Delegation Pattern

Platform shells own Navigation 3 keys, the back stack, `NavDisplay`, and every `backStack` mutation. Keep `@Serializable NavKey` types inside `:app` or `:wear`, not inside feature modules. Navigation keys describe platform composition, and `:app` and `:wear` often need different route shapes for the same domain journey.

Feature screens expose navigation intent through callback lambdas. They never import another feature's route type, mutate a platform back stack, or expose their own `NavKey` classes as a public feature API.

```kotlin
@Composable
fun ArticleListScreen(
    onArticleClick: (articleId: String) -> Unit,
) {
    // ...
}
```

The platform shell maps those callbacks to its own `NavKey` and back-stack operations:

```kotlin
@Serializable
sealed interface AppScreen : NavKey {
    @Serializable
    data object ArticleList : AppScreen

    @Serializable
    data class ArticleDetail(val articleId: String) : AppScreen
}

NavDisplay(
    backStack = backStack,
    entryProvider = entryProvider {
        entry<AppScreen.ArticleList> {
            ArticleListScreen(
                onArticleClick = { articleId -> backStack.add(AppScreen.ArticleDetail(articleId)) },
            )
        }
        entry<AppScreen.ArticleDetail> { screen ->
            ArticleDetailScreen(articleId = screen.articleId)
        }
    },
)
```

This keeps feature modules independent, prevents circular feature dependencies, and lets each platform shell choose its own navigation graph without changing feature UI APIs.

## Use Case Pattern

Use cases live in `:core:domain` under `domain/usecase/<capability>/` and encapsulate a single business operation. Group by capability (e.g., `usecase/library/`, `usecase/reader/`) for navigability. They use Kotlin's built-in `Result<T>` (from `kotlin.Result`) — not a custom wrapper. One-shot operations use `suspend` + `Result<T>`. Reactive streams use `Flow`.

There's no scaffold script for use cases — they're a single Kotlin file you copy and adapt.

**Suspend variant:**

```kotlin
package com.myapp.domain.usecase.library

import com.myapp.domain.repository.ArticleRepository
import com.myapp.model.Article

class GetArticlesUseCase(
    private val articleRepository: ArticleRepository,
) {
    suspend operator fun invoke(): Result<List<Article>> = runCatching {
        articleRepository.getArticles().sortedByDescending { it.date }
    }
}
```

**Flow variant:**

```kotlin
package com.myapp.domain.usecase.auth

import com.myapp.domain.repository.AuthRepository
import com.myapp.model.AuthState
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

Domain **models** live in `:core:model` under `model/`. Repository **interfaces** live in `:core:domain` under `domain/repository/`. Repository **implementations** live in `:core:data` under `data/repository/`. Room entities and DAOs live in `:core:data` under `data/local/`. Retrofit/Ktor interfaces live in `:core:data` under `data/remote/`.

```kotlin
// :core:model — model/Article.kt
package com.myapp.model

import java.time.LocalDateTime

data class Article(val id: String, val title: String, val date: LocalDateTime)

// :core:domain — domain/repository/ArticleRepository.kt
package com.myapp.domain.repository

import com.myapp.model.Article

interface ArticleRepository {
    suspend fun getArticles(): List<Article>
}

// :core:data — data/repository/ArticleRepositoryImpl.kt
package com.myapp.data.repository

import com.myapp.domain.repository.ArticleRepository
import com.myapp.model.Article

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
