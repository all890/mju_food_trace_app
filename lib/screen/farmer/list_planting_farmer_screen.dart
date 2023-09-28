import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/farmer_certificate_controller.dart';
import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/screen/farmer/navbar_farmer.dart';
import 'package:mju_food_trace_app/screen/farmer/send_agricultural_products.dart';
import 'package:mju_food_trace_app/screen/farmer/update_planting_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/view_planting_details_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../../model/farmer_certificate.dart';

class ListPlantingScreen extends StatefulWidget {
  const ListPlantingScreen({super.key});

  @override
  State<ListPlantingScreen> createState() => _ListPlantingScreenState();
}

class _ListPlantingScreenState extends State<ListPlantingScreen> {
  PlantingController plantingController = PlantingController();
  FarmerCertificateController farmerCertificateController =
      FarmerCertificateController();

  bool? isLoaded;

  FarmerCertificate? farmerCertificate;

  List<Planting>? plantings;
  Map<String, dynamic> remQtyOfPts = {};

  List<Planting>? cannotSentPlantings = [];
  List<Planting>? didNotSentPlantings = [];
  List<Planting>? sendPlantings = [];
  List<Planting>? emptyQtyPlantings = [];

  var dateFormat = DateFormat('dd-MM-yyyy');

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
    plantings = await plantingController.getListPlantingById(username);
    var fmCertResponse = await farmerCertificateController
        .getLastestFarmerCertificateByFarmerUsername(username);
    farmerCertificate =
        FarmerCertificate.fromJsonToFarmerCertificate(fmCertResponse);
    var remQtyOfPtsResponse =
        await plantingController.getRemQtyOfPtsByFarmerUsername(username);
    remQtyOfPts = json.decode(remQtyOfPtsResponse);
    print(remQtyOfPts);
    splitPlantingBySending();
    setState(() {
      isLoaded = true;
    });
    print(plantings?.length);
  }

  void splitPlantingBySending() {
    plantings?.forEach((planting) {
      print(planting.ptCurrBlockHash);
      var now = DateTime.now();
      if (planting.approxHarvDate?.isAfter(now) == true ||
          planting.approxHarvDate?.isAtSameMomentAs(now) == true &&
              planting.ptCurrBlockHash == null) {
        cannotSentPlantings?.add(planting);
      }
      if (planting.approxHarvDate?.isBefore(now) == true &&
          planting.ptCurrBlockHash == null) {
        didNotSentPlantings?.add(planting);
      }
      if ((remQtyOfPts[planting.plantingId] > 0) &&
          planting.ptCurrBlockHash != null) {
        sendPlantings?.add(planting);
      }
      if ((remQtyOfPts[planting.plantingId] <= 0) &&
          planting.ptCurrBlockHash != null) {
        emptyQtyPlantings?.add(planting);
      }
    });

    print("Length of cannotSentPlantings : ${cannotSentPlantings?.length}");
    print("Length of didNotSentPlantings : ${didNotSentPlantings?.length}");
    print("Length of sendPlantings : ${sendPlantings?.length}");
    print("Length of emptyQtyPlantings : ${emptyQtyPlantings?.length}");
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
      length: 4,
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
                    "รอเก็บเกี่ยว",
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
                    "สามารถส่งได้",
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
                    "ส่งแล้ว",
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
                    "ครบจำนวน",
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
                  cannotSentPlantings?.isNotEmpty == true
                      ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: cannotSentPlantings?.length,
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
                                        Text(
                                          "${cannotSentPlantings?[index1].plantName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim', fontSize: 22),
                                        ),
                                        Text(
                                            "วันที่ปลูก : " +
                                                dateFormat.format(
                                                    cannotSentPlantings?[index1]
                                                            .plantDate ??
                                                        DateTime.now()),
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่คาดว่าจะเก็บเกี่ยว : " +
                                                dateFormat.format(
                                                    cannotSentPlantings?[index1]
                                                            .approxHarvDate ??
                                                        DateTime.now()),
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "ปริมาณผลผลิตสุทธิ : ${cannotSentPlantings?[index1].netQuantity} ${cannotSentPlantings?[index1].netQuantityUnit}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            // TODO: Check fm cert before delete
                                            GestureDetector(
                                                onTap: () {
                                                  print("Delete Pressed!");
                                                  print(cannotSentPlantings
                                                      ?.length);
                                                  print(
                                                      "state is ${farmerCertificate?.fmCertExpireDate?.isAfter(DateTime.now())}");
                                                  if (farmerCertificate
                                                              ?.fmCertExpireDate
                                                              ?.isBefore(
                                                                  DateTime
                                                                      .now()) ==
                                                          true ||
                                                      farmerCertificate
                                                              ?.fmCertStatus ==
                                                          "ไม่อนุมัติ") {
                                                    showErrorToDeleteBecauseFmCertIsExpire();
                                                  } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
                                                    showErrorToDeleteBecauseFmCertIsWaitToAccept();
                                                  } else {
                                                    print("print this");
                                                    showConfirmToDeleteAlert(
                                                        cannotSentPlantings?[
                                                                index1]
                                                            .plantingId);
                                                  }
                                                },
                                                child: Icon(Icons.delete)),
                                            // TODO: Check fm cert before update
                                            GestureDetector(
                                                onTap: () {
                                                  print("Edit Pressed!");
                                                  if (farmerCertificate
                                                              ?.fmCertExpireDate
                                                              ?.isBefore(
                                                                  DateTime
                                                                      .now()) ==
                                                          true ||
                                                      farmerCertificate
                                                              ?.fmCertStatus ==
                                                          "ไม่อนุมัติ") {
                                                    showErrorToUpdateBecauseFmCertIsExpire();
                                                  } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
                                                    showErrorToUpdateBecauseFmCertIsWaitToAccept();
                                                  } else {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UpdatePlantingScreen(
                                                                  plantingId: cannotSentPlantings!
                                                                          .isEmpty
                                                                      ? ''
                                                                      : cannotSentPlantings![index1]
                                                                              .plantingId ??
                                                                          "")),
                                                    );
                                                  }
                                                },
                                                child: Icon(Icons.edit)),
                                          ],
                                        ),
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
                                "ไม่มีผลผลิตที่ต้องรอเก็บเกี่ยว",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                  didNotSentPlantings?.isNotEmpty == true
                      ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: didNotSentPlantings?.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
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
                                        Text(
                                          "${didNotSentPlantings?[index].plantName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim', fontSize: 22),
                                        ),
                                        Text(
                                            "วันที่ปลูก : " +
                                                dateFormat.format(
                                                    didNotSentPlantings?[index]
                                                            .plantDate ??
                                                        DateTime.now()),
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่คาดว่าจะเก็บเกี่ยว : " +
                                                dateFormat.format(
                                                    didNotSentPlantings?[index]
                                                            .approxHarvDate ??
                                                        DateTime.now()),
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "ปริมาณผลผลิตสุทธิ : ${didNotSentPlantings?[index].netQuantity} ${didNotSentPlantings?[index].netQuantityUnit}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // TODO: Check fm cert before delete
                                            GestureDetector(
                                                onTap: () {
                                                  print("Delete Pressed!");
                                                  if (farmerCertificate
                                                              ?.fmCertExpireDate
                                                              ?.isBefore(
                                                                  DateTime
                                                                      .now()) ==
                                                          true ||
                                                      farmerCertificate
                                                              ?.fmCertStatus ==
                                                          "ไม่อนุมัติ") {
                                                    showErrorToDeleteBecauseFmCertIsExpire();
                                                  } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
                                                    showErrorToDeleteBecauseFmCertIsWaitToAccept();
                                                  } else {
                                                    showConfirmToDeleteAlert(
                                                        didNotSentPlantings?[
                                                                    index]
                                                                .plantingId ??
                                                            "");
                                                  }
                                                },
                                                child: Icon(Icons.delete)),
                                            // TODO: Check fm cert before update
                                            GestureDetector(
                                                onTap: () {
                                                  print("Edit Pressed!");
                                                  if (farmerCertificate
                                                              ?.fmCertExpireDate
                                                              ?.isBefore(
                                                                  DateTime
                                                                      .now()) ==
                                                          true ||
                                                      farmerCertificate
                                                              ?.fmCertStatus ==
                                                          "ไม่อนุมัติ") {
                                                    showErrorToUpdateBecauseFmCertIsExpire();
                                                  } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
                                                    showErrorToUpdateBecauseFmCertIsWaitToAccept();
                                                  } else {
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              UpdatePlantingScreen(
                                                                  plantingId:
                                                                      didNotSentPlantings?[index]
                                                                              .plantingId ??
                                                                          "")),
                                                    );
                                                  }
                                                },
                                                child: Icon(Icons.edit)),
                                            // TODO: Check fm cert before send
                                            GestureDetector(
                                                onTap: () {
                                                  print("Send Pressed!");
                                                  if (farmerCertificate
                                                              ?.fmCertExpireDate
                                                              ?.isBefore(
                                                                  DateTime
                                                                      .now()) ==
                                                          true ||
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
                                                                      didNotSentPlantings?[index]
                                                                              .plantingId ??
                                                                          "")),
                                                    );
                                                  }
                                                },
                                                child: Icon(Icons.send))
                                          ],
                                        ),
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
                                image: AssetImage("images/rice_action2.png"),
                              ),
                              Text(
                                "ไม่มีผลผลิตที่สามารถส่งได้",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                  sendPlantings?.isNotEmpty == true
                      ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: sendPlantings?.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
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
                                        Text(
                                          "${sendPlantings?[index].plantName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim', fontSize: 22),
                                        ),
                                        Text(
                                            "วันที่ปลูก : " +
                                                dateFormat.format(
                                                    sendPlantings?[index]
                                                            .plantDate ??
                                                        DateTime.now()),
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่คาดว่าจะเก็บเกี่ยว : " +
                                                dateFormat.format(
                                                    sendPlantings?[index]
                                                            .approxHarvDate ??
                                                        DateTime.now()),
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "ปริมาณผลผลิตคงเหลือ : ${sendPlantings?[index].netQuantityUnit == "กิโลกรัม" ? remQtyOfPts[sendPlantings?[index].plantingId] / 1000 : remQtyOfPts[sendPlantings?[index].plantingId]} ${sendPlantings?[index].netQuantityUnit}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                      ],
                                    ),
                                    trailing: SizedBox(
                                      width: 100,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // TODO: Check fm cert before send
                                          Center(
                                            child: GestureDetector(
                                                onTap: () {
                                                  if (farmerCertificate
                                                              ?.fmCertExpireDate
                                                              ?.isBefore(
                                                                  DateTime
                                                                      .now()) ==
                                                          true ||
                                                      farmerCertificate
                                                              ?.fmCertStatus ==
                                                          "ไม่อนุมัติ") {
                                                    showErrorToSendBecauseFmCertIsExpire();
                                                  } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
                                                    showErrorToSendBecauseFmCertIsWaitToAccept();
                                                  } else {
                                                    print("Send Pressed!");
                                                    Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SendAgriculturalProducts(
                                                                plantingId:
                                                                    sendPlantings?[index]
                                                                            .plantingId ??
                                                                        "",
                                                                remQtyOfPt: sendPlantings?[index]
                                                                            .netQuantityUnit ==
                                                                        "กิโลกรัม"
                                                                    ? remQtyOfPts[sendPlantings?[index]
                                                                            .plantingId] /
                                                                        1000
                                                                    : remQtyOfPts[
                                                                        sendPlantings?[index]
                                                                            .plantingId],
                                                              )),
                                                    );
                                                  }
                                                },
                                                child: Icon(Icons.send)),
                                          )
                                        ],
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
                                image: AssetImage("images/rice_action1.png"),
                              ),
                              Text(
                                "ไม่มีผลผลิตที่เคยส่งแล้ว",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                  emptyQtyPlantings?.isNotEmpty == true
                      ? Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: emptyQtyPlantings?.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
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
                                      Text(
                                        "${emptyQtyPlantings?[index].plantName}",
                                        style: const TextStyle(
                                            fontFamily: 'Itim', fontSize: 22),
                                      ),
                                      Text(
                                          "วันที่ปลูก : " +
                                              dateFormat.format(
                                                  emptyQtyPlantings?[index]
                                                          .plantDate ??
                                                      DateTime.now()),
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 18)),
                                      Text(
                                          "วันที่คาดว่าจะเก็บเกี่ยว : " +
                                              dateFormat.format(
                                                  emptyQtyPlantings?[index]
                                                          .approxHarvDate ??
                                                      DateTime.now()),
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 18)),
                                    ],
                                  ),
                                ),
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
                                image: AssetImage("images/rice_action4.png"),
                              ),
                              Text(
                                "ไม่มีผลผลิตที่ส่งครบจำนวน",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                ]),
        ),
      ));
}
