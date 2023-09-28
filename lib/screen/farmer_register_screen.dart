


import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/register_success_screen.dart';
import 'package:quickalert/quickalert.dart';

import '../constant/constant.dart';
import '../controller/farmer_controller.dart';
import '../widgets/custom_text_form_field_widget.dart';
import 'choose_location_screen.dart';

class FarmerRegisterScreen extends StatefulWidget {
  const FarmerRegisterScreen({super.key});

  @override
  State<FarmerRegisterScreen> createState() => _FarmerRegisterScreenState();
}

class _FarmerRegisterScreenState extends State<FarmerRegisterScreen> {
  final FarmerController farmerController = FarmerController();

  var dateFormat = DateFormat('dd-MM-yyyy');

  DateTime currentDate = DateTime.now();
  DateTime? farmerCertRegDate;
  DateTime? farmerCertExpireDate;

  double? latitude;
  double? longitude;

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Farmer information session
  TextEditingController farmerNameTextController = TextEditingController();
  TextEditingController farmerLastnameTextController = TextEditingController();
  TextEditingController farmerEmailTextController = TextEditingController();
  TextEditingController farmerMobileNoTextController = TextEditingController();

  //Farm information session
  TextEditingController farmNameTextController = TextEditingController();
  TextEditingController farmLatitudeTextController = TextEditingController();
  TextEditingController farmLongitudeTextController = TextEditingController();

  //Farmer certificate session
  TextEditingController farmerCertImgTextController = TextEditingController();
  TextEditingController farmerCertNoTextController = TextEditingController();
  TextEditingController farmerCertRegDateTextController = TextEditingController();
  TextEditingController farmerCertExpireDateTextController = TextEditingController();

