
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/qrcode_controller.dart';
import 'package:qrscan/qrscan.dart' as scanner;

class TraceProductByQRCodeScreen extends StatefulWidget {
  const TraceProductByQRCodeScreen({super.key});

  @override
  State<TraceProductByQRCodeScreen> createState() => _TraceProductByQRCodeScreenState();
}

class _TraceProductByQRCodeScreenState extends State<TraceProductByQRCodeScreen> {

  String? result = "";

  QRCodeController qrCodeController = QRCodeController();

  startScan () async {
    print("OK");
    String? scanResult = await scanner.scan();
    var response = await qrCodeController.getProductDetailsByQRCodeId(scanResult??"");
    if (response == 200) {
      setState(() {
        result = "FOUND : ${scanResult}";
      });
    } else if (response == 404) {
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: const Text("SCAN QR CODE")
        ),
        body: Container(
          child: Text(
            "The result is ${result}"
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            startScan();
          },
          child: Icon(Icons.qr_code_scanner_sharp),
        ),
      ),
    );
  }
}