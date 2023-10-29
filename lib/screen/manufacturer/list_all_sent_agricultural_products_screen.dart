import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/controller/raw_material_shipping_controller.dart';
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';
import 'package:mju_food_trace_app/screen/manufacturer/add_manufacturing_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/request_renewing_manufacturer_certificate_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../model/manufacturer_certificate.dart';
import '../../service/config_service.dart';
import '../../widgets/buddhist_year_converter.dart';
import 'list_manufacturing.dart';
import 'navbar_manufacturer.dart';

class ListAllSentAgriculturalProductsScreen extends StatefulWidget {
  const ListAllSentAgriculturalProductsScreen({super.key});

  @override
  State<ListAllSentAgriculturalProductsScreen> createState() =>
      _ListAllSentAgriculturalProductsScreenState();
}

class _ListAllSentAgriculturalProductsScreenState extends State<ListAllSentAgriculturalProductsScreen> {
  RawMaterialShippingController rawMaterialShippingController =
      RawMaterialShippingController();
  
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  bool? isLoaded;
  ManufacturerCertificate? manufacturerCertificate;

  List<RawMaterialShipping>? raw_material_shippings = [];

  Map<String, dynamic> remQtyOfRms = {};
  Map<String, dynamic> rmsExists = {};

  List<RawMaterialShipping>? newRms = [];
  List<RawMaterialShipping>? notUsedRms = [];
  List<RawMaterialShipping>? usedRms = [];
  List<RawMaterialShipping>? emptyRms = [];

