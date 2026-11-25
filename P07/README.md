# P07 — HTTP API and PostgreSQL

Catch-up practice reconstructed from the supplied classroom guide.

## Run

```powershell
docker compose up -d
docker compose exec db pg_isready -U hotel
dart pub get
dart test
dart run bin/main.dart
```

## Notes
API listens on localhost:5080. GET /rooms/availability?checkIn=2026-11-12&checkOut=2026-11-14; POST /reservations; DELETE /reservations/R101; GET /openapi.yaml. Expected 15 checks. Stop with Ctrl+C; docker compose down retains data.

Runtime measurements and test results must be collected from an actual run; examples are not evidence.
