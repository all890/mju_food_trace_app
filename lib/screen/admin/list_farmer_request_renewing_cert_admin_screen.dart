
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/screen/admin/view_farmer_renewing_request_certificate_details_admin_screen.dart';


import '../../constant/constant.dart';
import '../../controller/farmer_certificate_controller.dart';
import '../../controller/farmer_controller.dart';
import 'navbar_admin.dart';

class ListFarmerRequestRenewingCertificateScreen extends StatefulWidget {
  const ListFarmerRequestRenewingCertificateScreen({super.key});

  @override
  State<ListFarmerRequestRenewingCertificateScreen> createState() => _ListFarmerRequestRenewingCertificateScreenState();
}

class _ListFarmerRequestRenewingCertificateScreenState extends State<ListFarmerRequestRenewingCertificateScreen> {

  FarmerCertificateController farmerCertificateController = FarmerCertificateController();

  bool? isLoaded;

  List<FarmerCertificate>? farmerCertificates;
  var dateFormat = DateFormat('dd-MMM-yyyy');
  
  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    farmerCertificates = await farmerCertificateController.getListAllFmRequestRenewCert();
    setState(() {
      isLoaded = true;
    });
    print(farmerCertificates?.length);
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
            title:Text("รายการขอใบรับรองเกษตรกรฉบับใหม่",style: TextStyle(fontFamily: 'Itim',shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            backgroundColor: kClipPathColorAM,
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
          farmerCertificates?.isNotEmpty == true? Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: farmerCertificates?.length,
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
                          SizedBox(
                  width: 50,
                  height: 50,
                  child: Image(
                    image: AssetImage('images/certificate-icon.png'),
                  ),
                ),
                      ],
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${farmerCertificates?[index].farmer?.farmerName} ${farmerCertificates?[index].farmer?.farmerLastname}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22,
                            color: Color.fromARGB(255, 50, 33, 3)
                          ),
                        ),
                        Text(
                          "ชื่อฟาร์ม : "+"${farmerCertificates?[index].farmer?.farmName}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "วันที่ลงทะเบียน : ${dateFormat.format(farmerCertificates?[index].fmCertRegDate ?? DateTime.now())}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        ),
                        Text(
                          "วันที่หมดอายุ : ${dateFormat.format(farmerCertificates?[index].fmCertExpireDate ?? DateTime.now())}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in,color: Color.fromARGB(255, 71, 46, 2),),
                    onTap: () {
                      print("Go to farmer ${farmerCertificates?[index].fmCertId} details page!");
                      
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewFarmerRenewingRequestCertDetailsAdminScreen(fmCertId: farmerCertificates?[index].fmCertId??"")));
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
                    image: AssetImage("images/rice_action6.png"),
                  ),
                  Text(
                    "ไม่มีการร้องขอต่ออายุใบรับรองเกษตรกร",
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