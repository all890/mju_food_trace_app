import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
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

  var dateFormat = DateFormat('dd-MM-yyyy');

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
    }
    splitRmsByType();
    setState(() {
      isLoaded = true;
    });
    print(raw_material_shippings?.length);
    print(remQtyOfRms);
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
                title: const Text("LIST ALL SENT AGRICULTURAL PRODUCTS"),
                bottom: const TabBar(
                  tabs: [
                    Tab(
                      child: Text(
                        "ผลผลิตที่ไม่เคยใช้",
                        style: TextStyle(
                          fontFamily: 'Itim'
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "ผลผลิตคงเหลือ",
                        style: TextStyle(
                          fontFamily: 'Itim'
                        ),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "ครบจำนวน",
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
                            title: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ส่ง : " +
                                      "${notUsedRms?[index].planting?.plantName}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "รหัสการส่งผลผลิต : " +
                                      "${notUsedRms?[index].planting?.plantingId}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "จาก : " +
                                      "${notUsedRms?[index].planting?.farmer?.farmName}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "วันที่ส่ง : " +
                                      "${dateFormat.format(notUsedRms?[index].rawMatShpDate ?? DateTime.now())}" +
                                      " จำนวน : " +
                                      "${notUsedRms?[index].rawMatShpQty}" +
                                      " " +
                                      "${notUsedRms?[index].rawMatShpQtyUnit}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                              ],
                            ),
                            onTap: () {
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
                            title: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ส่ง : " +
                                      "${usedRms?[index].planting?.plantName}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "รหัสการส่งผลผลิต : " +
                                      "${usedRms?[index].planting?.plantingId}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "จาก : " +
                                      "${usedRms?[index].planting?.farmer?.farmName}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "วันที่ส่ง : " +
                                      "${dateFormat.format(usedRms?[index].rawMatShpDate ?? DateTime.now())}",
                                
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "ปริมาณผลผลิตคงเหลือ : ${usedRms?[index].rawMatShpQtyUnit == "กิโลกรัม"? remQtyOfRms[usedRms?[index].rawMatShpId] / 1000.0 : remQtyOfRms[usedRms?[index].rawMatShpId]} " + "${usedRms?[index].rawMatShpQtyUnit}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                )
                              ],
                            ),
                            onTap: () {
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
                            title: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ส่ง : " +
                                      "${emptyRms?[index].planting?.plantName}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "รหัสการส่งผลผลิต : " +
                                      "${emptyRms?[index].planting?.plantingId}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "จาก : " +
                                      "${emptyRms?[index].planting?.farmer?.farmName}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
                                ),
                                Text(
                                  "วันที่ส่ง : " +
                                      "${dateFormat.format(emptyRms?[index].rawMatShpDate ?? DateTime.now())}",
                                  style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 22),
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
