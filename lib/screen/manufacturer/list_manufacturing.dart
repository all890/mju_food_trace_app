import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/model/manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/record_manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/update_manufacturing_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../../controller/manufacturing_controller.dart';
import '../../model/manufacturer_certificate.dart';
import 'navbar_manufacturer.dart';

class ListManufacturingScreen extends StatefulWidget {
  const ListManufacturingScreen({super.key});

  @override
  State<ListManufacturingScreen> createState() =>
      _ListManufacturingScreenState();
}

class _ListManufacturingScreenState extends State<ListManufacturingScreen> {
  ManufacturingController manufacturingController = ManufacturingController();
  ManufacturerCertificateController manufacturerCertificateController =
      ManufacturerCertificateController();

  bool? isLoaded;
  ManufacturerCertificate? manufacturerCertificate;

  List<Manufacturing>? manufacturings = [];

  List<Manufacturing>? recordedManufacturings = [];
  List<Manufacturing>? notRecordedManufacturings = [];

  var dateFormat = DateFormat('dd-MMM-yyyy');

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    manufacturings =
        await manufacturingController.getListAllManufacturingUsername(username);
    var manuftCertResponse = await manufacturerCertificateController
        .getLastestManufacturerCertificateByManufacturerUsername(username);
    manufacturerCertificate =
        ManufacturerCertificate.fromJsonToManufacturerCertificate(
            manuftCertResponse);
    splitManufacturingType();
    setState(() {
      isLoaded = true;
    });
    print(manufacturings?.length);
  }

  void showErrorToDeleteBecauseMnCertIsExpire() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถลบข้อมูลสินค้าได้เนื่องจากใบรับรองการผลิตของท่านหมดอายุ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToDeleteBecauseMnCertIsWaitToAccept() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถลบข้อมูลสินค้าได้เนื่องจากใบรับรองผู้ผลิตของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToRecordBecauseMnCertIsExpire() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถบันทึกการผลิตได้เนื่องจากใบรับรองผู้ผลิตของท่านหมดอายุ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToRecordBecauseMnCertIsWaitToAccept() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถบันทึกการผลิตได้เนื่องจากใบรับรองผู้ผลิตของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToUpdateBecauseMnCertIsExpire() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถแก้ไขข้อมูลสินค้าได้เนื่องจากใบรับรองการผลิตของท่านหมดอายุ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showErrorToUpdateBecauseMnCertIsWaitToAccept() {
    QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถแก้ไขข้อมูลสินค้าได้เนื่องจากใบรับรองผู้ผลิตของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          Navigator.pop(context);
        });
  }

  void showConfirmToDeleteAlert(String manufacturingId) async {
    print(manufacturingId);
    QuickAlert.show(
        context: context,
        showCancelBtn: true,
        title: "คุณแน่ใจหรือไม่?",
        text: "ว่าต้องการที่จะลบการผลิตสินค้า",
        type: QuickAlertType.warning,
        confirmBtnText: "ตกลง",
        cancelBtnText: "ยกเลิก",
        confirmBtnColor: Colors.green,
        onCancelBtnTap: () {
          Navigator.pop(context);
        },
        onConfirmBtnTap: () async {
          print("Accept!");
          http.Response deleteManufacturingResponse =
              await manufacturingController
                  .deleteManufacturing(manufacturingId);
          if (deleteManufacturingResponse.statusCode == 500) {
            Navigator.pop(context);
            showFailToDeleteManufacturingAlert();
          } else if (deleteManufacturingResponse.statusCode == 409) {
            showFailToDeleteManufacturingBecauseConflictAlert();
          } else {
            Navigator.pop(context);
            showDeleteManufacturingSuccessAlert();
          }
        });
  }

  void showFailToDeleteManufacturingAlert() {
    QuickAlert.show(
        context: context,
        showCancelBtn: true,
        title: "เกิดข้อผิดพลาด",
        text: "ไม่สามารถทำการลบข้อมูลการผลิตสินค้าได้ กรุณาลองใหม่อีกครั้ง",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () async {
          Navigator.pop(context);
        });
  }

  void showFailToDeleteManufacturingBecauseConflictAlert() {
    QuickAlert.show(
        context: context,
        showCancelBtn: true,
        title: "เกิดข้อผิดพลาด",
        text:
            "ไม่สามารถทำการลบข้อมูลการผลิตสินค้าได้ เนื่องจากการผลิตสินค้านี้ถูกบันทึกแล้ว",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () async {
          Navigator.pop(context);
        });
  }

  void showDeleteManufacturingSuccessAlert() {
    QuickAlert.show(
        context: context,
        title: "ลบข้อมูลสำเร็จ",
        text: "ลบข้อมูลสินค้าสำเร็จ",
        type: QuickAlertType.success,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const ListManufacturingScreen()));
          });
        });
  }

  void splitManufacturingType() {
    manufacturings?.forEach((manufacturing) {
      if (manufacturing.manuftCurrBlockHash == null) {
        notRecordedManufacturings?.add(manufacturing);
      } else {
        recordedManufacturings?.add(manufacturing);
      }
    });
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
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
              drawer: ManufacturerNavbar(),
              appBar: AppBar(
                title: Text(
                  "รายการผลิตสินค้า",
                  style: TextStyle(
                    fontFamily: 'Itim',
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
                        "ยังไม่ถูกบันทึก",
                        style: TextStyle(
                          fontFamily: 'Itim',
                          fontSize: 16,
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
                        "บันทึกแล้ว",
                        style: TextStyle(fontFamily: 'Itim',
                        fontSize: 16,
                        shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],),
                      ),
                    ),
                  ],
                ),
                backgroundColor:kClipPathColorMN,
              ),
              backgroundColor: kBackgroundColor,
              body: isLoaded == false
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
                    )
                  : TabBarView(children: [
                      notRecordedManufacturings?.isNotEmpty == true? Container(
                        padding: EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: notRecordedManufacturings?.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                // leading: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [Icon(Icons.compost)],
                                // ),
                                title: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "รหัสการผลิต "+"${notRecordedManufacturings?[index].manufacturingId}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                    Text(
                                      "${notRecordedManufacturings?[index].product?.productName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                    Text(
                                      "วันที่ทำการผลิต "+"${dateFormat.format(notRecordedManufacturings?[index].manufactureDate ?? DateTime.now())}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                     Text(
                                      "ปริมาณสินค้า "+"${notRecordedManufacturings?[index].productQty}"+" ${notRecordedManufacturings?[index].productUnit}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  width: 80,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            print("Edit Pressed!");
                                            if (manufacturerCertificate
                                                        ?.mnCertExpireDate
                                                        ?.isBefore(
                                                            DateTime.now()) ==
                                                    true ||
                                                manufacturerCertificate
                                                        ?.mnCertStatus ==
                                                    "ไม่อนุมัติ") {
                                              showErrorToUpdateBecauseMnCertIsExpire();
                                            } else if (manufacturerCertificate
                                                        ?.mnCertStatus ==
                                                    "รอการอนุมัติ") {
                                              showErrorToUpdateBecauseMnCertIsWaitToAccept();
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        UpdateManufacturingScreen(
                                                            manufacturingId:
                                                                notRecordedManufacturings?[
                                                                            index]
                                                                        .manufacturingId ??
                                                                    "")),
                                              );
                                            }
                                          },
                                          child: Icon(Icons.edit)),
                                      GestureDetector(
                                          onTap: () {
                                            print("Delete Pressed!");
                                            if (manufacturerCertificate
                                                        ?.mnCertExpireDate
                                                        ?.isBefore(
                                                            DateTime.now()) ==
                                                    true ||
                                                manufacturerCertificate
                                                        ?.mnCertStatus ==
                                                    "ไม่อนุมัติ") {
                                              showErrorToDeleteBecauseMnCertIsExpire();
                                            } else if (manufacturerCertificate
                                                        ?.mnCertStatus ==
                                                    "รอการอนุมัติ") {
                                              showErrorToDeleteBecauseMnCertIsWaitToAccept();
                                            } else {
                                              showConfirmToDeleteAlert(
                                                  notRecordedManufacturings?[
                                                              index]
                                                          .manufacturingId ??
                                                      "");
                                            }
                                          },
                                          child: Icon(Icons.delete)),
                                      GestureDetector(
                                          onTap: () {
                                            print("Record Pressed!");
                                            if (manufacturerCertificate
                                                        ?.mnCertExpireDate
                                                        ?.isBefore(
                                                            DateTime.now()) ==
                                                    true ||
                                                manufacturerCertificate
                                                        ?.mnCertStatus ==
                                                    "ไม่อนุมัติ") {
                                              showErrorToRecordBecauseMnCertIsExpire();
                                            } else if (manufacturerCertificate
                                                        ?.mnCertStatus ==
                                                    "รอการอนุมัติ") {
                                              showErrorToRecordBecauseMnCertIsWaitToAccept();
                                            } else {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        RecordManufacturingScreen(
                                                            manufacturingId:
                                                                notRecordedManufacturings?[
                                                                            index]
                                                                        .manufacturingId ??
                                                                    "")),
                                              );
                                            }
                                          },
                                          child: Icon(Icons.save))
                                    ],
                                  ),
                                ),
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
                                image: AssetImage("images/corn_action1.png"),
                              ),
                              Text(
                                "ไม่มีการผลิตสินค้าที่ไม่ถูกบันทึก",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      recordedManufacturings?.isNotEmpty == true? Container(
                        padding: EdgeInsets.all(10.0),
                        child: ListView.builder(
                          itemCount: recordedManufacturings?.length,
                          scrollDirection: Axis.vertical,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                // leading: Column(
                                //   mainAxisAlignment: MainAxisAlignment.center,
                                //   children: [Icon(Icons.compost)],
                                // ),
                                title: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "รหัสการผลิต "+"${recordedManufacturings?[index].manufacturingId}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                    Text(
                                      "${recordedManufacturings?[index].product?.productName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                    Text(
                                      "วันที่ทำการผลิต ${dateFormat.format(recordedManufacturings?[index].manufactureDate ?? DateTime.now())}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                    Text(
                                      "ปริมาณสินค้า ${recordedManufacturings?[index].productQty} ${recordedManufacturings?[index].productUnit}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim', fontSize: 20),
                                    ),
                                 
                                    
                                  ],
                                ),
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
                                image: AssetImage("images/corn_action2.png"),
                              ),
                              Text(
                                "ไม่มีการผลิตสินค้าที่ถูกบันทึก",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      )
                    ])),
        ),
      ),
    );
  }
}
