# P11 — Idempotency and safe retry

Catch-up practice reconstructed from the supplied classroom guide.

## Run

```powershell
dart pub get
dart test
dart run bin/main.dart
```

## Notes
Standalone teaching simulator based on P11 curriculum brief, not an official starter or durable integration. K1 + same payload returns original result; different payload conflicts. Retention bounds protection; deadline, capped exponential backoff, max attempts and correlation ID are included.

Runtime measurements and test results must be collected from an actual run; examples are not evidence.
