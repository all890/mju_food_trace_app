import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/controller/manufacturing_controller.dart';
import 'package:mju_food_trace_app/screen/manufacturer/generate_qr_code_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../model/manufacturing.dart';
import '../../widgets/buddhist_year_converter.dart';
import 'list_manufacturing.dart';

class RecordManufacturingScreen extends StatefulWidget {
  final String manufacturingId;
  const RecordManufacturingScreen({Key? key, required this.manufacturingId})
      : super(key: key);

  @override
  State<RecordManufacturingScreen> createState() =>
      _RecordManufacturingScreenState();
}

class _RecordManufacturingScreenState extends State<RecordManufacturingScreen> {
  ManufacturingController manufacturingController = ManufacturingController();
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  Manufacturing? manufacturings;

  var dateFormat = DateFormat('dd-MM-yyyy');
  DateTime currentDate = DateTime.now();
  DateTime? manufactureDate;
  DateTime? expireDate;
  bool? isLoaded;

  void fetchData(String manufacturingId) async {
    var username = await SessionManager().get("username");
    setState(() {
       isLoaded = false;
    });
    var response =
        await manufacturingController.getManufacturingById(manufacturingId);
    manufacturings = Manufacturing.fromJsonToManufacturing(response);

    //setTextToData();
    setState(() {
      isLoaded = true;
    });
  }

  void showRecordManufacturingSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "บันทึกข้อมูลสำเร็จ",
      text: "บันทึกข้อมูลการผลิตสินค้าสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) {
            return GenerateQRCodeScreen(manufacturingId: widget.manufacturingId);
          })
        );
      }
    );
  }

  void showRecordManufacturingError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถบันทึกการผลิตสินค้าได้ กรุณาลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showRecordManufacturingErrorBecauseEncryptionCodeNotMatch () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถบันทึกการผลิตสินค้าได้ เนื่องจากการเข้ารหัสของข้อมูลไม่ตรงกัน",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showConfirmToRecordManufacturingAlert (String manufacturingId) {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะบันทึกข้อมูลการผลิตสินค้า",
      type: QuickAlertType.warning,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("PRESSED!");

        var response = await manufacturingController.recordManufacturing(manufacturingId);

        if (response == 200) {
          Navigator.pop(context);
          showRecordManufacturingSuccessAlert();
          
        } else if (response == 500) {
          showRecordManufacturingError();
        } else if (response == 409) {
          showRecordManufacturingErrorBecauseEncryptionCodeNotMatch();
        }
      }
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData(widget.manufacturingId);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: kBackgroundColor,
            body: 
            isLoaded == false
                ? Column(
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
                  ):
            
            SingleChildScrollView(
             
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      child: Row(
                    
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
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return const ListManufacturingScreen();
                                          }));
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_back),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "กลับไปรายการการผลิตสินค้า",
                                              style: TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 20),
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
                                    "บันทึกการผลิตสินค้า",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim',
                                      color: Color.fromARGB(255, 5, 112, 41),
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                const Padding(
                    padding: EdgeInsets.only(left: 25, bottom: 8, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "รายละเอียดการผลิต",
                        style: TextStyle(fontSize: 20, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 15, left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "รหัสผลผลิตที่นำมาใช้ : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "${manufacturings?.rawMaterialShipping?.rawMatShpId}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "ชื่อของผลผลิต : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        "${manufacturings?.rawMaterialShipping?.planting?.plantName}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 15, left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                   Text(
                                    "จำนวนของผลผลิตที่ใช้ : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        "${manufacturings?.usedRawMatQty}" +
                                        " " +
                                        "${manufacturings?.usedRawMatQtyUnit}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 20),
                  //   child: Align(
                  //     alignment: Alignment.center,
                  //     child: Icon(
                  //       Icons.arrow_downward
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: Image(
                        image: AssetImage("images/assembly-line.gif")
                      ),
                    ),
                  ),
                  Card(
                    elevation: 10,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 15, left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "ผลิตเป็นสินค้า : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        "${manufacturings?.product?.productName}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "จำนวนสินค้าที่ได้ : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        "${manufacturings?.productQty}" +
                                        " " +
                                        "${manufacturings?.productUnit}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "วันที่ผลิตสินค้า : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        "${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturings?.manufactureDate ?? DateTime.now())}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 15, left: 15),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Row(
                                children: [
                                  Text(
                                    "วันหมดอายุของสินค้า : ",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Itim',fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                        "${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturings?.expireDate ?? DateTime.now())}",
                                    style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "คำเตือน : กรุณาตรวจสอบข้อมูลข้างต้นให้เรียบร้อยหลังจากที่ทำการบันทึกจะไม่สามารถแก้ไขข้อมูลได้อีก",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim',color: Colors.red,
                        
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<
                            RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(50.0))),
                          backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 5, 112, 41))
                        ),
                        onPressed: () {
                          showConfirmToRecordManufacturingAlert(widget.manufacturingId);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("บันทึก",
                              style: TextStyle(
                                fontSize: 20,
                                fontFamily: 'Itim'
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                               
                               
                               
                               
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
