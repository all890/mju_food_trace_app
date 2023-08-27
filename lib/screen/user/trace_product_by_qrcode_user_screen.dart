
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/qrcode_controller.dart';
import 'package:mju_food_trace_app/model/qrcode.dart';
import 'package:mju_food_trace_app/screen/user/navbar_user.dart';
import 'package:mju_food_trace_app/screen/user/trace_product_by_qrcode_second_user_screen.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:http/http.dart' as http;

class TraceProductByQRCodeScreen extends StatefulWidget {
  const TraceProductByQRCodeScreen({super.key});

  @override
  State<TraceProductByQRCodeScreen> createState() => _TraceProductByQRCodeScreenState();
}

class _TraceProductByQRCodeScreenState extends State<TraceProductByQRCodeScreen> {

  String? result = "";

  QRCodeController qrCodeController = QRCodeController();
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  QRCode? qrCode;

  void showNotFoundQRCodAlert () {

  }

  void showErrorToGetProductDetailsByQRCodeId () {

  }

  startScan () async {
    print("OK");
    String? scanResult = await scanner.scan();
    http.Response response = await qrCodeController.getProductDetailsByQRCodeId(scanResult??"");
    qrCode = QRCode.fromJsonToQRCode(json.decode(response.body));
    if (response.statusCode == 200) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return TraceProductByQRCodeSecondScreen(qrCode: qrCode);
          }
        )
      );
    } else if (response.statusCode == 404) {
      setState(() {
        result = "NOT FOUND : ${scanResult}";
      });
    } else {
      setState(() {
        result = "ERROR : ${scanResult}";
      });
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Image(
                      image: AssetImage('images/logo.png'),
                      width: 300,
                      height: 300,
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
                    Row(
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
                            ),
                          ),
                        ),
                        Container(
                          width: 50,
                          height: 60,
                          child: ElevatedButton(
                            onPressed: () {
                              
                            },
                            child: Icon(Icons.qr_code),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              startScan();
            },
            child: Icon(Icons.qr_code_scanner_sharp),
          ),
        ),
      ),
    );
  }
}