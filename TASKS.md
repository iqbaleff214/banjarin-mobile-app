# TASKS.md — Banjarin Project Task Breakdown

> Tasks follow Clean Architecture layer order within each phase: **Domain → Data → Presentation**.  
> Each task that produces logic must include unit tests before the implementation is considered done (TDD).  
> Mark a task done by checking its top-level checkbox: `- [x] TASK-XXX`.

---

## Legend

| Symbol | Meaning |
|---|---|
| `[ ]` | Not started |
| `[x]` | Done |
| **DoD** | Definition of Done |
| **API** | Endpoint(s) consumed |

---

## Phase 0 — Foundation

> Project scaffold, core infrastructure, and cross-cutting concerns. No feature code yet. All subsequent phases depend on this.

---

- [x] **TASK-001: Clean Architecture Directory Scaffold**

  **Description:** Create the full `lib/` and `test/` directory structure as specified in PRD §13.3. No code — structure only, with placeholder `.gitkeep` files so the tree is committed.

  **Expected Output:**
  - `lib/core/{error,network,storage,usecase,utils}/`
  - `lib/features/{dictionary,community,identity,ai,admin}/{domain,data,presentation}/`
  - `lib/injection/`
  - `test/` mirroring `lib/features/` + `test/core/`
  - `integration_test/`

  **Definition of Done:**
  - [ ] All directories exist and are committed
  - [ ] `flutter analyze` passes with zero errors on the empty scaffold
  - [ ] `test/` tree mirrors `lib/features/` exactly

  **Unit Tests:** N/A

---

- [x] **TASK-002: Core Error Types and `Either` Monad**

  **Description:** Define all `Failure` subtypes used across the app and establish the `Either<Failure, T>` return convention for use cases and repositories. Failures map directly to API error codes in `openapi.yaml`.

  **Expected Output:**
  - `lib/core/error/failures.dart` — `Failure` base + `ServerFailure`, `NetworkFailure`, `UnauthorizedFailure`, `ForbiddenFailure`, `NotFoundFailure`, `ConflictFailure`, `RateLimitedFailure`, `AIUnavailableFailure`, `ValidationFailure`, `CacheFailure`
  - `lib/core/error/exceptions.dart` — `ServerException`, `CacheException`, `NetworkException`
  - Add `dartz` (or `fpdart`) to `pubspec.yaml`

  **Definition of Done:**
  - [ ] All failure types defined with relevant fields (e.g. `message`, `details`)
  - [ ] `RateLimitedFailure` carries a `retryAfterSeconds` field for UI countdown
  - [ ] `ValidationFailure` carries a `Map<String, List<String>>` for field-level errors
  - [ ] Unit tests pass

  **Unit Tests:**
  - `Failure subtypes are distinct types`
  - `ValidationFailure stores field-level error map correctly`
  - `RateLimitedFailure stores retryAfterSeconds`

---

- [x] **TASK-003: Dio HTTP Client Setup**

  **Description:** Configure a `Dio` instance with base URL, default headers (`Content-Type: application/json`), timeouts, and error response mapping. Response interceptor maps API error envelopes (`success: false, error.code`) to the `Failure` subtypes from TASK-002.

  **Expected Output:**
  - `lib/core/network/dio_client.dart`
  - `lib/core/network/api_error_mapper.dart` — maps `error.code` string → `Failure`

  **Definition of Done:**
  - [ ] Base URL is read from `.env` via `flutter_dotenv`
  - [ ] Response interceptor maps each error code (`VALIDATION_ERROR`, `UNAUTHORIZED`, `FORBIDDEN`, `NOT_FOUND`, `CONFLICT`, `RATE_LIMITED`, `AI_UNAVAILABLE`, `INTERNAL_ERROR`) to correct `Failure`
  - [ ] Network timeout mapped to `NetworkFailure`
  - [ ] Unit tests pass with mocked `DioAdapter`

  **Unit Tests:**
  - `ApiErrorMapper when code is VALIDATION_ERROR returns ValidationFailure`
  - `ApiErrorMapper when code is RATE_LIMITED returns RateLimitedFailure with retryAfterSeconds`
  - `ApiErrorMapper when code is AI_UNAVAILABLE returns AIUnavailableFailure`
  - `ApiErrorMapper when code is UNAUTHORIZED returns UnauthorizedFailure`
  - `DioClient on network timeout returns NetworkFailure`

---

- [x] **TASK-004: Token Interceptor (Silent Refresh + 401 Redirect)**

  **Description:** Dio `QueuedInterceptorsWrapper` that attaches `Authorization: Bearer <access_token>` to every request. On 401 response, calls `POST /auth/refresh` once. If refresh succeeds, retries the original request. If refresh returns 401, clears tokens from secure storage and emits an `UnauthorizedFailure` that triggers navigation to the Login screen.

  **API:** `POST /auth/refresh`

  **Expected Output:**
  - `lib/core/network/token_interceptor.dart`

  **Definition of Done:**
  - [ ] Access token attached to all non-public requests
  - [ ] On 401: refresh called exactly once, original request retried with new token
  - [ ] On refresh 401: tokens cleared, `UnauthorizedFailure` emitted
  - [ ] Concurrent requests during refresh are queued and retried after refresh completes (no duplicate refresh calls)
  - [ ] Unit tests pass

  **Unit Tests:**
  - `TokenInterceptor attaches Bearer token to request headers`
  - `TokenInterceptor on 401 calls refresh and retries original request`
  - `TokenInterceptor on refresh 401 clears stored tokens`
  - `TokenInterceptor queues concurrent requests during refresh and retries all after success`
  - `TokenInterceptor does not attach token to POST /auth/login and POST /auth/register`

---

- [x] **TASK-005: Secure Storage Abstraction**

  **Description:** Abstract over `flutter_secure_storage` for storing and retrieving JWT access token, refresh token, and their expiry. Exposes a clean interface so the token interceptor and AuthBloc never depend on `flutter_secure_storage` directly.

  **Expected Output:**
  - `lib/core/storage/token_storage.dart` (abstract)
  - `lib/core/storage/secure_token_storage.dart` (implementation)

  **Definition of Done:**
  - [ ] Interface exposes `saveTokens`, `getAccessToken`, `getRefreshToken`, `clearTokens`
  - [ ] Unit tests pass with mock implementation

  **Unit Tests:**
  - `SecureTokenStorage saveTokens stores access and refresh tokens`
  - `SecureTokenStorage getAccessToken returns null when not set`
  - `SecureTokenStorage clearTokens removes both tokens`

---

- [x] **TASK-006: Hive Local Cache Abstraction**

  **Description:** Initialize Hive for local caching of word list (first page), word detail, and bookmarks. Define a generic `LocalDataSource` interface and a Hive-backed implementation with TTL support.

  **Expected Output:**
  - `lib/core/storage/local_cache.dart` (abstract: `get`, `put`, `invalidate`)
  - `lib/core/storage/hive_local_cache.dart` (implementation with TTL)
  - Hive box initialization in `main.dart`

  **Definition of Done:**
  - [ ] `put` stores data with an expiry timestamp
  - [ ] `get` returns `null` if TTL has elapsed
  - [ ] `invalidate` removes the entry immediately
  - [ ] Unit tests pass

  **Unit Tests:**
  - `HiveLocalCache get returns data before TTL expires`
  - `HiveLocalCache get returns null after TTL elapsed`
  - `HiveLocalCache invalidate removes stored entry`

---

- [x] **TASK-007: GoRouter Navigation Setup + Deep Links**

  **Description:** Configure `go_router` with all named routes, authentication redirect logic, and deep link handling for `banjarin://verify-email`, `banjarin://reset-password`, and `banjarin://word/{id}`.

  **Expected Output:**
  - `lib/core/router/app_router.dart`
  - Route constants in `lib/core/router/routes.dart`

  **Definition of Done:**
  - [ ] All routes from PRD §3.2 are declared
  - [ ] Unauthenticated access to `/terjemah`, `/simpanan`, `/profil/edit`, `/contributions` redirects to `/login`
  - [ ] Admin-only routes redirect to home if role is not `admin`
  - [ ] Deep links `banjarin://verify-email?token=`, `banjarin://reset-password?token=`, `banjarin://word/{id}` resolve to correct routes
  - [ ] `flutter analyze` passes

  **Unit Tests:** N/A (navigation integration tested in Phase 8)

---

- [x] **TASK-008: App Theme (Colors, Typography, Dark Mode)**

  **Description:** Define `ThemeData` for light and dark modes using the color palette from PRD §6.1. Include word class badge colors, source badge colors, and text styles for Banjar word display.

  **Expected Output:**
  - `lib/core/theme/app_theme.dart`
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`

  **Definition of Done:**
  - [ ] Light and dark `ThemeData` defined
  - [ ] Primary teal (`#0D7377`), amber (`#F2994A`), success, error colors present
  - [ ] Word class badge colors defined for all 7 classes (`n`, `v`, `a`, `adv`, `p`, `pb`, `ki`)
  - [ ] Source badge colors defined (`ai_generated` = amber, `contributed` = blue)
  - [ ] Theme switches correctly on system dark mode toggle

  **Unit Tests:** N/A

---

## Phase 1 — Identity

> Authentication, session management, and user profile. Depends on Phase 0.

---

- [x] **TASK-009: User Entity, TokenPair, and AuthSession**

  **Description:** Define pure Dart domain entities for the Identity bounded context. No JSON parsing here — that belongs in the data layer.

  **Expected Output:**
  - `lib/features/identity/domain/entities/user.dart` — `id`, `name`, `email`, `role` (enum: `user`/`admin`), `isActive`, `emailVerifiedAt`
  - `lib/features/identity/domain/entities/token_pair.dart` — `accessToken`, `refreshToken`, `expiresIn`
  - `lib/features/identity/domain/entities/auth_session.dart` — wraps `User` + `TokenPair`

  **Definition of Done:**
  - [ ] Entities are immutable (use `freezed` or manual `copyWith`)
  - [ ] `UserRole` enum has `user` and `admin` values
  - [ ] `User.isAdmin` getter returns `role == UserRole.admin`
  - [ ] Unit tests pass

  **Unit Tests:**
  - `User isAdmin returns true when role is admin`
  - `User isAdmin returns false when role is user`
  - `User emailVerified returns true when emailVerifiedAt is not null`

