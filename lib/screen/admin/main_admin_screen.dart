
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/screen/admin/navbar_admin.dart';

class MainAdminScreen extends StatefulWidget {
  const MainAdminScreen({super.key});

  @override
  State<MainAdminScreen> createState() => _MainAdminScreenState();
}

class _MainAdminScreenState extends State<MainAdminScreen> {

  String? username;
  String? userType;

  bool? isLoaded;

  void syncUser () async {
    setState(() {
      isLoaded = false;
    });
    var usernameDynamic = await SessionManager().get("username");
    var userTypeDynamic = await SessionManager().get("userType");
    username = usernameDynamic.toString();
    userType = userTypeDynamic.toString();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    syncUser();
  }

  @override
  Widget build(BuildContext context) {
    /*
    return Container(
      child: isLoaded == true? Text(
        "WELCOME TO SYSTEM ADMIN ${username}"
      ) : CircularProgressIndicator(),
    );
    */
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          drawer: AdminNavbar(),
          appBar: AppBar(
            title: Text("MAIN ADMIN"),
            backgroundColor: Colors.green,
          ),
          backgroundColor: kBackgroundColor,
          body: Text(
            "${username}"
          ),
        ),
      ),
    );
  }
}