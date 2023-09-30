import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_product_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../widgets/custom_text_form_field_widget.dart';
import 'list_manufacturing.dart';


class RequestRenewingManufacturerCertificateScreen extends StatefulWidget {
  const RequestRenewingManufacturerCertificateScreen({super.key});

  @override
  State<RequestRenewingManufacturerCertificateScreen> createState() => _RequestRenewingManufacturerCertificateScreenState();
}

class _RequestRenewingManufacturerCertificateScreenState extends State<RequestRenewingManufacturerCertificateScreen> {
  String? username;
  String? userType;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool? isLoaded;
  ManufacturerController manufacturerController = ManufacturerController();
  Manufacturer? manufacturer;

  DateTime currentDate = DateTime.now();
  DateTime? mnCertRegDate;
  DateTime? tempMnCertRegDate;
  var dateFormat = DateFormat('dd-MM-yyyy');

  TextEditingController mnCertNoTextController = TextEditingController();
  TextEditingController mnCertRegDateTextController = TextEditingController();
  TextEditingController mnCertExpireDateTextController = TextEditingController();
  TextEditingController mnCertImgTextController = TextEditingController();

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;

  void showMnCertImgIsEmptyError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "กรุณาเลือกรูปภาพของใบรับรองมาตรฐานการผลิต",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }
  
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
        mnCertImgTextController.text = fileName.toString();
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
    var response = await manufacturerController.getManufacturerByUsername(username ?? "");
    manufacturer = Manufacturer.fromJsonToManufacturer(response);
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    syncUser();
  }
  void showSaveManufacuringSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "บันทึกข้อมูลสำเร็จ",
      text: "ส่งคำร้องขอใบรับรองผู้ผลิตสำเร็จ กรุณารอตรวจสอบในเวลาไม่เกิน 3 วัน",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListProductScreen()));
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
                                            return const ListManufacturingScreen();
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
                                          "กลับไปหน้ารายการผลิตสินค้า",
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
                              "การยื่นคำร้องขอต่ออายุใบรับรองผู้ผลิต",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontFamily: 'Itim',
                                  color: Color.fromARGB(255, 33, 82, 35)),
                            ),
                          ),
                          const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "ข้อมูลใบรับรอง GMP ฉบับใหม่",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  ),
                                ),
                              ),
                            ),
                          CustomTextFormField(
                            controller: mnCertNoTextController,
                            hintText: "หมายเลขใบรับรอง",
                            maxLength: 30,
                            validator: (value) {
                              final manuftCertNoRegEx = RegExp(r'^((กษ|AC) [0-9-]{18,27})+$');
                              if (value!.isEmpty) {
                                return "กรุณากรอกหมายเลขใบรับรอง";
                              }
                              if (!manuftCertNoRegEx.hasMatch(value)) {
                                return "กรุณากรอกหมายเลขใบรับรองมาตรฐานผู้ผลิตให้ถูกต้องตามรูปแบบ";
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
                                    initialDate: tempMnCertRegDate ?? currentDate,
                                    firstDate: DateTime(1950),
                                    lastDate: currentDate);
                                setState(() {
                                  if (tempDate != null) {
                                    tempMnCertRegDate = tempDate;
                                    mnCertRegDate = tempDate;
                                    mnCertRegDateTextController.text =
                                      dateFormat.format(mnCertRegDate!);
                                    mnCertExpireDateTextController.text =
                                      dateFormat.format(mnCertRegDate!.add(Duration(days: 365*3)));
                                  } else {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  }
                                });
                                //print(mnCertRegDate);
                              },
                              readOnly: true,
                              controller: mnCertRegDateTextController,
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
                                  return "กรุณาเลือกวันที่ออกใบรับรอง";
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextFormField(
                              onTap: () async {
                                //print(mnCertRegDate);
                              },
                              readOnly: true,
                              enabled: false,
                              controller: mnCertExpireDateTextController,
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
                                    controller: mnCertImgTextController,
                                    enabled: false,
                                    decoration: InputDecoration(
                                        labelText: "รูปภาพใบรับรอง GMP",
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
                                  )),
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
                                  backgroundColor: MaterialStateProperty.all<Color>(kClipPathColorMN)
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    
                                    if (mnCertImgTextController.text == "") {
                                      return showMnCertImgIsEmptyError();
                                    } else {
                                      //Farmer's data insertion using farmer controller
                                      var username = await SessionManager().get("username");

                                      http.Response response = await manufacturerController.addmanufacturerCertificate(fileToDisplay!,
                                                                mnCertNoTextController.text,
                                                                mnCertRegDateTextController.text,
                                                                mnCertExpireDateTextController.text,
                                                                username.toString());

                                      //print("Status code is " + code.toString());

                                      if (response.statusCode == 500) {
                                        print("Error!");
                                        //showUsernameDuplicationAlert();
                                      } else {
                                        print("Farmer registration successfully!");

                                      showSaveManufacuringSuccessAlert();
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