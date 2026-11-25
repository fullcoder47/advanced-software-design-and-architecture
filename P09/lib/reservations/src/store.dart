import 'package:hotel_booking/rooms/rooms.dart';

import 'booking.dart';
import 'domain.dart';

// Keeps reservations in a list. P07 adds a PostgreSQL store with the same interface.
class InMemoryReservationStore implements ReservationStore {
  final List<Reservation> _rows = [];
  int _nextId = 101;

  @override
  String nextReservationId() => 'R${_nextId++}';

  @override
  int get count => _rows.length;

  @override
  bool hasOverlap(Room room, DateRange stay) => _rows.any((row) => row.blocks(room, stay));

  @override
  void save(Reservation reservation) {
    if (_rows.any((row) => row.blocks(reservation.room, reservation.stay))) {
      throw OverlapRejected('Overlapping reservation');
    }
    _rows.add(reservation);
  }

  @override
  Reservation? find(String id) {
    for (final row in _rows) {
      if (row.id == id) return row;
    }
    return null;
  }

  @override
  int countConfirmed(Room room, DateRange stay) =>
      _rows.where((row) => row.blocks(room, stay)).length;
}
