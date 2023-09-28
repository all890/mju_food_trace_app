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
  
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  bool? isLoaded;
  ManufacturerCertificate? manufacturerCertificate;

  List<RawMaterialShipping>? raw_material_shippings = [];

  Map<String, dynamic> remQtyOfRms = {};
  Map<String, dynamic> rmsExists = {};

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
    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true) {
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
        notUsedRms?.add(rms);
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
        length: 3,
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
                        "ผลผลิตที่ไม่เคยใช้",
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
                        "ผลผลิตคงเหลือ",
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
                  Container(
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
                                  width: 50,
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
                                          "${notUsedRms?[index].planting?.farmer?.farmerName}"+" "+"${notUsedRms?[index].planting?.farmer?.farmerLastname}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "ชื่อฟาร์ม : " +
                                          "${notUsedRms?[index].planting?.farmer?.farmName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 18),
                                    ),
                                    Text(
                                      "วันที่ส่ง : " +
                                          "${dateFormat.format(notUsedRms?[index].rawMatShpDate ?? DateTime.now())}",
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

                              var response = await rawMaterialShippingController.isRmsAndPlantingChainValid(notUsedRms?[index].rawMatShpId??"");

                              if (response == 200) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddManufacturingScreen(
                                              rawMatShpId: notUsedRms?[index].rawMatShpId ??"",
                                              remQtyOfRms: remQtyOfRms[notUsedRms?[index].rawMatShpId],)),
                                              
                                );
                              } else if (response == 409) {
                                showCannotUseRmsBecauseChainIsInvalidError();
                              } else if (response == 500) {
                                print("Error");
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
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
                                  width: 50,
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
                                          "${usedRms?[index].planting?.farmer?.farmerName}"+" "+"${usedRms?[index].planting?.farmer?.farmerLastname}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "ชื่อฟาร์ม : " +
                                          "${usedRms?[index].planting?.farmer?.farmName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "วันที่ส่ง : " +
                                          "${dateFormat.format(usedRms?[index].rawMatShpDate ?? DateTime.now())}",
                                    
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
                              
                              var response = await rawMaterialShippingController.isRmsAndPlantingChainValid(usedRms?[index].rawMatShpId??"");

                              if (response == 200) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          AddManufacturingScreen(
                                            rawMatShpId:
                                              usedRms?[index].rawMatShpId ??"",
                                            remQtyOfRms: remQtyOfRms[usedRms?[index].rawMatShpId],)),
                                );
                              } else if (response == 409) {
                                showCannotUseRmsBecauseChainIsInvalidError();
                              } else if (response == 500) {
                                print("Error!");
                              }
                              
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
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
                                  width: 50,
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "ผลผลิตที่ส่งมา : " +
                                          "${emptyRms?[index].planting?.plantName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "จาก : " +
                                          "${emptyRms?[index].planting?.farmer?.farmerName}"+" "+"${emptyRms?[index].planting?.farmer?.farmerLastname}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "ชื่อฟาร์ม : " +
                                          "${emptyRms?[index].planting?.farmer?.farmName}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "วันที่ส่ง : " +
                                          "${dateFormat.format(emptyRms?[index].rawMatShpDate ?? DateTime.now())}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    ),
                                    Text(
                                      "ผลผลิตที่ใช้ : "+"${emptyRms?[index].rawMatShpQty}"+" ${emptyRms?[index].rawMatShpQtyUnit}",
                                      style: const TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
