# Testing

Follow red-green TDD: write failing tests first, then implement until they pass. Run tests after every change. Read this file when you're about to add or modify tests.

- Use MockK for mocking.
- Prefer module-scoped test commands (`./gradlew :features:dashboard:app:test`) over `./gradlew test` when working on a single feature — leverages the modular architecture for faster feedback.
- `:core:model` and `:core:domain` tests run as plain JVM tests (no Android dependencies, no instrumentation) — instant feedback.

## Use case test

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

## ViewModel test

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
