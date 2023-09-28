
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_location_picker/export.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/main_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/request_renewing_farmer_certificate_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../controller/farmer_certificate_controller.dart';
import '../../model/farmer_certificate.dart';
import '../../widgets/custom_text_form_field_widget.dart';
import '../register_success_screen.dart';

class AddPlantingScreen extends StatefulWidget {
  const AddPlantingScreen({super.key});

  @override
  State<AddPlantingScreen> createState() => _AddPlantingScreenState();
}

class _AddPlantingScreenState extends State<AddPlantingScreen> {
  
  final PlantingController plantingController = PlantingController();
  final FarmerCertificateController farmerCertificateController = FarmerCertificateController();
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

  bool? isLoaded;
  FarmerCertificate? farmerCertificate;

  bool? enabledToSelectApproxHarvDate = false;

  double? calSquareMetres = 0.00;
  double? calSquareYards = 0.00;
  double? calRai = 0.00;

  void showFmCertExpireError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถใช้งานฟังก์ชั่นเพิ่มการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านหมดอายุ กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingFarmerCertificate()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showError (String errorPrompt) {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: errorPrompt,
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showFmCertIsWaitAcceptError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถใช้งานฟังก์ชั่นเพิ่มการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showFmCertWasRejectedError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถใช้งานฟังก์ชั่นเพิ่มการปลูกได้เนื่องจากใบรับรองเกษตรกรของท่านถูกปฏิเสธโดยผู้ดูแลระบบเนื่องจากข้อมูลที่ไม่ถูกต้อง กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingFarmerCertificate()));
        });
        Navigator.pop(context);
      }
    );
  }

  void fetchLatestFarmerCertificate () async {
    setState(() {
      isLoaded = false;
    });
    String farmerUsername = await SessionManager().get("username");
    var response = await farmerCertificateController.getLastestFarmerCertificateByFarmerUsername(farmerUsername);
    farmerCertificate = FarmerCertificate.fromJsonToFarmerCertificate(response);
    if (farmerCertificate?.fmCertExpireDate?.isBefore(DateTime.now()) == true) {
      showFmCertExpireError();
    } else if (farmerCertificate?.fmCertStatus == "รอการอนุมัติ") {
      showFmCertIsWaitAcceptError();
    } else if (farmerCertificate?.fmCertStatus == "ไม่อนุมัติ") {
      showFmCertWasRejectedError();
    }
    setState(() {
      isLoaded = true;
    });
  }

  void calculateAreaFromSquareMetres (String value) {
    if (value.isNotNullOrEmpty()) {
      print("VALUE IS : " + value);
      var currSqaureMetres = double.parse(value);
      var resSquareYards = currSqaureMetres / 4;
      var resRai = currSqaureMetres / 1600;
      squareYardsTextController.text = resSquareYards.toString();
      raiTextController.text = resRai.toString();
    }
  }

  void calculateAreaFromSquareYards (String value) {
    if (value.isNotNullOrEmpty()) {
      print("VALUE IS : " + value);
      var currSqaureYards = double.parse(value);
      var resSqaureMetres = currSqaureYards * 4;
      var resRai = currSqaureYards / 400;
      squareMetersTextController.text = resSqaureMetres.toString();
      raiTextController.text = resRai.toString();
    }
  }

  void calculateAreaFromRai (String value) {
    if (value.isNotNullOrEmpty()) {
      print("VALUE IS : " + value);
      var currRai = double.parse(value);
      var resSqaureMetres = currRai * 1600;
      var resSqaureYards = currRai * 400;
      squareMetersTextController.text = resSqaureMetres.toString();
      squareYardsTextController.text = resSqaureYards.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLatestFarmerCertificate();
  }

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
                                                return const ListPlantingScreen();
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
                                              "กลับไปหน้ารายการปลูก",
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
                                  maxLength: 35,
                                  numberOnly: false,
                                  validator: (value) {
                                    final plantNameRegEx = RegExp(r'^[ก-์a-zA-Z-()]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกชื่อผลผลิตที่ปลูก";
                                    }
                                    if (!plantNameRegEx.hasMatch(value)) {
                                      return "ชื่อผลผลิตที่ปลูกต้องเป็นภาษาไทย ภาษาอังกฤษ และมีอักขระ - () ได้";
                                    }
                                    if (value.length < 4) {
                                      return "กรุณากรอกชื่อผลผลิตให้มีความยาวตั้งแต่ 4 - 35 ตัวอักษร";
                                    }
                                  },
                                  icon: const Icon(Icons.grass)
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
                                        lastDate: currentDate
                                      );
                                      setState(() {
                                        plantDate = tempDate;
                                        plantDateTextController.text = dateFormat.format(plantDate!);
                                        enabledToSelectApproxHarvDate = true;
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
                                        return "กรุณาเลือกวันที่ปลูก";
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
                                        initialDate: currentDate.add(Duration(days: 3)),
                                        firstDate: currentDate.add(Duration(days: 3)),
                                        lastDate: DateTime(2100)
                                      );
                                      setState(() {
                                        approxHarvDate = tempDate;
                                        approxHarvDateTextController.text = dateFormat.format(approxHarvDate!);
                                      });
                                      print(plantDate);
                                    },
                                    readOnly: true,
                                    enabled: enabledToSelectApproxHarvDate,
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
                                            value: selected_bioextract_items,
                                            icon: const Icon(Icons.expand_more),
                                            elevation: 5,
                                            style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                            isExpanded: true,
                                            items: bioextract_items.map((String item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item)
                                              ),
                                            ).toList(),
                                            onChanged: (item) => setState(() =>  selected_bioextract_items = item),
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
                                            value: selected_plantingMethod_items ,
                                            icon: const Icon(Icons.expand_more),
                                            elevation: 5,
                                            style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.bubble_chart),
                                              prefixIconColor: Colors.black,
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white)
                                              )
                                            ),
                                            items:  plantingMethod_items.map((String item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item)
                                              ),
                                            ).toList(),
                                            onChanged: (item) => setState(() => selected_plantingMethod_items = item),
                                          )
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                CustomTextFormField(
                                  controller: netQuantityTextController,
                                  hintText: "ปริมาณผลผลิตสุทธิ",
                                  maxLength: 10,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณผลผลิตสุทธิ";
                                    }
                                    if (double.parse(value) <= 0.0 || double.parse(value) > 100000.0) {
                                      return "กรุณากรอกปริมาณผลผลิตสุทธิให้มีค่าตั้งแต่ 1 - 100,000";
                                    }
                                  },
                                  icon: const Icon(Icons.bubble_chart)
                                ),
                                
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
                                            value: selected_netQuantityUnit_items,
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.scale),
                                              prefixIconColor: Colors.black,
                                              enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.white)
                                              )
                                            ),
                                            icon: const Icon(Icons.expand_more),
                                            elevation: 5,
                                            style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                            isExpanded: true,
                                            items:  netQuantityUnit_items.map((String item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item)
                                              ),
                                            ).toList(),
                                            onChanged: (item) => setState(() => selected_netQuantityUnit_items = item),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                CustomTextFormField(
                                  controller: squareMetersTextController,
                                  hintText: "จำนวนตารางเมตร",
                                  maxLength: 10,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกจำนวนตารางเมตร";
                                    }
                                    if (double.parse(value) <= 0.0) {
                                      return "กรุณากรอกจำนวนตารางเมตรให้มีค่ามากกว่า 0";
                                    }
                                  },
                                  onChanged: (value) {
                                    calculateAreaFromSquareMetres(value ?? "");
                                  },
                                  icon: const Icon(Icons.filter_hdr)
                                ),

                                CustomTextFormField(
                                  controller: squareYardsTextController,
                                  hintText: "จำนวนตารางวา",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกจำนวนตารางวา";
                                    }
                                    if (double.parse(value) <= 0.0) {
                                      return "กรุณากรอกจำนวนตารางวาให้มีค่ามากกว่า 0";
                                    }
                                  },
                                  onChanged: (value) {
                                    calculateAreaFromSquareYards(value ?? "");
                                  },
                                  icon: const Icon(Icons.filter_hdr)
                                ),

                                 CustomTextFormField(
                                  controller: raiTextController,
                                  hintText: "จำนวนไร่",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกจำนวนไร่";
                                    }
                                    if (double.parse(value) <= 0.0) {
                                      return "กรุณากรอกจำนวนไร่ให้มีค่ามากกว่า 0";
                                    }
                                  },
                                  onChanged: (value) {
                                    calculateAreaFromRai(value ?? "");
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
                                        backgroundColor: MaterialStateProperty.all<Color>(kClipPathColorFM)
                                      ),
                                      onPressed: () async {
                                        if (formKey.currentState!.validate()) {
                                          
                                          if (plantingImgTextController.text == "") {
                                            showError("กรุณาเลือกรูปภาพการปลูก");
                                            return;
                                          } else if (selected_bioextract_items == "ประเภทของน้ำหมัก") {
                                            showError("กรุณาเลือกประเภทของน้ำหมัก");
                                            return;
                                          } else if (selected_plantingMethod_items == "วิธีการปลูก") {
                                            showError("กรุณาเลือกวิธีการปลูก");
                                            return;
                                          } else if (selected_netQuantityUnit_items == "หน่วยของปริมาณผลผลิตสุทธิ") {
                                            showError("กรุณาเลือกหน่วยของปริมาณผลผลิตสุทธิ");
                                            return;
                                          } else {
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
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text("เพิ่มการปลูก",
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