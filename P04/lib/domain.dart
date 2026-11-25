// The stay: check-in day included, check-out day excluded (half-open).
class DateRange {
  DateRange(this.checkIn, this.checkOut);

  final DateTime checkIn;
  final DateTime checkOut;

  bool isValid() => checkOut.isAfter(checkIn);

  // Two stays overlap when they share at least one night.
  bool overlaps(DateRange other) =>
      checkIn.isBefore(other.checkOut) && other.checkIn.isBefore(checkOut);
}

class Guest {
  Guest(this.name, this.email);

  final String name;
  final String email;
}

class Room {
  Room(this.number, this.type);

  final String number;
  final String type;

  // Dart compares objects by identity until a class says what equal means.
  @override
  bool operator ==(Object other) => other is Room && other.number == number && other.type == type;

  @override
  int get hashCode => Object.hash(number, type);
}

enum ReservationStatus { confirmed, cancelled }

class Reservation {
  Reservation(this.id, this.guest, this.room, this.stay);

  final String id;
  final Guest guest;
  final Room room;
  final DateRange stay;
  ReservationStatus status = ReservationStatus.confirmed;

  // A reservation blocks a request when it is still Confirmed for the same room and shares a night.
  bool blocks(Room room, DateRange stay) =>
      status == ReservationStatus.confirmed && this.room == room && this.stay.overlaps(stay);

  bool cancel() {
    if (status == ReservationStatus.cancelled) return false;
    status = ReservationStatus.cancelled;
    return true;
  }
}
