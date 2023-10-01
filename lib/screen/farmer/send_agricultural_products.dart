import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/controller/raw_material_shipping_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../constant/constant.dart';
import '../../controller/planting_controller.dart';
import '../../model/planting.dart';
import '../../service/config_service.dart';
import '../../widgets/autocomplete_widget.dart';
import '../../widgets/custom_text_form_field_widget.dart';
import 'list_planting_farmer_screen.dart';

class SendAgriculturalProducts extends StatefulWidget {
  final String plantingId;
  final double? remQtyOfPt;
  const SendAgriculturalProducts({Key? key, required this.plantingId, this.remQtyOfPt})
      : super(key: key);

  @override
  State<SendAgriculturalProducts> createState() =>
      _SendAgriculturalProductsState();
}

class _SendAgriculturalProductsState extends State<SendAgriculturalProducts> {
  PlantingController plantingController = PlantingController();
  ManufacturerController manufacturerController = ManufacturerController();
  RawMaterialShippingController rawMaterialShippingController = RawMaterialShippingController();

  List<String> rawMatShpQtyUnit_items = [
    "หน่วยของปริมาณผลผลิตสุทธิ",
    "กรัม",
    "กิโลกรัม"
  ];
 
  List<Manufacturer>? manufacturers;
  List<String>? manuftNames = [];
  final List<String> itemList=[]; // Li
 
  String? selected_rawMatShpQtyUnit_items = "หน่วยของปริมาณผลผลิตสุทธิ";

  TextEditingController rawMatShpDateTextController = TextEditingController();
  TextEditingController rawMatShpQtyTextController = TextEditingController();
  TextEditingController manuftIdTextController = TextEditingController();

  DateTime currentDate = DateTime.now();
  DateTime? plantDate;
  DateTime? approxHarvDate;

  bool? isLoaded;
  Planting? planting;
  String imgPlantingFileName = "";
  String? selectedManuftName = "";
  String? textSelectedManuftName = "";
  var dateFormat = DateFormat('dd-MM-yyyy');
  var newDateFormat = DateFormat('dd-MMM-yyyy');

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;


  
  TextEditingController plantingImgTextController = TextEditingController();
  
  void fetchName(){
    manufacturers?.forEach((manuft) {
      String manuftName = manuft.manuftName??"";
      manuftNames?.add(manuftName);
    });

    print(manuftNames?.length);
  }

  void fetchDateTimeNow () {
    rawMatShpDateTextController.text = dateFormat.format(DateTime.now());
  }

  void showManuftNameIsEmptyError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "กรุณากรอกชื่อผู้ผลิตที่ต้องการส่งผลผลิต",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showManuftNameIsNotAvailable () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่พบชื่อผู้ผลิตที่ต้องการส่งผลผลิตในระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showSelectedRawMatShpQtyUnitIsEmptyError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "กรุณาเลือกหน่วยของปริมาณผลผลิตที่ต้องการส่ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void fetchData(String plantingId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await plantingController.getPlantingrDetails(plantingId);
    manufacturers = await manufacturerController.getListAllManufacturer();
    fetchName();
    fetchDateTimeNow();
    planting = Planting.fromJsonToPlanting(response);
    String filePath = planting?.plantingImg ?? "";

    print(filePath);
    imgPlantingFileName =
        filePath.substring(filePath.lastIndexOf('/') + 1, filePath.length) ??
            "";
    print(imgPlantingFileName);

