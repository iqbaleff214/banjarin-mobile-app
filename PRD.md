# Product Requirements Document
# Banjarin — Kamus Banjar Mobile App

**Version:** 1.0.0  
**Date:** 2026-05-29  
**Status:** Draft  
**Platform:** Android & iOS (React Native / Flutter)  
**API:** Kamus Banjar API v2 (`/api/v2`)

---

## 1. Overview

### 1.1 Product Summary

Banjarin is a mobile dictionary app for the Banjar language (Dialek Hulu), digitized from *Kamus Bahasa Banjar Dialek Hulu-Indonesia, Edisi Pertama* (Balai Bahasa Banjarmasin, 2008). It provides fast word lookup, AI-powered translation from Banjar Hulu to Indonesian, community contributions, and admin moderation — all backed by the Kamus Banjar API v2.

### 1.2 Goals

- Provide fast, offline-friendly Banjar ↔ Indonesian word lookup on mobile
- Surface AI-assisted translation (Banjar Hulu → Indonesian) to authenticated users
- Enable community-driven dictionary contributions with an approval workflow
- Deliver a clean, accessible UX appropriate for language learners and researchers

### 1.3 Non-Goals

- No admin-panel-only features exposed on mobile (admin tools are secondary, minimal UI)
- No real-time chat or WebSocket features
- No multi-dialect support beyond Banjar Dialek Hulu in v1

---

## 2. User Roles

| Role | Description |
|---|---|
| **Guest** | Unauthenticated. Browse, search, read word details. |
| **User** | Authenticated. All guest access + bookmark, vote, comment, contribute, AI translate. |
| **Admin** | All user access + direct word management, moderation queue, user management, AI enrichment. |

---

## 3. Information Architecture

### 3.1 Bottom Navigation (all users)

```
[ Beranda ]  [ Cari ]  [ Terjemah* ]  [ Simpanan* ]  [ Profil ]
```

`*` requires authentication — tap redirects to login screen for guests.

### 3.2 Screen Map

```
App
├── Onboarding (first launch only)
├── Auth
│   ├── Login
│   ├── Register
│   ├── Forgot Password
│   ├── Reset Password
│   └── Verify Email Notice
│
├── Beranda (Home)
│   ├── Word List (browse A–Z, filters, sort)
│   └── Word Detail
│       ├── Definitions (with votes)
│       ├── Example Sentences
│       ├── Related Words
│       └── Comments
│
├── Cari (Search)
│   └── Search Results → Word Detail
│
├── Terjemah (AI Translate) [auth only]
│
├── Simpanan (Bookmarks) [auth only]
│   └── Word Detail
│
├── Profil
│   ├── Guest: Login / Register prompt
│   └── User/Admin:
│       ├── Profile Settings
│       ├── Change Password
│       ├── My Contributions
│       │   └── Contribution Detail
│       └── Logout
│
└── Admin Panel [admin only, accessible from Profil]
    ├── Dashboard (stats)
    ├── Word Management
    │   └── Create / Edit Word
    ├── Moderation Queue
    │   └── Contribution Review
    ├── Flagged Comments
    ├── User Management
    │   └── User Detail / Ban / Role
    └── AI Enrichment
        ├── Trigger Job (per word)
        └── AI Request History
            └── AI Request Review
```

---

## 4. Screens & Features

### 4.1 Onboarding

**Trigger:** First app launch (shown once, skippable).

**Content:**
- Screen 1: App identity — "Banjarin, Kamus Bahasa Banjar Dialek Hulu"
- Screen 2: Search & browse ~7,000 entries
- Screen 3: AI Translate (teaser — requires login)
- Screen 4: Contribute to grow the dictionary

**CTA:** "Mulai" → Home. "Masuk / Daftar" → Auth flow.

---

### 4.2 Auth Screens

#### 4.2.1 Login
**API:** `POST /auth/login`

- Fields: Email, Password (show/hide toggle)
- "Lupa kata sandi?" link → Forgot Password
- "Belum punya akun? Daftar" link
- Error: wrong credentials shows inline error message
- Rate limit (5 req/min per IP): show countdown timer on repeated failures

#### 4.2.2 Register
**API:** `POST /auth/register`

- Fields: Nama Lengkap, Email, Kata Sandi, Konfirmasi Kata Sandi
- Inline validation (password min 8 chars, email format, name min 2 chars)
- On success: show "Verifikasi Email" notice screen — prompt user to check inbox
- Email conflict (409) shows inline error

#### 4.2.3 Verify Email Notice

- Static screen shown after register
- Message: "Kami telah mengirim tautan verifikasi ke [email]. Periksa kotak masukmu."
- "Buka Aplikasi Email" button (deep-link to mail client)
- After deep-link back (token in URL): **API:** `POST /auth/verify-email` — handled transparently

#### 4.2.4 Forgot Password
**API:** `POST /auth/forgot-password`

- Field: Email
- On submit: "Jika akun ditemukan, tautan reset telah dikirim." (always show, privacy-safe)

#### 4.2.5 Reset Password
**API:** `POST /auth/reset-password`

- Reached via deep-link from email (token in URL)
- Fields: Kata Sandi Baru, Konfirmasi Kata Sandi

---

