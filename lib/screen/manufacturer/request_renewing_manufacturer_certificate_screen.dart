import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../widgets/custom_text_form_field_widget.dart';


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
  DateTime? plantDate;
  DateTime? approxHarvDate;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          drawer: ManufacturerNavbar(),
          appBar: AppBar(
            title: Text("REQUEST RENEWING CERTIFICATE"),
            backgroundColor: Colors.green,
          ),
          backgroundColor: kBackgroundColor,
          body: Form(key: formKey,
            child: Column(
              children: [
                //Text("${username}"),
                
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
                CustomTextFormField(
                    controller: mnCertNoTextController,
                    hintText: "หมายเลขใบรับรอง",
                    maxLength: 50,
                    numberOnly: false,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "กรุณากรอกหมายเลขใบรับรอง";
                      }
                      if (value.length < 27 || value.length > 27) {
                        return "กรุณากรอกหมายเลขใบรับรองให้มีความยาว 27 ตัวอักษร";
                      }
                      final mnCertRegEx = RegExp(r'กษ \d{2}-\d{4}-\d{4}-\d{11}');
                      if (!mnCertRegEx.hasMatch(value)) {
                        return "กรุณากรอกหมายเลขใบรับรองให้ถูกต้องตามรูปแบบ";
                      }
                    },
                    icon: const Icon(Icons.account_circle)),
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
                        mnCertRegDateTextController.text =
                          dateFormat.format(plantDate!);
                        mnCertExpireDateTextController.text =
                          dateFormat.format(plantDate!.add(Duration(days: 365)));
                      });
                      print(plantDate);
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
                        return "กรุณาเลือกวันวันที่ออกใบรับรอง";
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
                          lastDate: DateTime(2100));
                      setState(() {
                        plantDate = tempDate;
                        mnCertExpireDateTextController.text =
                            dateFormat.format(plantDate!);
                      });
                      print(plantDate);
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
                        if (mnCertImgTextController.text == "") {
                          return showMnCertImgIsEmptyError();
                        }

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
                          //  showSavePlantingSuccessAlert();
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("ยื่นใบรับรอง",
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
          ),
        ),
      ),
    );
  }
}