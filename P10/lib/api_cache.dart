// lib/api_cache.dart
/// The cache for the free-room search (P08): cache-aside in Redis, with a TTL and a version.
///
/// PostgreSQL is the source of truth. Redis keeps copies of search answers for 30 seconds.
/// Booking and cancelling never read the cache.
library;

import 'package:redis/redis.dart' show Command;

const ttlSeconds = 30;
const versionKey = 'availability:version';

// The three Redis commands the cache uses: GET, SET with a time to live, and INCR.
abstract interface class KeyValueStore {
  // Returns null when the key is missing.
  Future<String?> get(String key);

  Future<void> set(String key, String value, int ttlSeconds);

  Future<void> increment(String key);
}

// The three commands, sent to Redis over one open connection.
class RedisKeyValueStore implements KeyValueStore {
  RedisKeyValueStore(this._redis);

  final Command _redis;

  // Redis answers GET with the text, or with null when the key is missing.
  @override
  Future<String?> get(String key) async => await _redis.send_object(['GET', key]) as String?;

  @override
  Future<void> set(String key, String value, int ttlSeconds) =>
      _redis.send_object(['SET', key, value, 'EX', '$ttlSeconds']);

  @override
  Future<void> increment(String key) => _redis.send_object(['INCR', key]);
}

// Copies of search answers: the free room numbers for one stay, such as "R7,R8".
class AvailabilityCache {
  AvailabilityCache(this._store);

  final KeyValueStore _store;

  Future<String> key(String checkIn, String checkOut) async {
    // The version is part of the key, so raising it makes every older copy unreachable.
    final version = await _store.get(versionKey) ?? '0';
    return 'availability:v$version:$checkIn:$checkOut';
  }

  Future<String?> get(String key) => _store.get(key);

  Future<void> set(String key, String roomNumbers) => _store.set(key, roomNumbers, ttlSeconds);

  // A booking or a cancellation changed what is free: every cached search is now out of date.
  Future<void> invalidate() => _store.increment(versionKey);
}
