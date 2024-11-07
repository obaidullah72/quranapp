import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../common/constants.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  Location location = Location();
  LocationData? _currentPosition;
  double? latitude, longitude;

  Map<String, bool> notifications = {
    'Fajr': false,
    'Sunrise': false,
    'Zuhr': false,
    'Asr': false,
    'Maghrib': false,
    'Isha': false,
  };

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadNotificationStates();
  }
  Future<void> _loadNotificationStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notifications['Fajr'] = prefs.getBool('Fajr') ?? false;
      notifications['Sunrise'] = prefs.getBool('Sunrise') ?? false;
      notifications['Zuhr'] = prefs.getBool('Zuhr') ?? false;
      notifications['Asr'] = prefs.getBool('Asr') ?? false;
      notifications['Maghrib'] = prefs.getBool('Maghrib') ?? false;
      notifications['Isha'] = prefs.getBool('Isha') ?? false;
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff1B202D),
          centerTitle: true,
          title: Text(
            'Prayers Timing',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: FutureBuilder(
            future: getLoc(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Constants.kPrimary,
                  ),
                );
              }

              final myCoordinates = Coordinates(latitude!, longitude!);
              final params = CalculationMethod.karachi.getParameters();
              params.madhab = Madhab.hanafi;
              final prayerTimes = PrayerTimes.today(myCoordinates, params);

              return Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    buildPrayerTimeRow('Fajr', prayerTimes.fajr),
                    Divider(color: Colors.blueGrey, thickness: 1),
                    buildPrayerTimeRow('Sunrise', prayerTimes.sunrise),
                    Divider(color: Colors.blueGrey, thickness: 1),
                    buildPrayerTimeRow('Zuhr', prayerTimes.dhuhr),
                    Divider(color: Colors.blueGrey, thickness: 1),
                    buildPrayerTimeRow('Asr', prayerTimes.asr),
                    Divider(color: Colors.blueGrey, thickness: 1),
                    buildPrayerTimeRow('Maghrib', prayerTimes.maghrib),
                    Divider(color: Colors.blueGrey, thickness: 1),
                    buildPrayerTimeRow('Isha', prayerTimes.isha),
                    Divider(color: Colors.blueGrey, thickness: 1),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveNotificationState(String prayerName, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prayerName, value);
  }

  Widget buildPrayerTimeRow(String prayerName, DateTime prayerTime) {
    return Padding(
      padding: EdgeInsets.all(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Text(
                DateFormat.jm().format(prayerTime),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: notifications[prayerName]!,
                onChanged: (value) {
                  setState(() {
                    notifications[prayerName] = value;
                    _saveNotificationState(prayerName, value);
                    if (value) {
                      scheduleNotification(prayerName, prayerTime);
                    } else {
                      cancelNotification(prayerName);
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> scheduleNotification(String prayerName, DateTime prayerTime) async {
    final scheduledTime = prayerTime.subtract(Duration(minutes: 2));
    final notificationId = DateTime.now().millisecondsSinceEpoch;
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_notifications',
        'Prayer Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
    print('$prayerName notification confirmed');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationId, // Unique ID
      '$prayerName Time',
      'It\'s time for $prayerName prayer!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformChannelSpecifics,
      payload: prayerName,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_${prayerName.replaceAll(' ', '_')}_id', notificationId);
    print(notificationId);
  }

  Future<void> cancelNotification(String prayerName) async {
    // Cancel notifications by ID or other logic
    final prefs = await SharedPreferences.getInstance();
    final notificationId = prefs.getInt('notification_${prayerName.replaceAll(' ', '_')}_id');

    print(notificationId);
    if (notificationId != null) {
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
    print('$prayerName notification canceled');
  }

  Future<void> getLoc() async {
    try {
      bool _serviceEnabled = await location.serviceEnabled();
      PermissionStatus _permissionGranted;

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();
        if (!_serviceEnabled) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _currentPosition = await location.getLocation();
      latitude = _currentPosition!.latitude;
      longitude = _currentPosition!.longitude;
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }
}
