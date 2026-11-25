// lib/notifications/notifications.dart
/// Notifications: telling guests what happened. This file is the module's public contract.
library;

import 'dart:async';

/// Notifications' own message: it no longer needs the Reservation class.
class Confirmation {
  const Confirmation(this.reservationId, this.guestEmail, this.roomNumber, this.checkIn, this.checkOut);

  final String reservationId;
  final String guestEmail;
  final String roomNumber;
  final DateTime checkIn;
  final DateTime checkOut;
}

/// What a queued sender has promised, refused, finished and still owes.
///
/// Once nothing is in flight, accepted == completed + queued. If that ever stops holding, work has
/// been lost somewhere, and these four numbers are the only place it would show.
class NotificationCounts {
  const NotificationCounts(this.accepted, this.rejected, this.completed, this.queued);

  final int accepted;
  final int rejected;
  final int completed;
  final int queued;
}

// Notifications' public contract: "tell the guest". How the message travels is its own business,
// and it may answer with a Future - BookingService awaits it.
abstract interface class NotificationSender {
  FutureOr<void> sendConfirmation(Confirmation confirmation);
}

/// A sender that also publishes its counters, so the Api can read them without importing
/// Notifications' internal code and the module boundary of L03 still holds.
abstract interface class CountingNotificationSender implements NotificationSender {
  NotificationCounts counts();
}