---

- [x] **TASK-010: AuthRepository Interface**

  **Description:** Define the abstract `AuthRepository` interface used by all identity use cases. No implementation here.

  **Expected Output:**
  - `lib/features/identity/domain/repositories/auth_repository.dart`

  **Methods:** `login`, `register`, `logout`, `refreshToken`, `getProfile`, `updateProfile`, `changePassword`, `forgotPassword`, `resetPassword`, `verifyEmail`

  **Definition of Done:**
  - [ ] All method signatures defined with `Future<Either<Failure, T>>` return types
  - [ ] No platform or package imports (pure Dart)

  **Unit Tests:** N/A (interface only)

---

- [x] **TASK-011: Login, Register, Logout, and RefreshToken Use Cases**

  **Description:** Implement use cases for the core auth flow. Each use case takes a `Params` class and returns `Either<Failure, T>`.

  **Expected Output:**
  - `lib/features/identity/domain/usecases/login.dart`
  - `lib/features/identity/domain/usecases/register.dart`
  - `lib/features/identity/domain/usecases/logout.dart`
  - `lib/features/identity/domain/usecases/refresh_token.dart`

  **Definition of Done:**
  - [ ] Each use case calls only its repository method
  - [ ] `Login.Params` validates email format and non-empty password before calling repo
  - [ ] `Register.Params` validates password min 8 chars and password == confirmation
  - [ ] All unit tests pass

  **Unit Tests:**
  - `Login when credentials are valid returns TokenPair`
  - `Login when password is empty returns ValidationFailure`
  - `Login when email is malformed returns ValidationFailure`
  - `Register when password is less than 8 chars returns ValidationFailure`
  - `Register when password and confirmation mismatch returns ValidationFailure`
  - `Register when params are valid delegates to repository`
  - `Logout delegates to repository`
  - `RefreshToken delegates to repository with refresh token`

---

- [x] **TASK-012: GetProfile, UpdateProfile, and ChangePassword Use Cases**

  **Expected Output:**
  - `lib/features/identity/domain/usecases/get_profile.dart`
  - `lib/features/identity/domain/usecases/update_profile.dart`
  - `lib/features/identity/domain/usecases/change_password.dart`

  **Definition of Done:**
  - [ ] `UpdateProfile.Params` validates name min 2 chars
  - [ ] `ChangePassword.Params` validates new password min 8 chars and confirmation match
  - [ ] All unit tests pass

  **Unit Tests:**
  - `UpdateProfile when name is less than 2 chars returns ValidationFailure`
  - `ChangePassword when new passwords mismatch returns ValidationFailure`
  - `ChangePassword when new password is less than 8 chars returns ValidationFailure`
  - `GetProfile delegates to repository`

---

- [x] **TASK-013: ForgotPassword, ResetPassword, and VerifyEmail Use Cases**

  **Expected Output:**
  - `lib/features/identity/domain/usecases/forgot_password.dart`
  - `lib/features/identity/domain/usecases/reset_password.dart`
  - `lib/features/identity/domain/usecases/verify_email.dart`

  **Definition of Done:**
  - [ ] `ResetPassword.Params` validates new password min 8 chars and confirmation match
  - [ ] All unit tests pass

  **Unit Tests:**
  - `ResetPassword when passwords mismatch returns ValidationFailure`
  - `ResetPassword when token is empty returns ValidationFailure`
  - `ForgotPassword delegates to repository with email`
  - `VerifyEmail delegates to repository with token`

---

- [x] **TASK-014: Auth Data Layer (Remote Data Source + Models + Repository Impl)**

  **API:** `POST /auth/login`, `POST /auth/register`, `POST /auth/logout`, `POST /auth/refresh`, `GET /auth/me`, `PATCH /auth/me`, `PATCH /auth/me/password`, `POST /auth/verify-email`, `POST /auth/forgot-password`, `POST /auth/reset-password`

  **Expected Output:**
  - `lib/features/identity/data/models/user_model.dart` — `fromJson`/`toJson`
  - `lib/features/identity/data/models/token_pair_model.dart`
  - `lib/features/identity/data/datasources/auth_remote_data_source.dart`
  - `lib/features/identity/data/repositories/auth_repository_impl.dart`

  **Definition of Done:**
  - [ ] `UserModel.fromJson` maps all fields including nullable `emailVerifiedAt`
  - [ ] Repository impl maps `DioException` → `Failure` via `ApiErrorMapper`
  - [ ] Repository impl stores tokens via `TokenStorage` on login/refresh
  - [ ] Repository impl clears tokens via `TokenStorage` on logout
  - [ ] Unit tests pass with mocked Dio adapter and mocked TokenStorage

  **Unit Tests:**
  - `AuthRemoteDataSource login on 200 returns TokenPairModel`
  - `AuthRemoteDataSource login on 401 throws ServerException with UNAUTHORIZED`
  - `AuthRemoteDataSource login on 429 throws ServerException with RATE_LIMITED`
  - `AuthRepositoryImpl login on success stores tokens and returns TokenPair`
  - `AuthRepositoryImpl login on ServerException returns correct Failure`
  - `AuthRepositoryImpl logout clears tokens from storage`

---

- [x] **TASK-015: AuthBloc**

  **Description:** Manages authentication state machine: `Unauthenticated`, `Authenticating`, `Authenticated(User)`, `AuthError`. Handles login, register, logout, session restore on app start.

  **Expected Output:**
  - `lib/features/identity/presentation/bloc/auth_bloc.dart`
  - `lib/features/identity/presentation/bloc/auth_event.dart`
  - `lib/features/identity/presentation/bloc/auth_state.dart`

  **Definition of Done:**
  - [ ] `CheckSession` event on app start restores session from secure storage
  - [ ] `Login` event emits `[Authenticating, Authenticated]` on success
  - [ ] `Login` event emits `[Authenticating, AuthError]` on failure with correct `Failure`
  - [ ] `Register` event emits `[Authenticating, RegisterSuccess]` (not yet authenticated — awaits email verify)
  - [ ] `Logout` event emits `[Unauthenticated]` and clears storage
  - [ ] `UnauthorizedFailure` from token interceptor triggers `Logout` event
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `AuthBloc CheckSession when tokens exist emits Authenticated`
  - `AuthBloc CheckSession when no tokens emits Unauthenticated`
  - `AuthBloc Login on success emits [Authenticating, Authenticated]`
  - `AuthBloc Login on UnauthorizedFailure emits [Authenticating, AuthError]`
  - `AuthBloc Login on RateLimitedFailure emits [Authenticating, AuthError] with retryAfter`
  - `AuthBloc Register on success emits [Authenticating, RegisterSuccess]`
  - `AuthBloc Logout emits [Unauthenticated]`

---

- [x] **TASK-016: Login and Register Pages**

  **Description:** Build the Login and Register screens per PRD §4.2.1 and §4.2.2. Both pages observe `AuthBloc`.

  **Expected Output:**
  - `lib/features/identity/presentation/pages/login_page.dart`
  - `lib/features/identity/presentation/pages/register_page.dart`
  - `lib/features/identity/presentation/widgets/auth_text_field.dart` (reusable)
  - `lib/features/identity/presentation/widgets/password_field.dart` (show/hide toggle)

  **Definition of Done:**
  - [ ] Login: email field, password field with show/hide, "Masuk" button, "Lupa kata sandi?" link, "Daftar" link
  - [ ] Register: nama, email, password, konfirmasi password fields, "Daftar" button
  - [ ] Inline field-level validation errors from `ValidationFailure.details`
  - [ ] Button shows loading spinner while `Authenticating`
  - [ ] On `Authenticated` state, router redirects to Home
  - [ ] On `RegisterSuccess` state, router navigates to Verify Email Notice
  - [ ] Rate limit countdown shown on Login when `RateLimitedFailure`
  - [ ] Widget tests pass

  **Unit Tests (widget_test):**
  - `LoginPage renders email and password fields`
  - `LoginPage submit button is disabled when fields are empty`
  - `LoginPage shows inline error when AuthBloc emits AuthError with ValidationFailure`
  - `LoginPage shows rate limit countdown when AuthBloc emits AuthError with RateLimitedFailure`
  - `RegisterPage shows password mismatch error on mismatched confirmation`

---

- [x] **TASK-017: Forgot Password, Reset Password, and Verify Email Pages**

  **Expected Output:**
  - `lib/features/identity/presentation/pages/forgot_password_page.dart`
  - `lib/features/identity/presentation/pages/reset_password_page.dart`
  - `lib/features/identity/presentation/pages/verify_email_page.dart`

  **Definition of Done:**
  - [ ] Forgot Password: single email field, on submit always shows success message (privacy-safe)
  - [ ] Reset Password: reached via deep link, token pre-populated from URL, two password fields
  - [ ] Verify Email Notice: shows email placeholder, "Buka Aplikasi Email" opens mail deep link
  - [ ] Deep link `banjarin://verify-email?token=` calls `VerifyEmail` use case and navigates to Home on success
  - [ ] Deep link `banjarin://reset-password?token=` navigates to Reset Password with token pre-filled

  **Unit Tests (widget_test):**
  - `ForgotPasswordPage always shows success message after submit regardless of result`
  - `ResetPasswordPage submit button disabled when passwords mismatch`
  - `VerifyEmailPage displays the registered email address`

---

