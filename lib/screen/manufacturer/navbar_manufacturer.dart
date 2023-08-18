
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/screen/manufacturer/add_product_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_all_sent_agricultural_products_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/main_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/request_renewing_manufacturer_certificate_screen.dart';

import '../login_screen.dart';
import 'list_product_manufacturer_screen.dart';

class ManufacturerNavbar extends StatelessWidget {
  const ManufacturerNavbar({super.key});

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
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainManufacturerScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text("เพิ่มสินค้า"),
            onTap: () {
              print("Go to add product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text("รายการสินค้า"),
            onTap: () {
              print("Go to list product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListProductScreen()));
              });
              Navigator.pop(context);
            },
          ),
           ListTile(
            leading: const Icon(Icons.list),
            title: const Text("รายการผลิตสินค้า"),
            onTap: () {
              print("Go to list all sent agricultural product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListAllSentAgriculturalProductsScreen()));
              });
              Navigator.pop(context);
            },
          ),
            ListTile(
            leading: const Icon(Icons.newspaper_sharp),
            title: const Text("ต่ออายุใบรับรอง"),
            onTap: () {
              print("Go to request renewing manufacturer certificate page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingManufacturerCertificateScreen()));
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