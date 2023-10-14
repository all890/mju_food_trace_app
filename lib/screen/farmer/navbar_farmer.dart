
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/screen/farmer/add_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/main_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/request_renewing_farmer_certificate_screen.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_certificate_controller.dart';
import '../../controller/farmer_controller.dart';
import '../../model/farmer.dart';
import '../../model/farmer_certificate.dart';
import '../login_screen.dart';

class FarmerNavbar extends StatefulWidget {
  const FarmerNavbar({super.key});

  @override
  State<FarmerNavbar> createState() => _FarmerNavbarState();
}

class _FarmerNavbarState extends State<FarmerNavbar> {

  FarmerCertificate? farmerCertificate;
  bool? isLoaded;
 String? username;
  String? userType;

  FarmerCertificateController farmerCertificateController = FarmerCertificateController();

  Duration? differenceDuration;
  int? differenceDays;

  bool? showBadge = false;

  void fetchFarmerCertificateData () async {
    setState(() {
      isLoaded = false;
    });
    String farmerUsername = await SessionManager().get("username");
    var response = await farmerCertificateController.getLastestFarmerCertificateByFarmerUsername(farmerUsername);
    farmerCertificate = FarmerCertificate.fromJsonToFarmerCertificate(response);
   // print(farmerCertificate?.fmCertExpireDate);

    var userTypeDynamic = await SessionManager().get("userType");
     userType = userTypeDynamic.toString();
    setState(() {
      isLoaded = true;
      differenceDuration = farmerCertificate?.fmCertExpireDate?.difference(DateTime.now());
      differenceDays = differenceDuration?.inDays;
      if (differenceDays! <= 30) {
        showBadge = true;
      }
      print("DURATION IS : ${differenceDuration?.inDays}");
    });
  }
 

  @override
  void initState() {
    super.initState();
    fetchFarmerCertificateData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text("${farmerCertificate?.farmer?.farmerName} ${farmerCertificate?.farmer?.farmerLastname}",style: TextStyle(fontFamily: 'Itim',fontSize: 18,color: Colors?.white, shadows: [
                  Shadow(color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            accountEmail: Text("เกษตรกร",style: TextStyle(fontFamily: 'Itim',fontSize: 16,color: Colors.white, shadows: [
                  Shadow(color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            decoration: BoxDecoration(
              color:  kClipPathColorFM,
              // image: DecorationImage(
              //   image: AssetImage('images/ftmju_header_logo.png')
              // )
            ),
          ),
          //farmerCertificate?.fmCertExpireDate?.isBefore(DateTime.now()) == true || farmerCertificate?.fmCertStatus == "ไม่อนุมัติ" ?
          ListTile(
            leading: Badge(
              label: Text("!"),
              isLabelVisible: showBadge ?? false,
              child: const Icon(
                Icons.newspaper_sharp,
                color: Color.fromARGB(255, 124, 94, 4),
              )
            ),
            title:Text("ต่ออายุใบรับรอง",style: TextStyle(
                    fontFamily: 'Itim',
                    color: kClipPathColorTextNavbarFM,
                    fontSize: 16,
                  ),),
            onTap: () {
              print("Go to request renewing farmer certificate page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingFarmerCertificate()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add , color: Color.fromARGB(255, 124, 94, 4),),
            title: Text("เพิ่มการปลูกผลผลิต",style: TextStyle(
                    fontFamily: 'Itim',
                    color: kClipPathColorTextNavbarFM,
                    fontSize: 16,
                  ),),
            onTap: () {
              print("Go to add planting page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AddPlantingScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.nature , color: Color.fromARGB(255, 124, 94, 4),),
            title: Text("รายการปลูกผลผลิต",style: TextStyle(
                    fontFamily: 'Itim',
                    color: kClipPathColorTextNavbarFM,
                    fontSize: 16,
                  ),),
            onTap: () {
              print("Go to list planting page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Color.fromARGB(255, 124, 94, 4),),
            title: Text("ออกจากระบบ",style: TextStyle(
                    fontFamily: 'Itim',
                    color: kClipPathColorTextNavbarFM,
                    fontSize: 16,
                  ),),
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