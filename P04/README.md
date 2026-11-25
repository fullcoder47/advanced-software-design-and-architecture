# P04 — SOLID and refactoring

Catch-up practice reconstructed from the supplied classroom guide.

## Run

```powershell
dart pub get
dart test
dart run bin/main.dart --demo
dart run bin/main.dart --race
```

## Notes
Expected 8 behaviour tests. Dependency inversion: BookingService depends on store and sender interfaces; fake sender checks R6. Race is still deliberately present.

Runtime measurements and test results must be collected from an actual run; examples are not evidence.
