# Bounded contexts
| Context | Owns | Contract |
|---|---|---|
| Rooms | room number, type, sellable catalogue | RoomCatalog |
| Reservations | guest, stay, overlap, booking, cancellation | BookingService |
| Payments | deposit, paid/declined, refund policy | PaymentService |
| Notifications | confirmation, delivery, failure | NotificationSender |

Same word, different meaning: Room means sellable inventory in Rooms and room reference in Reservations; Cancel means release nights in Reservations and may require refund in Payments; Confirmed is not Paid or Sent.

Rule ownership: room catalogue and out-of-service status → Rooms; one guest per room/night, valid dates, cancel and lookup → Reservations; positive deposits and refunds → Payments; sending confirmation → Notifications. R6 keeps booking accepted even if notification fails.

Borders: Reservations asks Rooms for catalogue; Reservations requests payment using reservation ID and amount; Reservations sends ReservationConfirmed with reservationId, guestEmail, roomNumber, checkIn, checkOut to Notifications. Notifications never imports the Reservation class.
