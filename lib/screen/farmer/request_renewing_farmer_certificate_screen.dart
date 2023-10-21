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
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/main_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/navbar_farmer.dart';
import 'package:mju_food_trace_app/service/config_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../controller/farmer_certificate_controller.dart';
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
  bool? hasCertWaitToAccept;
  FarmerController farmerController = FarmerController();
  FarmerCertificateController farmerCertificateController = FarmerCertificateController();
  Farmer? farmer;
  FarmerCertificate? farmerCertificate;

  List<FarmerCertificate>? tempFmCertList;
  List<FarmerCertificate>? farmerCertificates;
  List<TextStyle>? statusColors = [];

  TextStyle? statusColorCurrentCert;

  DateTime currentDate = DateTime.now();
  DateTime? fmCertRegDate;
  DateTime? tempFmCertRegDate;
  var dateFormat = DateFormat('dd-MM-yyyy');
  var newDateFormat = DateFormat('dd-MMM-yyyy');

  Duration? differenceDuration;
  int? differenceDays;

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

    //Fetch user data session
    var usernameDynamic = await SessionManager().get("username");
    username = usernameDynamic.toString();
    var response = await farmerController.getFarmerByUsername(username ?? "");
    farmer = Farmer.fromJsonToFarmer(response);

    var fmCertResponse = await farmerCertificateController.getLastestFarmerCertificateByFarmerUsername(username ?? "");
    farmerCertificate = FarmerCertificate.fromJsonToFarmerCertificate(fmCertResponse);

    tempFmCertList = await farmerCertificateController.getFmCertsByFarmerUsername(username ?? "");

    farmerCertificates = tempFmCertList?.reversed.toList();

    farmerCertificates?.forEach((item) {
      if (item.fmCertStatus == "อนุมัติ") {
        statusColors?.add(TextStyle(fontFamily: 'Itim', fontSize: 18, color:Colors.green));
      } else if (item.fmCertStatus == "รอการอนุมัติ") {
        statusColors?.add(TextStyle(fontFamily: 'Itim', fontSize: 18, color:Colors.yellow));
      } else {
        statusColors?.add(TextStyle(fontFamily: 'Itim', fontSize: 18, color:Colors.red));
      }
    });

    //print("DURATION IS : ${differenceDuration?.inDays}");

    var hasWaitToAcceptCertResponse = await farmerCertificateController.hasCertWaitToAccept(username ?? "");
    if (hasWaitToAcceptCertResponse == 200) {
      hasCertWaitToAccept = false;
    } else {
      hasCertWaitToAccept = true;
    }

    setState(() {
      differenceDuration = farmerCertificate?.fmCertExpireDate?.difference(DateTime.now());
      differenceDays = differenceDuration?.inDays;
      print("DURATION IS : ${differenceDuration?.inDays}");
      if (differenceDays! > 30) {
        statusColorCurrentCert = TextStyle(fontFamily: 'Itim', fontSize: 16,color: Colors.green, shadows: [
                  Shadow(color: Color.fromARGB(255, 5, 53, 1).withOpacity(0.8), // สีของเงา 
                  offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                    blurRadius: 0, // ความคมของเงา
                  ),
                ],);
      } else if (differenceDays! <= 30 && differenceDays! > 20) {
        statusColorCurrentCert = TextStyle(fontFamily: 'Itim', fontSize: 16,color: Colors.yellow,shadows: [
                  Shadow(color: Color.fromARGB(255, 53, 45, 1)
                        .withOpacity(0.8), // สีของเงา
                    offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                    blurRadius: 0, // ความคมของเงา
                  ),
                ],);
      } else if (differenceDays! <= 20 && differenceDays! > 10) {
        statusColorCurrentCert = TextStyle(fontFamily: 'Itim', fontSize: 16,color: Colors.orange.shade800,shadows: [
                  Shadow(color: Color.fromARGB(255, 53, 32, 1)
                        .withOpacity(0.8), // สีของเงา
                    offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                    blurRadius: 0, // ความคมของเงา
                  ),
                ],);
      } else {
        statusColorCurrentCert = TextStyle(fontFamily: 'Itim', fontSize: 16,color: Colors.red,shadows: [
                  Shadow(color: Color.fromARGB(255, 53, 8, 1)
                        .withOpacity(0.8), // สีของเงา
                    offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                    blurRadius: 0, // ความคมของเงา
                  ),
                ],);
      }
      fmCertNoTextController.text = farmerCertificate?.fmCertNo ?? "";
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
  Widget build(BuildContext context) => DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          drawer: FarmerNavbar(),
          appBar: AppBar(
            title: Text(
              "ต่ออายุใบรับรองเกษตรกร",
              style: TextStyle(
                fontFamily: 'Itim',
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              tabs: [
                Tab(
                  child: Text(
                    "ใบรับรองปัจจุบัน",
                    style: TextStyle(
                      fontFamily: 'Itim',
                      color: kClipPathColorTextFM,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "ประวัติการร้องขอ",
                    style: TextStyle(
                      fontFamily: 'Itim',
                      color: kClipPathColorTextFM,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    "ต่ออายุใบรับรอง",
                    style: TextStyle(
                      fontFamily: 'Itim',
                      color: kClipPathColorTextFM,
                      fontSize: 14,
                      shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: kClipPathColorFM,
          ),
          backgroundColor: kBackgroundColor,
          body: isLoaded == false
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ],
                )
              : TabBarView(
                  children: [
                    //Page 1
                        SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text(
                                  "ใบรับรองเกษตรกรที่ใช้ปัจจุบัน"
                                ,style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 22),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10,left: 16,right: 2,bottom: 5),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text("ข้อมูลใบรับรอง",style: const TextStyle(
                                                  fontFamily: 'Itim', fontSize: 18),)
                                  ),
                                ),
                                Stack(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      child: Card(
                                        color: kBackgroundColor,
                                        elevation: 10,
                                        child: Column(
                                          children: [
                                            SizedBox(height: 90),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("วันที่ออกใบรับรอง : ${newDateFormat.format(farmerCertificate?.fmCertRegDate ?? DateTime.now())}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("วันที่หมดอายุ : ${newDateFormat.format(farmerCertificate?.fmCertExpireDate ?? DateTime.now())}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("วันที่ทำการอัปโหลด : ${newDateFormat.format(farmerCertificate?.fmCertUploadDate ?? DateTime.now())}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("สถานะใบรับรอง : ${farmerCertificate?.fmCertStatus}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("รูปใบรับรอง",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            SizedBox(
                                              height: 500,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 20),
                                                child: Image.network(baseURL + '/farmercertificate/${farmerCertificate?.fmCertImg}'),
                                              )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      child: Card(
                                        color: Colors.orange,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          child: Column(
                                            children: [
                                              Center(child: Text("หมายเลขใบรับรอง : ${farmerCertificate?.fmCertNo}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 18),)),
                                              Center(
                                                child: Text(
                                                  differenceDays! > 30 ? "ใบรับรองนี้จะมีอายุอีก : ${differenceDays} วัน" : differenceDays! <= 0 ? "ใบรับรองนี้หมดอายุแล้ว กรุณาต่ออายุใบรับรอง" : "เหลืออายุเพียง ${differenceDays} วัน ควรต่ออายุใบรับรอง",
                                                  style: statusColorCurrentCert,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ),
                        ),
                        //Page 2
                        Container(
                          padding: EdgeInsets.all(10.0),
                          child: ListView.builder(
                            itemCount: farmerCertificates?.length,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index1) {
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: ListTile(
                                    title: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10),
                                          child: Text(
                                            "เลขที่การร้องขอ : ${farmerCertificates?[index1].fmCertId}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 22),
                                          ),
                                        ),
                                        Text(
                                            "วันที่ลงทะเบียน : ${newDateFormat.format(farmerCertificates?[index1].fmCertRegDate ?? DateTime.now())}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่หมดอายุ : ${newDateFormat.format(farmerCertificates?[index1].fmCertExpireDate ?? DateTime.now())}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่ทำการร้องขอ : ${newDateFormat.format(farmerCertificates?[index1].fmCertUploadDate ?? DateTime.now())}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                "สถานะใบรับรอง : ",
                                                style: const TextStyle(
                                                    fontFamily: 'Itim',
                                                    fontSize: 18)),
                                              Text(
                                                "${farmerCertificates?[index1].fmCertStatus}",
                                                
                                                style: statusColors?[index1]
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              );
                            },
                          )
                        ),
                        //Page 3
                        (differenceDays ?? 0) <= 30 && hasCertWaitToAccept == false ?
                        SingleChildScrollView(
                          child: Form(
                            key: formKey,
                            child: Container(
                              padding: EdgeInsets.all(10.0),
                              child: Column(
                                children: [
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
                                  padding: EdgeInsets.only(top: 10, bottom: 10, left: 10),
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
                              )
                            ),
                          ),
                        ) : hasCertWaitToAccept == true? Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                height: 350,
                                width: 350,
                                image: AssetImage("images/corn_action2.png"),
                              ),
                              Text(
                                "ใบรับรองที่คุณร้องขอต่ออายุ\nกำลังรอการตรวจสอบจากผู้ดูแลระบบ",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ) : Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                height: 350,
                                width: 350,
                                image: AssetImage("images/corn_action2.png"),
                              ),
                              Text(
                                "ขณะนี้ยังไม่ถึงเวลาสำหรับการร้องขอต่ออายุ",
                                style:
                                    TextStyle(fontFamily: "Itim", fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                ]),
        ),
      ));
}