- [x] **TASK-018: Profile Page (View, Edit, Change Password, Logout)**

  **API:** `GET /auth/me`, `PATCH /auth/me`, `PATCH /auth/me/password`, `POST /auth/logout`

  **Expected Output:**
  - `lib/features/identity/presentation/bloc/profile_bloc.dart`
  - `lib/features/identity/presentation/pages/profile_page.dart`
  - `lib/features/identity/presentation/pages/edit_profile_page.dart`
  - `lib/features/identity/presentation/pages/change_password_page.dart`

  **Definition of Done:**
  - [ ] Profile page shows avatar (initial-based), name, email, role, email verification status
  - [ ] Unverified email shows "Verifikasi emailmu untuk berkontribusi" banner
  - [ ] Guest view shows "Masuk" and "Daftar" buttons (no profile content)
  - [ ] Admin role shows "Panel Admin" menu item
  - [ ] Logout shows confirmation dialog before calling `Logout` event
  - [ ] Edit Profile page updates name inline and shows save confirmation
  - [ ] Change Password page validates old + new + confirmation before submit
  - [ ] Bloc tests pass

  **Unit Tests (bloc_test):**
  - `ProfileBloc LoadProfile emits [Loading, Loaded(User)]`
  - `ProfileBloc UpdateProfile on success emits updated User`
  - `ProfileBloc ChangePassword on success emits PasswordChanged`
  - `ProfileBloc ChangePassword on ValidationFailure emits ProfileError`

---

## Phase 2 — Dictionary

> Public word browsing and search. Depends on Phase 0. Phase 1 not required (public endpoints).

---

- [x] **TASK-019: Word, Definition, Example, and RelatedWord Entities**

  **Expected Output:**
  - `lib/features/dictionary/domain/entities/word.dart`
  - `lib/features/dictionary/domain/entities/word_summary.dart`
  - `lib/features/dictionary/domain/entities/definition.dart`
  - `lib/features/dictionary/domain/entities/example.dart`
  - `lib/features/dictionary/domain/entities/related_word.dart`
  - `lib/features/dictionary/domain/entities/word_class.dart` (enum: `n`, `v`, `a`, `adv`, `p`, `pb`, `ki`)
  - `lib/features/dictionary/domain/entities/content_source.dart` (enum: `seeded`, `contributed`, `ai_generated`)

  **Definition of Done:**
  - [ ] All fields from `openapi.yaml` Word and WordSummary schemas covered
  - [ ] `WordClass` enum has a `label` getter returning full Indonesian name (e.g. `n` → "Nomina")
  - [ ] `ContentSource.isAiGenerated` and `ContentSource.isContributed` getters
  - [ ] Entities are immutable
  - [ ] Unit tests pass

  **Unit Tests:**
  - `WordClass n label returns Nomina`
  - `WordClass pb label returns Pribahasa`
  - `ContentSource isAiGenerated returns true only for ai_generated`
  - `Word with homonymNumber greater than 1 is considered a homonym`

---

- [x] **TASK-020: WordRepository Interface**

  **Expected Output:**
  - `lib/features/dictionary/domain/repositories/word_repository.dart`

  **Methods:** `getWordList`, `searchWords`, `getWordDetail`, `getDefinitions`, `getExamples`, `getRelatedWords`

  **Definition of Done:**
  - [ ] All signatures return `Future<Either<Failure, T>>`
  - [ ] `getWordList` accepts `WordListParams` (page, perPage, wordClass, isRoot, source, sort)
  - [ ] `searchWords` accepts `SearchParams` (query, page, perPage, sort)
  - [ ] No platform imports

  **Unit Tests:** N/A (interface only)

---

- [x] **TASK-021: GetWordList and SearchWords Use Cases**

  **Expected Output:**
  - `lib/features/dictionary/domain/usecases/get_word_list.dart`
  - `lib/features/dictionary/domain/usecases/search_words.dart`

  **Definition of Done:**
  - [ ] `SearchWords` returns `ValidationFailure` when query is empty
  - [ ] Both delegate to repository when params are valid
  - [ ] Unit tests pass

  **Unit Tests:**
  - `GetWordList delegates to repository with correct params`
  - `SearchWords when query is empty returns ValidationFailure`
  - `SearchWords when query is valid delegates to repository`
  - `GetWordList with word class filter passes filter to repository`

---

- [x] **TASK-022: GetWordDetail, GetDefinitions, GetExamples, GetRelatedWords Use Cases**

  **Expected Output:**
  - `lib/features/dictionary/domain/usecases/get_word_detail.dart`
  - `lib/features/dictionary/domain/usecases/get_definitions.dart`
  - `lib/features/dictionary/domain/usecases/get_examples.dart`
  - `lib/features/dictionary/domain/usecases/get_related_words.dart`

  **Definition of Done:**
  - [ ] All delegate to repository with word ID param
  - [ ] Unit tests pass

  **Unit Tests:**
  - `GetWordDetail delegates to repository with word id`
  - `GetWordDetail when repository returns NotFoundFailure propagates it`
  - `GetDefinitions delegates to repository with word id`
  - `GetExamples delegates to repository with word id`
  - `GetRelatedWords delegates to repository with word id`

---

- [x] **TASK-023: Dictionary Data Layer (Models + Data Sources + Repository Impl)**

  **API:** `GET /words`, `GET /words/search`, `GET /words/{id}`, `GET /words/{id}/definitions`, `GET /words/{id}/examples`, `GET /words/{id}/related`

  **Expected Output:**
  - `lib/features/dictionary/data/models/word_model.dart`
  - `lib/features/dictionary/data/models/word_summary_model.dart`
  - `lib/features/dictionary/data/models/definition_model.dart`
  - `lib/features/dictionary/data/models/example_model.dart`
  - `lib/features/dictionary/data/datasources/word_remote_data_source.dart`
  - `lib/features/dictionary/data/datasources/word_local_data_source.dart` (Hive cache)
  - `lib/features/dictionary/data/repositories/word_repository_impl.dart`

  **Definition of Done:**
  - [ ] `WordModel.fromJson` correctly parses nullable `banjarSyllabified` and `rootWordId`
  - [ ] `DefinitionModel` parses `upvotes` and `downvotes`
  - [ ] Repository impl tries local cache first; falls back to remote; updates cache on success
  - [ ] Cache TTL for word list: 5 minutes. Cache TTL for word detail: 10 minutes.
  - [ ] Pagination metadata parsed and returned
  - [ ] Unit tests pass

  **Unit Tests:**
  - `WordModel fromJson parses all fields correctly`
  - `WordModel fromJson handles null banjarSyllabified`
  - `WordRemoteDataSource getWordList on 200 returns list of WordSummaryModel`
  - `WordRemoteDataSource getWordDetail on 404 throws ServerException with NOT_FOUND`
  - `WordRepositoryImpl getWordList returns cached data when cache is fresh`
  - `WordRepositoryImpl getWordList calls remote when cache is stale`
  - `WordRepositoryImpl getWordList updates cache after successful remote call`

---

- [x] **TASK-024: WordListBloc and SearchBloc**

  **Expected Output:**
  - `lib/features/dictionary/presentation/bloc/word_list_bloc.dart`
  - `lib/features/dictionary/presentation/bloc/search_bloc.dart`

  **Definition of Done:**
  - [ ] `WordListBloc` state holds `words`, `isLoading`, `hasMore`, `currentPage`, `filters`, `sort`, `error`
  - [ ] `LoadWords` event loads first page; `LoadMoreWords` appends next page
  - [ ] `FilterChanged` and `SortChanged` reset to page 1 and reload
  - [ ] `RefreshWords` (pull-to-refresh) resets to page 1 and reloads
  - [ ] `SearchBloc` debounces query changes (400ms) before emitting `Searching` event
  - [ ] `SearchBloc` emits `SearchEmpty` when query is cleared
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `WordListBloc LoadWords emits [Loading, Loaded] with first page`
  - `WordListBloc LoadMoreWords appends results and increments page`
  - `WordListBloc LoadMoreWords does not emit when hasMore is false`
  - `WordListBloc FilterChanged resets page to 1 and reloads`
  - `WordListBloc on NetworkFailure emits [Loading, Error]`
  - `SearchBloc QueryChanged emits SearchResults after debounce`
  - `SearchBloc QueryChanged with empty query emits SearchEmpty`

---

- [x] **TASK-025: WordDetailBloc**

  **Description:** Manages state for the Word Detail screen — loads word, definitions, examples, related words, and comments. Vote and bookmark state handled here; delegated to VoteBloc/BookmarkBloc in Phase 3.

  **Expected Output:**
  - `lib/features/dictionary/presentation/bloc/word_detail_bloc.dart`

  **Definition of Done:**
  - [ ] State holds `word`, `definitions`, `examples`, `relatedWords`, `isLoading`, `error`
  - [ ] `LoadWordDetail` triggers parallel fetch of word + definitions + examples + related
  - [ ] On any sub-fetch failure, partial data shown with inline error
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `WordDetailBloc LoadWordDetail emits [Loading, Loaded] with full word data`
  - `WordDetailBloc LoadWordDetail on NotFoundFailure emits [Loading, Error]`
  - `WordDetailBloc LoadWordDetail on NetworkFailure shows partial cached data`

---

- [x] **TASK-026: Reusable Dictionary Widgets**

  **Description:** Build the core reusable display widgets used across Beranda, Search, and Word Detail.

  **Expected Output:**
  - `lib/features/dictionary/presentation/widgets/word_card.dart`
  - `lib/features/dictionary/presentation/widgets/word_class_chip.dart`
  - `lib/features/dictionary/presentation/widgets/source_badge.dart`
  - `lib/features/dictionary/presentation/widgets/definition_tile.dart`
  - `lib/features/dictionary/presentation/widgets/example_tile.dart`
  - `lib/features/dictionary/presentation/widgets/related_word_chip.dart`
  - `lib/features/dictionary/presentation/widgets/word_skeleton.dart` (loading skeleton)

  **Definition of Done:**
  - [ ] `WordClassChip` renders correct color for each of 7 word classes
  - [ ] `SourceBadge` shows "AI" amber chip for `ai_generated`, "Komunitas" blue for `contributed`, nothing for `seeded`
  - [ ] `WordCard` shows Banjar word, syllabified form (if present), word class chip, primary meaning, source badge, homonym superscript when `homonymNumber > 1`
  - [ ] `DefinitionTile` shows meaning, source badge, upvote/downvote counts
  - [ ] `WordSkeleton` matches `WordCard` layout with shimmer animation
  - [ ] Widget tests pass

  **Unit Tests (widget_test):**
  - `WordClassChip renders n with slate color`
  - `WordClassChip renders ki with teal color`
  - `SourceBadge renders AI chip for ai_generated source`
  - `SourceBadge renders nothing for seeded source`
  - `WordCard shows homonym superscript when homonymNumber is 2`
  - `WordCard does not show syllabified form when it is null`

