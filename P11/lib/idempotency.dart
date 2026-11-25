import 'dart:async';

class KeyConflict implements Exception {}
class LostResponse implements Exception {}

class _Entry {
  _Entry(this.payload, this.result, this.expires);
  final String payload;
  final Future<String> result;
  final DateTime expires;
}

/// In-memory teaching simulator; production requires transactional durable storage.
class BookingSimulator {
  BookingSimulator({this.retention = const Duration(hours: 24), DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;
  final Duration retention;
  final DateTime Function() _clock;
  final Map<String, _Entry> _keys = {};
  int bookings = 0;

  Future<String> book(String key, String payload, {bool loseResponse = false}) async {
    if (key.isEmpty || payload.isEmpty) throw ArgumentError('Key and payload are required');
    final now = _clock();
    _keys.removeWhere((_, value) => !now.isBefore(value.expires));
    final old = _keys[key];
    if (old != null) {
      if (old.payload != payload) throw KeyConflict();
      return old.result;
    }
    final id = 'R${101 + bookings++}';
    final result = Future.value(id);
    _keys[key] = _Entry(payload, result, now.add(retention));
    if (loseResponse) throw LostResponse();
    return result;
  }
}

Future<String> retry(BookingSimulator server, String key, String payload,
    {required String correlationId, int maxAttempts = 3,
    Duration deadline = const Duration(seconds: 2),
    Duration initialDelay = const Duration(milliseconds: 20),
    bool loseFirstResponse = false}) async {
  if (maxAttempts < 1 || correlationId.isEmpty) throw ArgumentError('Invalid retry policy');
  final watch = Stopwatch()..start();
  for (var i = 0; i < maxAttempts; i++) {
    final remaining = deadline - watch.elapsed;
    if (remaining <= Duration.zero) throw TimeoutException('Deadline exceeded: $correlationId');
    try {
      return await server.book(key, payload, loseResponse: loseFirstResponse && i == 0).timeout(remaining);
    } on LostResponse {
      if (i == maxAttempts - 1) rethrow;
    } on TimeoutException {
      if (i == maxAttempts - 1) rethrow;
    }
    final wait = initialDelay * (1 << i);
    final capped = wait > const Duration(milliseconds: 250) ? const Duration(milliseconds: 250) : wait;
    if (watch.elapsed + capped >= deadline) throw TimeoutException('Deadline exceeded: $correlationId');
    await Future<void>.delayed(capped);
  }
  throw StateError('Unreachable');
}
