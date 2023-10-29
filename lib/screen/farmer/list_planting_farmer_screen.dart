import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';

import 'package:mju_food_trace_app/controller/farmer_certificate_controller.dart';
import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/controller/raw_material_shipping_controller.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';
import 'package:mju_food_trace_app/screen/farmer/navbar_farmer.dart';
import 'package:mju_food_trace_app/screen/farmer/send_agricultural_products.dart';
import 'package:mju_food_trace_app/screen/farmer/update_planting_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/view_planting_details_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../../model/farmer_certificate.dart';
import '../../widgets/buddhist_year_converter.dart';

class ListPlantingScreen extends StatefulWidget {
  const ListPlantingScreen({super.key});

  @override
  State<ListPlantingScreen> createState() => _ListPlantingScreenState();
}

class _ListPlantingScreenState extends State<ListPlantingScreen> {
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();
  PlantingController plantingController = PlantingController();
  FarmerCertificateController farmerCertificateController =
      FarmerCertificateController();
  RawMaterialShippingController rawMaterialShippingController = RawMaterialShippingController();

  bool? isLoaded;

  FarmerCertificate? farmerCertificate;

  List<Planting>? plantings;
  List<RawMaterialShipping>? rawMaterialShippings;
  Map<String, dynamic> remQtyOfPts = {};

  var dateFormat = DateFormat('dd-MMM-yyyy');

