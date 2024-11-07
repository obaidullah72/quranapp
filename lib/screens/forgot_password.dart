import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:quranapp/common/constants.dart';
import 'package:quranapp/widgets/decoration_widget.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final heightsize = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: heightsize * 0.3,
                    decoration: BoxDecoration(
                      color: Constants.kPrimary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(70),
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock,
                        size: 90,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                    bottom: 40,
                    right: 30,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 38, left: 8, right: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(3),
                            child: TextFormField(
                              autocorrect: false,
                              keyboardType: TextInputType.emailAddress,
                              decoration: DecorationWidget(
                                  context, "Enter Your Email", Icons.email),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Constants.kPrimary,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 10),
                              textStyle: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            onPressed: () {},
                            child: Text(
                              "Forgot Password",
                              // style: TextStyle(
                              //   color: Colors.white,
                              //   fontWeight: FontWeight.bold,
                              // ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextButton(
                            onPressed: () {
                              Get.offAllNamed('/login');
                            },
                            child: Text(
                              "Back",
                              style: TextStyle(
                                color: Constants.kPrimary,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