---

- [x] **TASK-027: Beranda Page, Cari Page, and Word Detail Page (Structure)**

  **Description:** Build the three primary dictionary screens. At this stage: no vote/bookmark/comment interactions (Phase 3), no FAB (Phase 5). Focus on read-only display.

  **Expected Output:**
  - `lib/features/dictionary/presentation/pages/beranda_page.dart`
  - `lib/features/dictionary/presentation/pages/cari_page.dart`
  - `lib/features/dictionary/presentation/pages/word_detail_page.dart`

  **Definition of Done:**
  - [ ] Beranda: word list with infinite scroll, filter chips, sort toggle, pull-to-refresh, empty state
  - [ ] Cari: search bar with debounce, results list, empty state with query echo, recent searches list (local storage)
  - [ ] Word Detail: word header, tab/accordion for Definisi / Contoh / Kata Terkait / Komentar (komentar section shows placeholder)
  - [ ] Skeleton loaders shown while loading
  - [ ] Tapping a `RelatedWordChip` navigates to that word's detail
  - [ ] Deep link `banjarin://word/{id}` opens correct word detail

  **Unit Tests (widget_test):**
  - `BerandaPage renders word cards when WordListBloc emits Loaded state`
  - `BerandaPage shows skeleton loaders when WordListBloc emits Loading state`
  - `BerandaPage shows empty state when word list is empty`
  - `CariPage shows recent searches when search bar is empty`
  - `CariPage shows search results when SearchBloc emits SearchResults`
  - `WordDetailPage renders word title and syllabified form`

---

## Phase 3 — Community: Votes, Bookmarks, Comments

> Requires Phase 1 (auth) and Phase 2 (word detail screen).

---

- [x] **TASK-028: Vote Entity, Repository Interface, and Use Cases**

  **API:** `POST /words/{id}/votes`, `DELETE /words/{id}/votes`, `POST /definitions/{id}/votes`, `DELETE /definitions/{id}/votes`

  **Expected Output:**
  - `lib/features/community/domain/entities/vote.dart`
  - `lib/features/community/domain/repositories/vote_repository.dart`
  - `lib/features/community/domain/usecases/cast_vote.dart`
  - `lib/features/community/domain/usecases/remove_vote.dart`

  **Definition of Done:**
  - [ ] `Vote` entity has `id`, `userId`, `targetType` (enum: `word`/`definition`), `targetId`, `value` (enum: `up`/`down`)
  - [ ] `CastVote.Params` requires `targetType`, `targetId`, `value`
  - [ ] `CastVote` returns `UnauthorizedFailure` when user is not authenticated (checked via `AuthSession`)
  - [ ] Unit tests pass

  **Unit Tests:**
  - `CastVote when user is authenticated delegates to repository`
  - `CastVote when user is unauthenticated returns UnauthorizedFailure`
  - `RemoveVote delegates to repository with targetType and targetId`
  - `RemoveVote when user is unauthenticated returns UnauthorizedFailure`

---

- [x] **TASK-029: Bookmark Entity, Repository Interface, and Use Cases**

  **API:** `GET /bookmarks`, `POST /bookmarks`, `DELETE /bookmarks/{word_id}`

  **Expected Output:**
  - `lib/features/community/domain/entities/bookmark.dart`
  - `lib/features/community/domain/repositories/bookmark_repository.dart`
  - `lib/features/community/domain/usecases/get_bookmarks.dart`
  - `lib/features/community/domain/usecases/add_bookmark.dart`
  - `lib/features/community/domain/usecases/remove_bookmark.dart`

  **Definition of Done:**
  - [ ] `Bookmark` entity has `id`, `wordId`, `word` (`WordSummary`), `createdAt`
  - [ ] `AddBookmark` returns `ConflictFailure` when already bookmarked
  - [ ] `GetBookmarks` accepts pagination params
  - [ ] Unit tests pass

  **Unit Tests:**
  - `AddBookmark when word not bookmarked delegates to repository`
  - `AddBookmark when repository returns ConflictFailure propagates it`
  - `RemoveBookmark delegates to repository with wordId`
  - `GetBookmarks delegates to repository with pagination params`

---

- [x] **TASK-030: Comment Entity, Repository Interface, and Use Cases**

  **API:** `GET /words/{id}/comments`, `POST /words/{id}/comments`, `PATCH /comments/{id}`, `DELETE /comments/{id}`, `POST /comments/{id}/flag`

  **Expected Output:**
  - `lib/features/community/domain/entities/comment.dart`
  - `lib/features/community/domain/repositories/comment_repository.dart`
  - `lib/features/community/domain/usecases/get_comments.dart`
  - `lib/features/community/domain/usecases/post_comment.dart`
  - `lib/features/community/domain/usecases/edit_comment.dart`
  - `lib/features/community/domain/usecases/delete_comment.dart`
  - `lib/features/community/domain/usecases/flag_comment.dart`

  **Definition of Done:**
  - [ ] `PostComment.Params` validates body is non-empty and max 1000 chars
  - [ ] `EditComment.Params` validates same constraints
  - [ ] `FlagComment` returns `ConflictFailure` when already flagged
  - [ ] Unit tests pass

  **Unit Tests:**
  - `PostComment when body is empty returns ValidationFailure`
  - `PostComment when body exceeds 1000 chars returns ValidationFailure`
  - `PostComment when valid delegates to repository`
  - `EditComment when body exceeds 1000 chars returns ValidationFailure`
  - `FlagComment delegates to repository`
  - `DeleteComment delegates to repository with comment id`

---

- [x] **TASK-031: Vote Data Layer**

  **Expected Output:**
  - `lib/features/community/data/models/vote_model.dart`
  - `lib/features/community/data/datasources/vote_remote_data_source.dart`
  - `lib/features/community/data/repositories/vote_repository_impl.dart`

  **Definition of Done:**
  - [ ] `castVote` sends correct body `{"value": "up"|"down"}` to correct endpoint (word or definition)
  - [ ] `removeVote` calls correct DELETE endpoint based on `targetType`
  - [ ] Unit tests pass

  **Unit Tests:**
  - `VoteRemoteDataSource castVote on word sends to /words/{id}/votes`
  - `VoteRemoteDataSource castVote on definition sends to /definitions/{id}/votes`
  - `VoteRemoteDataSource removeVote on word sends DELETE to /words/{id}/votes`
  - `VoteRepositoryImpl castVote on 409 returns ConflictFailure`

---

- [x] **TASK-032: Bookmark Data Layer**

  **Expected Output:**
  - `lib/features/community/data/models/bookmark_model.dart`
  - `lib/features/community/data/datasources/bookmark_remote_data_source.dart`
  - `lib/features/community/data/datasources/bookmark_local_data_source.dart` (Hive cache)
  - `lib/features/community/data/repositories/bookmark_repository_impl.dart`

  **Definition of Done:**
  - [ ] Bookmark list cached locally; updated optimistically on add/remove
  - [ ] On network error for add/remove, local cache rolled back
  - [ ] Unit tests pass

  **Unit Tests:**
  - `BookmarkRepositoryImpl getBookmarks returns cached bookmarks when offline`
  - `BookmarkRepositoryImpl addBookmark updates local cache on success`
  - `BookmarkRepositoryImpl removeBookmark removes from local cache on success`
  - `BookmarkRepositoryImpl addBookmark rolls back local cache on network failure`

---

- [x] **TASK-033: Comment Data Layer**

  **Expected Output:**
  - `lib/features/community/data/models/comment_model.dart`
  - `lib/features/community/data/datasources/comment_remote_data_source.dart`
  - `lib/features/community/data/repositories/comment_repository_impl.dart`

  **Definition of Done:**
  - [ ] `CommentModel.fromJson` handles `isFlagged` boolean
  - [ ] Unit tests pass

  **Unit Tests:**
  - `CommentRemoteDataSource getComments on 200 returns list of CommentModel`
  - `CommentRemoteDataSource postComment on 201 returns CommentModel`
  - `CommentRemoteDataSource flagComment on 409 throws ServerException with CONFLICT`

---

- [x] **TASK-034: VoteBloc**

  **Description:** Manages vote state for a single word or definition. Used by both Word Detail and Definition Tile.

  **Expected Output:**
  - `lib/features/community/presentation/bloc/vote_bloc.dart`

  **Definition of Done:**
  - [ ] State tracks current user's vote (`up`, `down`, or `none`) and counts
  - [ ] `CastVote` event optimistically updates UI, then calls use case
  - [ ] If use case fails, reverts to previous vote state
  - [ ] `CastVote` with same value as current vote calls `RemoveVote` instead
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `VoteBloc CastVote up emits [Voting, VoteUpdated(up)]`
  - `VoteBloc CastVote up when already up emits [Voting, VoteUpdated(none)] (remove)`
  - `VoteBloc CastVote on failure reverts to previous vote state`
  - `VoteBloc CastVote when unauthenticated emits VoteError with UnauthorizedFailure`

---

- [x] **TASK-035: BookmarkBloc and Simpanan Page**

  **Expected Output:**
  - `lib/features/community/presentation/bloc/bookmark_bloc.dart`
  - `lib/features/community/presentation/pages/simpanan_page.dart`

  **Definition of Done:**
  - [ ] `BookmarkBloc` state tracks `isBookmarked` for current word + paginated bookmark list
  - [ ] Toggle bookmark optimistic update with rollback on failure
  - [ ] Simpanan page: paginated list with swipe-to-remove, empty state
  - [ ] Bookmark icon in Word Detail header reflects `isBookmarked` state
  - [ ] Guest tapping bookmark icon redirected to Login

  **Unit Tests (bloc_test):**
  - `BookmarkBloc ToggleBookmark when not bookmarked emits [Toggling, Bookmarked]`
  - `BookmarkBloc ToggleBookmark when bookmarked emits [Toggling, Unbookmarked]`
  - `BookmarkBloc ToggleBookmark on failure reverts state`
  - `BookmarkBloc LoadBookmarks emits [Loading, Loaded] with list`

