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
import '../../constant/constant.dart';
import '../../controller/planting_controller.dart';
import '../../model/planting.dart';
import '../../service/config_service.dart';
import '../../widgets/autocomplete_widget.dart';
import '../../widgets/custom_text_form_field_widget.dart';
import 'list_planting_farmer_screen.dart';

class SendAgriculturalProducts extends StatefulWidget {
  final String plantingId;
  const SendAgriculturalProducts({Key? key, required this.plantingId})
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

 List<String> suggestons = ["โรงงานออแกนิคสาขา 1", "โรงงานออแกนิคสาขา 2", "โรงงานผลิตผักสด(สาขาแม่โจ้)", "โรงงานผักกาดดอง(ลำพูน)", "โรงงานผักกาดดอง(สาขาแม่ริม)"];
//List<String> suggestons1 = manufacturers?[index].manuftName;

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
  var dateFormat = DateFormat('dd-MM-yyyy');

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

  void fetchData(String plantingId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await plantingController.getPlantingrDetails(plantingId);
    manufacturers = await manufacturerController.getListAllManufacturer();
    fetchName();
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
          body: Center(
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "ส่งข้อมูลปลูกผลผลิต",
                                    style: TextStyle(
                                        fontSize: 22, fontFamily: 'Itim'),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                    ? SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: Image.network(baseURL +
                                            '/planting/' +
                                            imgPlantingFileName))
                                    : SizedBox(
                                        width: 300,
                                        height: 300,
                                        child: Image.file(fileToDisplay!)),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "วันที่ปลูกผลผลิต : " +
                                          "${planting?.plantDate}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "วันที่คาดว่าจะเก็บเกี่ยว : " +
                                          "${planting?.approxHarvDate}",
                                      style: TextStyle(
                                          fontSize: 18, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                  padding: EdgeInsets.symmetric(vertical: 10),
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
                                  AutoCompleteStateful(
                                    itemList:manuftNames??itemList,
                                    onItemChanged: (e) {
                                      selectedManuftName = e;
                                    },
                                  ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    onTap: () async {
                                      DateTime? tempDate = await showDatePicker(
                                          context: context,
                                          initialDate: currentDate,
                                          firstDate: DateTime(1950),
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        plantDate = tempDate;
                                        rawMatShpDateTextController.text =
                                            dateFormat.format(plantDate??DateTime.now());
                                      });
                                      print(plantDate);
                                    },
                                    readOnly: true,
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
                                    hintText: "ปริมาณผลผลิต",
                                    maxLength: 50,
                                    numberOnly: true,
                                    validator: (value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "กรุณากรอกปริมาณผลผลิต";
                                      }
                                    },
                                    icon: const Icon(Icons.bubble_chart)),
                                Center(
                                  child: DropdownButton<String>(
                                    value: selected_rawMatShpQtyUnit_items,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 3,
                                      color: Color.fromARGB(255, 51, 149, 158),
                                    ),
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
                                  ),
                                ),
                               ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(50.0))),
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                                ),
                                onPressed: () async {

                                  String? manuftId = "";

                                  manufacturers?.forEach((manufacturer) {
                                    if (manufacturer.manuftName == selectedManuftName) {
                                      manuftId = manufacturer.manuftId;
                                    }
                                  });

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

