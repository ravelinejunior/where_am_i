# Where Am I? 🔴

> Missing persons registry focused on immigrants in Europe — especially Brazilians.

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x |
| State management | flutter_bloc |
| Navigation | go_router |
| Backend | Firebase (Firestore + Auth + Storage) |
| External API | Interpol Public REST API |
| Fonts | DM Serif Display + DM Sans (Google Fonts) |
| i18n | Flutter Gen l10n (EN + PT) |

## Architecture

Feature-first Clean Architecture:
- **Presentation** — BLoC + Screens + Widgets
- **Domain** — Entities + UseCases + Repository interfaces (pure Dart)
- **Data** — Repository impls + Remote datasources (Interpol, Firestore)

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Configure Firebase
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
This generates `lib/firebase_options.dart`. Then uncomment the Firebase init line in `main.dart`.

### 3. Generate l10n
```bash
flutter gen-l10n
```

### 4. Run
```bash
flutter run
```

## Commit Roadmap

| # | Commit | Status |
|---|---|---|
| 1 | `feat: project setup & theme` | ✅ Done |
| 2 | `feat: routing & splash screen` | ✅ Done (included in #1) |
| 3 | `feat: missing person entity & repo interface` | ⏳ Next |
| 4 | `feat: interpol remote datasource` | ⏳ |
| 5 | `feat: firestore remote datasource` | ⏳ |
| 6 | `feat: repository impl (merge sources)` | ⏳ |
| 7 | `feat: missing list bloc + screen` | ⏳ |
| 8 | `feat: missing detail bloc + screen` | ⏳ |
| 9 | `feat: SOS button (112)` | ⏳ |
| 10 | `feat: auth bloc + login screen` | ⏳ |
| 11 | `feat: report case screen + bloc` | ⏳ |
| 12 | `feat: l10n (pt + en)` | ⏳ |
| 13 | `feat: admin approval flow` | ⏳ |

## Interpol API

Public endpoint, no API key required:
```
GET https://ws-public.interpol.int/notices/v1/yellow?nationality=BR&page=1&resultPerPage=20
GET https://ws-public.interpol.int/notices/v1/yellow/{id}
GET https://ws-public.interpol.int/notices/v1/yellow/{id}/images
```

## Firestore Schema

```
/cases/{caseId}
  name: string
  birthDate: Timestamp
  lastSeenDate: Timestamp
  lastSeenLocation: string
  nationality: string
  sex: "M" | "F" | "U"
  heightCm: number?
  photoUrls: string[]
  facts: string[]
  contacts: { label: string, value: string }[]
  source: "user" | "admin"
  status: "pending" | "approved" | "resolved" | "rejected"
  reportedBy: string (userId)
  createdAt: Timestamp
```

## Emergency

SOS button calls `tel:112` (European emergency number).

## Localization

- English: `lib/l10n/app_en.arb`
- Portuguese: `lib/l10n/app_pt.arb`

Run `flutter gen-l10n` after editing `.arb` files.
