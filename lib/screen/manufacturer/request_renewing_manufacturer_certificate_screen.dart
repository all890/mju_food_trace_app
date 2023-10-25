import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_product_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';
import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../model/manufacturer_certificate.dart';
import '../../service/config_service.dart';
import '../../widgets/buddhist_year_converter.dart';
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
  bool? hasCertWaitToAccept;
  ManufacturerController manufacturerController = ManufacturerController();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();
  Manufacturer? manufacturer;
  ManufacturerCertificate? manufacturerCertificate;

  List<ManufacturerCertificate>? tempMnCertList;
  List<ManufacturerCertificate>? manufacturerCertificates;
  List<TextStyle>? statusColors = [];

  TextStyle? statusColorCurrentCert;

  DateTime currentDate = DateTime.now();
  DateTime? mnCertRegDate;
  DateTime? tempMnCertRegDate;
  var dateFormat = DateFormat('dd-MM-yyyy');
  var newDateFormat = DateFormat('dd-MMM-yyyy');

  Duration? differenceDuration;
  int? differenceDays;

  TextEditingController mnCertNoTextController = TextEditingController();
  TextEditingController mnCertRegDateTextController = TextEditingController();
  TextEditingController mnCertExpireDateTextController = TextEditingController();
  TextEditingController mnCertImgTextController = TextEditingController();

  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

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
  

 void syncUser() async {
    setState(() {
      isLoaded = false;
    });

   //Fetch user data session
    var usernameDynamic = await SessionManager().get("username");
    username = usernameDynamic.toString();
    var response = await manufacturerController.getManufacturerByUsername(username ?? "");
    manufacturer = Manufacturer.fromJsonToManufacturer(response);

    var mnCertResponse = await manufacturerCertificateController.getLastestManufacturerCertificateByManufacturerUsername(username ?? "");
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(mnCertResponse);

    tempMnCertList = await manufacturerCertificateController.getMnCertsByManuftUsername(username ?? "");

    manufacturerCertificates = tempMnCertList?.reversed.toList();

    manufacturerCertificates?.forEach((item) {
      if (item.mnCertStatus == "อนุมัติ") {
        statusColors?.add(TextStyle(fontFamily: 'Itim', fontSize: 18, color:Colors.green, shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 1, 45, 13)
                              .withOpacity(0.8), // สีของเงา
                          offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                          blurRadius: 0, // ความคมของเงา
                        ),
                      ],));
      } else if (item.mnCertStatus == "รอการอนุมัติ") {
        statusColors?.add(TextStyle(fontFamily: 'Itim', fontSize: 18, color:Colors.yellow, shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 45, 38, 1)
                              .withOpacity(0.8), // สีของเงา
                          offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                          blurRadius: 0, // ความคมของเงา
                        ),
                      ],));
      } else {
        statusColors?.add(TextStyle(fontFamily: 'Itim', fontSize: 18, color:Colors.red, shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 45, 7, 1)
                              .withOpacity(0.8), // สีของเงา
                          offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                          blurRadius: 0, // ความคมของเงา
                        ),
                      ],));
      }
    });

    //print("DURATION IS : ${differenceDuration?.inDays}");

    var hasWaitToAcceptCertResponse = await manufacturerCertificateController.hasCertWaitToAccept(username ?? "");
    if (hasWaitToAcceptCertResponse == 200) {
      hasCertWaitToAccept = false;
    } else {
      hasCertWaitToAccept = true;
    }

