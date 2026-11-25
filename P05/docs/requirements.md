# Hotel booking requirements

## R1 — Search
List free rooms for requested dates. Check: empty hotel, 12–14 November → R7 and R8.

## R2 — Book
Book a free room and return a reservation ID. Check: Maya books R7 for 12–14 November → Accepted R101.

## R3 — No clash
A room never has two Confirmed bookings for the same night. Check-out must be after check-in.
- Maya R7 12–14 → Accepted.
- Omar R7 13–15 → Unavailable (night 13 overlaps).
- Nora R7 14–16 → Accepted (check-out day excluded).
- R8 already booked 20–22: 22–24 → Accepted; 21–23 → Unavailable (night 21).

## R4 — Cancel
Keep the cancelled record; free its nights. Check: cancel R101 → R7 is free for 12–14.

## R5 — View
Retrieve saved booking by ID. Check: R101 → Maya, R7, 12–14 November, Confirmed.

## R6 — Failed message
A failed confirmation must not undo an accepted saved booking; report the failure.
