import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/farmer_certificate_controller.dart';
import 'package:mju_food_trace_app/screen/admin/list_farmer_request_renewing_cert_admin_screen.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../constant/constant.dart';
import '../../model/farmer_certificate.dart';
import '../../service/config_service.dart';

class ViewFarmerRenewingRequestCertDetailsAdminScreen
 extends StatefulWidget {

  final String fmCertId;

  const  ViewFarmerRenewingRequestCertDetailsAdminScreen({Key? key, required this.fmCertId}) : super(key: key);

  @override
  State<ViewFarmerRenewingRequestCertDetailsAdminScreen> createState() => 
  _ViewFarmerRenewingRequestCertDetailsAdminScreenState();
}

class _ViewFarmerRenewingRequestCertDetailsAdminScreenState extends State<ViewFarmerRenewingRequestCertDetailsAdminScreen
> {

  FarmerCertificateController farmerCertificateController = FarmerCertificateController();
  TextEditingController farmerIDTextController = TextEditingController();
  TextEditingController farmerNameTextController = TextEditingController();
  TextEditingController farmerLastnameTextController = TextEditingController();
  TextEditingController farmerCertRegDateTextController = TextEditingController();
  TextEditingController farmerCertExpireDateTextController= TextEditingController();
  TextEditingController farmerCertNoTextController = TextEditingController();
  bool? isLoaded;

  String? imgCertFileName;

  var dateFormat = DateFormat('dd-MM-yyyy');
  FarmerCertificate? farmerCertificate;

   void showUpdateFarmerRegistStatusFailAlert () {
    QuickAlert.show(
      context: context,
      title: "อัปเดตสถานะไม่สำเร็จ",
      text: "ไม่สามารถอัปเดตสถานะการขออนุมัติการลงทะเบียนใบรับรองฉบับใหม่ของเกษตรกรได้",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

    void showAcceptRegistrationAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะอนุมัติปฎิเสธการขออนุมัติการลงทะเบียนใบรับรองฉบับใหม่ของเกษตรกร",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("Accept!");
      
        http.Response updateFarmerResponse = await farmerCertificateController.updateFmRenewingRequestCertStatus(farmerCertificate?.fmCertId??"");
        if (updateFarmerResponse.statusCode == 500) {
          Navigator.pop(context);
          showUpdateFarmerRegistStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListFarmerRequestRenewingCertificateScreen()));
          });
        }
      }
    );
  }
   void showDeclineRegistrationAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะปฎิเสธการขออนุมัติการลงทะเบียนใบรับรองฉบับใหม่ของเกษตรกร",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () {
        print("Accept!");
        Navigator.pop(context);
      }
    );
  }

  void fetchData (String fmCertId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await farmerCertificateController.getFarmerCertDetails(fmCertId);

    farmerCertificate = FarmerCertificate.fromJsonToFarmerCertificate(response);


    String filePath = farmerCertificate?.fmCertImg ?? "";
   

    imgCertFileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length);
    setTextToData();
    setState(() {
      isLoaded = true;
    });
  }
   void setTextToData () {
     farmerIDTextController.text = farmerCertificate?.farmer?.farmerId?? "";
    farmerNameTextController.text = farmerCertificate?.farmer?.farmerName ?? "";
    farmerLastnameTextController.text = farmerCertificate?.farmer?.farmerLastname ?? "";
    

    farmerCertNoTextController.text = farmerCertificate?.fmCertNo ?? "";
    farmerCertRegDateTextController.text = dateFormat.format(farmerCertificate?.fmCertRegDate ?? DateTime.now());
    farmerCertExpireDateTextController.text = dateFormat.format(farmerCertificate?.fmCertExpireDate ?? DateTime.now());

   
  }

    @override
  void initState() {
    super.initState();
    fetchData(widget.fmCertId);
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
              child: Column(children: [
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
                                "กลับไปหน้ารายการร้องขอใบรับรอง",
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
                      "รายละเอียดคำร้องขอต่ออายุ",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ใบรับรองของเกษตรกร",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "วันที่ทำการร้องขอต่ออายุ : " +
                            "${dateFormat.format(farmerCertificate?.fmCertUploadDate ?? DateTime.now())}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                    Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerIDTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "รหัสเกษตรกร",
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
                      controller: farmerNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อเกษตรกร",
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
                      controller: farmerLastnameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "นามสกุลเกษตรกร",
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
                   Image.network(baseURL + '/farmercertificate/' + imgCertFileName!),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerCertNoTextController,
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
                      controller: farmerCertRegDateTextController,
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
                      controller: farmerCertExpireDateTextController,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 53,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                            ),
                            onPressed: () {
                              showAcceptRegistrationAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("อนุมัติ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 200,
                          height: 53,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)
                            ),
                            onPressed: () {
                              showDeclineRegistrationAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("ปฎิเสธ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
              ]),
            ),
          ),
        )

    ));
  }
}