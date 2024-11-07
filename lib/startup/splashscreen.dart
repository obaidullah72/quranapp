import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  User? user = FirebaseAuth.instance.currentUser;
  bool alreadyUsed = false;

  void getData() async {
    final prefs = await SharedPreferences.getInstance();
    alreadyUsed = prefs.getBool('alreadyUsed') ?? false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    Timer(
        Duration(seconds: 3),
            () {
          if(user != null && user!.uid != null){
            Get.offNamed('/main');
          } else {
            Get.offNamed('/login');
          }
        }
    );

  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Muslim Life',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            top: 450,
            child: Image.asset(
              'assets/islamic.png',
              width: size.width,
            ),
          ),
        ],
      ),
    ));
  }
}
