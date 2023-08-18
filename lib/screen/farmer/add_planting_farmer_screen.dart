
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/main_farmer_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../widgets/custom_text_form_field_widget.dart';
import '../register_success_screen.dart';

class AddPlantingScreen extends StatefulWidget {
  const AddPlantingScreen({super.key});

  @override
  State<AddPlantingScreen> createState() => _AddPlantingScreenState();
}

class _AddPlantingScreenState extends State<AddPlantingScreen> {
  
  final PlantingController plantingController = PlantingController();
  var dateFormat = DateFormat('dd-MM-yyyy');

  List<String> bioextract_items= ["ประเภทของน้ำหมัก","น้ำหมักทางชีวภาพจากพืช","น้ำหมักทางชีวภาพจากสัตว์","น้ำหมักชีวภาพจากเศษปลา","น้ำหมักชีวภาพจากผลไม้รสเปรี้ยว"];
  String? selected_bioextract_items = "ประเภทของน้ำหมัก";
  List<String> plantingMethod_items = ["วิธีการปลูก", "การหว่านเมล็ด","การปลูกด้วยต้นกล้า","การหยอดเมล็ด","ฝังในแปลงปลูก"];
  String? selected_plantingMethod_items  = "วิธีการปลูก";
  List<String> netQuantityUnit_items = ["หน่วยของปริมาณผลผลิตสุทธิ","กรัม","กิโลกรัม"];
  String? selected_netQuantityUnit_items  = "หน่วยของปริมาณผลผลิตสุทธิ";

  DateTime currentDate = DateTime.now();
  DateTime? plantDate;
  DateTime? approxHarvDate;

  TextEditingController plantNameTextController = TextEditingController();
  TextEditingController plantingImgTextController = TextEditingController();
  TextEditingController plantDateTextController = TextEditingController();
  TextEditingController approxHarvDateTextController = TextEditingController();
  TextEditingController netQuantityTextController = TextEditingController();
  TextEditingController squareMetersTextController = TextEditingController();
  TextEditingController squareYardsTextController = TextEditingController();
  TextEditingController raiTextController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;

