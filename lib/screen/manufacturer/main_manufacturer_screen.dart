
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';

import '../../constant/constant.dart';

class MainManufacturerScreen extends StatefulWidget {
  const MainManufacturerScreen({super.key});

  @override
  State<MainManufacturerScreen> createState() => _MainManufacturerScreenState();
}

class _MainManufacturerScreenState extends State<MainManufacturerScreen> {
  String? username;
  String? userType;

  bool? isLoaded;

  void syncUser () async {
    setState(() {
      isLoaded = false;
    });
    var usernameDynamic = await SessionManager().get("username");
    username = usernameDynamic.toString();
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
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          drawer: ManufacturerNavbar(),
          appBar: AppBar(
            title: Text("MAIN MANUFACTURER"),
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