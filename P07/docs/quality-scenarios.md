# Quality scenarios — course targets

Stakeholders: guest, receptionist, hotel manager, development team, payment and messaging providers. Targets are not observed results.

| ID | Source / stimulus / environment | Artifact | Response and measurable target | Checked in |
|---|---|---|---|---|
| S1 | 200 guests search within 1 minute | Availability search | Correct results, p95 ≤ 1 second | P08/P23 |
| S2 | 100 pairs book the same room/night concurrently | Reservation store | Exactly one confirmed per pair; 0 double bookings | P09 |
| S3 | Email provider down for 10 minutes | BookingService and sender | Every valid booking saved, 0 lost; failed messages reported | P04/P10 |
| S4 | Guest makes 100 attempts to read another guest's booking | Reservation access | 0 unauthorized disclosures | P21 |
| S5 | Hotel adds SMS | Notification sender | BookingService unchanged; at most 2 files change | P04 |
| S6 | Same 1,000 searches before and after change | Search/cache | At least 20% fewer watt-hours per 1,000 completed searches | P08/P24 |