    plantingImgTextController.text = imgPlantingFileName;

    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData(widget.plantingId);
    
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
          Center(
            child: SingleChildScrollView(
              child: Center(
                child: Form(
                  key: formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
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
                                            return const ListPlantingScreen();
                                          }));
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_back),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "กลับไปหน้ารายการปลูก",
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
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Text(
                                    "ส่งข้อมูลปลูกผลผลิต",
                                    style: TextStyle(
                                        fontSize: 22, fontFamily: 'Itim'),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "รายละเอียดการปลูก",
                                      style: TextStyle(
                                          fontSize: 22, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                               fileToDisplay == null
                                    ? Padding(
                                      padding: const EdgeInsets.only(top: 25, bottom: 25),
                                      child: SizedBox(
                                            width: 300,
                                            height: 300,
                                          child: Image.network(baseURL +
                                              '/planting/' +
                                              imgPlantingFileName)),
                                    )
                                    : Padding(
                                      padding: const EdgeInsets.only(top: 25, bottom: 25),
                                      child: SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: Image.file(fileToDisplay!)),
                                    ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ชื่อของผลผลิตที่ปลูก : " +
                                          "${planting?.plantName}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "วันที่ปลูกผลผลิต : " +
                                          "${newDateFormat.format(planting?.plantDate ?? DateTime.now())}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ประเภทของน้ำหมัก : " +
                                          "${planting?.bioextract}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "วิธีการปลูก : " +
                                          "${planting?.plantingMethod}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "วันที่คาดว่าจะเก็บเกี่ยว : " +
                                          "${newDateFormat.format(planting?.approxHarvDate ?? DateTime.now())}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                planting?.ptCurrBlockHash == null ?
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ปริมาณผลผลิตสุทธิ : " +
                                          "${planting?.netQuantity}" +
                                          " " +
                                          "${planting?.netQuantityUnit}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ) :
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ปริมาณผลผลิตคงเหลือ : " +
                                          "${widget.remQtyOfPt}" +
                                          " " +
                                          "${planting?.netQuantityUnit}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "จำนวนตารางเมตร : " +
                                          "${planting?.squareMeters}" +
                                          " ตารางเมตร",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "จำนวนตารางวา: " +
                                          "${planting?.squareYards}" +
                                          " ตารางวา",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 2),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "จำนวนไร่: " +
                                          "${planting?.rai}" +
                                          " ไร่",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ข้อมูลการส่งผลผลิต",
                                      style: TextStyle(
                                          fontSize: 22, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                const Center(
                                  
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "ค้นหาผู้ผลิตที่ต้องการจะส่งผลผลิต",
                                        style: TextStyle(
                                            fontSize: 16, fontFamily: 'Itim'),
                                      ),
                                    ),
                                  ),
                                ),
                                  AutoCompleteStateful(
                                    itemList:manuftNames??itemList,
                                    onItemChanged: (e) {
                                      selectedManuftName = e;
                                    },
                                    onTextChanged: (v) {
                                      textSelectedManuftName = v;
                                      print(textSelectedManuftName);
                                    },
                                  ),
                              
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    readOnly: true,
                                    enabled: false,
                                    controller: rawMatShpDateTextController,
                                    decoration: InputDecoration(
                                        labelText: "วันที่ส่งผลผลิต",
                                        counterText: "",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        prefixIcon:
                                            const Icon(Icons.calendar_month),
                                        prefixIconColor: Colors.black),
                                    style: const TextStyle(
                                        fontFamily: 'Itim', fontSize: 18),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "กรุณาเลือกวันที่ส่งผลผลิต";
                                      }
                                    },
                                  ),
                                ),
                                CustomTextFormField(
                                    controller: rawMatShpQtyTextController,
                                    hintText: "ปริมาณผลผลิตที่ส่ง",
                                    maxLength: 10,
                                    numberOnly: true,
                                    validator: (value) {

                                      if (value!.isEmpty) {
                                        return "กรุณากรอกปริมาณผลผลิต";
                                      }

                                      if (double.parse(value) <= 0) {
                                        return "กรุณากรอกปริมาณผลผลิตให้มากกว่า 0";
                                      }

                                      if (planting?.ptCurrBlockHash == null) {
                                        double actualGrams = 0;

                                        if (selected_rawMatShpQtyUnit_items == "กิโลกรัม") {
                                          actualGrams = double.parse(rawMatShpQtyTextController.text??"0") * 1000;
                                        } else if (selected_rawMatShpQtyUnit_items == "กรัม") {
                                          actualGrams = double.parse(rawMatShpQtyTextController.text??"0");
                                        }

                                        double ptNetQuantityGrams = 0;

                                        print(planting?.netQuantityUnit);

                                        if (planting?.netQuantityUnit == "กิโลกรัม") {
                                          ptNetQuantityGrams = (planting?.netQuantity??0) * 1000.0;
                                          print("kg : ${ptNetQuantityGrams}");
                                        } else if (planting?.netQuantityUnit == "กรัม") {
                                          ptNetQuantityGrams = planting?.netQuantity??0;
                                        }

                                        if (actualGrams > ptNetQuantityGrams) {
                                          return "ปริมาณผลผลิตที่ส่งต้องไม่เกินปริมาณผลผลิตของการปลูกที่เลือกส่ง";
                                        }
                                      } else {
                                        double actualGrams2 = 0;

                                        if (selected_rawMatShpQtyUnit_items == "กิโลกรัม") {
                                          actualGrams2 = double.parse(rawMatShpQtyTextController.text??"0") * 1000;
                                        } else if (selected_rawMatShpQtyUnit_items == "กรัม") {
                                          actualGrams2 = double.parse(rawMatShpQtyTextController.text??"0");
                                        }

                                        double ptNetQuantityGrams2 = 0;

                                        print(widget.remQtyOfPt);

                                        if (planting?.netQuantityUnit == "กิโลกรัม") {
                                          ptNetQuantityGrams2 = widget.remQtyOfPt! * 1000.0;
                                        } else if (planting?.netQuantityUnit == "กรัม") {
                                          ptNetQuantityGrams2 = widget.remQtyOfPt!;
                                        }

                                        if (actualGrams2 > ptNetQuantityGrams2) {
                                          return "ปริมาณผลผลิตที่ส่งต้องไม่เกินปริมาณผลผลิตคงเหลือของการปลูก";
                                        }
                                      }

                                    },
                                    icon: const Icon(Icons.bubble_chart)),

                                      Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SizedBox(
                                    width: 393,
                                    height: 64,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: DropdownButtonFormField<String>(
                                             value: selected_rawMatShpQtyUnit_items,
                                    icon: const Icon(Icons.expand_more),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                    
                                    items: rawMatShpQtyUnit_items
                                        .map(
                                          (String item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item)),
                                        )
                                        .toList(),
                                    onChanged: (item) => setState(() =>
                                        selected_rawMatShpQtyUnit_items = item),
                                            
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.bubble_chart),
                                              prefixIconColor: Colors.black,
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white)
                                              )
                                            ),
                                            
                                          )
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              
                               Padding(
                                 padding: const EdgeInsets.all(10.0),
                                 child: SizedBox(
                                  height: 53,
                                  width: 170,
                                   child: ElevatedButton(
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(50.0))),
                                      backgroundColor: MaterialStateProperty.all<Color>(kClipPathColorFM)
                                    ),
                                    onPressed: () async {
                                 
                                      if (textSelectedManuftName == "") {
                                        return showManuftNameIsEmptyError();
                                      }

                                      http.Response manuftNameRes = await manufacturerController.isManufacturerAvailable(textSelectedManuftName ?? "");

                                      if (manuftNameRes.statusCode == 409) {
                                        return showManuftNameIsNotAvailable();
                                      }

                                      if (selected_rawMatShpQtyUnit_items == "หน่วยของปริมาณผลผลิตสุทธิ") {
                                        return showSelectedRawMatShpQtyUnitIsEmptyError();
                                      }

                                      if (formKey.currentState!.validate()) {

                                        
                                          String? manuftId = "";
                                  
                                          manufacturers?.forEach((manufacturer) {
                                            if (manufacturer.manuftName == selectedManuftName) {
                                              manuftId = manufacturer.manuftId;
                                            }
                                          });
                                  
                                          print("actual: ${rawMatShpQtyTextController.text}, ptQty: ${planting?.netQuantity}");
                                  
                                          http.Response response = await rawMaterialShippingController.addRawMaterialShipping(
                                                manuftId??"",
                                                rawMatShpDateTextController.text,
                                                double.parse(rawMatShpQtyTextController.text),
                                                selected_rawMatShpQtyUnit_items??"",
                                                planting?.plantingId??"");
                                  
                                          if (response.statusCode == 200) {
                                            print("Add rms successfully!");
                                            Navigator.of(context).pushReplacement(
                                                MaterialPageRoute(builder:
                                                    (BuildContext context) {
                                              return const ListPlantingScreen();
                                            }));
                                          } else if (response.statusCode == 480) {
                                            print("Sum of rawMatShpQty greater than plantingNetQty");
                                          } else {
                                            print("Error!");
                                          }
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text("ส่งผลผลิต",
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

