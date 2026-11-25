# P09 — Concurrency and exclusion constraint

Catch-up practice reconstructed from the supplied classroom guide.

## Run

```powershell
docker compose up -d
dart pub get
dart test
dart run bin/main.dart --race
```

## Notes
Expected 19 checks. One accepted, one unavailable. For HTTP race: start server with HOTEL_SLOW_STEP=1 and run dart run tool/race_http.dart in second terminal. Use a fresh P09 database; do not reuse an older schema. PostgreSQL sequence allocates IDs and GiST exclusion constraint rejects overlaps even across instances.

Runtime measurements and test results must be collected from an actual run; examples are not evidence.
