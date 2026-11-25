import 'domain.dart';

// What BookingService needs: "tell the guest". How the message travels is not its business.
abstract interface class NotificationSender {
  void sendConfirmation(Reservation reservation);
}

// Simulated: counts the emails it would send and needs no network.
class EmailNotificationSender implements NotificationSender {
  int sent = 0;

  @override
  void sendConfirmation(Reservation reservation) => sent++;
}

// Added in Step 7 without changing BookingService. Simulated, like the email sender.
class SmsNotificationSender implements NotificationSender {
  int sent = 0;

  @override
  void sendConfirmation(Reservation reservation) => sent++;
}