---

- [x] **TASK-036: CommentBloc and Comments Section in Word Detail**

  **Expected Output:**
  - `lib/features/community/presentation/bloc/comment_bloc.dart`
  - `lib/features/community/presentation/widgets/comment_tile.dart`
  - `lib/features/community/presentation/widgets/comment_input.dart`

  **Wire into:** `WordDetailPage` Komentar tab

  **Definition of Done:**
  - [ ] Comment list paginated, load-more on scroll
  - [ ] Auth users see comment input; guest sees "Masuk untuk berkomentar" prompt
  - [ ] Own comments show edit (pencil) and delete (trash) actions
  - [ ] Edit opens inline text field pre-filled with comment body
  - [ ] Delete shows confirmation dialog
  - [ ] Flag icon on non-own comments; disabled after flagging (conflict handled gracefully)
  - [ ] Flagged comments shown greyed with "Ditandai untuk moderasi"

  **Unit Tests (bloc_test):**
  - `CommentBloc LoadComments emits [Loading, Loaded] with list`
  - `CommentBloc PostComment emits [Posting, CommentAdded] and prepends to list`
  - `CommentBloc PostComment when unauthenticated emits CommentError`
  - `CommentBloc EditComment emits [Editing, CommentUpdated]`
  - `CommentBloc DeleteComment removes comment from state`
  - `CommentBloc FlagComment on 409 emits CommentError with ConflictFailure`

---

## Phase 4 — AI Translate

> Requires Phase 1 (auth). Independent of Phases 2–3.

---

- [x] **TASK-037: TranslationResult Entity, AIRepository Interface, and TranslateBanjar Use Case**

  **Expected Output:**
  - `lib/features/ai/domain/entities/translation_result.dart` — `original`, `translation`, `dialect`, `model`, `confidence` (enum: `high`/`medium`/`low`), `notes`
  - `lib/features/ai/domain/repositories/ai_repository.dart`
  - `lib/features/ai/domain/usecases/translate_banjar.dart`

  **Definition of Done:**
  - [ ] `TranslateBanjar.Params` validates text is non-empty and max 1000 chars
  - [ ] Returns `UnauthorizedFailure` when not authenticated
  - [ ] Returns `AIUnavailableFailure` on 503
  - [ ] Unit tests pass

  **Unit Tests:**
  - `TranslateBanjar when text is empty returns ValidationFailure`
  - `TranslateBanjar when text exceeds 1000 chars returns ValidationFailure`
  - `TranslateBanjar when unauthenticated returns UnauthorizedFailure`
  - `TranslateBanjar when authenticated and valid delegates to repository`

---

- [x] **TASK-038: AI Data Layer**

  **API:** `POST /ai/translate`

  **Expected Output:**
  - `lib/features/ai/data/models/translation_result_model.dart`
  - `lib/features/ai/data/datasources/ai_remote_data_source.dart`
  - `lib/features/ai/data/repositories/ai_repository_impl.dart`

  **Definition of Done:**
  - [ ] On 503 response, maps to `AIUnavailableFailure`
  - [ ] On 429 response, maps to `RateLimitedFailure` with `retryAfterSeconds`
  - [ ] Result is never cached (stateless per API spec)
  - [ ] Unit tests pass

  **Unit Tests:**
  - `AIRemoteDataSource translate on 200 returns TranslationResultModel`
  - `AIRemoteDataSource translate on 503 throws ServerException with AI_UNAVAILABLE`
  - `AIRemoteDataSource translate on 429 throws ServerException with RATE_LIMITED`
  - `AIRepositoryImpl translate never writes to cache`

---

- [x] **TASK-039: TranslateBloc**

  **Expected Output:**
  - `lib/features/ai/presentation/bloc/translate_bloc.dart`

  **Definition of Done:**
  - [ ] State: `TranslateInitial`, `Translating`, `TranslateSuccess(result)`, `TranslateError(failure)`, `RateLimited(retryAfterSeconds)`
  - [ ] `RateLimited` state carries `retryAfterSeconds` for countdown display
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `TranslateBloc Translate emits [Translating, TranslateSuccess]`
  - `TranslateBloc Translate on AIUnavailableFailure emits TranslateError`
  - `TranslateBloc Translate on RateLimitedFailure emits RateLimited with retryAfterSeconds`
  - `TranslateBloc Translate on UnauthorizedFailure emits TranslateError`

---

- [x] **TASK-040: Terjemah Page**

  **Expected Output:**
  - `lib/features/ai/presentation/pages/terjemah_page.dart`
  - `lib/features/ai/presentation/widgets/translation_result_card.dart`
  - `lib/features/ai/presentation/widgets/confidence_badge.dart`

  **Definition of Done:**
  - [ ] Multi-line text input with 1000-char counter
  - [ ] Optional context field (collapsed by default, expandable)
  - [ ] "Terjemahkan" button disabled when input is empty or `Translating`
  - [ ] Result card shows original, translation (large), dialect badge, confidence badge (color-coded), lexical notes, copy button
  - [ ] Rate limit state shows countdown in Indonesian: "Coba lagi dalam X menit"
  - [ ] AI unavailable state shows friendly error message
  - [ ] Unauthenticated access → redirected to Login by router guard
  - [ ] Widget tests pass

  **Unit Tests (widget_test):**
  - `TerjemahPage submit button disabled when text field is empty`
  - `TerjemahPage shows char counter updating on input`
  - `TerjemahPage shows loading state when TranslateBloc emits Translating`
  - `TerjemahPage shows result card when TranslateBloc emits TranslateSuccess`
  - `TerjemahPage shows rate limit countdown when TranslateBloc emits RateLimited`
  - `ConfidenceBadge renders green for high confidence`
  - `ConfidenceBadge renders red for low confidence`

---

## Phase 5 — Contributions

> Requires Phase 1 (auth). Depends on Phase 2 (word context for target_word_id).

---

- [x] **TASK-041: Contribution Entity, Repository Interface, and Use Cases**

  **Expected Output:**
  - `lib/features/community/domain/entities/contribution.dart` — `id`, `type` (enum: `new_word`/`new_definition`/`new_example`/`edit_word`), `contributorId`, `targetWordId`, `payload`, `status` (enum), `reviewerNote`, `submittedAt`, `reviewedAt`
  - `lib/features/community/domain/repositories/contribution_repository.dart`
  - `lib/features/community/domain/usecases/submit_contribution.dart`
  - `lib/features/community/domain/usecases/get_contributions.dart`
  - `lib/features/community/domain/usecases/get_contribution_detail.dart`
  - `lib/features/community/domain/usecases/withdraw_contribution.dart`

  **Definition of Done:**
  - [ ] `SubmitContribution` validates `targetWordId` is present for all types except `new_word`
  - [ ] `new_word` payload validates `banjar` non-empty, `wordClass` present, at least 1 definition
  - [ ] `new_definition` payload validates `meaning` non-empty and max 2000 chars
  - [ ] `new_example` payload validates `banjarSentence` and `indonesianTranslation` non-empty
  - [ ] `WithdrawContribution` returns `ConflictFailure` if status is not `pending`
  - [ ] Unit tests pass

  **Unit Tests:**
  - `SubmitContribution new_definition without targetWordId returns ValidationFailure`
  - `SubmitContribution new_word without definitions returns ValidationFailure`
  - `SubmitContribution new_definition meaning exceeds 2000 chars returns ValidationFailure`
  - `WithdrawContribution when status is approved returns ConflictFailure`
  - `WithdrawContribution when status is pending delegates to repository`
  - `GetContributions delegates to repository with status filter`

---

- [x] **TASK-042: Contribution Data Layer**

  **API:** `POST /contributions`, `GET /contributions`, `GET /contributions/{id}`, `PATCH /contributions/{id}/withdraw`

  **Expected Output:**
  - `lib/features/community/data/models/contribution_model.dart`
  - `lib/features/community/data/datasources/contribution_remote_data_source.dart`
  - `lib/features/community/data/repositories/contribution_repository_impl.dart`

  **Definition of Done:**
  - [ ] `ContributionModel.fromJson` parses polymorphic `payload` as `Map<String, dynamic>`
  - [ ] On 429 from `POST /contributions`, maps to `RateLimitedFailure`
  - [ ] Unit tests pass

  **Unit Tests:**
  - `ContributionRemoteDataSource submit on 201 returns ContributionModel`
  - `ContributionRemoteDataSource submit on 429 throws RateLimited ServerException`
  - `ContributionRemoteDataSource withdraw on 409 throws ConflictFailure`
  - `ContributionRepositoryImpl submit maps response to Contribution entity`

---

- [x] **TASK-043: ContributionBloc**

  **Expected Output:**
  - `lib/features/community/presentation/bloc/contribution_bloc.dart`

  **Definition of Done:**
  - [ ] States: `ContributionInitial`, `Submitting`, `Submitted`, `Loading`, `Loaded(contributions)`, `Withdrawing`, `Withdrawn`, `ContributionError`
  - [ ] Status filter tab drives `LoadContributions` event
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `ContributionBloc SubmitContribution emits [Submitting, Submitted]`
  - `ContributionBloc SubmitContribution on RateLimitedFailure emits ContributionError`
  - `ContributionBloc LoadContributions emits [Loading, Loaded]`
  - `ContributionBloc WithdrawContribution emits [Withdrawing, Withdrawn] and removes from list`
  - `ContributionBloc WithdrawContribution on ConflictFailure emits ContributionError`

---

