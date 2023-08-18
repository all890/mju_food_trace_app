
import 'package:flutter/material.dart';

class RegisterSuccessScreen extends StatefulWidget {
  const RegisterSuccessScreen({super.key});

  @override
  State<RegisterSuccessScreen> createState() => _RegisterSuccessScreenState();
}

class _RegisterSuccessScreenState extends State<RegisterSuccessScreen> {

  //Test Comment From James

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