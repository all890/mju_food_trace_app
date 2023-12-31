import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_google_location_picker/export.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../service/config_service.dart';
import '../../widgets/custom_text_form_field_widget.dart';

class UpdatePlantingScreen extends StatefulWidget {
  final String plantingId;
  const UpdatePlantingScreen({Key? key, required this.plantingId}) : super(key: key);

  @override
  State<UpdatePlantingScreen> createState() => _UpdatePlantingScreenState();
}

class _UpdatePlantingScreenState extends State<UpdatePlantingScreen> {

  PlantingController plantingController = PlantingController();
  
  DateTime currentDate = DateTime.now();
  DateTime? plantDate;
  DateTime? tempPlantDate;
  DateTime? approxHarvDate;
  DateTime? tempApproxHarvDate;

  FilePickerResult? filePickerResult;
  String? fileName;
  PlatformFile? pickedFile;
  File? fileToDisplay;
  bool isLoadingPicture = true;

  TextEditingController plantNameTextController = TextEditingController();

  TextEditingController plantingImgTextController = TextEditingController();

  TextEditingController plantDateTextController = TextEditingController();
  TextEditingController approxHarvDateTextController = TextEditingController();
  TextEditingController netQuantityTextController = TextEditingController();
  TextEditingController squareMetersTextController = TextEditingController();
  TextEditingController squareYardsTextController = TextEditingController();
  TextEditingController raiTextController = TextEditingController();

 final GlobalKey<FormState> formKey = GlobalKey<FormState>();

 List<String> bioextract_items= ["ประเภทของน้ำหมัก","น้ำหมักทางชีวภาพจากพืช","น้ำหมักทางชีวภาพจากสัตว์","น้ำหมักชีวภาพจากเศษปลา","น้ำหมักชีวภาพจากผลไม้รสเปรี้ยว"];
  //String? selected_bioextract_items = "";
  List<String> plantingMethod_items = ["วิธีการปลูก", "การหว่านเมล็ด","การปลูกด้วยต้นกล้า","การหยอดเมล็ด","ฝังในแปลงปลูก"];
 // String? selected_plantingMethod_items  = "";
  List<String> netQuantityUnit_items = ["หน่วยของปริมาณผลผลิตสุทธิ","กรัม","กิโลกรัม"];
  //String? selected_netQuantityUnit_items  = "";

