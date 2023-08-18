import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/model/manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/record_manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/update_manufacturing_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../../controller/manufacturing_controller.dart';
import 'navbar_manufacturer.dart';

class ListManufacturingScreen extends StatefulWidget {
  const ListManufacturingScreen({super.key});

  @override
  State<ListManufacturingScreen> createState() => _ListManufacturingScreenState();
}

class _ListManufacturingScreenState extends State<ListManufacturingScreen> {
   ManufacturingController manufacturingController = ManufacturingController();

  bool? isLoaded;

  List<Manufacturing>? manufacurings;

  var dateFormat = DateFormat('dd-MM-yyyy');

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    manufacurings = await manufacturingController.getListAllManufacturingUsername(username);
    setState(() {
      isLoaded = true;
    });
    print(manufacurings?.length);
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
      child: SafeArea(
        child: Scaffold(
          drawer: ManufacturerNavbar(),
          appBar: AppBar(
            title: const Text("LIST MANUFACTURINGS"),
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
          manufacurings?.length == 0?
          Container(
            child: Text("ยังไม่มีสินค้าของคุณ")
          ) :
          Column(
            children: [
               const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "รายการการผลิตสินค้า",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Itim',
                                  color: Color.fromARGB(255, 33, 82, 35)),
                            ),
                          ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: manufacurings?.length,
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
                                "${manufacurings?[index].product?.productName}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 22
                                ),
                              ),
                                 Text(
                                "${dateFormat.format(manufacurings?[index].manufactureDate ?? DateTime.now())}",
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
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => UpdateManufacturingScreen(manufacturingId: manufacurings?[index].manufacturingId ?? "")),
                                    );
                                  },
                                  child: Icon(Icons.edit)
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("Delete Pressed!");
                                    showConfirmToDeleteAlert(manufacurings?[index].manufacturingId ?? "");
                                  },
                                  child: Icon(Icons.delete)
                                ),
                                 GestureDetector(
                                  onTap: () {
                                    print("Record Pressed!");
                                      Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => RecordManufacturingScreen(manufacturingId: manufacurings?[index].manufacturingId ?? "")),
                                    );
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
              ),
            ],
          )
        ),
      ),
    );;
  }
}