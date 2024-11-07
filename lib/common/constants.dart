import 'dart:ui';

import 'package:flutter/material.dart';

class Constants {
  static const kPrimary = Color(0xff4A90E2); // Base blue color

  static const MaterialColor kSwatchColor =
  const MaterialColor(0xff4A90E2, const <int, Color>{
    50: const Color(0xff5A9CE6),  // 10% lighter
    100: const Color(0xff6AA8EA), // 20% lighter
    200: const Color(0xff7AB5EE), // 30% lighter
    300: const Color(0xff8AC1F2), // 40% lighter
    400: const Color(0xff9ACDF6), // 50% lighter
    500: const Color(0xffAAD9FA), // 60% lighter
    600: const Color(0xffBAD6FD), // 70% lighter
    700: const Color(0xffCAE3FF), // 80% lighter
    800: const Color(0xffDAEFFF), // 90% lighter
    900: const Color(0xffEBFBFF), // 100% lighter
  });

  static int? juzIndex;
  static int? surahIndex;
}
