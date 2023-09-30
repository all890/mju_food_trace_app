import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/farmer_controller.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/main_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/navbar_farmer.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../controller/planting_controller.dart';
import '../../model/farmer.dart';
import '../../widgets/custom_text_form_field_widget.dart';

class RequestRenewingFarmerCertificate extends StatefulWidget {
  const RequestRenewingFarmerCertificate({super.key});

  @override
  State<RequestRenewingFarmerCertificate> createState() =>
      _RequestRenewingFarmerCertificateState();
}

class _RequestRenewingFarmerCertificateState
    extends State<RequestRenewingFarmerCertificate> {
  String? username;
  String? userType;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool? isLoaded;
  FarmerController farmerController = FarmerController();
  Farmer? farmer;

  DateTime currentDate = DateTime.now();
  DateTime? fmCertRegDate;
  DateTime? tempFmCertRegDate;
  var dateFormat = DateFormat('dd-MM-yyyy');

  TextEditingController fmCertNoTextController = TextEditingController();
  TextEditingController fmCertRegDateTextController = TextEditingController();
  TextEditingController fmCertExpireDateTextController = TextEditingController();
  TextEditingController fmCertImgTextController = TextEditingController();

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;

  void _pickFile() async {
    try {
      setState(() {
        isLoadingPicture = true;
      });
      filePickerResult = await FilePicker.platform
          .pickFiles(allowMultiple: false, type: FileType.image);
      if (filePickerResult != null) {
        fileName = filePickerResult!.files.first.name;
        pickedFile = filePickerResult!.files.first;
        fileToDisplay = File(pickedFile!.path.toString());
        fmCertImgTextController.text = fileName.toString();
        print("File is ${fileName}");
      }
      setState(() {
        isLoadingPicture = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void syncUser() async {
    setState(() {
      isLoaded = false;
    });

    var usernameDynamic = await SessionManager().get("username");
    username = usernameDynamic.toString();
    var response = await farmerController.getFarmerByUsername(username ?? "");
    farmer = Farmer.fromJsonToFarmer(response);
    setState(() {
      isLoaded = true;
    });
  }

  void showFmCertImgIsEmptyError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "กรุณาเลือกรูปภาพของใบรับรองมาตรฐานเกษตรกร",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  @override
  void initState() {
    super.initState();
    syncUser();
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
          body: SingleChildScrollView(
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
                                "การยื่นคำร้องขอต่ออายุใบรับรองเกษตรกร",
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
                                  "ข้อมูลใบรับรอง IFOAM ฉบับใหม่",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  ),
                                ),
                              ),
                            ),
                            
                            CustomTextFormField(
                              controller: fmCertNoTextController,
                              hintText: "หมายเลขใบรับรอง",
                              maxLength: 8,
                              numberOnly: false,
                              validator: (value) {
                                final farmerCertNoRegEx = RegExp(r'^[0-9]{6}OC');
                                if (value!.isEmpty) {
                                  return "กรุณากรอกหมายเลขใบรับรองมาตรฐานเกษตรกร";
                                }
                                if (value!.contains(" ")) {
                                  return "หมายเลขใบรับรองมาตรฐานเกษตรกรต้องไม่ประกอบไปด้วยช่องว่าง";
                                }
                                if (!farmerCertNoRegEx.hasMatch(value)) {
                                  return "กรุณากรอกหมายเลขใบรับรองมาตรฐานเกษตรกรให้ถูกต้องตามรูปแบบ";
                                }
                              },
                              icon: const Icon(Icons.account_circle)
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                onTap: () async {
                                  DateTime? tempDate = await showDatePicker(
                                      context: context,
                                      initialDate: tempFmCertRegDate ?? currentDate,
                                      firstDate: DateTime(1950),
                                      lastDate: currentDate);
                                  setState(() {
                                    if (tempDate != null) {
                                      tempFmCertRegDate = tempDate;
                                      fmCertRegDate = tempDate;
                                      fmCertRegDateTextController.text =
                                          dateFormat.format(fmCertRegDate!);
                                      fmCertExpireDateTextController.text =
                                          dateFormat.format(fmCertRegDate!.add(Duration(days: 365)));
                                    } else {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    }
                                  });
                                  //print(fmCertRegDate);
                                },
                                readOnly: true,
                                controller: fmCertRegDateTextController,
                                decoration: InputDecoration(
                                    labelText: "วันที่ออกใบรับรอง",
                                    counterText: "",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    prefixIcon: const Icon(Icons.calendar_month),
                                    prefixIconColor: Colors.black),
                                style: const TextStyle(fontFamily: 'Itim', fontSize: 18),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "กรุณาเลือกวันวันที่ออกใบรับรอง";
                                  }
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: TextFormField(
                                onTap: () async {
                                  //print(plantDate);
                                },
                                readOnly: true,
                                enabled: false,
                                controller: fmCertExpireDateTextController,
                                decoration: InputDecoration(
                                    labelText: "วันหมดอายุใบรับรอง",
                                    counterText: "",
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    prefixIcon: const Icon(Icons.calendar_month),
                                    prefixIconColor: Colors.black),
                                style: const TextStyle(fontFamily: 'Itim', fontSize: 18),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "กรุณาเลือกวันวันหมดอายุใบรับรอง";
                                  }
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: TextFormField(
                                      controller: fmCertImgTextController,
                                      enabled: false,
                                      decoration: InputDecoration(
                                          labelText: "รูปภาพใบรับรอง IFOAM",
                                          counterText: "",
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10)),
                                          prefixIcon: const Icon(Icons.image),
                                          prefixIconColor: Colors.black),
                                      style:
                                          const TextStyle(fontFamily: 'Itim', fontSize: 18),
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
                                          backgroundColor: MaterialStateProperty.all<Color>(
                                              Colors.grey)),
                                    ),
                                  )
                                ),
                              ],
                            ),
                              const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "สามารถเลือกไฟล์ที่มีนามสกุล png,jpg,pdf",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Itim'
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
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

                                        if (fmCertImgTextController.text == "") {
                                          return showFmCertImgIsEmptyError();
                                        } else {
                                          //Farmer's data insertion using farmer controller
                                        var username = await SessionManager().get("username");
          
                                        http.Response response = await farmerController.addfarmerCertificate(fileToDisplay!,
                                                                  fmCertNoTextController.text,
                                                                  fmCertRegDateTextController.text,
                                                                  fmCertExpireDateTextController.text,
                                                                  username.toString());
            
                                        //print("Status code is " + code.toString());
            
                                        if (response.statusCode == 500) {
                                          print("Error!");
                                          //showUsernameDuplicationAlert();
                                          
                                        } else {
                                          print("Farmer renewing req cert successfully!");
                                        //  showSavePlantingSuccessAlert();
                                        Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (BuildContext context) {
                                            return const ListPlantingScreen();
                                          }
                                        )
                                      );
                                        }
                                        }
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text("ยื่นคำร้องขอ",
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
    );
  }
}