### 4.3 Beranda (Home)

**API:** `GET /words` (paginated, default sort: alphabetical)

#### Layout
- Header: App logo + search icon (taps to Search tab)
- Filter bar (horizontal scroll chips): All | n | v | a | adv | p | pb | ki
- Sort toggle: Abjad | Terpopuler | Terbaru
- Word list (infinite scroll / load more)

#### Word List Item
Each item shows:
- Banjar word (bold, large)
- Syllabified form if available (muted, small) — e.g. `a.bah`
- Word class badge — colored chip (e.g. `n`, `v`)
- Primary meaning (1 line, truncated)
- Source badge: `AI` (orange), `Komunitas` (blue) for non-seeded entries
- Homonym number superscript if `homonym_number > 1` — e.g. `¹amar`

#### Empty State
- No results: illustration + "Kata tidak ditemukan" + "Kontribusikan kata ini" button (auth) or "Masuk untuk berkontribusi" (guest)

#### Pull-to-Refresh
Reloads first page.

---

### 4.4 Word Detail

**APIs used:**
- `GET /words/{id}` — full word
- `GET /words/{id}/definitions` — definitions with votes
- `GET /words/{id}/examples` — examples
- `GET /words/{id}/related` — related words
- `GET /words/{id}/comments` — comments (paginated)
- `POST /words/{id}/votes` / `DELETE /words/{id}/votes` — word vote
- `POST /definitions/{id}/votes` / `DELETE /definitions/{id}/votes` — definition vote
- `POST /bookmarks` / `DELETE /bookmarks/{word_id}` — bookmark toggle
- `POST /words/{id}/comments` — post comment

#### Header
- Back button
- Word title (Banjar, large bold)
- Syllabified form below title
- Word class badge
- Bookmark icon (top-right) — filled/outlined, toggles on tap; guest redirected to login
- Upvote/Downvote row: `▲ 12  ▼ 1` — tapping changes vote, second tap removes vote

#### Sections (tab or accordion)

**Definisi**
- Numbered list of definitions
- Each definition:
  - Meaning text
  - Source badge (seeded = no badge, ai_generated = `AI` chip, contributed = `Komunitas` chip)
  - `▲ N  ▼ N` vote controls (auth only; guest sees count only)
- "Tambah Definisi" button at bottom (auth only) → Contribution form

**Contoh Kalimat**
- Each example:
  - Banjar sentence (italic)
  - Indonesian translation
  - Source badge
- "Tambah Contoh" button (auth only) → Contribution form

**Kata Terkait**
- Horizontal scroll of word chips → tap navigates to that word's detail
- Source: `GET /words/{id}/related`

**Komentar**
- Flat list, newest first
- Each comment: avatar placeholder + name + time + body + flag icon (auth only)
- Flagged indicator: greyed out with "Ditandai untuk moderasi"
- Own comment: shows edit (pencil) + delete (trash) icons
- Comment input at bottom (auth only); guest sees "Masuk untuk berkomentar"
- Pagination: load more button

#### Contribute FAB (floating action button)
Visible for auth users. Tapping shows bottom sheet:
- "Kontribusikan kata baru" → `new_word` form
- "Tambah definisi" → `new_definition` form for this word
- "Tambah contoh kalimat" → `new_example` form for this word
- "Usulkan perbaikan kata" → `edit_word` form for this word

---

### 4.5 Cari (Search)

**API:** `GET /words?q={query}` or `GET /words/search?q={query}`

- Search bar (auto-focused on tab tap)
- Search triggers on submit (keyboard) and after 400ms debounce
- Supports searching both Banjar words and Indonesian meanings
- Results same card format as Beranda list
- Filter chips same as Beranda (word class)
- Sort: Abjad | Terpopuler | Terbaru
- Recent searches stored locally (max 10) — shown when search bar empty
- "Hapus riwayat" to clear local history

---

### 4.6 Terjemah (AI Translate) [Auth Only]

**API:** `POST /ai/translate`

#### Layout
- Input area: multi-line text field — label "Teks Bahasa Banjar Hulu" — max 1000 chars
- Char counter: `0/1000`
- Optional context field (collapsed, expandable): "Konteks (opsional)" — e.g. "percakapan informal"
- "Terjemahkan" button (disabled when empty)

#### Result Card (appears below after success)
- Original text
- Translation (Indonesian) — larger font
- Dialect badge: `Banjar Hulu`
- Confidence badge: `Tinggi` (green) / `Sedang` (yellow) / `Rendah` (red)
- Lexical notes (italic, muted) if present — e.g. "kada=tidak, kawa=bisa"
- Model attribution (very small, muted)
- Copy translation button

#### Rate Limit State
- 30 req/hour per user — show "Batas tercapai. Coba lagi dalam X menit." with countdown

#### AI Unavailable State
- "Layanan AI sedang tidak tersedia. Coba beberapa saat lagi."

---

### 4.7 Simpanan (Bookmarks) [Auth Only]

**APIs:** `GET /bookmarks` (paginated), `DELETE /bookmarks/{word_id}`

- List of bookmarked words (same card format as word list)
- Swipe left to remove bookmark
- Empty state: "Belum ada simpanan. Simpan kata favoritmu dari halaman detail."
- Tapping a card → Word Detail

