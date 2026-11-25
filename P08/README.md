# P08 — Redis cache-aside

Catch-up practice reconstructed from the supplied classroom guide.

## Run

```powershell
docker compose up -d
docker compose exec cache redis-cli ping
dart pub get
dart test
dart run bin/main.dart
```

## Notes
Second terminal: dart run tool/measure.dart. Expected 17 tests. Cache TTL 30 s, version-based invalidation on accepted booking or cancellation.

Runtime measurements and test results must be collected from an actual run; examples are not evidence.
