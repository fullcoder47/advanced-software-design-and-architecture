// lib/api.dart
/// The HTTP API: three endpoints that turn HTTP requests into BookingService calls and back.
/// It lives outside the four modules and uses only their public contracts. bin/main.dart decides
/// which store the endpoints use, through the unit of work.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'reservations/reservations.dart';
import 'rooms/rooms.dart';

/// Runs one request's work with a BookingService, then saves whatever changed.
typedef UnitOfWork = Future<T> Function<T>(FutureOr<T> Function(BookingService service) work);

const fields = ['guestName', 'guestEmail', 'room', 'checkIn', 'checkOut'];
const bodyDetail = 'The body must be JSON with guestName, guestEmail, room, checkIn and checkOut.';
const dateDetail = 'checkIn and checkOut must be dates such as 2026-11-12.';

Response json(int status, Object? body) =>
    Response(status, body: jsonEncode(body), headers: {'content-type': 'application/json'});

// Problem details (RFC 9457): every error has the same three keys.
Response problem(int status, String title, String detail) => Response(status,
    body: jsonEncode({'title': title, 'status': status, 'detail': detail}),
    headers: {'content-type': 'application/problem+json'});

// A date written exactly like 2026-11-12, otherwise null.
DateTime? parseDate(Object? text) {
  if (text is! String || !RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$').hasMatch(text)) return null;
  final day = DateTime.tryParse('${text}T00:00:00Z');
  return day != null && day.toIso8601String().startsWith(text) ? day : null;
}

// Turns a booking answer into an HTTP status code and a JSON body (L04).
Response toHttp(BookingResult result) {
  if (result.outcome == 'Accepted') {
    return json(201, {
      'id': result.reservationId,
      'status': 'Confirmed',
      'notificationFailed': result.notificationFailed
    });
  }
  if (result.outcome == 'Unavailable') {
    return problem(409, 'Unavailable', 'The room is booked for at least one night of this stay.');
  }
  return problem(400, 'InvalidDates', 'checkOut must be after checkIn.');
}

Handler createApi(List<Room> rooms, UnitOfWork unitOfWork) {
  final router = Router();

  router.get('/openapi.yaml', (Request request) {
    return Response.ok(File('docs/openapi.yaml').readAsStringSync(),
        headers: {'content-type': 'application/yaml'});
  });

  router.get('/rooms/availability', (Request request) async {
    final query = request.url.queryParameters;
    final checkIn = parseDate(query['checkIn']);
    final checkOut = parseDate(query['checkOut']);
    if (checkIn == null || checkOut == null) return problem(400, 'InvalidDates', dateDetail);
    final stay = DateRange(checkIn, checkOut);
    if (!stay.isValid()) return problem(400, 'InvalidDates', 'checkOut must be after checkIn.');
    final limitText = query['limit'] ?? '20';
    final limit = int.tryParse(limitText) ?? 0;
    if (!RegExp(r'^[0-9]{1,3}$').hasMatch(limitText) || limit < 1 || limit > 100) {
      return problem(400, 'InvalidRequest', 'limit must be a whole number from 1 to 100.');
    }

    final free = await unitOfWork((service) => service.findFreeRooms(stay));
    // Cursor pagination (L04): the rooms after the last one the client has seen, in text order.
    final after = query['after'] ?? '';
    final rest = free.where((room) => room.number.compareTo(after) > 0).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
    final page = rest.take(limit).toList();
    return json(200, {
      'checkIn': query['checkIn'],
      'checkOut': query['checkOut'],
      'rooms': [
        for (final room in page) {'number': room.number, 'type': room.type}
      ],
      'next': rest.length > page.length ? page.last.number : null,
    });
  });

  router.post('/reservations', (Request request) async {
    if (request.mimeType != 'application/json') return problem(400, 'InvalidRequest', bodyDetail);
    Object? json;
    try {
      json = jsonDecode(await request.readAsString());
    } on FormatException {
      return problem(400, 'InvalidRequest', bodyDetail);
    }
    final body = json is Map ? json : const {};
    if (!fields.every((field) => body[field] is String && body[field] != '')) {
      return problem(400, 'InvalidRequest', bodyDetail);
    }
    final checkIn = parseDate(body['checkIn']);
    final checkOut = parseDate(body['checkOut']);
    if (checkIn == null || checkOut == null) return problem(400, 'InvalidDates', dateDetail);
    final room = rooms.where((room) => room.number == body['room']).firstOrNull;
    if (room == null) return problem(400, 'UnknownRoom', 'There is no room ${body['room']}.');

    final guest = Guest(body['guestName'] as String, body['guestEmail'] as String);
    final result =
        await unitOfWork((service) => service.reserve(guest, room, DateRange(checkIn, checkOut)));
    return toHttp(result);
  });

  router.delete('/reservations/<id>', (Request request, String id) async {
    final cancelled = await unitOfWork((service) => service.cancel(id));
    if (!cancelled) return problem(404, 'NotFound', 'There is no confirmed reservation $id.');
    return Response(204);
  });

  return router.call;
}