  void _pickFile () async {
    try {
      setState(() {
        isLoadingPicture = true;
      });
      filePickerResult = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image
      );
      if (filePickerResult != null) {
        fileName = filePickerResult!.files.first.name;
        pickedFile = filePickerResult!.files.first;
        fileToDisplay = File(pickedFile!.path.toString());
        plantingImgTextController.text = fileName.toString();
        print("File is ${fileName}");
      }
      setState(() {
        isLoadingPicture = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void showSavePlantingSuccessAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: false,
      title: "สำเร็จ",
      text: "เพิ่มข้อมูลการปลูกสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
          });
      }
    );
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
                        borderRadius: BorderRadius.circular(10)
                      ),
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
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return const MainFarmerScreen();
                                              }
                                            )
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.arrow_back
                                            ),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "กลับไปหน้าหลัก",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 20
                                              ),
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
                                    "เพิ่มการปลูกผลผลิต",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ข้อมูลการปลูก",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Itim'
                                      ),
                                    ),
                                  ),
                                ),
                                
                                CustomTextFormField(
                                  controller: plantNameTextController,
                                  hintText: "ชื่อผลผลิตที่ปลูก",
                                  maxLength: 50,
                                  numberOnly: false,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อผลผลิตที่ปลูก";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          controller: plantingImgTextController,
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: "รูปของการปลูกผลผลิต",
                                            counterText: "",
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                            prefixIcon: const Icon(Icons.image),
                                            prefixIconColor: Colors.black
                                          ),
                                          style: const TextStyle(
                                            fontFamily: 'Itim',
                                            fontSize: 18
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _pickFile();
                                          },
                                          child: const Text("เลือกรูปภาพ"),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    onTap: () async {
                                      DateTime? tempDate = await showDatePicker(
                                        context: context,
                                        initialDate: currentDate,
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime(2100)
                                      );
                                      setState(() {
                                        plantDate = tempDate;
                                        plantDateTextController.text = dateFormat.format(plantDate!);
                                      });
                                      print(plantDate);
                                    },
                                    readOnly: true,
                                    controller: plantDateTextController,
                                    decoration: InputDecoration(
                                      labelText: "วันที่ปลูก",
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: const Icon(Icons.calendar_month),
                                      prefixIconColor: Colors.black
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 18
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "กรุณาเลือกวันวันที่ปลูก";
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextFormField(
                                    onTap: () async {
                                      DateTime? tempDate = await showDatePicker(
                                        context: context,
                                        initialDate: currentDate,
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime(2100)
                                      );
                                      setState(() {
                                        approxHarvDate = tempDate;
                                        approxHarvDateTextController.text = dateFormat.format(approxHarvDate!);
                                      });
                                      print(plantDate);
                                    },
                                    readOnly: true,
                                    controller: approxHarvDateTextController,
                                    decoration: InputDecoration(
                                      labelText: "วันที่คาดว่าจะเก็บเกี่ยว",
                                      counterText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                      prefixIcon: const Icon(Icons.calendar_month),
                                      prefixIconColor: Colors.black
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Itim',
                                      fontSize: 18
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "กรุณาเลือกวันที่คาดว่าจะเก็บเกี่ยว";
                                      }
                                    },
                                  ),
                                ),
                                Center(
                                  child: DropdownButton<String>(
                                    value: selected_bioextract_items,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                    isExpanded: true,
                                    underline: Container(
                                    height: 3,
                                    color: Color.fromARGB(255, 51, 149, 158),
                                    ),
                                    items: bioextract_items.map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item)
                                      ),
                                    ).toList(),
                                    onChanged: (item) => setState(() =>  selected_bioextract_items = item),
                                  ),
                                ),

                                 Center(
                                  child: DropdownButton<String>(
                                    value: selected_plantingMethod_items ,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                    isExpanded: true,
                                    underline: Container(
                                    height: 3,
                                    color: Color.fromARGB(255, 51, 149, 158),
                                    ),
                                    items:  plantingMethod_items.map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item)
                                      ),
                                    ).toList(),
                                    onChanged: (item) => setState(() => selected_plantingMethod_items = item),
                                  ),
                                ),

                                CustomTextFormField(
                                  controller: netQuantityTextController,
                                  hintText: "ปริมาณผลผลิตสุทธิ",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณผลผลิตสุทธิ";
                                    }
                                  },
                                  icon: const Icon(Icons.bubble_chart)
                                ),
                                
                                Center(
                                  child: DropdownButton<String>(
                                    value: selected_netQuantityUnit_items,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                    isExpanded: true,
                                    underline: Container(
                                    height: 3,
                                    color: Color.fromARGB(255, 51, 149, 158),
                                    ),
                                    items:  netQuantityUnit_items.map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item)
                                      ),
                                    ).toList(),
                                    onChanged: (item) => setState(() => selected_netQuantityUnit_items = item),
                                  ),
                                ),

                                CustomTextFormField(
                                  controller: squareMetersTextController,
                                  hintText: "จำนวนตารางเมตร",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกจำนวนตารางเมตร";
                                    }
                                  },
                                  icon: const Icon(Icons.filter_hdr)
                                ),

                                CustomTextFormField(
                                  controller: squareYardsTextController,
                                  hintText: "จำนวนตารางวา",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกจำนวนตารางวา";
                                    }
                                  },
                                  icon: const Icon(Icons.filter_hdr)
                                ),

                                 CustomTextFormField(
                                  controller: raiTextController,
                                  hintText: "จำนวนไร",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกจำนวนไร";
                                    }
                                  },
                                  icon: const Icon(Icons.filter_hdr)
                                ),
                                
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 10),
                                  child: SizedBox(
                                    height: 53,
                                    width: 200,
                                    child: ElevatedButton(
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(50.0))),
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                                      ),
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          
                                          //Farmer data insertion
                                          /*
                                          Provider.of<FarmersData>(context, listen: false)
                                                          .addFarmer(
                                                            farmerNameTextController.text,
                                                            farmerLastnameTextController.text,
                                                            farmerEmailTextController.text,
                                                            farmerMobileNoTextController.text,
                                                            farmNameTextController.text,
                                                            double.parse(farmLatitudeTextController.text),
                                                            double.parse(farmLongitudeTextController.text),
                                                            farmerUsernameTextController.text,
                                                            farmerPasswordTextController.text
                                                          );
                                          */
    
                                          //Farmer's data insertion using farmer controller
                                          var username = await SessionManager().get("username");

                                          http.Response response = await plantingController.addPlanting(plantNameTextController.text,
                                                                    plantDateTextController.text,
                                                                    fileToDisplay!,
                                                                    selected_bioextract_items!,
                                                                    approxHarvDateTextController.text,
                                                                    selected_plantingMethod_items!,
                                                                    netQuantityTextController.text,
                                                                    selected_netQuantityUnit_items!,
                                                                    squareMetersTextController.text,
                                                                    squareYardsTextController.text,
                                                                    raiTextController.text,
                                                                    username.toString());
    
                                          //print("Status code is " + code.toString());
    
                                          if (response.statusCode == 500) {
                                            print("Error!");
                                            //showUsernameDuplicationAlert();
                                          } else {
                                            print("Farmer registration successfully!");
                                            showSavePlantingSuccessAlert();
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text("ลงทะเบียน",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'Itim'
                                            )
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )

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
          ),
        ),
      ),
    );
  }
}