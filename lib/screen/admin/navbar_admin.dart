
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/admin/main_admin_screen.dart';

import 'list_farmer_registration_admin_screen.dart';
import 'list_manuft_registration_admin_screen.dart';

class AdminNavbar extends StatelessWidget {
  const AdminNavbar({super.key});

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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainAdminScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("การลงทะเบียนเกษตรกร"),
            onTap: () {
              print("Go to farmer registration page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListFarmerRegistrationScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("การลงทะเบียนผู้ผลิต"),
            onTap: () {
              print("Go to manuft registration page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRegistrationScreen()));
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