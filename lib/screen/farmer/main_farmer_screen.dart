
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/controller/farmer_controller.dart';
import 'package:mju_food_trace_app/screen/farmer/navbar_farmer.dart';

import '../../constant/constant.dart';
import '../../model/farmer.dart';

class MainFarmerScreen extends StatefulWidget {
  const MainFarmerScreen({super.key});

  @override
  State<MainFarmerScreen> createState() => _MainFarmerScreenState();
}

class _MainFarmerScreenState extends State<MainFarmerScreen> {

  String? username;
  String? userType;

  bool? isLoaded;
  FarmerController farmerController = FarmerController();
  Farmer? farmer;
  
  void syncUser () async {
    setState(() {
      isLoaded = false;
    });
    
    var usernameDynamic = await SessionManager().get("username");
    username = usernameDynamic.toString();
    var response = await farmerController.getFarmerByUsername(username ?? "");
    farmer = Farmer.fromJsonToFarmer(response);
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
          drawer: FarmerNavbar(),
          appBar: AppBar(
            title: Text("MAIN FARMER"),
            backgroundColor: Colors.green,
          ),
          backgroundColor: kBackgroundColor,
          body: Column (
          children: [
              Text("${username}"),
              Text("${farmer?.farmerName} ${farmer?.farmerLastname}"),
              Text("${farmer?.farmerEmail}"),
              Text("${farmer?.farmerMobileNo}"),
          ],
         ),
        ),
      ),
    );
  }
}