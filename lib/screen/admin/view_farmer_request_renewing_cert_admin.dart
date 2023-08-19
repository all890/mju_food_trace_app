
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/screen/admin/list_farmer_request_renewing_cert_admin_screen.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_certificate_controller.dart';
import '../../service/config_service.dart';

class ViewFarmerRequestRenewingCertificateScreen extends StatefulWidget {
  final String fmCertId;
  const ViewFarmerRequestRenewingCertificateScreen({Key? key, required this.fmCertId}) : super(key: key);

  @override
  State<ViewFarmerRequestRenewingCertificateScreen> createState() => _ViewFarmerRequestRenewingCertificateScreenState();
}

class _ViewFarmerRequestRenewingCertificateScreenState extends State<ViewFarmerRequestRenewingCertificateScreen> {
  
  FarmerCertificateController farmerCertificateController = FarmerCertificateController();

  TextEditingController fmCertUploadDateTextController = TextEditingController();
  TextEditingController fmCertNoTextController = TextEditingController();
  TextEditingController fmCertRegDateTextController = TextEditingController();
  TextEditingController fmCertExpireDateTextController = TextEditingController();

  bool? isLoaded;
  FarmerCertificate? farmerCertificate;
  String? imgCertFileName;

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    farmerCertificate = await farmerCertificateController.getFmRequestRenewById(widget.fmCertId);
    String filePath = farmerCertificate?.fmCertImg ?? "";

    imgCertFileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length);
    setState(() {
      isLoaded = true;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
        SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: InkWell(
                          onTap: () {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListFarmerRequestRenewingCertificateScreen()));
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "กลับไปหน้ารายการลงทะเบียน",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Image(
                          image: AssetImage('images/logo.png'),
                          width: 50,
                          height: 50,
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ข้อมูลการร้องขอต่ออายุใบรับรองเกษตรกร",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  Image.network(baseURL + '/farmercertificate/' + imgCertFileName!),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: fmCertNoTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "หมายเลขใบรับรองมาตรฐานเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: fmCertRegDateTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: fmCertExpireDateTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "วันที่หมดอายุใบรับรองมาตรฐานเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ข้อมูลชื่อผู้ใช้และรหัสผ่าน",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}