---

### 4.8 Profil

#### 4.8.1 Guest View
- Illustration + "Masuk untuk fitur lengkap"
- "Masuk" primary button → Login
- "Daftar" secondary button → Register
- Dictionary attribution (book source info)

#### 4.8.2 Authenticated User View
**API:** `GET /auth/me`

- Avatar (initial-based, colored)
- Display name + email
- Account status badge (verified email / unverified)
- Menu items:
  - **Kontribusiku** → My Contributions screen
  - **Edit Profil** → Profile Edit screen
  - **Ubah Kata Sandi** → Change Password screen
  - **Panel Admin** (admin only) → Admin Panel
  - **Keluar** → confirms then `POST /auth/logout`

#### 4.8.3 Edit Profile
**API:** `PATCH /auth/me`

- Field: Nama
- Save button

#### 4.8.4 Change Password
**API:** `PATCH /auth/me/password`

- Fields: Kata Sandi Saat Ini, Kata Sandi Baru, Konfirmasi Kata Sandi

---

### 4.9 My Contributions [Auth Only]

**API:** `GET /contributions` (own, paginated)

#### Layout
- Filter tabs: Semua | Menunggu | Disetujui | Ditolak | Dicabut
- Each contribution card:
  - Type badge: `Kata Baru`, `Definisi`, `Contoh`, `Edit Kata`
  - Target word (if applicable)
  - Status badge: color-coded
    - `Menunggu` — yellow
    - `Disetujui` — green
    - `Ditolak` — red
    - `Dicabut` — grey
  - Submitted date
  - For rejected: reviewer note displayed inline
  - For pending: "Cabut" button → `PATCH /contributions/{id}/withdraw` with confirm dialog

#### Contribution Detail
**API:** `GET /contributions/{id}`

- Full payload display
- Status timeline
- Reviewer note (if rejected)

---

### 4.10 Contribution Forms

**API:** `POST /contributions`

#### New Word (`new_word`)
- Kata Banjar (required)
- Bentuk Suku Kata (optional) — e.g. `a.bah`
- Kelas Kata (required) — dropdown: n, v, a, adv, p, pb, ki
- Definisi (required, min 1) — dynamic list, add/remove rows
- Contoh Kalimat (optional) — dynamic pairs (Banjar + Indonesia)
- Submit → pending review notice

#### New Definition (`new_definition`)
- Target word shown (read-only)
- Definisi (required, max 2000 chars)

#### New Example (`new_example`)
- Target word shown (read-only)
- Kalimat Banjar (required)
- Terjemahan Indonesia (required)

#### Edit Word (`edit_word`)
- Target word shown (read-only)
- Editable: Kata Banjar, Bentuk Suku Kata, Kelas Kata

All forms: validation inline, rate limit notice (10 contributions/hour).

---

## 5. Admin Panel [Admin Only]

Accessible from Profil → "Panel Admin". Uses a separate stack navigator.

### 5.1 Admin Dashboard

**API:** `GET /admin/moderation/stats`

- Stats cards:
  - Kontribusi Menunggu
  - Komentar Ditandai
  - Disetujui Minggu Ini
  - Ditolak Minggu Ini
- Quick links: Antrian Moderasi, Komentar Ditandai, Manajemen Kata, Manajemen Pengguna, Pengayaan AI

### 5.2 Word Management

**APIs:** `GET /admin/words`, `POST /admin/words`, `PATCH /admin/words/{id}`, `DELETE /admin/words/{id}`

- Full word list (includes deprecated) with status filter
- Search by Banjar word
- Filter by word class, source, status
- Tap word → Word Admin Detail
  - Edit all fields (full `WordInput` form)
  - Delete (soft) with confirmation dialog
  - Trigger AI Enrichment buttons (see §5.5)
- FAB: Create new word → full `WordInput` form (no approval needed)

### 5.3 Moderation Queue

**APIs:** `GET /admin/moderation/queue`, `PATCH /contributions/{id}/approve`, `PATCH /contributions/{id}/reject`

- List of pending contributions
- Filter by type: Semua | Kata Baru | Definisi | Contoh | Edit Kata
- Each item:
  - Contributor name, submitted time
  - Type + target word
  - Payload preview
- Tap → Contribution Review screen:
  - Full payload
  - "Setujui" button (optional approval note)
  - "Tolak" button (required rejection note, max 500 chars)
  - AI Quality Check button → `POST /admin/ai/check/{contribution_id}`

### 5.4 Flagged Comments

**APIs:** `GET /admin/moderation/flags`, `DELETE /comments/{id}`

- List flagged comments
- Each: comment text, author, word context, flag count
- Actions: Delete Comment | Dismiss Flag (mark as resolved)

### 5.5 User Management

**APIs:** `GET /admin/users`, `GET /admin/users/{id}`, `PATCH /admin/users/{id}/ban`, `PATCH /admin/users/{id}/unban`, `PATCH /admin/users/{id}/role`

- Paginated user list
- Search by name/email
- Filter by role (user/admin), status (active/banned)
- User detail:
  - Name, email, role, join date, email verified status
  - Activity summary
  - Ban / Unban button (with reason field for ban)
  - Change Role dropdown (user ↔ admin) with confirmation

