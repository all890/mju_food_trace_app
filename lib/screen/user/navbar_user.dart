import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/user/trace_product_by_qrcode_user_screen.dart';

class UserNavbar extends StatefulWidget {
  const UserNavbar({super.key});

  @override
  State<UserNavbar> createState() => _UserNavbarState();
}

class _UserNavbarState extends State<UserNavbar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: null,
            accountEmail: null,
            decoration: BoxDecoration(
                color: kClipPathColorAM,
                image: DecorationImage(
                    image: AssetImage('images/ftmju.png'))),
          ),
          ListTile(
            leading: const Icon(Icons.add,color:  Color.fromARGB(255, 13, 69, 6)),
            title: const Text(
              "ตรวจสอบย้อนกลับสินค้า",
              style: TextStyle(fontSize: 16, fontFamily: 'Itim'),
            ),
            onTap: () {
              print("Go to list all sent agricultural product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TraceProductByQRCodeScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle,color: Color.fromARGB(255, 13, 69, 6)),
            title: const Text(
              "เข้าสู่ระบบ",
              style: TextStyle(fontSize: 16, fontFamily: 'Itim'),
            ),
            onTap: () {
              print("Go to login page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              });
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
