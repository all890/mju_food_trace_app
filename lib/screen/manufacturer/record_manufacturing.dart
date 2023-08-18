import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/controller/manufacturing_controller.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';

import '../../constant/constant.dart';
import '../../model/manufacturing.dart';
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
                                      color: Color.fromARGB(255, 33, 82, 35)
                                    ),
                                  ),
                                ),
                                const Padding(
                    padding: EdgeInsets.only(left: 15, bottom: 8, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "รายละเอียดการผลิต",
                        style: TextStyle(fontSize: 22, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "รหัสผลผลิตที่นำมาใช้ : " +
                            "${manufacturings?.rawMaterialShipping?.rawMatShpId}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "ชื่อของผลผลิต : " +
                            "${manufacturings?.rawMaterialShipping?.planting?.plantName}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "จำนวนของผลผลิตที่ใช้ในการผลิตสินค้า : " +
                            "${manufacturings?.rawMaterialShipping?.rawMatShpQty}" +
                            " " +
                            "${manufacturings?.rawMaterialShipping?.rawMatShpQtyUnit}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "ผลิตเป็นสินค้า : " +
                            "${manufacturings?.product?.productName}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "จำนวนสินค้าที่ได้ : " +
                            "${manufacturings?.productQty}" +
                            " " +
                            "${manufacturings?.productUnit}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "วันที่ผลิตสินค้า : " +
                            "${dateFormat.format(manufacturings?.manufactureDate ?? DateTime.now())}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "วันหมดอายุของสินค้า : " +
                            "${dateFormat.format(manufacturings?.expireDate ?? DateTime.now())}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "คำเตือน กรุณาตรวจสอบข้อมูลข้างต้นให้เรียบร้อยหลังจากที่ทำการบันทึกจะไม่สามารถแก้ไขข้อมูลได้อีก",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim',color: Colors.red),
                        
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