### 5.6 AI Enrichment

**Trigger APIs:**
- `POST /admin/ai/enrich/{word_id}` — definisi enrichment
- `POST /admin/ai/example/{word_id}` — contoh kalimat
- `POST /admin/ai/related/{word_id}` — kata terkait
- `POST /admin/ai/check/{contribution_id}` — quality check

**Review APIs:**
- `GET /admin/ai/requests` (paginated, filterable by type/status/review_status)
- `GET /admin/ai/requests/{id}`
- `PATCH /admin/ai/requests/{id}/approve`
- `PATCH /admin/ai/requests/{id}/reject`

#### AI Request History Screen
- List with filter tabs: Semua | Menunggu Review | Disetujui | Ditolak
- Each card:
  - Type badge: `Definisi`, `Contoh`, `Terkait`, `Quality Check`
  - Target word
  - Status: Pending / Completed / Failed
  - Review status: Unreviewed / Approved / Rejected
  - Created date

#### AI Request Detail Screen
- Request type + target word
- Model used
- Parsed output displayed in human-readable format:
  - For `enrich_definition`: suggested definitions list
  - For `suggest_example`: Banjar sentence + Indonesian pair
  - For `suggest_related`: related word list
  - For `quality_check`: accuracy score + flags + notes (advisory, no approve/reject)
- For non-quality-check: "Setujui & Gabungkan" | "Tolak" buttons
- Failed state: error message, re-trigger option

---

## 6. UX & UI Design Guidelines

### 6.1 Design Language

- **Style:** Clean, flat, modern — inspired by Indonesian language app aesthetics
- **Typography:** System font (San Francisco on iOS, Roboto on Android). Banjar words displayed in a slightly larger, heavier weight to emphasize the foreign-language entry.
- **Color palette:**
  - Primary: Deep teal (`#0D7377`) — language/culture feel
  - Secondary: Warm amber (`#F2994A`) — AI-generated content
  - Success: `#27AE60`
  - Error: `#EB5757`
  - Background: `#FAFAFA` (light) / `#121212` (dark)
- **Dark mode:** Full support, system-aware default
- **Rounded corners:** 12px cards, 8px chips/badges
- **Motion:** Subtle — slide transitions, skeleton loaders, micro-interactions on vote/bookmark

### 6.2 Source Badges

Visible wherever content originates from different sources:

| Source | Label | Color |
|---|---|---|
| `seeded` | *(no badge)* | — |
| `contributed` | `Komunitas` | Blue |
| `ai_generated` | `AI` | Amber |

Always shown next to definitions and examples. Users understand AI-generated content is labeled and unverified.

### 6.3 Word Class Badges

Colored pill chips for each word class:

| Class | Label | Color |
|---|---|---|
| `n` | Nomina | Slate |
| `v` | Verba | Blue |
| `a` | Adjektiva | Green |
| `adv` | Adverbia | Purple |
| `p` | Partikel | Orange |
| `pb` | Pribahasa | Red |
| `ki` | Kiasan | Teal |

### 6.4 Loading States

- **Skeleton loaders** for word lists and word detail (never blank screens)
- **Inline spinners** for vote, bookmark, comment post actions
- **Full-screen loader** only for login/register/submit actions

### 6.5 Error States

| Error | UI |
|---|---|
| Network offline | Persistent top banner "Tidak ada koneksi" + cached data shown |
| 401 Unauthorized | Auto-redirect to login, session expires notification |
| 404 Not Found | In-card "Konten tidak ditemukan" |
| 429 Rate Limited | Inline countdown: "Coba lagi dalam X menit" |
| 503 AI Unavailable | Inline: "Layanan AI sedang gangguan. Coba nanti." |
| 500 Internal Error | Toast: "Terjadi kesalahan. Coba beberapa saat lagi." |

### 6.6 Empty States

Each list has a tailored empty state with illustration + message:
- Word list: "Tidak ada kata ditemukan"
- Bookmarks: "Belum ada simpanan"
- Contributions: "Belum ada kontribusi"
- Search: "Tidak ada hasil untuk '[query]'"
- Moderation queue: "Antrian kosong 🎉"

### 6.7 Accessibility

- Minimum touch target: 44×44pt
- Color contrast meets WCAG AA
- Screen reader labels on all icon-only buttons (bookmark, vote, flag)
- VoiceOver / TalkBack compatible

### 6.8 Performance

- Word list uses virtualized scroll (FlatList/LazyColumn)
- Search debounce: 400ms
- Paginated lists: load 20 at a time, load-more on scroll-to-end
- Recent searches cached locally (AsyncStorage / SharedPreferences)
- JWT refresh handled silently in the background (token interceptor) — user never sees re-login for token expiry during active use

---

## 7. API Endpoint Coverage

All API v2 endpoints consumed by the mobile app:

### Dictionary (Public)
| Endpoint | Screen |
|---|---|
| `GET /words` | Beranda, Cari |
| `GET /words/search` | Cari |
| `GET /words/{id}` | Word Detail |
| `GET /words/{id}/definitions` | Word Detail — Definisi tab |
| `GET /words/{id}/examples` | Word Detail — Contoh tab |
| `GET /words/{id}/related` | Word Detail — Terkait section |
| `GET /words/{id}/comments` | Word Detail — Komentar section |

