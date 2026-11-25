// lib/notifications/src/email.dart
import '../notifications.dart';

// Simulated: counts the emails it would send and needs no network.
//
// sendSeconds makes it as slow as a real mail server. P10 Step 1 turns it up to one second, which
// is how a booking that does well under a millisecond of work becomes a one-second request.
class EmailNotificationSender implements NotificationSender {
  EmailNotificationSender({this.sendSeconds = 0});

  final double sendSeconds;
  int sent = 0;

  @override
  Future<void> sendConfirmation(Confirmation confirmation) async {
    if (sendSeconds > 0) {
      await Future<void>.delayed(Duration(milliseconds: (sendSeconds * 1000).round()));
    }
    sent++;
  }
}
