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

// Keeps reservations in a list. P07 adds a PostgreSQL store with the same interface.
class InMemoryReservationStore implements ReservationStore {
  final List<Reservation> _rows = [];

  @override
  int get count => _rows.length;

  @override
  bool hasOverlap(Room room, DateRange stay) => _rows.any((row) => row.blocks(room, stay));

  @override
  void save(Reservation reservation) => _rows.add(reservation);

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