  //Username and password session
  TextEditingController farmerUsernameTextController = TextEditingController();
  TextEditingController farmerPasswordTextController = TextEditingController();
  TextEditingController farmerConfirmPasswordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    farmerCertRegDateTextController.text = farmerCertRegDate != null? dateFormat.format(farmerCertRegDate!) : "";
    farmerCertExpireDateTextController.text = farmerCertExpireDate != null? dateFormat.format(farmerCertExpireDate!) : "";
  }

  @override
  Widget build(BuildContext context) {

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
          farmerCertImgTextController.text = fileName.toString();
          print("File is ${fileName}");
        }
        setState(() {
          isLoadingPicture = false;
        });
      } catch (e) {
        print(e);
      }
    }

    void callModalBottomSheet () {
      FocusManager.instance.primaryFocus?.unfocus();
      showModalBottomSheet(
          context: context,
          builder: (context) {
          return const ChooseLocation();
        }
      ).then((value) {
        setState(() {
          latitude = value[0]["latitude"];
          longitude = value[1]["longitude"];
          farmLatitudeTextController.text = latitude.toString();
          farmLongitudeTextController.text = longitude.toString();
        });
      });
    }

    void showUsernameDuplicationAlert() {
      QuickAlert.show(
        context: context,
        title: "เกิดข้อผิดพลาด",
        text: "ชื่อผู้ใช้ไม่สามารถใช้งานได้",
        type: QuickAlertType.error,
        confirmBtnText: "ตกลง",
        onConfirmBtnTap: () {
          
          Navigator.pop(context);
        }
      );
    }

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
                              //Beginning of all main elements
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
                                                return const LoginScreen();
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
                                              "กลับไปหน้าล็อกอิน",
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
                                    "ข้อมูลเกษตรกร",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: farmerNameTextController,
                                  hintText: "ชื่อเกษตรกร",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อเกษตรกร";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: farmerLastnameTextController,
                                  hintText: "นามสกุลเกษตรกร",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกนามสกุลเกษตรกร";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: farmerEmailTextController,
                                  hintText: "อีเมลเกษตรกร",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกอีเมลเกษตรกร";
                                    }
                                  },
                                  icon: const Icon(Icons.email)
                                ),
                                CustomTextFormField(
                                  controller: farmerMobileNoTextController,
                                  hintText: "เบอร์โทรศัพท์มือถือเกษตรกร",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกเบอร์โทรศัพท์มือถือเกษตรกร";
                                    }
                                  },
                                  icon: const Icon(Icons.call)
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 2,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "ข้อมูลฟาร์ม / สถานที่เพาะปลูกผลผลิต",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: farmNameTextController,
                                  hintText: "ชื่อฟาร์ม",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อฟาร์ม";
                                    }
                                  },
                                  icon: const Icon(Icons.gite)
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: TextFormField(
                                              controller: farmLatitudeTextController,
                                              enabled: false,
                                              decoration: InputDecoration(
                                                labelText: "ตำแหน่งละติจูด",
                                                counterText: "",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10)),
                                                prefixIcon: const Icon(Icons.location_on),
                                                prefixIconColor: Colors.black
                                              ),
                                              style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: TextFormField(
                                              controller: farmLongitudeTextController,
                                              enabled: false,
                                              decoration: InputDecoration(
                                                labelText: "ตำแหน่งลองติจูด",
                                                counterText: "",
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10)),
                                                prefixIcon: const Icon(Icons.location_on),
                                                prefixIconColor: Colors.black
                                              ),
                                              style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 140,
                                        child: ElevatedButton(
                                          onPressed: callModalBottomSheet,
                                          child: const Text(
                                            "เลือกตำแหน่ง",
                                            textAlign: TextAlign.center,
                                          ),
                                          style: ButtonStyle(
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.grey)
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 2,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "ข้อมูลใบรับรองมาตรฐานเกษตรกร",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                /*
                                Center(
                                  child: isLoadingPicture?
                                  const SizedBox() :
                                  SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Image.file(fileToDisplay!),
                                  ),
                                ),
                                */
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: TextFormField(
                                          controller: farmerCertImgTextController,
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: "รูปภาพใบรับรอง IFOAM",
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
                                CustomTextFormField(
                                  controller: farmerCertNoTextController,
                                  hintText: "หมายเลขใบรับรองมาตรฐานเกษตรกร",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกหมายเลขใบรับรองมาตรฐานเกษตรกร";
                                    }
                                  },
                                  icon: const Icon(Icons.description),
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
                                        farmerCertRegDate = tempDate;
                                        farmerCertRegDateTextController.text = dateFormat.format(farmerCertRegDate!);
                                        farmerCertExpireDateTextController.text = dateFormat.format(farmerCertRegDate!.add(Duration(days: 365)));
                                      });
                                      print(farmerCertRegDate);
                                    },
                                    readOnly: true,
                                    controller: farmerCertRegDateTextController,
                                    decoration: InputDecoration(
                                      labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานเกษตรกร",
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
                                        return "กรุณาเลือกวันที่ลงทะเบียนใบรับรองมาตรฐานเกษตรกร";
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
                                        lastDate: DateTime(2100),
                                        helpText: "วันที่หมดอายุใบรับรองมาตรฐานเกษตรกร"
                                      );
                                      setState(() {
                                        farmerCertExpireDate = tempDate;
                                        farmerCertExpireDateTextController.text = dateFormat.format(farmerCertExpireDate!);
                                      });
                                      print(farmerCertExpireDate);
                                    },
                                    readOnly: true,
                                    enabled: false,
                                    controller: farmerCertExpireDateTextController,
                                    decoration: InputDecoration(
                                      labelText: "วันที่หมดอายุใบรับรองมาตรฐานเกษตรกร",
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
                                        return "กรุณาเลือกวันที่หมดอายุใบรับรองมาตรฐานเกษตรกร";
                                      }
                                    },
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Divider(
                                    color: Colors.black,
                                    thickness: 2,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    "ข้อมูลชื่อผู้ใช้และรหัสผ่าน",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: farmerUsernameTextController,
                                  hintText: "ชื่อผู้ใช้ระบบ",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อผู้ใช้ระบบ";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle),
                                ),
                                CustomTextFormField(
                                  controller: farmerPasswordTextController,
                                  hintText: "รหัสผ่าน",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกรหัสผ่าน";
                                    }
                                  },
                                  icon: const Icon(Icons.lock),
                                ),
                                CustomTextFormField(
                                  controller: farmerConfirmPasswordTextController,
                                  hintText: "ยืนยันรหัสผ่าน",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else if (value != farmerPasswordTextController.text) {
                                      return "กรุณากรอกยืนยันรหัสผ่านให้ตรงกับรหัสผ่าน";
                                    } else {
                                      return "กรุณายืนยันรหัสผ่าน";
                                    }
                                  },
                                  icon: const Icon(Icons.lock),
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
                                          http.Response response = await farmerController.addFarmer(farmerNameTextController.text,
                                                                    farmerLastnameTextController.text,
                                                                    farmerEmailTextController.text,
                                                                    farmerMobileNoTextController.text,
                                                                    farmNameTextController.text,
                                                                    farmLatitudeTextController.text,
                                                                    farmLongitudeTextController.text,
                                                                    farmerUsernameTextController.text,
                                                                    farmerPasswordTextController.text,
                                                                    fileToDisplay!,
                                                                    farmerCertNoTextController.text,
                                                                    farmerCertRegDateTextController.text,
                                                                    farmerCertExpireDateTextController.text);
    
                                          //print("Status code is " + code.toString());
    
                                          if (response.statusCode == 409) {
                                            print("Username is already exists!");
                                            showUsernameDuplicationAlert();
                                          } else {
                                            print("Farmer registration successfully!");
                                            Navigator.of(context).pushReplacement(
                                              MaterialPageRoute(
                                                builder: (BuildContext context) {
                                                  return const RegisterSuccessScreen();
                                                }
                                              )
                                            );
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