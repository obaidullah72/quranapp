import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:quranapp/common/constants.dart';
import 'package:quranapp/screens/main_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IntroductionScreen(
          pages: [
            PageViewModel(
              title: "Read Quran",
              bodyWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Customize your reading view in multiple \nlanguage, listen different audio",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              image: Center(
                  child: Image.asset(
                'assets/quran.png',
                fit: BoxFit.fitWidth,
              )),
            ),
            PageViewModel(
              title: "Prayer alerts",
              bodyWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Choose your adhan, which prayer to be\n notified of and how often",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),                ],
              ),
              image: Center(child: Image.asset('assets/prayer.png')),
            ),
            PageViewModel(
              title: "Build Better Habits",
              bodyWidget: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Make islamic practices a part of \nyour daily life in a way that \nbest suits your life.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              image: Center(child: Image.asset('assets/zakat.png')),
            ),
          ],
          onDone: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => MainScreen()));
          },
          onSkip: () {},

          showNextButton: true,
          // showSkipButton: true,
          // skip: const Icon(Icons.skip_next),
          next: const Icon(
            Icons.arrow_forward,
            color: Colors.black,
          ),
          done: const Text(
            'Done',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
          dotsDecorator: DotsDecorator(
              size: const Size.square(10.0),
              activeSize: const Size(20.0, 10.0),
              activeColor: Constants.kPrimary,
              color: Colors.grey,
              spacing: const EdgeInsets.symmetric(horizontal: 3.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              )),
        ),
      ),
    );
  }
}
