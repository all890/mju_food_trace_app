import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/screen/manufacturer/add_product_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_all_sent_agricultural_products_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/main_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/request_renewing_manufacturer_certificate_screen.dart';

import '../../model/manufacturer_certificate.dart';
import '../login_screen.dart';
import 'list_product_manufacturer_screen.dart';

class ManufacturerNavbar extends StatefulWidget {
  const ManufacturerNavbar({super.key});

  @override
  State<ManufacturerNavbar> createState() => _ManufacturerNavbarState();
}

class _ManufacturerNavbarState extends State<ManufacturerNavbar> {
  final ManufacturerCertificateController manufacturerCertificateController =
      ManufacturerCertificateController();

  ManufacturerCertificate? manufacturerCertficate;
  bool? isLoaded;

  void fetchManufacturerCertificateData() async {
    setState(() {
      isLoaded = false;
    });
    var username = await SessionManager().get("username");
    var manuftCertficateResponse = await manufacturerCertificateController
        .getLastestManufacturerCertificateByManufacturerUsername(username);
    manufacturerCertficate =
        ManufacturerCertificate.fromJsonToManufacturerCertificate(
            manuftCertficateResponse);
    print(manufacturerCertficate?.mnCertExpireDate);
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchManufacturerCertificateData();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName:  Text("${manufacturerCertficate?.manufacturer?.manuftName}",style: TextStyle(fontFamily: 'Itim',fontSize: 18,color: Colors?.white, shadows: [
                  Shadow(color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            accountEmail: Text("ผู้ผลิต",style: TextStyle(fontFamily: 'Itim',fontSize: 18,color: Colors?.white, shadows: [
                  Shadow(color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            decoration: BoxDecoration(
                color: kClipPathColorMN,
                // image: DecorationImage(
                //     image: AssetImage('images/ftmju_header_logo.png'))
                ),
          ),
          manufacturerCertficate?.mnCertExpireDate?.isBefore(DateTime.now()) ==
                      true ||
                  manufacturerCertficate?.mnCertStatus == "ไม่อนุมัติ"
              ? ListTile(
                  leading: Icon(Icons.newspaper_sharp,
                      color: KClipPathIconsColorNavberMN),
                  title: Text(
                    "ต่ออายุใบรับรอง",
                    style: TextStyle(
                      fontFamily: 'Itim',
                      color: kClipPathColorTextNavbarMN,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () {
                    print(
                        "Go to request renewing manufacturer certificate page");
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const RequestRenewingManufacturerCertificateScreen()));
                    });
                    Navigator.pop(context);
                  },
                )
              : Container(),
          ListTile(
            leading: Icon(Icons.add, color: KClipPathIconsColorNavberMN),
            title: Text(
              "เพิ่มสินค้า",
              style: TextStyle(
                fontFamily: 'Itim',
                color: kClipPathColorTextNavbarMN,
                fontSize: 16,
              ),
            ),
            onTap: () {
              print("Go to add product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AddProductScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.list, color: KClipPathIconsColorNavberMN),
            title: Text(
              "รายการสินค้า",
              style: TextStyle(
                fontFamily: 'Itim',
                color: kClipPathColorTextNavbarMN,
                fontSize: 16,
              ),
            ),
            onTap: () {
              print("Go to list product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ListProductScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.add, color: KClipPathIconsColorNavberMN),
            title: Text(
              "เพิ่มการผลิตสินค้า",
              style: TextStyle(
                fontFamily: 'Itim',
                color: kClipPathColorTextNavbarMN,
                fontSize: 16,
              ),
            ),
            onTap: () {
              print("Go to list all sent agricultural product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ListAllSentAgriculturalProductsScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.list, color: KClipPathIconsColorNavberMN),
            title: Text(
              "รายการผลิตสินค้า",
              style: TextStyle(
                fontFamily: 'Itim',
                color: kClipPathColorTextNavbarMN,
                fontSize: 16,
              ),
            ),
            onTap: () {
              print("Go to list all sent agricultural product page");
              WidgetsBinding.instance!.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ListManufacturingScreen()));
              });
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: KClipPathIconsColorNavberMN),
            title: Text(
              "ออกจากระบบ",
              style: TextStyle(
                fontFamily: 'Itim',
                color: kClipPathColorTextNavbarMN,
                fontSize: 16,
              ),
            ),
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