- [x] **TASK-044: Contribution Form Pages**

  **Description:** Four form pages for each contribution type. All forms validate inline before submission.

  **Expected Output:**
  - `lib/features/community/presentation/pages/contribution_new_word_page.dart`
  - `lib/features/community/presentation/pages/contribution_new_definition_page.dart`
  - `lib/features/community/presentation/pages/contribution_new_example_page.dart`
  - `lib/features/community/presentation/pages/contribution_edit_word_page.dart`
  - `lib/features/community/presentation/widgets/contribution_form_fields.dart` (shared form widgets)

  **Definition of Done:**
  - [ ] New Word form: Kata Banjar, Bentuk Suku Kata (optional), Kelas Kata (dropdown), dynamic definition rows (add/remove), optional example pairs
  - [ ] New Definition form: target word shown read-only, Definisi field with 2000-char counter
  - [ ] New Example form: target word shown read-only, Kalimat Banjar + Terjemahan Indonesia
  - [ ] Edit Word form: target word shown read-only, editable fields with current values pre-filled
  - [ ] Submit disables button and shows spinner while `Submitting`
  - [ ] On `Submitted`, shows success snackbar and navigates back
  - [ ] Rate limit message shown when `RateLimitedFailure`
  - [ ] Unverified email shows banner and disables submit

  **Unit Tests (widget_test):**
  - `ContributionNewWordPage submit button disabled when Kata Banjar is empty`
  - `ContributionNewWordPage add definition row adds a new input field`
  - `ContributionNewDefinitionPage shows 2000-char counter`
  - `ContributionNewDefinitionPage submit disabled when meaning is empty`

---

- [x] **TASK-045: My Contributions Page, Contribution Detail, and FAB on Word Detail**

  **Expected Output:**
  - `lib/features/community/presentation/pages/my_contributions_page.dart`
  - `lib/features/community/presentation/pages/contribution_detail_page.dart`
  - `lib/features/community/presentation/widgets/contribution_card.dart`
  - Wire FAB into `WordDetailPage` (bottom sheet with 4 contribution shortcuts)

  **Definition of Done:**
  - [ ] My Contributions: filter tabs (Semua/Menunggu/Disetujui/Ditolak/Dicabut), paginated list
  - [ ] Each card shows type badge, target word, status badge (color-coded), submission date
  - [ ] Pending items show "Cabut" button with confirm dialog
  - [ ] Rejected items show reviewer note inline
  - [ ] Contribution Detail shows full payload + status + reviewer note
  - [ ] Word Detail FAB visible only to authenticated users; bottom sheet shows 4 options
  - [ ] Tapping FAB option navigates to correct form with `targetWordId` pre-set

  **Unit Tests (widget_test):**
  - `ContributionCard shows reviewer note for rejected status`
  - `ContributionCard shows Cabut button only for pending status`
  - `MyContributionsPage shows correct count per filter tab`

---

## Phase 6 — Admin Panel

> Requires Phase 1 (auth + admin role guard). Depends on Phases 2 and 5.

---

- [ ] **TASK-046: Admin Role Guard**

  **Description:** Route-level guard that redirects non-admin users away from all `/admin/*` routes. Widget-level guard for admin-only UI elements.

  **Expected Output:**
  - `lib/features/admin/presentation/widgets/admin_guard.dart` — wraps child, shows 403 screen for non-admin
  - GoRouter redirect added to all `/admin/*` routes in `app_router.dart`

  **Definition of Done:**
  - [ ] Non-admin user navigating to any admin route is redirected to Home
  - [ ] Admin-only menu items (e.g. "Panel Admin" in Profil) hidden for `user` role
  - [ ] Widget test passes

  **Unit Tests (widget_test):**
  - `AdminGuard shows 403 screen when user role is user`
  - `AdminGuard shows child when user role is admin`

---

- [ ] **TASK-047: Admin Word Use Cases and Data Layer**

  **API:** `GET /admin/words`, `POST /admin/words`, `PATCH /admin/words/{id}`, `DELETE /admin/words/{id}`

  **Expected Output:**
  - `lib/features/admin/domain/usecases/get_admin_words.dart`
  - `lib/features/admin/domain/usecases/create_word.dart`
  - `lib/features/admin/domain/usecases/update_word.dart`
  - `lib/features/admin/domain/usecases/delete_word.dart`
  - `lib/features/admin/domain/repositories/admin_repository.dart` (interface, word methods)
  - `lib/features/admin/data/datasources/admin_remote_data_source.dart` (word methods)
  - `lib/features/admin/data/repositories/admin_repository_impl.dart` (word methods)

  **Definition of Done:**
  - [ ] `CreateWord` validates required fields: `banjar` non-empty, `wordClass` present, at least 1 definition
  - [ ] `DeleteWord` is soft-delete (maps to DELETE endpoint)
  - [ ] Unit tests pass

  **Unit Tests:**
  - `CreateWord when banjar is empty returns ValidationFailure`
  - `CreateWord when definitions list is empty returns ValidationFailure`
  - `CreateWord when valid delegates to repository`
  - `DeleteWord delegates to repository with word id`
  - `AdminRemoteDataSource createWord on 409 throws ConflictFailure`
  - `AdminRemoteDataSource deleteWord on 204 completes successfully`

---

- [ ] **TASK-048: Admin User Management Use Cases and Data Layer**

  **API:** `GET /admin/users`, `GET /admin/users/{id}`, `PATCH /admin/users/{id}/ban`, `PATCH /admin/users/{id}/unban`, `PATCH /admin/users/{id}/role`

  **Expected Output:**
  - `lib/features/admin/domain/usecases/get_admin_users.dart`
  - `lib/features/admin/domain/usecases/get_user_detail.dart`
  - `lib/features/admin/domain/usecases/ban_user.dart`
  - `lib/features/admin/domain/usecases/unban_user.dart`
  - `lib/features/admin/domain/usecases/change_user_role.dart`
  - Add to `admin_remote_data_source.dart` and `admin_repository_impl.dart`

  **Definition of Done:**
  - [ ] `BanUser.Params` requires a non-empty reason string
  - [ ] All unit tests pass

  **Unit Tests:**
  - `BanUser when reason is empty returns ValidationFailure`
  - `BanUser when reason present delegates to repository`
  - `ChangeUserRole delegates to repository with new role`
  - `AdminRemoteDataSource banUser on 404 throws NotFoundFailure`

---

- [ ] **TASK-049: Admin Moderation Use Cases and Data Layer**

  **API:** `GET /admin/moderation/queue`, `GET /admin/moderation/flags`, `GET /admin/moderation/stats`, `PATCH /contributions/{id}/approve`, `PATCH /contributions/{id}/reject`

  **Expected Output:**
  - `lib/features/admin/domain/entities/moderation_stats.dart`
  - `lib/features/admin/domain/usecases/get_moderation_queue.dart`
  - `lib/features/admin/domain/usecases/get_flagged_comments.dart`
  - `lib/features/admin/domain/usecases/get_moderation_stats.dart`
  - `lib/features/admin/domain/usecases/approve_contribution.dart`
  - `lib/features/admin/domain/usecases/reject_contribution.dart`
  - Add to `admin_remote_data_source.dart` and `admin_repository_impl.dart`

  **Definition of Done:**
  - [ ] `RejectContribution.Params` requires a non-empty note
  - [ ] `ApproveContribution` returns `ConflictFailure` if contribution status is not pending
  - [ ] Unit tests pass

  **Unit Tests:**
  - `RejectContribution when note is empty returns ValidationFailure`
  - `RejectContribution when note present delegates to repository`
  - `ApproveContribution delegates to repository`
  - `AdminRemoteDataSource approveContribution on 409 throws ConflictFailure`
  - `AdminRemoteDataSource getModQueueStats on 200 returns ModerationStatsModel`

---

- [ ] **TASK-050: Admin Blocs (AdminWordBloc, UserMgmtBloc, ModerationBloc)**

  **Expected Output:**
  - `lib/features/admin/presentation/bloc/admin_word_bloc.dart`
  - `lib/features/admin/presentation/bloc/user_mgmt_bloc.dart`
  - `lib/features/admin/presentation/bloc/moderation_bloc.dart`

  **Definition of Done:**
  - [ ] `AdminWordBloc` manages admin word list with status/class/source filters + search, create, update, delete
  - [ ] `UserMgmtBloc` manages user list with role/status filters + ban, unban, role change
  - [ ] `ModerationBloc` manages contribution queue + stats + approve/reject
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `AdminWordBloc LoadAdminWords emits [Loading, Loaded]`
  - `AdminWordBloc DeleteWord emits [Deleting, Deleted] and removes from list`
  - `UserMgmtBloc BanUser emits [Banning, Banned] and updates user in list`
  - `UserMgmtBloc ChangeRole emits [ChangingRole, RoleChanged]`
  - `ModerationBloc LoadQueue emits [Loading, Loaded]`
  - `ModerationBloc ApproveContribution emits [Approving, Approved] and removes from queue`
  - `ModerationBloc RejectContribution emits [Rejecting, Rejected] and removes from queue`

---

- [ ] **TASK-051: Admin Dashboard Page**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_dashboard_page.dart`

  **Definition of Done:**
  - [ ] 4 stat cards: Kontribusi Menunggu, Komentar Ditandai, Disetujui Minggu Ini, Ditolak Minggu Ini
  - [ ] Quick-link buttons to each admin sub-section
  - [ ] Auto-refreshes stats on focus
  - [ ] "Panel Admin" entry point visible in Profil page only for admin role
  - [ ] Widget test passes

  **Unit Tests (widget_test):**
  - `AdminDashboardPage renders 4 stat cards`
  - `AdminDashboardPage shows pending count from ModerationBloc`

---

- [ ] **TASK-052: Admin Word Management Pages**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_word_list_page.dart`
  - `lib/features/admin/presentation/pages/admin_word_form_page.dart` (create + edit, shared)

  **Definition of Done:**
  - [ ] List page: search bar, status filter, word class filter, source filter
  - [ ] Each row shows Banjar word, class, source, status, edit and delete icon buttons
  - [ ] Delete shows confirmation dialog (warns about soft-delete)
  - [ ] Form page: all `WordInput` fields, dynamic definition list, dynamic example list
  - [ ] Edit pre-populates current word data
  - [ ] Create and edit both show success snackbar and navigate back on save
  - [ ] Trigger AI enrichment buttons on word detail: Enrich Definisi, Sarankan Contoh, Sarankan Kata Terkait (wired in Phase 7)

  **Unit Tests (widget_test):**
  - `AdminWordFormPage submit disabled when banjar field is empty`
  - `AdminWordFormPage add definition row adds a new input`
  - `AdminWordListPage shows delete confirmation dialog on delete tap`

