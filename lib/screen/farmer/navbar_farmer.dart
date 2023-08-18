
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/screen/farmer/add_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/main_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/request_renewing_farmer_certificate_screen.dart';

import '../login_screen.dart';

class FarmerNavbar extends StatelessWidget {
  const FarmerNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: null,
            accountEmail: null,
            decoration: BoxDecoration(
              color: Colors.green,
              image: DecorationImage(
                image: AssetImage('images/ftmju_header_logo.png')
              )
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("หน้าหลัก"),
            onTap: () {
              print("Go to main page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainFarmerScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("เพิ่มการปลูกผลผลิต"),
            onTap: () {
              print("Go to add planting page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AddPlantingScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.nature),
            title: const Text("รายการปลูกผลผลิต"),
            onTap: () {
              print("Go to list planting page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
              });
              Navigator.pop(context);
            },
          ),
           ListTile(
            leading: const Icon(Icons.newspaper_sharp),
            title: const Text("ต่ออายุใบรับรอง"),
            onTap: () {
              print("Go to request renewing farmer certificate page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingFarmerCertificate()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("ออกจากระบบ"),
            onTap: () async {
              print("Go to login page");
              await SessionManager().set("username", "");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}