### Votes (Auth)
| Endpoint | Screen |
|---|---|
| `POST /words/{id}/votes` | Word Detail |
| `DELETE /words/{id}/votes` | Word Detail |
| `POST /definitions/{id}/votes` | Word Detail — Definisi tab |
| `DELETE /definitions/{id}/votes` | Word Detail — Definisi tab |

### Bookmarks (Auth)
| Endpoint | Screen |
|---|---|
| `GET /bookmarks` | Simpanan |
| `POST /bookmarks` | Word Detail (bookmark icon) |
| `DELETE /bookmarks/{word_id}` | Word Detail, Simpanan (swipe) |

### Comments (Auth)
| Endpoint | Screen |
|---|---|
| `POST /words/{id}/comments` | Word Detail |
| `PATCH /comments/{id}` | Word Detail (edit own) |
| `DELETE /comments/{id}` | Word Detail (delete own) |
| `POST /comments/{id}/flag` | Word Detail (flag) |

### Contributions (Auth)
| Endpoint | Screen |
|---|---|
| `POST /contributions` | Contribution Forms |
| `GET /contributions` | My Contributions |
| `GET /contributions/{id}` | Contribution Detail |
| `PATCH /contributions/{id}/withdraw` | My Contributions |

### AI (Auth)
| Endpoint | Screen |
|---|---|
| `POST /ai/translate` | Terjemah |

### Auth
| Endpoint | Screen |
|---|---|
| `POST /auth/register` | Register |
| `POST /auth/login` | Login |
| `POST /auth/logout` | Profil |
| `POST /auth/refresh` | Background (token interceptor) |
| `GET /auth/me` | Profil |
| `PATCH /auth/me` | Edit Profil |
| `PATCH /auth/me/password` | Change Password |
| `POST /auth/verify-email` | Deep-link handler |
| `POST /auth/forgot-password` | Forgot Password |
| `POST /auth/reset-password` | Reset Password (deep-link) |

### Admin — Words
| Endpoint | Screen |
|---|---|
| `GET /admin/words` | Admin Word Management |
| `POST /admin/words` | Admin Create Word |
| `PATCH /admin/words/{id}` | Admin Edit Word |
| `DELETE /admin/words/{id}` | Admin Word Detail |

### Admin — Users
| Endpoint | Screen |
|---|---|
| `GET /admin/users` | Admin User Management |
| `GET /admin/users/{id}` | Admin User Detail |
| `PATCH /admin/users/{id}/ban` | Admin User Detail |
| `PATCH /admin/users/{id}/unban` | Admin User Detail |
| `PATCH /admin/users/{id}/role` | Admin User Detail |

### Admin — Moderation
| Endpoint | Screen |
|---|---|
| `GET /admin/moderation/queue` | Admin Moderation Queue |
| `GET /admin/moderation/flags` | Admin Flagged Comments |
| `GET /admin/moderation/stats` | Admin Dashboard |
| `PATCH /contributions/{id}/approve` | Admin Contribution Review |
| `PATCH /contributions/{id}/reject` | Admin Contribution Review |

### Admin — AI
| Endpoint | Screen |
|---|---|
| `POST /admin/ai/enrich/{word_id}` | Admin Word Detail, AI Requests |
| `POST /admin/ai/example/{word_id}` | Admin Word Detail |
| `POST /admin/ai/related/{word_id}` | Admin Word Detail |
| `POST /admin/ai/check/{contribution_id}` | Admin Contribution Review |
| `GET /admin/ai/requests` | Admin AI Request History |
| `GET /admin/ai/requests/{id}` | Admin AI Request Detail |
| `PATCH /admin/ai/requests/{id}/approve` | Admin AI Request Detail |
| `PATCH /admin/ai/requests/{id}/reject` | Admin AI Request Detail |

---

## 8. Token Management

- Store `access_token` + `refresh_token` securely (Keychain on iOS / Keystore on Android)
- Access token TTL: 15 min — interceptor calls `POST /auth/refresh` transparently before expiry
- Refresh token TTL: 7 days — on refresh failure (401), clear tokens and redirect to Login
- Logout: call `POST /auth/logout` then clear both tokens from secure storage
- Email must be verified before contribution forms are accessible — unverified users see a banner "Verifikasi emailmu untuk berkontribusi" with a resend link

---

## 9. Offline & Caching

| Data | Cache Strategy |
|---|---|
| Word list (first page) | Cache last fetch, show stale + refresh indicator |
| Word detail | Cache on view, show stale with "Terakhir diperbarui" timestamp |
| Search results | Not cached (always fresh) |
| Bookmarks | Cache locally, sync on reconnect |
| Recent searches | Always local (AsyncStorage) |
| AI translations | Not cached (stateless by design) |

---

## 10. Deep Linking

| URL Pattern | Action |
|---|---|
| `banjarin://verify-email?token={token}` | Call `POST /auth/verify-email`, navigate to Home |
| `banjarin://reset-password?token={token}` | Navigate to Reset Password screen with token pre-filled |
| `banjarin://word/{id}` | Navigate to Word Detail |

---

## 11. Notifications (v1 scope: in-app only)