---

- [ ] **TASK-053: Admin Moderation Queue and Contribution Review Pages**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_moderation_queue_page.dart`
  - `lib/features/admin/presentation/pages/admin_contribution_review_page.dart`

  **Definition of Done:**
  - [ ] Queue page: filter tabs by type, paginated list
  - [ ] Each item shows contributor name, submission time, type badge, target word, payload preview
  - [ ] Review page: full payload display, "Setujui" button (optional note), "Tolak" button (required note)
  - [ ] Approve/Reject show inline confirmation and navigate back on success
  - [ ] AI Quality Check button present (wired in Phase 7)

  **Unit Tests (widget_test):**
  - `AdminContributionReviewPage Tolak button disabled when note is empty`
  - `AdminContributionReviewPage shows payload for new_word type correctly`

---

- [ ] **TASK-054: Admin Flagged Comments Page**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_flagged_comments_page.dart`

  **Definition of Done:**
  - [ ] Paginated list of flagged comments
  - [ ] Each item: comment body, author, word context, "Hapus Komentar" action button
  - [ ] Delete shows confirm dialog; on confirm, removes from list

  **Unit Tests (widget_test):**
  - `AdminFlaggedCommentsPage shows delete confirmation dialog on delete tap`

---

- [ ] **TASK-055: Admin User Management Pages**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_user_list_page.dart`
  - `lib/features/admin/presentation/pages/admin_user_detail_page.dart`

  **Definition of Done:**
  - [ ] List page: search by name/email, role filter, active/banned filter
  - [ ] Detail page: user info, role badge, account status, Ban/Unban button, Change Role dropdown
  - [ ] Ban shows modal with reason text field (required)
  - [ ] Unban shows confirm dialog
  - [ ] Role change shows confirm dialog with new role label

  **Unit Tests (widget_test):**
  - `AdminUserDetailPage shows Unban button when user is_active is false`
  - `AdminUserDetailPage shows Ban button when user is_active is true`
  - `AdminUserDetailPage Ban button disabled when reason field is empty`

---

## Phase 7 — Admin AI Enrichment

> Requires Phase 6 (Admin Panel). Depends on admin word management pages for trigger entry points.

---

- [ ] **TASK-056: AIRequest Entity, Admin AI Use Cases**

  **Expected Output:**
  - `lib/features/admin/domain/entities/ai_request.dart` — `id`, `type` (enum: `enrich_definition`/`suggest_example`/`suggest_related`/`quality_check`), `targetWordId`, `targetContributionId`, `model`, `status`, `reviewStatus`, `parsedOutput`, `createdAt`
  - `lib/features/admin/domain/usecases/trigger_ai_enrich.dart`
  - `lib/features/admin/domain/usecases/trigger_ai_example.dart`
  - `lib/features/admin/domain/usecases/trigger_ai_related.dart`
  - `lib/features/admin/domain/usecases/run_quality_check.dart`
  - `lib/features/admin/domain/usecases/get_ai_requests.dart`
  - `lib/features/admin/domain/usecases/get_ai_request_detail.dart`
  - `lib/features/admin/domain/usecases/approve_ai_request.dart`
  - `lib/features/admin/domain/usecases/reject_ai_request.dart`

  **Definition of Done:**
  - [ ] `ApproveAIRequest` returns `ConflictFailure` when `type` is `quality_check`
  - [ ] `ApproveAIRequest` returns `ConflictFailure` when `reviewStatus` is already `approved` or `rejected`
  - [ ] All unit tests pass

  **Unit Tests:**
  - `ApproveAIRequest when type is quality_check returns ConflictFailure`
  - `ApproveAIRequest when reviewStatus is approved returns ConflictFailure`
  - `ApproveAIRequest when valid delegates to repository`
  - `RejectAIRequest delegates to repository`
  - `TriggerAIEnrich delegates to repository with wordId`
  - `RunQualityCheck delegates to repository with contributionId`

---

- [ ] **TASK-057: Admin AI Data Layer**

  **API:** `POST /admin/ai/enrich/{word_id}`, `POST /admin/ai/example/{word_id}`, `POST /admin/ai/related/{word_id}`, `POST /admin/ai/check/{contribution_id}`, `GET /admin/ai/requests`, `GET /admin/ai/requests/{id}`, `PATCH /admin/ai/requests/{id}/approve`, `PATCH /admin/ai/requests/{id}/reject`

  **Expected Output:**
  - `lib/features/admin/data/models/ai_request_model.dart`
  - Add AI request methods to `admin_remote_data_source.dart` and `admin_repository_impl.dart`

  **Definition of Done:**
  - [ ] `AIRequestModel.fromJson` parses nullable `parsedOutput` as `Map<String, dynamic>?`
  - [ ] All trigger endpoints return 202 which is mapped to `AIRequest` with `status: pending`
  - [ ] On 429 from trigger endpoints, maps to `RateLimitedFailure`
  - [ ] Unit tests pass

  **Unit Tests:**
  - `AdminRemoteDataSource triggerEnrich on 202 returns AIRequestModel with status pending`
  - `AdminRemoteDataSource triggerEnrich on 429 throws RateLimitedFailure`
  - `AdminRemoteDataSource approveAIRequest on 409 throws ConflictFailure`
  - `AIRequestModel fromJson handles null parsedOutput`

---

- [ ] **TASK-058: AIRequestBloc**

  **Expected Output:**
  - `lib/features/admin/presentation/bloc/ai_request_bloc.dart`

  **Definition of Done:**
  - [ ] States: `AIRequestInitial`, `Triggering`, `Triggered(AIRequest)`, `Loading`, `Loaded(requests)`, `Reviewing`, `Reviewed`, `AIRequestError`
  - [ ] Filter by `type`, `status`, `reviewStatus`
  - [ ] All bloc tests pass

  **Unit Tests (bloc_test):**
  - `AIRequestBloc TriggerEnrich emits [Triggering, Triggered] with pending AIRequest`
  - `AIRequestBloc TriggerEnrich on RateLimitedFailure emits AIRequestError`
  - `AIRequestBloc LoadRequests emits [Loading, Loaded]`
  - `AIRequestBloc ApproveRequest emits [Reviewing, Reviewed] and updates list`
  - `AIRequestBloc ApproveRequest on ConflictFailure emits AIRequestError`
  - `AIRequestBloc RejectRequest emits [Reviewing, Reviewed]`

---

- [ ] **TASK-059: Admin AI Request History Page**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_ai_requests_page.dart`
  - `lib/features/admin/presentation/widgets/ai_request_card.dart`

  **Definition of Done:**
  - [ ] Filter tabs: Semua | Menunggu Review | Disetujui | Ditolak
  - [ ] Each card: type badge, target word, job status badge (Pending/Completed/Failed), review status badge, date
  - [ ] Tapping a card navigates to AI Request Detail
  - [ ] Failed jobs shown with error indicator

  **Unit Tests (widget_test):**
  - `AIRequestCard renders correct type badge for enrich_definition`
  - `AIRequestCard renders failed state with error indicator`

---

- [ ] **TASK-060: Admin AI Request Detail Page**

  **Expected Output:**
  - `lib/features/admin/presentation/pages/admin_ai_request_detail_page.dart`
  - `lib/features/admin/presentation/widgets/ai_parsed_output_view.dart`

  **Definition of Done:**
  - [ ] Shows request type, target word, model used, created date
  - [ ] `parsedOutput` rendered in human-readable format per type:
    - `enrich_definition` → numbered list of suggested definitions
    - `suggest_example` → Banjar sentence + Indonesian pair
    - `suggest_related` → word chip list
    - `quality_check` → accuracy score + flags + notes (no approve/reject buttons)
  - [ ] "Setujui & Gabungkan" and "Tolak" buttons shown for non-`quality_check` types only
  - [ ] Buttons disabled when `reviewStatus` is not `unreviewed`
  - [ ] Approve/Reject show confirmation dialogs

  **Unit Tests (widget_test):**
  - `AdminAIRequestDetailPage hides approve/reject for quality_check type`
  - `AdminAIRequestDetailPage disables approve button when reviewStatus is approved`
  - `AIParsedOutputView renders definition list for enrich_definition type`

---

- [ ] **TASK-061: Wire AI Trigger Buttons into Admin Word Management**

  **Description:** Add "Pengayaan AI" action buttons to the Admin Word Detail screen (from TASK-052), enabling admins to trigger the three enrichment job types directly from the word context.

  **Wire into:** `AdminWordFormPage` / Admin Word Detail (read view)

  **Definition of Done:**
  - [ ] Three buttons: "Perkaya Definisi", "Sarankan Contoh", "Sarankan Kata Terkait"
  - [ ] Each button triggers the correct `TriggerAI*` use case with the current `wordId`
  - [ ] On success, shows snackbar: "Permintaan AI dikirim" + navigation shortcut to AI Request History
  - [ ] On rate limit, shows "Batas permintaan tercapai. Coba lagi dalam X menit."
  - [ ] Quality Check button added to Admin Contribution Review page (TASK-053)

  **Unit Tests (widget_test):**
  - `AdminWordDetailPage shows 3 AI trigger buttons`
  - `AdminWordDetailPage shows rate limit message when AIRequestBloc emits RateLimitedFailure`

---

## Phase 8 — Polish & Quality Assurance

> Final hardening. Depends on all previous phases.

---

