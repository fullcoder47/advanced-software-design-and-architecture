import 'package:hotel_booking/idempotency.dart';
import 'package:test/test.dart';
void main() {
  test('lost response replays the committed result', () async {
    final s = BookingSimulator();
    expect(await retry(s, 'K1', 'stay', correlationId: 'trace', loseFirstResponse: true), 'R101');
    expect(s.bookings, 1);
  });
  test('same key different payload rejected', () async {
    final s = BookingSimulator();
    await s.book('K1', 'stay');
    await expectLater(s.book('K1', 'different'), throwsA(isA<KeyConflict>()));
    expect(s.bookings, 1);
  });
  test('concurrent repeat shares result', () async {
    final s = BookingSimulator();
    expect(await Future.wait([s.book('K1', 'stay'), s.book('K1', 'stay')]), ['R101', 'R101']);
    expect(s.bookings, 1);
  });
  test('expiry bounds replay protection', () async {
    var now = DateTime.utc(2026);
    final s = BookingSimulator(retention: const Duration(seconds: 1), clock: () => now);
    await s.book('K1', 'stay');
    now = now.add(const Duration(seconds: 2));
    expect(await s.book('K1', 'stay'), 'R102');
  });
}
