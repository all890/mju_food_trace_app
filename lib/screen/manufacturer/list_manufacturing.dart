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
  State<ListManufacturingScreen> createState() => _ListManufacturingScreenState();
}

class _ListManufacturingScreenState extends State<ListManufacturingScreen> {
  ManufacturingController manufacturingController = ManufacturingController();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  bool? isLoaded;
  ManufacturerCertificate? manufacturerCertificate;

  List<Manufacturing>? manufacturings = [];

  List<Manufacturing>? recordedManufacturings = [];
  List<Manufacturing>? notRecordedManufacturings = [];

  var dateFormat = DateFormat('dd-MM-yyyy');

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    manufacturings = await manufacturingController.getListAllManufacturingUsername(username);
    var manuftCertResponse = await manufacturerCertificateController.getLastestManufacturerCertificateByManufacturerUsername(username);
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(manuftCertResponse);
    splitManufacturingType();
    setState(() {
      isLoaded = true;
    });
    print(manufacturings?.length);
  }

  void showErrorToDeleteBecauseMnCertIsExpire () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถลบข้อมูลสินค้าได้เนื่องจากใบรับรองการผลิตของท่านหมดอายุ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void showErrorToRecordBecauseMnCertIsExpire () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถบันทึกการผลิตได้ เนื่องจากใบรับรองผู้ผลิตของท่านหมดอายุ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void showErrorToUpdateBecauseMnCertIsExpire () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถแก้ไขข้อมูลสินค้าได้เนื่องจากใบรับรองการผลิตของท่านหมดอายุ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void showConfirmToDeleteAlert (String manufacturingId) async {
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
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("Accept!");
        http.Response deleteManufacturingResponse = await manufacturingController.deleteManufacturing(manufacturingId);
        if (deleteManufacturingResponse.statusCode == 500) {
          Navigator.pop(context);
          showFailToDeleteManufacturingAlert();
        } else if (deleteManufacturingResponse.statusCode == 409) {
          showFailToDeleteManufacturingBecauseConflictAlert();
        } else {
          Navigator.pop(context);
          showDeleteManufacturingSuccessAlert();
        }
      }
    );
  }

  void showFailToDeleteManufacturingAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถทำการลบข้อมูลการผลิตสินค้าได้ กรุณาลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () async {
        Navigator.pop(context);
      }
    );
  }

  void showFailToDeleteManufacturingBecauseConflictAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถทำการลบข้อมูลการผลิตสินค้าได้ เนื่องจากการผลิตสินค้านี้ถูกบันทึกแล้ว",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () async {
        Navigator.pop(context);
      }
    );
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManufacturingScreen()));
        });
      }
    );
  }

  void splitManufacturingType () {
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
              title: const Text("LIST MANUFACTURINGS"),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "ยังไม่ถูกบันทึก",
                      style: TextStyle(
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  Tab(
                    child: Text(
                      "บันทึกแล้ว",
                      style: TextStyle(
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
            ),
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
            TabBarView(
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: notRecordedManufacturings?.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.place)
                            ],
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${notRecordedManufacturings?[index].product?.productName}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 22
                                ),
                              ),
                                  Text(
                                "${dateFormat.format(notRecordedManufacturings?[index].manufactureDate ?? DateTime.now())}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 22
                                ),
                              ),
                            ],
                          ),
                          trailing: SizedBox(
                            width: 80,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print("Edit Pressed!");
                                    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true || manufacturerCertificate?.mnCertStatus != "อนุมัติ") {
                                      showErrorToUpdateBecauseMnCertIsExpire();
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => UpdateManufacturingScreen(manufacturingId: notRecordedManufacturings?[index].manufacturingId ?? "")),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.edit)
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("Delete Pressed!");
                                    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true || manufacturerCertificate?.mnCertStatus != "อนุมัติ") {
                                      showErrorToDeleteBecauseMnCertIsExpire();
                                    } else {
                                      showConfirmToDeleteAlert(notRecordedManufacturings?[index].manufacturingId ?? "");
                                    }
                                  },
                                  child: Icon(Icons.delete)
                                ),
                                  GestureDetector(
                                  onTap: () {
                                    print("Record Pressed!");
                                    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true || manufacturerCertificate?.mnCertStatus != "อนุมัติ") {
                                      showErrorToRecordBecauseMnCertIsExpire();
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => RecordManufacturingScreen(manufacturingId: notRecordedManufacturings?[index].manufacturingId ?? "")),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.save)
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: recordedManufacturings?.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.place)
                            ],
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${recordedManufacturings?[index].product?.productName}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 22
                                ),
                              ),
                                  Text(
                                "${dateFormat.format(recordedManufacturings?[index].manufactureDate ?? DateTime.now())}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 22
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              ]
            )
          ),
        ),
      ),
    );
  }
}