import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quranapp/screens/juz_screen.dart';
import 'package:quranapp/screens/login_screen.dart';
import 'package:quranapp/screens/main_screen.dart';
import 'package:quranapp/screens/prayer_screen.dart'; // Import PrayerScreen
import 'package:quranapp/screens/register_screen.dart';
import 'package:quranapp/screens/surahdetail.dart';
import 'package:quranapp/startup/splashscreen.dart';

import 'common/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAioXQVkJ0pNELDuzPtT06H9XG3Glrat4U",
      appId: "1:705940704313:android:b3f1677b7ad91bf02891e8",
      messagingSenderId: "705940704313",
      projectId: "quranapp-8003d",
      storageBucket: "quranapp-8003d.appspot.com",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Muslim Soul',
      theme: ThemeData(
        primarySwatch: Constants.kSwatchColor,
        primaryColor: Constants.kPrimary,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins',
      ),
      home: SplashScreen(),
      routes: {
        JuzScreen.id: (context) => JuzScreen(),
        Surahdetail.id: (context) => Surahdetail(),
        '/prayer': (context) => const PrayerScreen(), // Add PrayerScreen route
      },
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/main', page: () => MainScreen()),
        GetPage(name: '/prayer', page: () => const PrayerScreen()), // Add PrayerScreen page
      ],
    );
  }
}
