# Banjarin

> Kamus Bahasa Banjar Dialek Hulu untuk Android & iOS

Banjarin is a community-driven mobile dictionary for the Banjar language (Dialek Hulu), digitized from *Kamus Bahasa Banjar Dialek Hulu-Indonesia, Edisi Pertama* (Balai Bahasa Banjarmasin, Departemen Pendidikan Nasional, 2008). It surfaces ~7,000 entries with AI-assisted translation, community contributions, and admin moderation — all backed by the [Kamus Banjar API v2](../banjarin-api).

---

## Features

| Feature | Guest | User | Admin |
|---|:---:|:---:|:---:|
| Browse & search ~7,000 entries | ✓ | ✓ | ✓ |
| View definitions, examples, related words | ✓ | ✓ | ✓ |
| Bookmark words | — | ✓ | ✓ |
| Vote on words & definitions | — | ✓ | ✓ |
| Comment on words | — | ✓ | ✓ |
| AI translate Banjar Hulu → Indonesian | — | ✓ | ✓ |
| Contribute new words, definitions, examples | — | ✓ | ✓ |
| Moderation queue & word management | — | — | ✓ |
| AI enrichment jobs (enrich / suggest / check) | — | — | ✓ |

---

## Architecture

Clean Architecture + DDD, organized by bounded context. Dependencies flow inward — Presentation → Application → Domain ← Infrastructure.

```
lib/
├── core/                   # Error types, HTTP client, storage, utils
└── features/
    ├── dictionary/         # Word browse, search, detail
    ├── community/          # Votes, bookmarks, comments, contributions
    ├── identity/           # Auth, profile
    ├── ai/                 # Banjar → Indonesian translation
    └── admin/              # Word mgmt, moderation, AI enrichment
```

Each feature follows the same internal structure:

```
<feature>/
├── domain/
│   ├── entities/           # Pure Dart models
│   ├── repositories/       # Abstract interfaces
│   └── usecases/           # One class per use case
├── data/
│   ├── datasources/        # Remote (API) + local (cache)
│   ├── models/             # JSON ↔ entity mapping
│   └── repositories/       # Implementations
└── presentation/
    ├── bloc/               # Bloc / Cubit + states + events
    ├── pages/              # Full screens
    └── widgets/            # Reusable UI components
```

State management: [flutter_bloc](https://pub.dev/packages/flutter_bloc).  
Dependency injection: [get_it](https://pub.dev/packages/get_it) + [injectable](https://pub.dev/packages/injectable).

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` |
| Dependency injection | `get_it` + `injectable` |
| HTTP client | `dio` |
| Secure token storage | `flutter_secure_storage` |
| Local cache | `hive` |
| Navigation | `go_router` |
| Unit & widget testing | `flutter_test` + `bloc_test` + `mocktail` |
| Integration testing | `integration_test` |
| Code generation | `build_runner` + `freezed` + `json_serializable` |

---

## Getting Started

### Prerequisites

- Flutter `>=3.22.0` (stable channel)
- Dart `>=3.4.0`
- A running instance of [Kamus Banjar API v2](../banjarin-api) or access to staging

### Setup

```bash
# 1. Clone
git clone https://github.com/iqbaleff214/banjarin.git
cd banjarin

# 2. Install dependencies
flutter pub get

# 3. Run code generation
dart run build_runner build --delete-conflicting-outputs

# 4. Copy and fill environment config
cp .env.example .env
```

Configure `.env`:

```env
API_BASE_URL=https://api.banjarin.id/api/v2
```

### Run

```bash
# Debug
flutter run

# Release
flutter run --release
```

---

## Testing

This project follows Test-Driven Development. Tests are organized by layer:

```bash
# All unit + widget tests
flutter test

# With coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Integration tests (requires device or emulator + staging API)
flutter test integration_test/
```

### Coverage targets

| Layer | Minimum |
|---|---|
| Domain (entities + use cases) | 90% |
| Application (Blocs / Cubits) | 85% |
| Infrastructure (repositories, data sources) | 70% |
| Presentation (widgets, pages) | 60% |

---

## Project Structure (full)

```
banjarin/
├── lib/
│   ├── core/
│   │   ├── error/              # Failure types, exceptions
│   │   ├── network/            # Dio client, token interceptor
│   │   ├── storage/            # Secure storage, Hive cache
│   │   ├── usecase/            # UseCase<P,R> base class
│   │   └── utils/              # Debouncer, extensions, constants
│   ├── features/
│   │   ├── dictionary/
│   │   ├── community/
│   │   ├── identity/
│   │   ├── ai/
│   │   └── admin/
│   └── injection/              # get_it registrations
├── test/
│   ├── features/               # Unit + widget tests (mirror of lib/)
│   └── core/
├── integration_test/           # End-to-end flows
├── assets/
│   ├── fonts/
│   └── images/
├── android/
├── ios/
├── PRD.md                      # Product Requirements Document
├── BE_PRD.md                   # Backend PRD reference
└── openapi.yaml                # API contract (Kamus Banjar API v2)
```

---

## API Reference

The app consumes **Kamus Banjar API v2**. Full contract: [`openapi.yaml`](openapi.yaml).

Base URL: `/api/v2`  
Auth: Bearer JWT (`POST /auth/login` → `access_token`)  
Token refresh: 15-min access token, 7-day refresh token (handled transparently by token interceptor)

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Write tests first (TDD)
4. Implement until tests pass
5. Open a pull request

All PRs must maintain domain + bloc coverage thresholds. CI will block merges that drop below target.

---

## Data Source

> **Kamus Bahasa Banjar Dialek Hulu-Indonesia**, Edisi Pertama  
> Balai Bahasa Banjarmasin, Departemen Pendidikan Nasional, 2008  
> ISBN: 978-979-685-776-0  
> Authors: Musdalipah, Siti Akbari, Jandiah, Wandanie Rakhman, Muhammad Yamani, H. Dede Hidayatullah, Noor Hastiah

Dictionary digitized and seeded with permission for open-source linguistic preservation.

---

## License

MIT © iqbaleff214
