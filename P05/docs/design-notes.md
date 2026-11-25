# P03 design notes
The guests and receptionist use the same store. Date range is half-open [check-in, check-out). Both checks can run before either write: the demo deliberately exposes double booking. P09 enforces the invariant at the storage layer.

P04: SRP separates storage, booking and notifications. OCP allows SMS without changing BookingService. LSP allows substitutes that keep the contract. ISP keeps interfaces narrow. DIP depends on abstractions. Refactoring preserves the six original behaviours and adds two tests.
