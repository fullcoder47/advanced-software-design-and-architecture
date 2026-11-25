# P10 — Bounded notification queue

Catch-up practice reconstructed from the supplied classroom guide.

## Run

```powershell
docker compose up -d
dart pub get
dart test
$env:HOTEL_EMAIL_SECONDS = "1"
dart run bin/main.dart
```

## Notes
Second terminal: dart run tool/burst.dart; inspect GET /stats. Expected 22 checks. Queue capacity 10 by default; rejected confirmations do not reject bookings. Graceful shutdown drains queue; process crash loses memory jobs.

Runtime measurements and test results must be collected from an actual run; examples are not evidence.
