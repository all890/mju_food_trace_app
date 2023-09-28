
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/register_success_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../constant/constant.dart';
import '../controller/manufacturer_controller.dart';
import '../widgets/custom_text_form_field_widget.dart';
import 'choose_location_screen.dart';

class ManufacturerRegisterScreen extends StatefulWidget {
  const ManufacturerRegisterScreen({super.key});

  @override
  State<ManufacturerRegisterScreen> createState() => _ManufacturerRegisterScreenState();
}

class _ManufacturerRegisterScreenState extends State<ManufacturerRegisterScreen> {
  final ManufacturerController manufacturerController = ManufacturerController();

  var dateFormat = DateFormat('dd-MM-yyyy');

  DateTime currentDate = DateTime.now();
  DateTime? manuftCertRegDate;
  DateTime? manuftCertExpireDate;

  double? latitude;
  double? longitude;

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //Manufacturer information session
  TextEditingController manuftNameTextController = TextEditingController();
  TextEditingController manuftEmailTextController = TextEditingController();

  //Factory information session
  TextEditingController factoryLatitudeTextController = TextEditingController();
  TextEditingController factoryLongitudeTextController = TextEditingController();
  TextEditingController factoryTelNoTextController = TextEditingController();
  TextEditingController factorySupNameTextController = TextEditingController();
  TextEditingController factorySupLastnameTextController = TextEditingController();

  //Manufacturer certificate session
  TextEditingController manuftCertImgTextController = TextEditingController();
  TextEditingController manuftCertNoTextController = TextEditingController();
  TextEditingController manuftCertRegDateTextController = TextEditingController();
  TextEditingController manuftCertExpireDateTextController = TextEditingController();

  //Username and password session
  TextEditingController manuftUsernameTextController = TextEditingController();
  TextEditingController manuftPasswordTextController = TextEditingController();
  TextEditingController manuftConfirmPasswordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    manuftCertRegDateTextController.text = manuftCertRegDate != null? dateFormat.format(manuftCertRegDate!) : "";
    manuftCertExpireDateTextController.text = manuftCertExpireDate != null? dateFormat.format(manuftCertExpireDate!) : "";
  }

  @override
  Widget build(BuildContext context) {

    void _pickFile () async {
      FocusManager.instance.primaryFocus?.unfocus();
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
          manuftCertImgTextController.text = fileName.toString();
          print("File is ${fileName}");
        }
        setState(() {
          isLoadingPicture = false;
        });
      } catch (e) {
        print(e);
      }
    }

    void _callModalBottomSheet () {
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
          factoryLatitudeTextController.text = latitude.toString();
          factoryLongitudeTextController.text = longitude.toString();
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
                                    "ข้อมูลผู้ผลิต",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: manuftNameTextController,
                                  hintText: "ชื่อผู้ผลิต",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อผู้ผลิต";
                                    }
                                  },
                                  icon: const Icon(Icons.home_filled)
                                ),
                                CustomTextFormField(
                                  controller: manuftEmailTextController,
                                  hintText: "อีเมลผู้ผลิต",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกอีเมลผู้ผลิต";
                                    }
                                  },
                                  icon: const Icon(Icons.email)
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
                                    "ข้อมูลโรงงานผู้ผลิต",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim'
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
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
                                              controller: factoryLatitudeTextController,
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
                                              controller: factoryLongitudeTextController,
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
                                          onPressed: _callModalBottomSheet,
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
                                CustomTextFormField(
                                  controller: factoryTelNoTextController,
                                  hintText: "เบอร์โทรศัพท์โรงงานผู้ผลิต",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกเบอร์โทรศัพท์โรงงานผู้ผลิต";
                                    }
                                  },
                                  icon: const Icon(Icons.call),
                                ),
                                CustomTextFormField(
                                  controller: factorySupNameTextController,
                                  hintText: "ชื่อผู้ดูแลโรงงานผู้ผลิต",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อผู้ดูแลโรงงานผู้ผลิต";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle),
                                ),
                                CustomTextFormField(
                                  controller: factorySupLastnameTextController,
                                  hintText: "นามสกุลผู้ดูแลโรงงานผู้ผลิต",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกนามสกุลผู้ดูแลโรงงานผู้ผลิต";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle),
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
                                    "ข้อมูลใบรับรองมาตรฐานผู้ผลิต",
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
                                          controller: manuftCertImgTextController,
                                          enabled: false,
                                          decoration: InputDecoration(
                                            labelText: "รูปภาพใบรับรอง GMP",
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
                                //Text(fileName != null? fileName.toString() : ""),
                                CustomTextFormField(
                                  controller: manuftCertNoTextController,
                                  hintText: "หมายเลขใบรับรองมาตรฐานผู้ผลิต",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกหมายเลขใบรับรองมาตรฐานผู้ผลิต";
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
                                        manuftCertRegDate = tempDate;
                                        manuftCertRegDateTextController.text = dateFormat.format(manuftCertRegDate!);
                                        manuftCertExpireDateTextController.text = dateFormat.format(manuftCertRegDate!.add(Duration(days: 365*3)));
                                      });
                                      print(manuftCertRegDate);
                                    },
                                    readOnly: true,
                                    controller: manuftCertRegDateTextController,
                                    decoration: InputDecoration(
                                      labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานผู้ผลิต",
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
                                        return "กรุณาเลือกวันที่ลงทะเบียนใบรับรองมาตรฐานผู้ผลิต";
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
                                        helpText: "วันที่หมดอายุใบรับรองมาตรฐานผู้ผลิต"
                                      );
                                      setState(() {
                                        manuftCertExpireDate = tempDate;
                                        manuftCertExpireDateTextController.text = dateFormat.format(manuftCertExpireDate!);
                                      });
                                      print(manuftCertExpireDate);
                                    },
                                    readOnly: true,
                                    enabled: false,
                                    controller: manuftCertExpireDateTextController,
                                    decoration: InputDecoration(
                                      labelText: "วันที่หมดอายุใบรับรองมาตรฐานผู้ผลิต",
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
                                  controller: manuftUsernameTextController,
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
                                  controller: manuftPasswordTextController,
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
                                  controller: manuftConfirmPasswordTextController,
                                  hintText: "ยืนยันรหัสผ่าน",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else if (value != manuftPasswordTextController.text) {
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
                                          
                                          print(manuftCertRegDateTextController.text);

                                          var code = await manufacturerController.addManufacturer(
                                            manuftNameTextController.text,
                                            manuftEmailTextController.text,
                                            factoryLatitudeTextController.text,
                                            factoryLongitudeTextController.text,
                                            factoryTelNoTextController.text,
                                            factorySupNameTextController.text,
                                            factorySupLastnameTextController.text,
                                            manuftUsernameTextController.text,
                                            manuftPasswordTextController.text,
                                            fileToDisplay!,
                                            manuftCertNoTextController.text,
                                            manuftCertRegDateTextController.text,
                                            manuftCertExpireDateTextController.text
                                          );

                                          //print("Status code is " + code.toString());
    
                                          if (code == 409) {
                                            print("Username is already exists!");
                                            showUsernameDuplicationAlert();
                                          } else {
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