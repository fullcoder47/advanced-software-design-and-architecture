import '../notifications.dart';

// Added in Step 7 without changing BookingService. Simulated, like the email sender.
class SmsNotificationSender implements NotificationSender {
  int sent = 0;

  @override
  void sendConfirmation(Confirmation confirmation) => sent++;
}