  bool? isLoaded;
  Planting? planting;
  String imgPlantingFileName = "";
   var dateFormat = DateFormat('dd-MM-yyyy');
  
  
  void showUpdatePlantingSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "แก้ไขข้อมูลสำเร็จ",
      text: "แก้ไขข้อมูลการปลูกผลผลิตสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
        });
      }
    );
  }

  void fetchData (String plantingId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await plantingController.getPlantingrDetails(plantingId);
    planting = Planting.fromJsonToPlanting(response);
    String filePath = planting?.plantingImg ?? "";
    
    print(filePath);
    imgPlantingFileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length) ?? "";
    print(imgPlantingFileName);

    plantingImgTextController.text = imgPlantingFileName;

    setTextToData();
    setState(() {
      isLoaded = true;
    });
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

  void showConfirmToUpdateProductAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะแก้ไขข้อมูลการปลูกผลผลิต",
      type: QuickAlertType.warning,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("PRESSED!");
        if (formKey.currentState!.validate()) {

          if (plantingImgTextController.text == "") {
            Navigator.pop(context);
            showError("กรุณาเลือกรูปภาพการปลูก");
            //Navigator.pop(context);
            return;
          } else if (planting?.bioextract == "ประเภทของน้ำหมัก") {
            Navigator.pop(context);
            showError("กรุณาเลือกประเภทของน้ำหมัก");
            //Navigator.pop(context);
            return;
          } else if (planting?.plantingImg == "วิธีการปลูก") {
            Navigator.pop(context);
            showError("กรุณาเลือกวิธีการปลูก");
            //Navigator.pop(context);
            return;
          } else if (planting?.netQuantityUnit == "หน่วยของปริมาณผลผลิตสุทธิ") {
            Navigator.pop(context);
            showError("กรุณาเลือกหน่วยของปริมาณผลผลิตสุทธิ");
            //Navigator.pop(context);
            return;
          } else {
            print("UPDATE PLANTING!");
            //String username = await SessionManager().get("username");

            DateFormat dateFormat = DateFormat('dd-MM-yyyy');

            Planting plantingUpdate = Planting(
              plantingId: planting?.plantingId,
              plantName: plantNameTextController.text,
              plantDate: dateFormat.parse(plantDateTextController.text),
              plantingImg: plantingImgTextController.text,
              bioextract: planting?.bioextract,
              approxHarvDate: dateFormat.parse(approxHarvDateTextController.text),
              plantingMethod: planting?.plantingMethod,
              netQuantity: double.parse(netQuantityTextController.text),
              netQuantityUnit: planting?.netQuantityUnit,
              squareMeters: double.parse(squareMetersTextController.text),
              squareYards: double.parse(squareYardsTextController.text),
              rai: double.parse(raiTextController.text),
              ptPrevBlockHash: "0",
              ptCurrBlockHash: null,
              farmerCertificate: planting?.farmerCertificate
            );

            http.Response response = await plantingController.updatePlanting(fileToDisplay, plantingUpdate);

            if (response.statusCode == 500) {
              //showFailToSaveProductAlert();
              print("Failed to update!");
            } else {
              Navigator.pop(context);
              showUpdatePlantingSuccessAlert();
              print("Update successfully!");
            }
          }
        } else {
          Navigator.pop(context);
        }
      }
    );
  }

  void setTextToData () {
    plantNameTextController.text = planting?.plantName ?? "";
    plantDateTextController.text =  dateFormat.format(planting?.plantDate?? DateTime.now());
    approxHarvDateTextController.text = dateFormat.format(planting?.approxHarvDate ?? DateTime.now());
    netQuantityTextController.text = (planting?.netQuantity ?? 0.0).toString();
    squareMetersTextController.text = (planting?.squareMeters ?? 0.0).toString();
    squareYardsTextController.text =(planting?.squareYards ?? 0.0).toString();
    raiTextController.text =(planting?.rai ?? 0.0).toString();
    //selected_bioextract_items = planting?.bioextract ?? "";
    //selected_plantingMethod_items = planting?.plantingMethod ?? "";
    //selected_netQuantityUnit_items = planting?.netQuantityUnit ?? "";
    setState(() {
      plantDate = planting?.plantDate;
      approxHarvDate = planting?.approxHarvDate;
    });
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
          body: isLoaded == false?
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ],
          ) :
          Center(
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
                                    "แก้ไขการปลูกผลผลิต",
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
                                  icon: const Icon(Icons.account_circle)
                                ),
                                fileToDisplay == null? 
                                SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: Image.network(baseURL + '/planting/' + imgPlantingFileName)
                                ) : 
                                SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: Image.file(fileToDisplay!)
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
                                        initialDate: tempPlantDate ?? plantDate!,
                                        firstDate: DateTime(1950),
                                        lastDate: currentDate
                                      );
                                      setState(() {
                                        if (tempDate != null) {
                                          plantDate = tempDate;
                                          tempPlantDate = plantDate;
                                          plantDateTextController.text = dateFormat.format(plantDate!);
                                          if (plantDate!.isAfter(approxHarvDate ?? currentDate) || plantDate!.isAtSameMomentAs(approxHarvDate ?? currentDate)) {
                                            approxHarvDate = plantDate?.add(Duration(days: 3));
                                            approxHarvDateTextController.text = dateFormat.format(approxHarvDate ?? DateTime.now());
                                          }
                                        } else {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
                                      });
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
                                        initialDate: approxHarvDate ?? DateTime.now(),
                                        firstDate: plantDate!.add(Duration(days: 3)),
                                        lastDate: DateTime(2100)
                                      );
                                      setState(() {
                                        if (tempDate != null) {
                                          approxHarvDate = tempDate;
                                          approxHarvDateTextController.text = dateFormat.format(approxHarvDate!);
                                        } else {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
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
                                            value: planting?.bioextract,
                                    icon: const Icon(Icons.expand_more),
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                    isExpanded: true,
                                    
                                    items: bioextract_items.map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item)
                                      ),
                                    ).toList(),
                                    onChanged: (item) => setState(() =>  planting?.bioextract = item),
                                            
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
                                             value: planting?.plantingMethod ,
                                    icon: const Icon(Icons.expand_more),
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                    isExpanded: true,
                                    
                                    items:  plantingMethod_items.map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item)
                                      ),
                                    ).toList(),
                                    onChanged: (item) => setState(() => planting?.plantingMethod = item),
                                  
                                            
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
                                            value: planting?.netQuantityUnit,
                                    icon: const Icon(Icons.expand_more),
                                    elevation: 5,
                                    style: const TextStyle(color: Colors.black,fontSize: 18,fontFamily: 'Itim',),
                                    isExpanded: true,
                                    items:  netQuantityUnit_items.map((String item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(item)
                                      ),
                                    ).toList(),
                                    onChanged: (item) => setState(() => planting?.netQuantityUnit = item),
                                  
                                            
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
                                  maxLength: 10,
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
                                  hintText: "จำนวนไร",
                                  maxLength: 10,
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 53,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 203, 203, 34))
                            ),
                            onPressed: () {
                              showConfirmToUpdateProductAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("แก้ไข",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 200,
                          height: 53,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)
                            ),
                            onPressed: () {
                              WidgetsBinding.instance!.addPostFrameCallback((_) {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("ยกเลิก",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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