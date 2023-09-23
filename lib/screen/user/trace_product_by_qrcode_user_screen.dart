
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/farmer_certificate_controller.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/controller/qrcode_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';
import 'package:mju_food_trace_app/model/qrcode.dart';
import 'package:mju_food_trace_app/screen/user/navbar_user.dart';
import 'package:mju_food_trace_app/screen/user/trace_product_by_qrcode_second_user_screen.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../model/farmer_certificate.dart';

class TraceProductByQRCodeScreen extends StatefulWidget {
  const TraceProductByQRCodeScreen({super.key});

  @override
  State<TraceProductByQRCodeScreen> createState() => _TraceProductByQRCodeScreenState();
}

class _TraceProductByQRCodeScreenState extends State<TraceProductByQRCodeScreen> {

  String? result = "";

  QRCodeController qrCodeController = QRCodeController();
  FarmerCertificateController farmerCertificateController = FarmerCertificateController();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  QRCode? qrCode;
  FarmerCertificate? farmerCertificate;
  ManufacturerCertificate? manufacturerCertificate;

  TextEditingController qrcodeIdTextController = TextEditingController();

  void showError (String errorPrompt) {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: errorPrompt,
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  startScan () async {
    print("OK");
    String? scanResult = await scanner.scan();
    http.Response qrResponse = await qrCodeController.getProductDetailsByQRCodeId(scanResult??"");
    
    if (qrResponse.statusCode == 200) {
      qrCode = QRCode.fromJsonToQRCode(json.decode(utf8.decode(qrResponse.bodyBytes)));

      var fmCertResponse = await farmerCertificateController.getLastestFarmerCertificateByFarmerUsername(
        qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.user?.username ?? ""
      );
      farmerCertificate = FarmerCertificate.fromJsonToFarmerCertificate(fmCertResponse);

      var mnCertResponse = await manufacturerCertificateController.getLastestManufacturerCertificateByManufacturerUsername(
        qrCode?.manufacturing?.product?.manufacturer?.user?.username ?? ""
      );
      manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(mnCertResponse);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return TraceProductByQRCodeSecondScreen(qrCode: qrCode, farmerCertificate: farmerCertificate, manufacturerCertificate: manufacturerCertificate,);
          }
        )
      );
    } else if (qrResponse.statusCode == 404) {
      showError("ไม่พบสินค้าที่ท่านค้นหา");
    } else {
      showError("ไม่สามารถตรวจสอบกลับสินค้าได้ กรุณาลองใหม่อีกครั้ง");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          key: _globalKey,
          backgroundColor: kBackgroundColor,
          drawer: UserNavbar(),
          body: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.menu_rounded),
                  iconSize: 40.0,
                  onPressed: () {
                    _globalKey.currentState?.openDrawer();
                  },
                ),
              ),
              Form(
                key: formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Image(
                          image: AssetImage('images/logo.png'),
                          width: 250,
                          height: 250,
                        ),
                        Text(
                          "ระบบการตรวจสอบกลับสินค้า",
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "ทางการเกษตร มหาวิทยาลัยแม่โจ้",
                          style: TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      hintText: "รหัสคิวอาร์โค้ด",
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 18
                                    ),
                                    controller: qrcodeIdTextController,
                                    maxLength: 10,
                                  ),
                                ),
                              ),
                              Container(
                                width: 100,
                                height: 61,
                                child: OutlinedButton(
                                  onPressed: () {
                                    startScan();
                                  },
                                  child: Icon(
                                    Icons.qr_code,
                                    color: Colors.black
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                                  )
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: SizedBox(
                            height: 53,
                            width: 170,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(50.0))),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                              ),
                              onPressed: () async {
                                
                                if (qrcodeIdTextController.text == "") {
                                  return showError("กรุณากรอกรหัสคิวอาร์โค้ด");
                                }
                  
                                if (qrcodeIdTextController.text.length < 10) {
                                  return showError("กรุณากรอกรหัสคิวอาร์โค้ดให้มีความยาว 10 ตัวอักษร");
                                }
                  
                                http.Response response = await qrCodeController.getProductDetailsByQRCodeId(qrcodeIdTextController.text);
                                
                                if (response.statusCode == 200) {
                                  qrCode = QRCode.fromJsonToQRCode(json.decode(response.body));
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return TraceProductByQRCodeSecondScreen(qrCode: qrCode);
                                      }
                                    )
                                  );
                                } else if (response.statusCode == 404) {
                                  showError("ไม่พบสินค้าที่ท่านค้นหา");
                                } else {
                                  showError("ไม่สามารถตรวจสอบกลับสินค้าได้ กรุณาลองใหม่อีกครั้ง");
                                }
                  
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("ค้นหา",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: 'Itim'
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}