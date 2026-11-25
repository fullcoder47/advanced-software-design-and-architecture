import 'package:hotel_booking/idempotency.dart';
Future<void> main() async {
  final server = BookingSimulator();
  final id = await retry(server, 'K1', 'R7:2026-12-01:2026-12-02',
      correlationId: 'trace-1', loseFirstResponse: true);
  print('Recovered booking: $id; committed bookings: ${server.bookings}');
  try { await server.book('K1', 'different payload'); }
  on KeyConflict { print('409: key reused with different payload'); }
}
