# ADR-002
PostgreSQL remains source of truth. Redis cache-aside for search results only, TTL 30 seconds; version increments on successful booking/cancel. Booking never trusts cache. Alternative: no cache (more DB queries), cache as authority (incorrect). Tradeoff: temporary stale search after failures; booking still enforces database rule.