| Event | In-app notification |
|---|---|
| Contribution approved | "Kontribusimu untuk '[kata]' disetujui! 🎉" |
| Contribution rejected | "Kontribusimu ditolak. Lihat catatan reviewer." |
| Comment flagged (admin) | "Komentar ditandai untuk ditinjau." |

Push notifications (FCM/APNs) deferred to v2. In v1, status changes surfaced via My Contributions screen badge and pull-to-refresh.

---

## 12. Feature Flag: Email Verification Gate

Contribution privileges (POST /contributions) blocked in-app if `email_verified_at` is null:
- All contribution form entry points show inline warning
- Forms disabled with "Verifikasi emailmu terlebih dahulu"
- Resend verification email button (calls `POST /auth/forgot-password` flow adapted for verify)

---

## 13. Architecture

### 13.1 Approach: Clean Architecture + DDD

The mobile app applies Clean Architecture with DDD-aligned bounded contexts, identical in spirit to the backend. Dependencies flow inward — Presentation depends on Domain via Use Cases; Infrastructure implements Domain interfaces.

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│   Screens · ViewModels/Blocs · Widgets      │
├─────────────────────────────────────────────┤
│             Application Layer               │
│   Use Cases (commands & queries)            │
├─────────────────────────────────────────────┤
│               Domain Layer                  │
│   Entities · Value Objects · Repo Interfaces│
├─────────────────────────────────────────────┤
│            Infrastructure Layer             │
│   API data sources · Local cache · Repos    │
└─────────────────────────────────────────────┘
```

**Rule:** Domain has zero Flutter/platform imports. Use Cases depend only on Domain. Infrastructure depends on Domain interfaces — never the reverse.

---

### 13.2 Bounded Contexts

| Context | Entities / Value Objects | Use Cases |
|---|---|---|
| **Dictionary** | `Word`, `Definition`, `Example`, `RelatedWord` | `GetWordList`, `SearchWords`, `GetWordDetail`, `GetDefinitions`, `GetExamples`, `GetRelatedWords` |
| **Community** | `Vote`, `Bookmark`, `Comment`, `Contribution` | `CastVote`, `RemoveVote`, `AddBookmark`, `RemoveBookmark`, `GetBookmarks`, `PostComment`, `EditComment`, `DeleteComment`, `FlagComment`, `SubmitContribution`, `WithdrawContribution`, `GetMyContributions` |
| **Identity** | `User`, `TokenPair`, `AuthSession` | `Login`, `Register`, `Logout`, `RefreshToken`, `GetProfile`, `UpdateProfile`, `ChangePassword`, `ForgotPassword`, `ResetPassword`, `VerifyEmail` |
| **AI** | `TranslationResult` | `TranslateBanjar` |
| **Admin** | `ModerationStats`, `AIRequest` | `GetAdminWords`, `CreateWord`, `UpdateWord`, `DeleteWord`, `GetModerationQueue`, `ApproveContribution`, `RejectContribution`, `GetFlaggedComments`, `GetUsers`, `BanUser`, `UnbanUser`, `ChangeUserRole`, `TriggerAIEnrich`, `TriggerAIExample`, `TriggerAIRelated`, `RunQualityCheck`, `GetAIRequests`, `ApproveAIRequest`, `RejectAIRequest` |

---

### 13.3 Directory Structure

```
lib/
├── core/
│   ├── error/              # Failure types, exceptions
│   ├── network/            # HTTP client, token interceptor, connectivity
│   ├── storage/            # Secure storage, local cache abstraction
│   ├── usecase/            # UseCase<Params, Result> base class
│   └── utils/              # Debouncer, extensions, constants
│
├── features/
│   ├── dictionary/
│   │   ├── domain/
│   │   │   ├── entities/       # Word, Definition, Example, RelatedWord
│   │   │   ├── repositories/   # WordRepository (interface)
│   │   │   └── usecases/       # GetWordList, SearchWords, GetWordDetail, ...
│   │   ├── data/
│   │   │   ├── datasources/    # WordRemoteDataSource (API), WordLocalDataSource (cache)
│   │   │   ├── models/         # WordModel, DefinitionModel, ExampleModel (JSON ↔ entity)
│   │   │   └── repositories/   # WordRepositoryImpl
│   │   └── presentation/
│   │       ├── bloc/           # WordListBloc, WordDetailBloc (or Cubit)
│   │       ├── pages/          # BerandaPage, WordDetailPage
│   │       └── widgets/        # WordCard, DefinitionTile, SourceBadge, WordClassChip
│   │
│   ├── community/
│   │   ├── domain/
│   │   │   ├── entities/       # Vote, Bookmark, Comment, Contribution
│   │   │   ├── repositories/   # VoteRepository, BookmarkRepository, CommentRepository, ContributionRepository
│   │   │   └── usecases/
│   │   ├── data/
│   │   └── presentation/
│   │       ├── bloc/           # VoteBloc, BookmarkBloc, CommentBloc, ContributionBloc
│   │       ├── pages/          # SimpananPage, MyContributionsPage, ContributionFormPage
│   │       └── widgets/        # CommentTile, VoteRow, ContributionCard
│   │
│   ├── identity/
│   │   ├── domain/
│   │   │   ├── entities/       # User, TokenPair, AuthSession
│   │   │   ├── repositories/   # AuthRepository
│   │   │   └── usecases/
│   │   ├── data/
│   │   └── presentation/
│   │       ├── bloc/           # AuthBloc, ProfileBloc
│   │       └── pages/          # LoginPage, RegisterPage, ProfilPage, ...
│   │
│   ├── ai/
│   │   ├── domain/
│   │   │   ├── entities/       # TranslationResult
│   │   │   ├── repositories/   # AIRepository
│   │   │   └── usecases/       # TranslateBanjar
│   │   ├── data/
│   │   └── presentation/
│   │       ├── bloc/           # TranslateBloc
│   │       └── pages/          # TerjemahPage
│   │
│   └── admin/
│       ├── domain/
│       │   ├── entities/       # ModerationStats, AIRequest
│       │   ├── repositories/   # AdminRepository
│       │   └── usecases/
│       ├── data/
│       └── presentation/
│           ├── bloc/           # AdminWordBloc, ModerationBloc, UserMgmtBloc, AIRequestBloc
│           └── pages/          # AdminDashboardPage, WordManagementPage, ...
│
└── injection/              # Dependency injection (get_it / injectable)
```

---

### 13.4 State Management

Bloc/Cubit pattern (flutter_bloc). Each feature has its own Bloc per major data flow:

| Bloc | State shape | Key events |
|---|---|---|
| `WordListBloc` | `{words, isLoading, hasMore, error, filters}` | `Load`, `LoadMore`, `FilterChanged`, `SortChanged` |
| `WordDetailBloc` | `{word, isLoading, userVote, isBookmarked, error}` | `Load`, `CastVote`, `ToggleBookmark` |
| `SearchBloc` | `{results, isLoading, query, error}` | `QueryChanged`, `LoadMore` |
| `CommentBloc` | `{comments, isPosting, error}` | `Load`, `Post`, `Edit`, `Delete`, `Flag` |
| `ContributionBloc` | `{contributions, isSubmitting, error}` | `Load`, `Submit`, `Withdraw` |
| `AuthBloc` | `{user, status, error}` | `Login`, `Register`, `Logout`, `Refresh`, `CheckSession` |
| `TranslateBloc` | `{result, isLoading, error, rateLimitReset}` | `Translate` |
| `BookmarkBloc` | `{bookmarks, isLoading, error}` | `Load`, `Add`, `Remove` |
| `ModerationBloc` | `{queue, stats, isLoading, error}` | `LoadQueue`, `Approve`, `Reject`, `LoadStats` |
| `AIRequestBloc` | `{requests, current, isLoading, error}` | `Load`, `Trigger`, `Approve`, `Reject` |

---

### 13.5 Dependency Injection

All repositories and use cases registered via `get_it`. Feature modules register their own dependencies. Presentation receives use cases only — never repositories or data sources directly.

```dart
// Example wiring (dictionary feature)
sl.registerLazySingleton<WordRepository>(
  () => WordRepositoryImpl(
    remote: sl<WordRemoteDataSource>(),
    local: sl<WordLocalDataSource>(),
  ),
);
sl.registerLazySingleton(() => GetWordDetail(sl<WordRepository>()));
sl.registerFactory(() => WordDetailBloc(getWordDetail: sl()));
```

---

## 14. Testing Strategy (TDD)

### 14.1 Approach

Red → Green → Refactor. Tests written before implementation for all Domain and Application layers. Presentation and Infrastructure layers are tested after-the-fact with widget and integration tests.

### 14.2 Test Layers

| Layer | Tool | What is tested |
|---|---|---|
| **Unit — Domain** | `flutter_test`, `mocktail` | Entities, value objects, use case business logic (pure Dart, no Flutter) |
| **Unit — Bloc** | `bloc_test`, `mocktail` | State transitions for every event, including loading/error/success |
| **Widget** | `flutter_test` | Individual widgets and pages with mocked Blocs |
| **Integration** | `integration_test` | End-to-end user flows against a real (staging) API |

### 14.3 Coverage Targets

| Layer | Minimum coverage |
|---|---|
| Domain (entities + use cases) | **90%** |
| Application (Blocs/Cubits) | **85%** |
| Infrastructure (repositories, data sources) | **70%** |
| Presentation (widgets, pages) | **60%** |

### 14.4 Mocking Rules

- **Domain use cases** always mocked in Bloc tests (never call real use case)
- **Repositories** always mocked in use case tests (never call real data source)
- **HTTP client** mocked in data source unit tests (`http_mock_adapter` / `mockito`)
- **Integration tests** hit a real staging API — no mocks

### 14.5 Key Test Scenarios

#### Dictionary Context

| Scenario | Type |
|---|---|
| `GetWordList` returns paginated `WordSummary` list | Unit |
| `GetWordList` with `word_class` filter passes correct query param | Unit |
| `SearchWords` with empty query returns validation failure | Unit |
| `GetWordDetail` returns `Word` with definitions + examples | Unit |
| `WordListBloc` emits `[Loading, Loaded]` on `Load` event | Bloc |
| `WordListBloc` emits `[Loading, Error]` when repository throws | Bloc |
| `WordDetailBloc` emits updated vote state after `CastVote` succeeds | Bloc |
| `WordCard` widget renders word class badge + source badge correctly | Widget |
| `SourceBadge` shows "AI" chip for `ai_generated`, nothing for `seeded` | Widget |

#### Community Context

| Scenario | Type |
|---|---|
| `CastVote` returns failure if user unauthenticated | Unit |
| `CastVote` updates existing vote when direction changes | Unit |
| `RemoveVote` returns `NotFound` failure if no vote exists | Unit |
| `AddBookmark` returns `Conflict` failure if already bookmarked | Unit |
| `SubmitContribution` `new_definition` requires `target_word_id` | Unit |
| `SubmitContribution` `new_word` requires at least one definition | Unit |
| `WithdrawContribution` returns `Conflict` if status is not `pending` | Unit |
| `ContributionBloc` emits `[Submitting, Submitted]` on `Submit` event | Bloc |
| `VoteRow` widget shows active state for current user vote | Widget |

#### Identity Context

| Scenario | Type |
|---|---|
| `Login` with valid credentials returns `TokenPair` | Unit |
| `Login` with invalid credentials returns `Unauthorized` failure | Unit |
| `Register` with password mismatch returns `ValidationError` failure | Unit |
| `Register` with duplicate email returns `Conflict` failure | Unit |
| `RefreshToken` on expired access token returns new `TokenPair` | Unit |
| `RefreshToken` on invalid refresh token clears session | Unit |
| `AuthBloc` emits `[Loading, Authenticated]` on successful `Login` | Bloc |
| `AuthBloc` emits `[Loading, Unauthenticated]` on `Logout` | Bloc |
| Token interceptor calls `RefreshToken` when 401 received | Unit |
| Token interceptor redirects to login when refresh also 401 | Unit |

#### AI Context

| Scenario | Type |
|---|---|
| `TranslateBanjar` with text exceeding 1000 chars returns `ValidationError` | Unit |
| `TranslateBanjar` returns `Unauthorized` for unauthenticated user | Unit |
| `TranslateBanjar` returns `AIUnavailable` on 503 response | Unit |
| `TranslateBloc` emits rate-limit state with reset timestamp on 429 | Bloc |
| `TerjemahPage` char counter updates on input | Widget |
| `TerjemahPage` disables submit button when input is empty | Widget |
| Translation result card shows correct confidence badge color | Widget |

#### Admin Context

| Scenario | Type |
|---|---|
| `ApproveContribution` returns `Conflict` if already approved | Unit |
| `RejectContribution` requires non-empty `note` | Unit |
| `ApproveAIRequest` returns `Conflict` for `quality_check` type | Unit |
| `ModerationBloc` emits updated queue after `Approve` event | Bloc |
| `AIRequestBloc` emits `[Triggering, Triggered]` on `Trigger` event | Bloc |

### 14.6 Test File Conventions

```
test/
├── features/
│   ├── dictionary/
│   │   ├── domain/
│   │   │   ├── usecases/
│   │   │   │   ├── get_word_list_test.dart
│   │   │   │   ├── search_words_test.dart
│   │   │   │   └── get_word_detail_test.dart
│   │   │   └── entities/
│   │   │       └── word_test.dart
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── word_remote_data_source_test.dart
│   │   │   └── repositories/
│   │   │       └── word_repository_impl_test.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── word_list_bloc_test.dart
│   │       │   └── word_detail_bloc_test.dart
│   │       └── widgets/
│   │           ├── word_card_test.dart
│   │           └── source_badge_test.dart
│   ├── community/  ...
│   ├── identity/   ...
│   ├── ai/         ...
│   └── admin/      ...
├── core/
│   ├── network/
│   │   └── token_interceptor_test.dart
│   └── usecase/
│       └── usecase_test.dart
└── integration_test/
    ├── auth_flow_test.dart
    ├── dictionary_browse_test.dart
    ├── translate_flow_test.dart
    └── contribution_flow_test.dart
