# Restaurant QR Code Ordering System

A full Flutter + Firebase restaurant ordering app: customers scan a table
QR code, browse the live menu, order, and track status in real time; chefs
manage the kitchen queue; admins manage the menu, tables, and see daily
metrics.

## Highlights
- **Clean Architecture / MVVM** — `models → services → repositories →
  viewmodels → views`, each layer depending only on the one below it.
- **No manual table entry** — the table id is decoded entirely from the
  scanned QR deep link (`restaurant://menu?table=N`).
- **Real-time everywhere** — Firestore streams power the customer's order
  tracker and the chef dashboard simultaneously; a status change by the
  chef appears on the customer's screen within moments.
- **Material 3**, light & dark theme, responsive grid layouts.
- **Provider** for state management (swap-in-ready for Riverpod if
  preferred — the ViewModel layer has no direct Provider dependency).

## Modules
| Module | Screens |
|---|---|
| Customer | Home/Menu, Food Details, Cart, Checkout, Order Tracking |
| Chef | Dashboard (Incoming / Preparing / Ready / Completed) |
| Admin | Dashboard, Manage Menu, Manage Categories, Manage Orders, Manage Tables, QR Generator |

## Quick start
See **BUILD_INSTRUCTIONS.md** for full setup (Firebase config, security
rules, sample data, deep links, APK build).

```bash
flutter pub get
flutterfire configure   # wires up your Firebase project
flutter run
```

## Repo layout
```
lib/                         Flutter source (see BUILD_INSTRUCTIONS.md)
firestore.rules              Security rules
firestore.indexes.json       Composite indexes
sample_data/                 Seed data + Node import script
android/app/AndroidManifest_deeplink_snippet.xml   QR deep-link intent filter
```

## Order status flow
`Pending → Accepted → Preparing → Ready → Completed` (or `Rejected` from
Pending). Every transition is a single Firestore field update on the order
document, observed live by both the chef dashboard and the customer's
tracking screen.