setState(() {
      differenceDuration = manufacturerCertificate?.mnCertExpireDate?.difference(DateTime.now());
      differenceDays = differenceDuration?.inDays;
      print("DURATION IS : ${differenceDuration?.inDays}");
      if (differenceDays! > 90) {
        statusColorCurrentCert = TextStyle(fontFamily: 'Itim', fontSize: 16,color: Colors.green, shadows: [
                  Shadow(color: Color.fromARGB(255, 5, 53, 1).withOpacity(0.8), // สีของเงา 
                  offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                    blurRadius: 0, // ความคมของเงา
                  ),
                ],);
      } else if (differenceDays! <= 90 && differenceDays! > 60) {
        statusColorCurrentCert = TextStyle(fontFamily: 'Itim', fontSize: 16,color: Colors.yellow,shadows: [
                  Shadow(color: Color.fromARGB(255, 53, 45, 1)
                        .withOpacity(0.8), // สีของเงา
                    offset: Offset(1, 1), // ตำแหน่งเงา (X, Y)
                    blurRadius: 0, // ความคมของเงา
                  ),
                ],);
      } else if (differenceDays! <= 60 && differenceDays! > 30) {
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
      mnCertNoTextController.text = manufacturerCertificate?.mnCertNo ?? "";
      isLoaded = true;
    });

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
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: SafeArea(
      child: Scaffold(
        drawer: ManufacturerNavbar(),
        appBar: AppBar(
           title: Text(
              "ต่ออายุใบรับรองผู้ผลิต",
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
                      color: kClipPathColorTextMN,
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
                      color: kClipPathColorTextMN,
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
                      color: kClipPathColorTextMN,
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
            backgroundColor: kClipPathColorMN,
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
            //page1
             SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Text(
                                  "ใบรับรองผู้ผลิตที่ใช้ปัจจุบัน"
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
                                            SizedBox(height: 120),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("วันที่ออกใบรับรอง : ${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturerCertificate?.mnCertRegDate ?? DateTime.now())}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("วันที่หมดอายุ : ${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturerCertificate?.mnCertExpireDate ?? DateTime.now())}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("วันที่ทำการอัปโหลด : ${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturerCertificate?.mnCertUploadDate ?? DateTime.now())}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 16),)
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 25),
                                              child: Align(
                                                alignment: Alignment.topLeft, 
                                                child: Text("สถานะใบรับรอง : ${manufacturerCertificate?.mnCertStatus}",style: const TextStyle(
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
                                              //height: 500,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 20),
                                                child: Image.network(baseURL + '/manuftcertificate/${manufacturerCertificate?.mnCertImg}'),
                                              )
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      child: Card(
                                        color: Color.fromARGB(255, 3, 204, 204),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 15),
                                          child: Column(
                                            children: [
                                              Center(child: Text("หมายเลขใบรับรอง",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 18),)),
                                              Center(child: Text("${manufacturerCertificate?.mnCertNo}",style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 18),)),
                                              Center(
                                                child: Text(
                                                  differenceDays! > 90 ? "ใบรับรองนี้จะมีอายุอีก : ${differenceDays} วัน" : differenceDays! <= 0 ? "ใบรับรองนี้หมดอายุแล้ว กรุณาต่ออายุใบรับรอง" : "เหลืออายุเพียง ${differenceDays} วัน ควรต่ออายุใบรับรอง",
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
                            itemCount: manufacturerCertificates?.length,
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
                                            "เลขที่การร้องขอ : ${manufacturerCertificates?[index1].mnCertId}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim', fontSize: 22),
                                          ),
                                        ),
                                        Text(
                                            "วันที่ลงทะเบียน : ${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturerCertificates?[index1].mnCertRegDate ?? DateTime.now())}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่หมดอายุ : ${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturerCertificates?[index1].mnCertExpireDate ?? DateTime.now())}",
                                            style: const TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 18)),
                                        Text(
                                            "วันที่ทำการร้องขอ : ${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturerCertificates?[index1].mnCertUploadDate ?? DateTime.now())}",
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
                                                "${manufacturerCertificates?[index1].mnCertStatus}",
                                                
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
                        (differenceDays ?? 0) <= 90 && hasCertWaitToAccept == false ?
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
                                    "การยื่นคำร้องขอต่ออายุใบรับรองผู้ผลิต",
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
                                  hintText: "หมายเลขใบรับรองมาตรฐานผู้ผลิต",
                                  maxLength: 30,
                                  validator: (value) {
                                    final manuftCertNoRegEx = RegExp(r'^((กษ|AC) [0-9-]{18,27})+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกหมายเลขใบรับรองมาตรฐานผู้ผลิต";
                                    }
                                    if (!manuftCertNoRegEx.hasMatch(value)) {
                                      return "กรุณากรอกหมายเลขใบรับรองมาตรฐานผู้ผลิตให้ถูกต้องตามรูปแบบ";
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
                                      //print(fmCertRegDate);
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
                                      //print(plantDate);
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
                                              print("Farmer renewing req cert successfully!");
                                            //  showSavePlantingSuccessAlert();
                                            Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) {
                                                return const ListManufacturingScreen();
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
          ],
      )

      )),
  );
  
}