- [ ] **TASK-062: Offline Cache Strategy Enforcement**

  **Description:** Implement and validate the cache strategies from PRD §9 across all features. Ensure stale data is displayed with a refresh indicator when the device is offline.

  **Expected Output:**
  - `lib/core/network/connectivity_checker.dart`
  - Cache TTL config constants in `lib/core/utils/cache_config.dart`
  - Stale data banner widget: `lib/core/widgets/stale_data_banner.dart`

  **Definition of Done:**
  - [ ] Word list first page: cached 5 min, stale banner shown after TTL
  - [ ] Word detail: cached 10 min per word ID
  - [ ] Bookmarks: cached indefinitely, synced on reconnect
  - [ ] Search results, AI translations, contributions: never cached
  - [ ] Network offline banner appears at top of affected screens
  - [ ] Unit tests pass

  **Unit Tests:**
  - `ConnectivityChecker emits offline when connection lost`
  - `ConnectivityChecker emits online when connection restored`
  - `WordRepositoryImpl returns cached data when connectivity is offline`

---

- [ ] **TASK-063: Skeleton Loaders for All Screens**

  **Description:** Ensure every list and detail screen has a skeleton loader matching the actual content layout. No blank screens or spinners-only states.

  **Expected Output:**
  - `lib/core/widgets/shimmer_box.dart` (reusable shimmer rectangle)
  - Skeleton widgets for: `WordListSkeleton`, `WordDetailSkeleton`, `BookmarkListSkeleton`, `ContributionListSkeleton`, `AdminQueueSkeleton`

  **Definition of Done:**
  - [ ] Every screen with async data shows skeleton matching real content dimensions
  - [ ] Skeleton uses shimmer animation (light/dark mode aware)
  - [ ] Widget tests pass for each skeleton

  **Unit Tests (widget_test):**
  - `WordListSkeleton renders same number of placeholder items as expected list`
  - `ShimmerBox adapts color to dark mode`

---

- [ ] **TASK-064: Empty States for All Lists**

  **Description:** Every list screen with a potentially-empty result must have a tailored empty state per PRD §6.6.

  **Expected Output:**
  - `lib/core/widgets/empty_state.dart` (configurable illustration + message + optional CTA button)

  **Definition of Done:**
  - [ ] Beranda: "Tidak ada kata ditemukan" + contribute CTA (auth) or login CTA (guest)
  - [ ] Cari: "Tidak ada hasil untuk '[query]'"
  - [ ] Simpanan: "Belum ada simpanan"
  - [ ] My Contributions: "Belum ada kontribusi"
  - [ ] Admin Queue: "Antrian kosong"
  - [ ] Admin Flagged Comments: "Tidak ada komentar yang ditandai"
  - [ ] Widget tests pass

  **Unit Tests (widget_test):**
  - `EmptyState renders correct message and optional CTA button`
  - `BerandaPage shows contribute CTA in empty state for authenticated user`
  - `BerandaPage shows login CTA in empty state for guest`

---

- [ ] **TASK-065: Global Error State Handling**

  **Description:** Standardize all error states across the app per PRD §6.5.

  **Expected Output:**
  - `lib/core/widgets/error_view.dart` (inline error card for list/detail failures)
  - `lib/core/widgets/network_banner.dart` (persistent top banner for offline)
  - Global `UnauthorizedFailure` listener in root widget that triggers `AuthBloc.Logout`

  **Definition of Done:**
  - [ ] Network offline: persistent yellow top banner "Tidak ada koneksi"
  - [ ] 401: forces logout → Login redirect (global listener)
  - [ ] 404: inline "Konten tidak ditemukan" card in the affected widget
  - [ ] 429: inline countdown "Coba lagi dalam X menit" per PRD
  - [ ] 503 (AI): inline "Layanan AI sedang gangguan. Coba nanti."
  - [ ] 500: dismissable toast "Terjadi kesalahan. Coba beberapa saat lagi."
  - [ ] Widget tests pass

  **Unit Tests (widget_test):**
  - `NetworkBanner renders when connectivity emits offline`
  - `ErrorView renders 429 message with countdown for RateLimitedFailure`
  - `ErrorView renders AI unavailable message for AIUnavailableFailure`

---

- [ ] **TASK-066: Onboarding Screen**

  **Expected Output:**
  - `lib/features/onboarding/presentation/pages/onboarding_page.dart`
  - `lib/core/storage/onboarding_storage.dart` (flag: has seen onboarding)

  **Definition of Done:**
  - [ ] 4 slides per PRD §4.1 with page indicator dots
  - [ ] "Lewati" (skip) button on all slides except last
  - [ ] "Mulai" CTA on last slide → Home
  - [ ] "Masuk / Daftar" CTA → Auth
  - [ ] Shown only on first launch; subsequent launches go directly to Home
  - [ ] Onboarding flag stored via Hive

  **Unit Tests (widget_test):**
  - `OnboardingPage shows 4 pages`
  - `OnboardingPage skip button navigates to Home`
  - `OnboardingPage Masuk/Daftar button navigates to Login`

---

- [ ] **TASK-067: Dark Mode and Theme Switching**

  **Description:** Validate full dark mode support across all screens. Confirm system-aware theme switching works correctly.

  **Definition of Done:**
  - [ ] All screens render correctly in both light and dark modes
  - [ ] `SourceBadge`, `WordClassChip`, `ConfidenceBadge` use theme-aware colors
  - [ ] Skeleton shimmer adapts to dark mode background
  - [ ] `MaterialApp` uses `ThemeMode.system` by default
  - [ ] No hardcoded `Colors.*` usages outside `app_colors.dart`
  - [ ] `flutter analyze` reports zero `avoid_hardcoded_color` lint warnings

  **Unit Tests (widget_test):**
  - `AppTheme dark theme uses correct primary color`
  - `SourceBadge AI chip uses amber color in both light and dark mode`

---

- [ ] **TASK-068: Accessibility Audit**

  **Description:** Ensure the app meets WCAG AA standards and is screen-reader compatible per PRD §6.7.

  **Definition of Done:**
  - [ ] All icon-only buttons (`bookmark`, `vote`, `flag`, `edit`, `delete`) have `Semantics` labels
  - [ ] All images have `semanticLabel`
  - [ ] Minimum touch target 44×44pt enforced (use `SizedBox` wrappers where needed)
  - [ ] Color contrast ratio ≥ 4.5:1 for all body text (verified against theme colors)
  - [ ] VoiceOver (iOS) and TalkBack (Android) tested manually on Login, Beranda, Word Detail

  **Unit Tests (widget_test):**
  - `BookmarkIconButton has Semantics label "Simpan kata"`
  - `VoteUpButton has Semantics label "Upvote"`

---

- [ ] **TASK-069: Integration Tests**

  **Description:** End-to-end flows against staging API per PRD §14.4.

  **Expected Output:**
  - `integration_test/auth_flow_test.dart`
  - `integration_test/dictionary_browse_test.dart`
  - `integration_test/translate_flow_test.dart`
  - `integration_test/contribution_flow_test.dart`

  **Test Flows:**

  | File | Scenario |
  |---|---|
  | `auth_flow_test` | Register → verify email notice → login → logout → login again |
  | `auth_flow_test` | Forgot password screen submits without error |
  | `dictionary_browse_test` | Open app → scroll word list → tap word → read detail |
  | `dictionary_browse_test` | Search for "abah" → tap result → read definition |
  | `translate_flow_test` | Login → navigate to Terjemah → enter text → receive translation |
  | `contribution_flow_test` | Login → open word detail → FAB → submit new definition → check My Contributions |

  **Definition of Done:**
  - [ ] All integration tests pass against staging API
  - [ ] Tests run in CI on merge to `main`

  **Unit Tests:** These are the integration tests — no further unit tests needed.

---

- [ ] **TASK-070: CI Pipeline Setup**

  **Description:** Configure GitHub Actions (or equivalent) for automated testing and coverage enforcement per PRD §14.7.

  **Expected Output:**
  - `.github/workflows/test.yml`
  - `.github/workflows/integration.yml`

  **Definition of Done:**
  - [ ] `test.yml`: runs `flutter test --coverage` on every PR; fails if domain coverage < 90% or bloc coverage < 85%
  - [ ] `test.yml`: runs `flutter analyze` with zero warnings threshold
  - [ ] `integration.yml`: runs `flutter test integration_test/` on merge to `main` against staging
  - [ ] Coverage report uploaded as PR artifact
  - [ ] Both workflows pass on a clean branch

  **Unit Tests:** N/A

---

- [ ] **TASK-071: Deep Link Testing and Final End-to-End Verification**

  **Description:** Validate all three deep links work end-to-end on physical devices (Android + iOS).

  **Definition of Done:**
  - [ ] `banjarin://verify-email?token=<valid>` → calls `POST /auth/verify-email` → navigates to Home with success toast
  - [ ] `banjarin://verify-email?token=<invalid>` → shows error toast and stays on Verify Email Notice
  - [ ] `banjarin://reset-password?token=<valid>` → opens Reset Password page with token pre-filled
  - [ ] `banjarin://word/{valid_id}` → opens Word Detail for that word
  - [ ] `banjarin://word/{invalid_id}` → shows 404 inline error in Word Detail
  - [ ] Deep links work when app is: (a) not running, (b) in background, (c) in foreground
  - [ ] Tested on Android 10+ physical device and iOS 15+ physical device

  **Unit Tests:** N/A (manual + integration)

---

## Summary

| Phase | Tasks | Scope |
|---|---|---|
| 0 — Foundation | TASK-001 → 008 | Scaffold, error types, HTTP, storage, routing, theme |
| 1 — Identity | TASK-009 → 018 | Auth flow, profile, token management |
| 2 — Dictionary | TASK-019 → 027 | Public word browse, search, detail |
| 3 — Community | TASK-028 → 036 | Votes, bookmarks, comments |
| 4 — AI Translate | TASK-037 → 040 | Terjemah screen |
| 5 — Contributions | TASK-041 → 045 | Contribution forms, my contributions |
| 6 — Admin Panel | TASK-046 → 055 | Dashboard, word mgmt, moderation, user mgmt |
| 7 — Admin AI | TASK-056 → 061 | AI enrichment jobs, review flow |
| 8 — Polish & QA | TASK-062 → 071 | Cache, skeletons, errors, a11y, CI |
| **Total** | **71 tasks** | |
