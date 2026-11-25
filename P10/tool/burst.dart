// tool/burst.dart
// Sends a burst of bookings as fast as it can, then reads GET /stats.
// 
// Every booking is for a different room and night - R7 and R8, one night each, 1 to 15 December - so
// all 30 are legal under P09's exclusion constraint and nothing is refused by the booking rule.
// Whatever is refused here was refused by the notification queue, which is the thing being measured.
// 
// Start the app with HOTEL_EMAIL_SECONDS=1 first, so the confirmation sender is as slow as a real
// mail server.
//
//   dart run tool/burst.dart
import 'dart:convert';
import 'dart:io';

const base = 'http://localhost:5080';
const burst = 30;

Future<void> main() async {
  final client = HttpClient();
  print('Sending $burst bookings, one after another...');
  print('');

  var accepted = 0;
  var rejected = 0;
  var slowest = 0;
  final started = DateTime.now();
  for (var index = 0; index < burst; index++) {
    final night = 1 + index ~/ 2;
    final room = index % 2 == 0 ? 'R7' : 'R8';
    final body = {
      'guestName': 'Guest$night$room',
      'guestEmail': 'guest$night$room@example.com',
      'room': room,
      'checkIn': '2026-12-${night.toString().padLeft(2, '0')}',
      'checkOut': '2026-12-${(night + 1).toString().padLeft(2, '0')}',
    };
    final one = DateTime.now();
    final request = await client.postUrl(Uri.parse('$base/reservations'));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close();
    await response.drain<void>();
    final elapsed = DateTime.now().difference(one).inMilliseconds;
    if (elapsed > slowest) slowest = elapsed;
    if (response.statusCode == 201) {
      accepted++;
    } else {
      rejected++;
    }
  }
  final total = DateTime.now().difference(started).inMilliseconds / 1000;

  print('Accepted: $accepted');
  print('Rejected: $rejected');
  print('Slowest booking: $slowest ms');
  print('Total: ${total.toStringAsFixed(1)} s');
  print('');
  print('GET /stats');
  final stats = await (await client.getUrl(Uri.parse('$base/stats'))).close();
  print(await stats.transform(utf8.decoder).join());
  client.close();
}