  void showErrorToUpdateBecauseFmCertIsExpire() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถอัพเดตข้อมูลการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านหมดอายุ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToUpdateBecauseFmCertIsWaitToAccept() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถอัพเดตข้อมูลการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToSendBecauseFmCertIsExpire() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถส่งผลผลิตของการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านหมดอายุ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToSendBecauseFmCertIsWaitToAccept() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถส่งผลผลิตของการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToDeleteBecauseFmCertIsExpire() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถลบข้อมูลการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านหมดอายุ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToDeleteBecauseFmCertIsWaitToAccept() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถลบข้อมูลการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showConfirmToDeleteAlert(String? plantingId) {
    QuickAlert.show(
        context: context,
        showCancelBtn: true,
        title: "แจ้งเตือน",
        text: "คุณต้องการลบการปลูกนี้หรือไม่",
        type: QuickAlertType.warning,
        confirmBtnText: "ตกลง",
        cancelBtnText: "ยกเลิก",
        onConfirmBtnTap: () async {
          print(plantingId);
          http.Response response =
              await plantingController.deletePlanting(plantingId!);
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
          });
        });
  }

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    List<Planting>? tempPlantings;
    tempPlantings = await plantingController.getListPlantingById(username);
    plantings = tempPlantings?.reversed.toList();
    List<RawMaterialShipping>? tempRawMaterialShippings;
    tempRawMaterialShippings = await rawMaterialShippingController.getListAllSentAgriByFarmerUsername(username);
    rawMaterialShippings = tempRawMaterialShippings?.reversed.toList();
    var fmCertResponse = await farmerCertificateController
        .getLastestFarmerCertificateByFarmerUsername(username);
    farmerCertificate =
        FarmerCertificate.fromJsonToFarmerCertificate(fmCertResponse);
    var remQtyOfPtsResponse =
        await plantingController.getRemQtyOfPtsByFarmerUsername(username);
    remQtyOfPts = json.decode(remQtyOfPtsResponse);
    print(remQtyOfPts);
    setState(() {
      isLoaded = true;
    });
    print(plantings?.length);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          drawer: FarmerNavbar(),
          appBar: AppBar(
            title: Text(
              "รายการปลูกผลผลิต",
              style: TextStyle(
                fontFamily: 'Itim',
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "รายการปลูกผลผลิต",
                    style: TextStyle(
                      fontFamily: 'Itim',
                      color: kClipPathColorTextFM,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "ประวัติส่งผลผลิต",
                    style: TextStyle(
                      fontFamily: 'Itim',
                      color: kClipPathColorTextFM,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: kClipPathColorFM,
          ),
          backgroundColor: kBackgroundColor,
          body: isLoaded == false
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                )
              : TabBarView(children: [
                  plantings?.isNotEmpty == true
                      ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: plantings?.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index1) {
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                    title: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            "${plantings?[index1].plantName}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 22,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 93, 43, 1)),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "วันที่ปลูก : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 16,fontWeight: FontWeight.bold)),
                                            Text(
                                                buddhistYearConverter.convertDateTimeToBuddhistDate(
                                                        plantings?[index1]
                                                                .plantDate ??
                                                            DateTime.now()),
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "คาดว่าจะเก็บเกี่ยว : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 16,fontWeight: FontWeight.bold)),
                                            Text(
                                                buddhistYearConverter.convertDateTimeToBuddhistDate(
                                                        plantings?[index1]
                                                                .approxHarvDate ??
                                                            DateTime.now()),
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                               Text(
                                                  "ปริมาณคาดว่าสุทธิ : ",
                                                  style: const TextStyle(
                                                      fontFamily: 'Itim',
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold)),
                                              Text(
                                                  "${plantings?[index1].netQuantity} ${plantings?[index1].netQuantityUnit}",
                                                  style: const TextStyle(
                                                      fontFamily: 'Itim',
                                                      fontSize: 18)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: GestureDetector(
                                            onTap: () {
                                              print("Send Pressed!");
                                              if (farmerCertificate?.fmCertExpireDate?.isBefore(DateTime.now()) == true && !(farmerCertificate?.fmCertExpireDate?.difference(DateTime.now()).inDays == 0) ||
                                                  farmerCertificate
                                                          ?.fmCertStatus ==
                                                      "ไม่อนุมัติ") {
                                                showErrorToSendBecauseFmCertIsExpire();
                                              } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
                                                showErrorToSendBecauseFmCertIsWaitToAccept();
                                              } else {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          SendAgriculturalProducts(
                                                              plantingId:
                                                                  plantings?[index1]
                                                                          .plantingId ??
                                                                      "")),
                                                );
                                              }
                                            },
                                            child: Icon(Icons.send,color: Color.fromARGB(255, 112, 87, 11),)),
                                      ),
                                    )),
                              );
                            },
                          ),
                        )
                      : Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                height: 350,
                                width: 350,
                                image: AssetImage("images/rice_action3.png"),
                              ),
                              Text(
                                "ไม่มีรายการปลูกผลผลิต",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                        rawMaterialShippings?.isNotEmpty == true ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: rawMaterialShippings?.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index1) {
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                    title: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                "รหัสการส่งผลผลิต : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim', fontSize: 20,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 93, 43, 1)),
                                              ),
                                              Text(
                                                "${rawMaterialShippings?[index1].rawMatShpId}",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim', fontSize: 20,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 93, 43, 1)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "วันที่ส่งผลผลิต : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 16,fontWeight: FontWeight.bold)),
                                            Text(
                                                    buddhistYearConverter.convertDateTimeToBuddhistDate(
                                                        rawMaterialShippings?[index1]
                                                                .rawMatShpDate ??
                                                            DateTime.now()),
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "ปริมาณผลผลิตที่ส่ง : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 16,fontWeight: FontWeight.bold)),
                                            Text(
                                              "${rawMaterialShippings?[index1].rawMatShpQty} ${rawMaterialShippings?[index1].rawMatShpQtyUnit}",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                                    
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "ส่งให้กับ :",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 16,fontWeight: FontWeight.bold)),
                                            Text(
                                                "${rawMaterialShippings?[index1].manufacturer?.manuftName}",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "ผลผลิตที่ส่ง : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 16,fontWeight: FontWeight.bold)),
                                            Text(
                                                "${rawMaterialShippings?[index1].planting?.plantName}",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Text(
                                              "สถานะการส่ง : ${rawMaterialShippings?[index1].status}",
                                              style: const TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 18,fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                  ),
                              );
                            },
                          ),
                        ) : Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                height: 350,
                                width: 350,
                                image: AssetImage("images/rice_action4.png"),
                              ),
                              Text(
                                "ไม่มีประวัติรายการส่งผลผลิต",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        )
                ]),
        ),
      ));
}
