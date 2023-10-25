
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/qrcode_controller.dart';
import 'package:mju_food_trace_app/model/qrcode.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_manufacturing.dart';
import 'package:mju_food_trace_app/service/config_service.dart';
import 'package:path_provider/path_provider.dart';

import '../../widgets/buddhist_year_converter.dart';

class GenerateQRCodeScreen extends StatefulWidget {

  final String manufacturingId;

  const GenerateQRCodeScreen({super.key, required this.manufacturingId});

  @override
  State<GenerateQRCodeScreen> createState() => _GenerateQRCodeScreenState();
}

class _GenerateQRCodeScreenState extends State<GenerateQRCodeScreen> {

  QRCodeController qrCodeController = QRCodeController();
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  QRCode? qrCode;

  bool? isLoaded;

  var dateFormat = DateFormat('dd-MM-yyyy');

  void generateQRCode (String manufacturingId) async {
    setState(() {
      isLoaded = false;
    });
    var responseQRCode = await qrCodeController.generateQRCode(manufacturingId);
    qrCode = QRCode.fromJsonToQRCode(json.decode(responseQRCode));
    saveImageToDevice();
    setState(() {
      isLoaded = true;
    });
  }

  void saveImageToDevice () async {
    print(baseURL + '/qrcode/getqrcodebyid/${qrCode?.qrcodeId}');

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${qrCode?.qrcodeId}.jpg';

    var response = await Dio().get(baseURL + '/qrcode/getqrcodebyid/${qrCode?.qrcodeId}', options: Options(responseType: ResponseType.bytes));

    var result = await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('รูปภาพคิวอาร์โค้ดได้ถูกบันทึกแล้ว'))
    );
  }

  @override
  void initState() {
    super.initState();
    generateQRCode(widget.manufacturingId);
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        ) :
        SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)
                ),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) {
                                          return const ListManufacturingScreen();
                                        }
                                      )
                                    );
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
                                        "กลับไปหน้ารายการผลิตสินค้า",
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
                            padding: EdgeInsets.only(top: 30),
                            child: Text(
                              "คิวอาร์โค้ดการตรวจสอบย้อนกลับสินค้า",
                              style: TextStyle(
                                fontSize: 22,
                                fontFamily: 'Itim',
                                color: Color.fromARGB(255, 33, 82, 35)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: Card(
                              elevation: 30,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: SizedBox(
                                width: 300,
                                child: Image.network(
                                  baseURL + '/qrcode/getqrcodebyid/${qrCode?.qrcodeId}',
                                  scale: 0.5
                                )
                              ),
                            ),
                          ),
                          //Image.network(baseURL + '/qrcode/getqrcodebyid/${qrCode?.qrcodeId}', scale: 0.9),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "รหัสการผลิตสินค้า : ${qrCode?.manufacturing?.manufacturingId}",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Itim',
                                color: Colors.black
                              )
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "รหัสคิวอาร์โค้ด : ${qrCode?.qrcodeId}",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Itim',
                                color: Colors.black
                              )
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              "วันที่สร้างคิวอาร์โค้ด : ${buddhistYearConverter.convertDateTimeToBuddhistDate(qrCode?.generateDate ?? DateTime.now())}",
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Itim',
                                color: Colors.black
                              )
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}