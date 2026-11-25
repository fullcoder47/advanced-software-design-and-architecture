// bin/main.dart
// P08 · Hotel booking: the P07 API with a Redis cache for the free-room search.
// dart run bin/main.dart          -> the API on http://localhost:5080 (first: docker compose up -d)
// dart run bin/main.dart --demo   -> the P06 demo, with the data in lists
// dart run bin/main.dart --race   -> two guests book the same room at the same moment
import 'dart:async';
import 'dart:io';

import 'package:hotel_booking/api.dart';
import 'package:hotel_booking/api_cache.dart';
import 'package:hotel_booking/notifications/src/email.dart';
import 'package:hotel_booking/notifications/src/queued.dart';
import 'package:hotel_booking/reservations/reservations.dart';
import 'package:hotel_booking/reservations/src/postgres_store.dart';
import 'package:hotel_booking/reservations/src/store.dart';
import 'package:hotel_booking/rooms/rooms.dart';
import 'package:hotel_booking/rooms/src/catalog.dart';
import 'package:hotel_booking/rooms/src/postgres_catalog.dart';
import 'package:postgres/postgres.dart' show Endpoint, Pool, PoolSettings, SslMode;
import 'package:redis/redis.dart' show RedisConnection;
import 'package:shelf/shelf_io.dart';

final r7 = Room('R7', 'Standard');
final r8 = Room('R8', 'Deluxe');
final maya = Guest('Maya', 'maya@example.com');
final omar = Guest('Omar', 'omar@example.com');
final nora = Guest('Nora', 'nora@example.com');

// The wiring: the only app code that imports the src/ files of the modules.
final catalog = InMemoryRoomCatalog([r7, r8]);

DateRange nov(int checkIn, int checkOut) =>
    DateRange(DateTime.utc(2026, 11, checkIn), DateTime.utc(2026, 11, checkOut));

String names(List<Room> rooms) => rooms.map((room) => room.number).join(', ');

// Dart prints booleans as true/false; the course output says True, so the demo spells it out.
String boolText(bool value) => value ? 'True' : 'False';

Future<void> main(List<String> args) async {
  if (args.contains('--race')) {
    await runRace();
  } else if (args.contains('--demo')) {
    await runDemo();
  } else {
    await runApi();
  }
}

Future<void> runApi() async {
  // The wiring for the web app: PostgreSQL and Redis from docker-compose.yml
  // (HOTEL_DB_PORT and HOTEL_REDIS_PORT only if 5432 or 6379 is taken).
  final port = int.parse(Platform.environment['HOTEL_DB_PORT'] ?? '5432');
  final pool = Pool.withEndpoints([
    Endpoint(host: 'localhost', port: port, database: 'hotel', username: 'hotel', password: 'hotel')
  ], settings: PoolSettings(sslMode: SslMode.disable));
  final rooms = await PostgresRoomCatalog(pool).all();
  // P10: the mail server is slow, and the booking no longer waits for it. HOTEL_EMAIL_SECONDS
  // makes the sender as slow as a real one; the queue is what keeps that out of the request.
  final email = EmailNotificationSender(
      sendSeconds: double.parse(Platform.environment['HOTEL_EMAIL_SECONDS'] ?? '0'));
  final notifications = QueuedNotificationSender(
    email,
    capacity: int.parse(Platform.environment['HOTEL_QUEUE_CAPACITY'] ?? '10'),
    workers: int.parse(Platform.environment['HOTEL_WORKERS'] ?? '1'),
  );
  final stats = Stats();
  final redisPort = int.parse(Platform.environment['HOTEL_REDIS_PORT'] ?? '6379');
  // One connection for the whole app; connecting stops here if Redis is not running.
  final redis = await RedisConnection().connect('localhost', redisPort);
  final cache = AvailabilityCache(RedisKeyValueStore(redis));
  // Step 1 widens the gap between the check and the save, so the race happens on every run.
  final slowStep =
      Duration(milliseconds: (double.parse(Platform.environment['HOTEL_SLOW_STEP'] ?? '0') * 1000).round());

  // One request: a fresh store, counted for GET /stats; save what changed at the end.
  Future<T> unitOfWork<T>(FutureOr<T> Function(BookingService service) work) async {
    final store = PostgresReservationStore(pool, rooms);
    final result = await work(
        BookingService(rooms, CountingReservationStore(store, stats), notifications, slowStep: slowStep));
    await store.saveChanges();
    return result;
  }

  // Step 4 starts a second instance with HOTEL_PORT=5081, against the same database.
  final apiPort = int.parse(Platform.environment['HOTEL_PORT'] ?? '5080');
  // P10 Step 6: drain the queue before the worker stops, so a polite shutdown owes nobody an
  // email. Nothing here helps with a killed process: see docs/queue-trace.md.
  ProcessSignal.sigint.watch().listen((_) async {
    print('Draining the notification queue...');
    await notifications.close(drain: true);
    final left = notifications.counts();
    print('Notification worker stopped. accepted=${left.accepted} completed=${left.completed} queued=${left.queued}');
    exit(0);
  });

  await serve(
      createApi(rooms, unitOfWork, stats, cache, notificationCounts: notifications.counts),
      'localhost', apiPort);
  print('Listening on http://localhost:$apiPort');
}

Future<void> runDemo() async {
  final store = InMemoryReservationStore();
  final email = EmailNotificationSender();
  final service = BookingService(catalog.all(), store, email);

  print('Free rooms 12-14 Nov: ${names(await service.findFreeRooms(nov(12, 14)))}');
  print('Maya books R7 12-14 Nov: ${await service.reserve(maya, r7, nov(12, 14))}');
  print('Omar books R7 13-15 Nov: ${await service.reserve(omar, r7, nov(13, 15))}');
  print('Nora books R7 14-16 Nov: ${await service.reserve(nora, r7, nov(14, 16))}');
  print('Omar books R8 15-15 Nov: ${await service.reserve(omar, r8, nov(15, 15))}');
  print('Free rooms 12-14 Nov: ${names(await service.findFreeRooms(nov(12, 14)))}');
  print('Maya cancels R101: ${boolText(await service.cancel('R101'))}');
  print('Free rooms 12-14 Nov: ${names(await service.findFreeRooms(nov(12, 14)))}');
  print('Confirmation emails sent: ${email.sent}');
}

Future<void> runRace() async {
  final store = InMemoryReservationStore();
  // Each request now spends half a second between checking and saving.
  final service = BookingService(
    catalog.all(),
    store,
    EmailNotificationSender(),
    slowStep: const Duration(milliseconds: 500),
  );
  final stay = nov(12, 14);

  print('Maya and Omar both book R7 for 12-14 Nov at the same moment...');
  final mayaRequest = service.reserve(maya, r7, stay);
  // Omar clicks a moment after Maya
  await Future<void>.delayed(const Duration(milliseconds: 100));
  final omarRequest = service.reserve(omar, r7, stay);
  final results = await Future.wait([mayaRequest, omarRequest]);

  print('Maya: ${results[0]}');
  print('Omar: ${results[1]}');
  final confirmed = store.countConfirmed(r7, stay);
  print('Confirmed reservations for R7 on 12-14 Nov: $confirmed');
  print(
    confirmed > 1
        ? 'Double booking! Both requests checked before either one saved.'
        : 'Only one guest has R7.',
  );
}
