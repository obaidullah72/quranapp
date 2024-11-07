import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:quranapp/screens/chathomescreen.dart';
import 'package:quranapp/screens/home_screen.dart';
import 'package:quranapp/screens/prayer_screen.dart';
import 'package:quranapp/screens/qari_screen.dart';
import 'package:quranapp/screens/quran_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedindex = 0;

  List<Widget> _widgetsList = [
    HomeScreen(),
    QuranScreen(),
    QariListScreen(),
    PrayerScreen(),
    ChatHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: _widgetsList[selectedindex],
          bottomNavigationBar: ConvexAppBar(
            items: [
              TabItem(
                  icon: Image.asset(
                    'assets/home.png',
                    color: Colors.white,
                  ),
                  title: 'Home'),
              TabItem(
                  icon: Image.asset(
                    'assets/holyQuran.png',
                    color: Colors.white,
                  ),
                  title: 'Quran'),
              TabItem(
                  icon: Image.asset(
                    'assets/audio.png',
                    color: Colors.white,
                  ),
                  title: 'Audio'),
              TabItem(
                  icon: Image.asset(
                    'assets/mosque.png',
                    color: Colors.white,
                  ),
                  title: 'Prayer'),
              TabItem(
                  icon: Image.asset(
                    'assets/chat.png',
                    color: Colors.white,
                  ),
                  title: 'Chat'),
            ],
            initialActiveIndex: 0,
            onTap: updateIndex,
            backgroundColor: Color(0xff1B202D),
            activeColor: Color(0xff1B202D),
          )),
    );
  }

  void updateIndex(index) {
    setState(() {
      selectedindex = index;
    });
  }
}