```

### 14.7 CI Enforcement

- Unit + widget tests run on every PR (fast, < 2 min)
- Integration tests run on merge to `main` against staging
- Coverage report generated via `flutter test --coverage` + `lcov`
- PR blocked if domain or bloc coverage drops below threshold
- Test naming convention: `[unit under test] [scenario] [expected outcome]`  
  Example: `TranslateBanjar when text exceeds 1000 chars returns ValidationError`

---

## 15. Milestones

| Phase | Scope |
|---|---|
| **Phase 1** | Project setup, navigation shell, Auth screens (Login, Register, Verify Email, Forgot/Reset Password) |
| **Phase 2** | Beranda + Word Detail (browse, search, definitions, examples, related words) — public, no auth |
| **Phase 3** | Auth-gated features: Bookmark, Vote, Comments |
| **Phase 4** | AI Translate screen (Terjemah tab) |
| **Phase 5** | Contributions (forms, My Contributions, withdraw) |
| **Phase 6** | Admin Panel (Dashboard, Word Management, Moderation Queue, Flagged Comments, User Management) |
| **Phase 7** | Admin AI Enrichment (trigger, review/approve/reject) |
| **Phase 8** | Polish: offline caching, deep links, skeleton loaders, dark mode, accessibility audit, edge case error states |
