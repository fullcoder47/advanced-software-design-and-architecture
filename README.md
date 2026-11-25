# Advanced Software Design and Architecture

PDP University P01–P11 catch-up study repository. Course Dart example code reconstructed from supplied materials, with P02 Python and a P11 Dart simulation. This is catch-up work, not evidence of attendance or past submissions. Runtime results are not claimed unless actually observed.

| Practice | Topic | Run |
|---|---|---|
| [P01](P01) | Design baseline | Read docs |
| [P02](P02) | OS processes | `python starter/parent.py` |
| [P03](P03) | UML and in-memory hotel | `dart run bin/hotel_booking.dart` |
| [P04](P04) | SOLID/refactoring | `dart test` |
| [P05](P05) | DDD contexts | `dart test` and docs |
| [P06](P06) | Modular monolith | `dart test` |
| [P07](P07) | HTTP/PostgreSQL | `docker compose up -d`, `dart run bin/main.dart` |
| [P08](P08) | Redis | Same; `dart run tool/measure.dart` |
| [P09](P09) | Concurrency | Same; `dart run tool/race_http.dart` |
| [P10](P10) | Bounded queue | Same; `dart run tool/burst.dart` |
| [P11](P11) | Idempotency | `dart test`, `dart run bin/main.dart` |

Each Dart directory is an independent snapshot. Run `dart pub get` from it before running tests. Stop Docker services before switching snapshots because they use the same ports. Use each practice's own compose project/database, do not remove existing data without checking. See MIDTERM.md and TEST_ALL.ps1.

Verification: Python syntax/smoke test can be performed locally; Dart and Docker require SDK/runtime. GitHub Actions configuration is provided for Dart unit tests. PostgreSQL and Redis live integration checks remain manual.
