# Build & Setup Instructions

## 1. Prerequisites
- Flutter SDK (latest stable, 3.22+) — `flutter --version`
- A Firebase project (console.firebase.google.com)
- Node.js (only needed for the optional sample-data import script)
- Android Studio / Xcode for platform builds

## 2. Get the code running

```bash
cd restaurant_qr_ordering
flutter pub get
```

## 3. Connect Firebase

The project ships with a **placeholder** `lib/firebase_options.dart`. Replace it
with your own project's config:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This will:
- Ask you to pick/create a Firebase project
- Register Android / iOS / Web apps
- Overwrite `lib/firebase_options.dart` with real keys
- Download `google-services.json` into `android/app/`

Enable these products in the Firebase Console:
- **Authentication** → Sign-in method → enable "Anonymous" and "Email/Password"
- **Cloud Firestore** → Create database (start in production mode)
- **Cloud Messaging** → no extra setup needed beyond the default
- **Storage** (optional, for uploading your own food images)

## 4. Deploy Firestore rules & indexes

```bash
npm install -g firebase-tools
firebase login
firebase use --add            # select your project
firebase deploy --only firestore:rules,firestore:indexes
```

The rules (`firestore.rules`) and composite indexes (`firestore.indexes.json`)
are already included at the project root.

## 5. Seed sample data

Two options:

**A. Manual** — copy documents from `sample_data/firestore_sample_data.json`
into the Firebase console (Firestore > Start collection) — simplest for a
quick demo.

**B. Scripted import:**
```bash
cd sample_data
npm install firebase-admin
# Download a service account key (Project Settings > Service accounts)
# and save it here as service-account.json
node import_sample_data.js
```

Then create the chef & admin accounts (Authentication > Add user), copy their
UIDs, and either:
- Manually create matching docs in `users/{uid}` with `role: "chef"` /
  `role: "admin"`, or
- Call `AuthRepository.registerStaff(...)` once from a debug button in-app.

## 6. Enable the QR deep link (Android)

Open `android/app/src/main/AndroidManifest.xml` and add the `<intent-filter>`
block from `android/app/AndroidManifest_deeplink_snippet.xml` inside your
`<activity android:name=".MainActivity">` tag. This makes any QR code
encoding `restaurant://menu?table=1` open the app directly, landing the
customer straight on Table 1's menu — no manual table entry.

For iOS, add a matching URL scheme under
`ios/Runner/Info.plist` → `CFBundleURLTypes` with scheme `restaurant`.

## 7. Generate & print table QR codes

Run the app, log in as Admin → **Generate Table QR Codes**. This renders one
QR code per table (1–4), each encoding `restaurant://menu?table=N`. Screenshot
or print these and place them on the corresponding physical tables.

## 8. Run in development

```bash
flutter run
```

Use the in-app "Simulate Table N" buttons on the role-gate screen to test the
customer flow without physically scanning a code, or scan the generated QR
with a second device.

## 9. Build a release APK

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
```

For an installable per-ABI split (smaller download size):
```bash
flutter build apk --release --split-per-abi
```

For Play Store distribution:
```bash
flutter build appbundle --release
```

> Remember to configure signing (`android/key.properties` +
> `android/app/build.gradle`) before a production release build — the
> default debug signing config is fine for local testing only.

## 10. Cloud Functions for push notifications (recommended, optional)

`NotificationService` stores FCM tokens on the `orders` and `users`
documents. To actually deliver pushes, add a small Cloud Function that
listens for order writes and calls `admin.messaging().send(...)`:

- On `orders/{orderId}` **create** → notify all chef tokens (`role == 'chef'`)
- On `orders/{orderId}` **update** where `status` changed → notify
  `customerFcmToken` on that order

This keeps all push logic server-side and out of client trust boundaries.

## 11. Folder structure recap

```
lib/
  core/        constants, theme, utils, reusable widgets
  models/      plain data classes (User, Table, Category, MenuItem, Order, OrderItem, CartItem)
  services/    Firebase/QR/notification wrappers (no business logic)
  repositories/ data-access layer consumed by ViewModels
  viewmodels/  ChangeNotifier classes (MVVM) — one per screen/flow
  views/       UI screens grouped by module (splash, auth, customer, chef, admin)
```
