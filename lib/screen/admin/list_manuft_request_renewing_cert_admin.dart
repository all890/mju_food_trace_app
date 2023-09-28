
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';
import 'package:mju_food_trace_app/screen/admin/view_manuft_renewing_request_certificate_details_admin_screen.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_certificate_controller.dart';
import 'navbar_admin.dart';

class ListManuftRequestRenewingCertificateScreen extends StatefulWidget {
  const ListManuftRequestRenewingCertificateScreen({super.key});

  @override
  State<ListManuftRequestRenewingCertificateScreen> createState() => _ListManuftRequestRenewingCertificateScreenState();
}

class _ListManuftRequestRenewingCertificateScreenState extends State<ListManuftRequestRenewingCertificateScreen> {
  
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  bool? isLoaded;

  List<ManufacturerCertificate>? manufacturerCertificates;
  var dateFormat = DateFormat('dd-MMM-yyyy');

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    manufacturerCertificates = await manufacturerCertificateController.getListAllMnRequestRenewCert();
    setState(() {
      isLoaded = true;
    });
    print(manufacturerCertificates?.length);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          drawer: AdminNavbar(),
          appBar: AppBar(
            title:Text("รายการขอใบรับรองผู้ผลิตฉบับใหม่",style: TextStyle(fontFamily: 'Itim',shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            backgroundColor: Colors.green,
          ),
          backgroundColor: kBackgroundColor,
          body: isLoaded == false?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ) : 
          manufacturerCertificates?.isNotEmpty == true? Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: manufacturerCertificates?.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_circle)
                      ],
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${manufacturerCertificates?[index].manufacturer?.manuftName}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22
                          ),
                        ),
                        Text(
                          "${manufacturerCertificates?[index].manufacturer?.manuftEmail}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "${dateFormat.format(manufacturerCertificates?[index].mnCertUploadDate ?? DateTime.now())}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in),
                    onTap: () {
                      print("Go to manufacturer ${manufacturerCertificates?[index].mnCertId} details page!");
                      
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewManuftRenewingRequestCertDetailsAdminScreen(mnCertId: manufacturerCertificates?[index].mnCertId??"")));
                      });
                      
                    },
                  ),
                );
              },
            ),
          ) :
          Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    height: 350,
                    width: 350,
                    image: AssetImage("images/bean_action4.png"),
                  ),
                  Text(
                    "ไม่มีการร้องขอต่ออายุใบรับรองผู้ผลิต",
                    style:
                        TextStyle(fontFamily: "Itim", fontSize: 20),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}