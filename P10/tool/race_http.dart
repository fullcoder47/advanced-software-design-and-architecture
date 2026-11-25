// tool/race_http.dart
// Sends two POST /reservations for the same room and the same nights at the same moment, and prints
// what each one got back and how many confirmed reservations the room ended up with.
//
//   dart run tool/race_http.dart                          both requests to http://localhost:5080
//   dart run tool/race_http.dart http://localhost:5081    Omar's request to the second instance
//
// Start the app with HOTEL_SLOW_STEP=1 first. Without it the gap between the check and the save is
// too small to land in reliably, and the race shows up only now and then.
//
// Maya's request goes first and Omar's 500 ms later, so the two reach the gap together and leave it
// in a known order. That is what makes the output the same on every run; it is not what makes the
// bug possible. The bug is possible because checking and saving are two separate statements.
//
// A warm-up request is sent before the two bookings. The very first request to a freshly started
// app pays for connection pools, servlet initialisation and JIT, which can cost more than the
// head start Maya is given - and then Omar wins instead and the output comes out the other way
// round. The warm-up cannot reach the booking path itself, though - GET /stats never inserts - so
// Maya's request is still the first to compile the insert, which measured as much as 140 ms more
// than Omar's. Half a second of head start covers that and leaves both requests inside the gap.
import 'dart:convert';
import 'dart:io';

const maya = {
  'guestName': 'Maya',
  'guestEmail': 'maya@example.com',
  'room': 'R7',
  'checkIn': '2026-11-12',
  'checkOut': '2026-11-14'
};
const omar = {
  'guestName': 'Omar',
  'guestEmail': 'omar@example.com',
  'room': 'R7',
  'checkIn': '2026-11-12',
  'checkOut': '2026-11-14'
};
const reasons = {201: '201 Created   ', 409: '409 Conflict  ', 400: '400 Bad Request  '};

Future<String> book(HttpClient client, String base, Map<String, String> body) async {
  final request = await client.postUrl(Uri.parse('$base/reservations'));
  request.headers.contentType = ContentType.json;
  request.write(jsonEncode(body));
  final response = await request.close();
  final text = await response.transform(utf8.decoder).join();
  return '${reasons[response.statusCode] ?? '${response.statusCode}  '}$text';
}

Future<void> main(List<String> args) async {
  const mayaBase = 'http://localhost:5080';
  final omarBase = args.isNotEmpty ? args[0] : mayaBase;
  final client = HttpClient();

  // The warm-up: see the note at the top.
  final warmUp = await (await client.getUrl(Uri.parse('$mayaBase/stats'))).close();
  await warmUp.drain<void>();

  print('Two bookings for R7, 2026-11-12 to 2026-11-14, sent at the same moment.');
  if (omarBase != mayaBase) print('Maya -> $mayaBase   Omar -> $omarBase');
  print('');

  // Both requests are started before either is awaited: that is what "at the same moment" means.
  final mayaRequest = book(client, mayaBase, maya);
  final omarRequest = Future<void>.delayed(const Duration(milliseconds: 500))
      .then((_) => book(client, omarBase, omar)); // Omar clicks a moment after Maya
  final answers = await Future.wait([mayaRequest, omarRequest]);
  client.close();

  print('Maya -> ${answers[0]}');
  print('Omar -> ${answers[1]}');
  print('');

  final accepted = answers.where((answer) => answer.startsWith('201')).length;
  print('Confirmed reservations for R7 on 12-14 Nov: $accepted');
  print(accepted > 1
      ? 'DOUBLE BOOKED: the room has two confirmed reservations for the same nights.'
      : 'CORRECT: one booking was accepted and one was refused.');
}
