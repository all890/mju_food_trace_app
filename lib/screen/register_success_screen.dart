
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen> {

  Timer scheduleTimeout([int milliseconds = 10000]) =>
    Timer(Duration(milliseconds: milliseconds), goToLoginPage);

  void goToLoginPage() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return const LoginScreen();
        }
      )
    );
  }

  @override
  void initState() {
    super.initState();
    scheduleTimeout(3000);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('images/check_correct2.gif')
              ),
              Text(
                "ลงทะเบียนสำเร็จ",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Itim'
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}