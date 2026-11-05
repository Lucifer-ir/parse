# Parseh Language Academy

A mobile-first Flutter welcome screen based on the supplied Parseh reference UI.

## Run

```bash
flutter pub get
flutter run -d chrome
flutter run -d <android-device>
```

The layout keeps a mobile canvas on the web with a `480px` maximum width, so both targets share the same visual composition. The buttons currently show a local placeholder message; no backend or navigation is connected yet.

## Structure

- `lib/main.dart` — app shell, welcome screen, responsive layout, animated mascot and actions.
- `assets/fonts/Tahoma.ttf` — bundled font asset for consistent Persian rendering.
