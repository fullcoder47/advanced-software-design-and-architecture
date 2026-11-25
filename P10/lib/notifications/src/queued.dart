// lib/notifications/src/queued.dart
import 'dart:async';
import 'dart:collection';

import '../notifications.dart';

// Takes confirmations off the request and gives them to a background worker.
//
// It keeps the NotificationSender promise, so BookingService cannot tell the difference: the
// booking hands over a Confirmation and carries on. What changes is when the email is sent, and
// what happens when there are more of them than the worker can keep up with.
//
// The queue is bounded. When it is full a confirmation is refused and counted rather than waited
// for, because making the booking wait is the thing this class exists to stop. A refused
// confirmation is not a failed booking - the room is already the guest's - but it is not free
// either, and the rejected counter is what makes that cost visible instead of invisible.
//
// No locks anywhere, and none are needed: Dart runs one request's code at a time on this isolate,
// so adding to the queue and reading its length cannot be interleaved with anything.
class QueuedNotificationSender implements CountingNotificationSender {
  QueuedNotificationSender(this._sender, {int capacity = 10, int workers = 1})
      : _capacity = capacity {
    if (capacity < 1 || workers < 1) throw ArgumentError("capacity and workers must be positive");
    _workers = List.generate(workers, (_) => _drain());
  }

  final NotificationSender _sender;
  final int _capacity;
  final Queue<Confirmation> _jobs = Queue<Confirmation>();
  late final List<Future<void>> _workers;
  int _accepted = 0;
  int _rejected = 0;
  int _completed = 0;
  bool _stopping = false;

  // Never waits and never throws: the whole point is that the booking is not held up.
  @override
  void sendConfirmation(Confirmation confirmation) {
    if (_stopping || _jobs.length >= _capacity) {
      _rejected++;
      return;
    }
    _jobs.add(confirmation);
    _accepted++;
  }

  @override
  NotificationCounts counts() =>
      NotificationCounts(_accepted, _rejected, _completed, _jobs.length);

  /// Stop the workers. With drain the queue is emptied first, so a polite shutdown owes nobody an
  /// email; without it, whatever is still queued dies with the process.
  Future<void> close({bool drain = true}) async {
    if (drain) {
      while (_jobs.isNotEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    }
    _stopping = true;
    await Future.wait(_workers);
  }

  Future<void> _drain() async {
    while (!_stopping) {
      if (_jobs.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        continue;
      }
      final confirmation = _jobs.removeFirst();
      try {
        await _sender.sendConfirmation(confirmation);
        _completed++;
      } catch (failure) {
        // A confirmation that could not be sent is lost, and saying so is the point: it stays
        // counted as accepted but never completed, so accepted != completed + queued, which is
        // exactly the signal that work went missing.
      }
    }
  }
}
