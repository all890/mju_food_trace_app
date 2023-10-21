import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/controller/administrator_controller.dart';
import 'package:mju_food_trace_app/model/administrator.dart';
import 'package:mju_food_trace_app/screen/admin/list_farmer_request_renewing_cert_admin_screen.dart';
import 'package:mju_food_trace_app/screen/admin/list_manuft_request_renewing_cert_admin.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/admin/main_admin_screen.dart';

import '../../constant/constant.dart';
import 'list_farmer_registration_admin_screen.dart';
import 'list_manuft_registration_admin_screen.dart';

class AdminNavbar extends StatefulWidget {
  const AdminNavbar({super.key});

  @override
  State<AdminNavbar> createState() => _AdminNavbarState();
}

class _AdminNavbarState extends State<AdminNavbar> {

  AdministratorController administratorController = AdministratorController();

  Administrator? administrator;
  String? username;

  void fetchAdminInfo () async {
    var usernameDynamic = await SessionManager().get("username");
    username = usernameDynamic.toString();
    var response = await administratorController.getAdminByUsername(username ?? "");
    Administrator tempAdmin = Administrator.fromJsonToAdministrator(response);
    setState(() {
      administrator = tempAdmin;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAdminInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountEmail: Text(
              "ผู้ดูแลระบบ",
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],
              ),
            ),
            accountName: Text(
              "${administrator?.adminName} ${administrator?.adminLastname}",
              style: TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],
              ),
            ),
            decoration: BoxDecoration(
              color:kClipPathColorAM,
              // image: DecorationImage(
              //     image: AssetImage('images/ftmju_header_logo.png'))
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle,color: Color.fromARGB(255, 46, 153, 50)),
            title: const Text("การลงทะเบียนเกษตรกร",style: TextStyle(fontFamily: 'Itim',color:Colors.black,fontSize: 16 ),),
            onTap: () {
              print("Go to farmer registration page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ListFarmerRegistrationScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_circle,color: Color.fromARGB(255, 46, 153, 50)),
            title: const Text("การลงทะเบียนผู้ผลิต",style: TextStyle(fontFamily: 'Itim',color:Colors.black,fontSize: 16 ),),
            onTap: () {
              print("Go to manuft registration page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ListManuftRegistrationScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner,color: Color.fromARGB(255, 46, 153, 50)),
            title: const Text("การร้องขอต่ออายุใบรับรองเกษตรกร",style: TextStyle(fontFamily: 'Itim',color:Colors.black,fontSize: 16 ),),
            onTap: () {
              print("Go to manuft registration page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ListFarmerRequestRenewingCertificateScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.document_scanner,color: Color.fromARGB(255, 46, 153, 50)),
            title: const Text("การร้องขอต่ออายุใบรับรองผู้ผลิต",style: TextStyle(fontFamily: 'Itim',color:Colors.black,fontSize: 16 ),),
            onTap: () {
              print("Go to manuft registration page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ListManuftRequestRenewingCertificateScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout,color:  Color.fromARGB(255, 46, 153, 50)),
            title: const Text("ออกจากระบบ",style: TextStyle(fontFamily: 'Itim',color:Colors.black,fontSize: 16 ),),
            onTap: () async {
              print("Go to login page");
              await SessionManager().set("username", "");
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
