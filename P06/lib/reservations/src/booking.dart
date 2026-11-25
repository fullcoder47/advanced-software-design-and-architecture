import 'package:hotel_booking/notifications/notifications.dart';
import 'package:hotel_booking/rooms/rooms.dart';

import 'domain.dart';

// What BookingService needs from storage. Today a list in memory; from P07 a database.
abstract interface class ReservationStore {
  int get count;

  bool hasOverlap(Room room, DateRange stay);

  void save(Reservation reservation);

  // Returns null when no reservation has that id.
  Reservation? find(String id);

  int countConfirmed(Room room, DateRange stay);
}

class BookingResult {
  BookingResult(this.outcome, [this.reservationId, this.notificationFailed = false]);

  final String outcome;
  final String? reservationId;
  final bool notificationFailed;

  @override
  String toString() => reservationId == null ? outcome : '$outcome $reservationId';
}

// Owns the booking rule. Uses only the public contracts of Rooms and Notifications.
class BookingService {
  BookingService(this.rooms, this.store, this.notifications, {this.slowStep = Duration.zero});

  final List<Room> rooms;
  final ReservationStore store;
  final NotificationSender notifications;
  final Duration slowStep;

  List<Room> findFreeRooms(DateRange stay) =>
      rooms.where((room) => !store.hasOverlap(room, stay)).toList();

  Future<BookingResult> reserve(Guest guest, Room room, DateRange stay) async {
    if (!stay.isValid()) return BookingResult('InvalidDates');
    if (store.hasOverlap(room, stay)) return BookingResult('Unavailable');

    // A pause that lets other requests run while this one waits.
    await Future<void>.delayed(slowStep);

    final reservation = Reservation('R${101 + store.count}', guest, room, stay);
    store.save(reservation);
    try {
      // Notifications gets its own message: the five fields it needs, not the Reservation.
      notifications.sendConfirmation(
          Confirmation(reservation.id, guest.email, room.number, stay.checkIn, stay.checkOut));
    } catch (failure) {
      // R6: the booking is already saved, so a failed message must not undo or hide it.
      return BookingResult('Accepted', reservation.id, true);
    }
    return BookingResult('Accepted', reservation.id);
  }

  bool cancel(String reservationId) => store.find(reservationId)?.cancel() ?? false;
}
