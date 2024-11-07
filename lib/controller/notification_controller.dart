import 'package:get/get.dart';

class NotificationController extends GetxController {
  var notifications = {
    'Fajr': false,
    'Sunrise': false,
    'Zuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  }.obs;

  void toggleNotification(String prayerName, bool value) {
    notifications[prayerName] = value;
    // Save to persistent storage if needed
  }
}