  var dateFormat = DateFormat('dd-MMM-yyyy');

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    raw_material_shippings = await rawMaterialShippingController
        .getListAllSentAgriByUsername(username);
    var responseManuftCert = await manufacturerCertificateController.getLastestManufacturerCertificateByManufacturerUsername(username);
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(responseManuftCert);
    var remQtyOfRmsResponse = await rawMaterialShippingController.getRemQtyOfRmsByManufacturerUsername(username);
    var rmsExistResponse = await rawMaterialShippingController.getRmsExistInManufacturingByManutftUsername(username);
    remQtyOfRms = json.decode(remQtyOfRmsResponse);
    rmsExists = json.decode(rmsExistResponse);
    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true && !(manufacturerCertificate?.mnCertExpireDate?.difference(DateTime.now()).inDays == 0)) {
      showMnCertExpireError();
    } else if (manufacturerCertificate?.mnCertStatus == "รอการอนุมัติ") {
      showMnCertIsWaitAcceptError();
    } else if (manufacturerCertificate?.mnCertStatus == "ไม่อนุมัติ") {
      showMnCertWasRejectedError();
    }
    splitRmsByType();
    setState(() {
      isLoaded = true;
    });
    raw_material_shippings?.forEach((element) {
      print(element.rawMatShpDate);
    });
  }

  void showMnCertWasRejectedError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มสินค้าได้ เนื่องจากใบรับรองเกษตรกรของท่านถูกปฏิเสธโดยผู้ดูแลระบบเนื่องจากข้อมูลที่ไม่ถูกต้อง กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingManufacturerCertificateScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showMnCertIsWaitAcceptError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มการปลูกได้ เนื่องจากใบรับรองเกษตรกรของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManufacturingScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showMnCertExpireError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มการผลิตสินค้าได้ เนื่องจากใบรับรองผู้ผลิตของท่านหมดอายุ กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingManufacturerCertificateScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showCannotUseRmsBecauseChainIsInvalidError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถใช้ผลผลิตที่เลือกได้ เนื่องจากข้อมูลในการเข้ารหัสไม่ตรงกัน",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void splitRmsByType () {
    raw_material_shippings?.forEach((rms) {
      if (rmsExists.containsKey(rms.rawMatShpId)) {
        if (remQtyOfRms[rms.rawMatShpId] <= 0) {
          emptyRms?.add(rms);
        } else {
          usedRms?.add(rms);
        }
      } else {
        if (rms.rmsCurrBlockHash == null) {
          newRms?.add(rms);
        } else if (rms.status != "ถูกปฏิเสธ") {
          notUsedRms?.add(rms);
        }
      }
      
    });
  }

  void showError (String prompt) {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: prompt,
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
    );
  }

  void showSuccess (String prompt) {
    QuickAlert.show(
      context: context,
      title: "สำเร็จ",
      text: prompt,
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ListAllSentAgriculturalProductsScreen()),
        );
      },
    );
  }

  void showSureToAcceptRmsAlert (String? rawMatShpId) {
    QuickAlert.show(
      context: context,
      title: "แน่ใจหรือไม่",
      text: "คุณต้องการที่จะรับผลผลิตนี้หรือไม่?",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      onConfirmBtnTap: () async {
        
        var response = await rawMaterialShippingController.acceptRms(rawMatShpId ?? "");
        if (response == 200) {
          Navigator.pop(context);
          showSuccess("ยืนยันการรับผลผลิตสำเร็จ");
        } else {
          Navigator.pop(context);
          showError("ไม่สามารถยืนยันการรับผลผลิตได้ กรุณาลองใหม่อีกครั้ง");
        }

      },
      onCancelBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showSureToNotAcceptRmsAlert (String? rawMatShpId) {
    QuickAlert.show(
      context: context,
      title: "แน่ใจหรือไม่",
      text: "คุณต้องการที่จะปฎิเสธการรับผลผลิตนี้หรือไม่?",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      onConfirmBtnTap: () async {
        
        var response = await rawMaterialShippingController.declineRms(rawMatShpId ?? "");
        if (response == 200) {
          Navigator.pop(context);
          showSuccess("ปฎิเสธการรับผลผลิตสำเร็จ");
        } else {
          Navigator.pop(context);
          showError("ไม่สามารถปฎิเสธการรับผลผลิตได้ กรุณาลองใหม่อีกครั้ง");
        }

      },
      onCancelBtnTap: () {
        Navigator.pop(context);
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
      child: DefaultTabController(
        length: 4,
        child: SafeArea(
          child: Scaffold(
              drawer: ManufacturerNavbar(),
              appBar: AppBar(
                title:Text("รายการผลผลิตที่ถูกส่งจากเกษตรกร",style:  TextStyle(fontFamily: 'Itim',
                        shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],),),
                bottom:TabBar(
                  tabs: [
                    Tab(
                      child: Text(
                        "ส่งมาใหม่",
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
                        "ไม่เคยใช้",
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
                        "คงเหลือ",
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
                        "ครบจำนวน",
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
                  ],
                ),
                backgroundColor: kClipPathColorMN,
              ),
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
              )
              :
              TabBarView(
                children: [
                  newRms?.isNotEmpty == true? Container(
                    padding: EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: newRms?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                           
                            Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(10)),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: SizedBox(
                                        child: Image.network(baseURL + '/planting/${newRms?[index].planting?.plantingImg ?? ""}'),
                                        width: 100,
                                        height: 100,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 25,
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                         
                                        Text(
                                          "${newRms?[index].planting?.plantName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20),
                                        ),
                                      
                                        Text(
                                          "จาก : " +
                                              "${newRms?[index].planting?.farmerCertificate?.farmer?.farmerName}"+" "+"${newRms?[index].planting?.farmerCertificate?.farmer?.farmerLastname}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "ชื่อฟาร์ม : " +
                                              "${newRms?[index].planting?.farmerCertificate?.farmer?.farmName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 18),
                                        ),
                                        Text(
                                          "วันที่ส่ง : " +
                                              "${buddhistYearConverter.convertDateTimeToBuddhistDate(newRms?[index].rawMatShpDate ?? DateTime.now())}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 18),
                                        ),
                                         Text(
                                          "จำนวน : " +
                                              "${newRms?[index].rawMatShpQty}" +
                                              " " +
                                              "${newRms?[index].rawMatShpQtyUnit}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, right: 4),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      child: SizedBox(
                                        width: 45,
                                        height: 60,
                                        child: Container(
                                          child: Icon(Icons.done),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.only(topRight: Radius.circular(10))
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        print("Hi! ${newRms?[index].rawMatShpId}");
                                        showSureToAcceptRmsAlert(newRms?[index].rawMatShpId);
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      child: SizedBox(
                                        width: 45,
                                        height: 60,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))
                                          ),
                                          child: Icon(Icons.close),
                                        ),
                                      ),
                                      onTap: () {
                                        print("Hi! 2 ${newRms?[index].rawMatShpId}");
                                        showSureToNotAcceptRmsAlert(newRms?[index].rawMatShpId);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ) : Center(
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            height: 350,
                            width: 350,
                            image: AssetImage("images/bean_action3.png"),
                          ),
                          Text(
                            "ไม่มีผลผลิตที่ส่งมาใหม่",
                            style:
                                TextStyle(fontFamily: "Itim", fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  notUsedRms?.isNotEmpty == true? Container(
                    padding: EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: notUsedRms?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10)),
                          child: ListTile(
                            title: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    child: Image.network(baseURL + '/planting/${notUsedRms?[index].planting?.plantingImg ?? ""}'),
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                     
                                    Text(
                                      "ผลผลิตที่ส่งมา : " +
                                          "${notUsedRms?[index].planting?.plantName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                  
                                    Text(
                                      "จาก : " +
                                          "${notUsedRms?[index].planting?.farmerCertificate?.farmer?.farmerName}"+" "+"${notUsedRms?[index].planting?.farmerCertificate?.farmer?.farmerLastname}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "ชื่อฟาร์ม : " +
                                          "${notUsedRms?[index].planting?.farmerCertificate?.farmer?.farmName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "วันที่ส่ง : " +
                                          "${buddhistYearConverter.convertDateTimeToBuddhistDate(notUsedRms?[index].rawMatShpDate ?? DateTime.now())}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 18),
                                    ),
                                     Text(
                                      "จำนวน : " +
                                          "${notUsedRms?[index].rawMatShpQty}" +
                                          " " +
                                          "${notUsedRms?[index].rawMatShpQtyUnit}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () async {
                              print(notUsedRms?[index]
                                  .rawMatShpId);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AddManufacturingScreen(
                                            rawMatShpId: notUsedRms?[index].rawMatShpId ??"",
                                            remQtyOfRms: remQtyOfRms[notUsedRms?[index].rawMatShpId],)),
                                            
                              );
                              
                              /*
                              var response = await rawMaterialShippingController.isRmsAndPlantingChainValid(notUsedRms?[index].rawMatShpId??"");

                              if (response == 200) {
                                
                              } else if (response == 409) {
                                showCannotUseRmsBecauseChainIsInvalidError();
                              } else if (response == 500) {
                                print("Error");
                              }
                              */
                            },
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
                            image: AssetImage("images/bean_action3.png"),
                          ),
                          Text(
                            "ไม่มีผลผลิตที่ยังไม่เคยใช้",
                            style:
                                TextStyle(fontFamily: "Itim", fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  usedRms?.isNotEmpty == true? Container(
                    padding: EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: usedRms?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10)),
                          child: ListTile(
                            title: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    child: Image.network(baseURL + '/planting/${usedRms?[index].planting?.plantingImg ?? ""}'),
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                SizedBox(
                                  width: 25,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ผลผลิตที่ส่งมา : " +
                                          "${usedRms?[index].planting?.plantName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "จาก : " +
                                          "${usedRms?[index].planting?.farmerCertificate?.farmer?.farmerName}"+" "+"${usedRms?[index].planting?.farmerCertificate?.farmer?.farmerLastname}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "ชื่อฟาร์ม : " +
                                          "${usedRms?[index].planting?.farmerCertificate?.farmer?.farmName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "วันที่ส่ง : " +
                                          "${buddhistYearConverter.convertDateTimeToBuddhistDate(usedRms?[index].rawMatShpDate ?? DateTime.now())}",
                                    
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "คงเหลือ : ${usedRms?[index].rawMatShpQtyUnit == "กิโลกรัม"? remQtyOfRms[usedRms?[index].rawMatShpId] / 1000.0 : remQtyOfRms[usedRms?[index].rawMatShpId]} " + "${usedRms?[index].rawMatShpQtyUnit}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            onTap: () async {
                              print(usedRms?[index]
                                  .rawMatShpId);
                              
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddManufacturingScreen(
                                            rawMatShpId:
                                              usedRms?[index].rawMatShpId ??"",
                                            remQtyOfRms: remQtyOfRms[usedRms?[index].rawMatShpId],)),
                                );

                              /*
                              var response = await rawMaterialShippingController.isRmsAndPlantingChainValid(usedRms?[index].rawMatShpId??"");

                              if (response == 200) {
                                
                              } else if (response == 409) {
                                showCannotUseRmsBecauseChainIsInvalidError();
                              } else if (response == 500) {
                                print("Error!");
                              }
                              */
                              
                            },
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
                            image: AssetImage("images/bean_action6.png"),
                          ),
                          Text(
                            "ไม่มีผลผลิตที่คงเหลือ",
                            style:
                                TextStyle(fontFamily: "Itim", fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                  emptyRms?.isNotEmpty == true? Container(
                    padding: EdgeInsets.all(10.0),
                    child: ListView.builder(
                      itemCount: emptyRms?.length,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10)),
                          child: ListTile(
                            title: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    child: Image.network(baseURL + '/planting/${emptyRms?[index].planting?.plantingImg ?? ""}'),
                                    width: 100,
                                    height: 100,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "ผลผลิตที่ส่งมา : ",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            "${emptyRms?[index].planting?.plantName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "จาก : ",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                              "${emptyRms?[index].planting?.farmerCertificate?.farmer?.farmerName}"+" "+"${emptyRms?[index].planting?.farmerCertificate?.farmer?.farmerLastname}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "ชื่อฟาร์ม : ",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                              "${emptyRms?[index].planting?.farmerCertificate?.farmer?.farmName}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                         Text(
                                          "วันที่ส่ง : ",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${buddhistYearConverter.convertDateTimeToBuddhistDate(emptyRms?[index].rawMatShpDate ?? DateTime.now())}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "ผลผลิตที่ใช้ : ",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "${emptyRms?[index].rawMatShpQty}"+" ${emptyRms?[index].rawMatShpQtyUnit}",
                                          style: const TextStyle(
                                              fontFamily: 'Itim',
                                              fontSize: 20),
                                        ),
                                      ],
                                    )
                                  ],
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
                            image: AssetImage("images/bean_action7.png"),
                          ),
                          Text(
                            "ไม่มีผลผลิตที่ใช้ครบจำนวน",
                            style:
                                TextStyle(fontFamily: "Itim", fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              )     
          ),
        ),
      ),
    );
  }
}
