
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_product_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/main_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/request_renewing_manufacturer_certificate_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../controller/manufacturer_certificate_controller.dart';
import '../../controller/product_controller.dart';
import '../../widgets/custom_text_form_field_widget.dart';
import '../register_success_screen.dart';
import 'package:http/http.dart' as http;

import 'navbar_manufacturer.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {

  ProductController productController = ProductController();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  TextEditingController productNameTextController = TextEditingController();
  TextEditingController netVolumeTextController = TextEditingController();
  TextEditingController netEnergyTextController = TextEditingController();
  TextEditingController saturatedFatTextController = TextEditingController();
  TextEditingController cholesteralTextController = TextEditingController();
  TextEditingController proteinTextController = TextEditingController();
  TextEditingController sodiumTextController = TextEditingController();
  TextEditingController fiberTextController = TextEditingController();
  TextEditingController sugarTextController = TextEditingController();
  TextEditingController vitATextController = TextEditingController();
  TextEditingController vitB1TextController = TextEditingController();
  TextEditingController vitB2TextController = TextEditingController();
  TextEditingController ironTextController = TextEditingController();
  TextEditingController calciumTextController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  ManufacturerCertificate? manufacturerCertificate;
  bool? isLoaded;

  void showFailToSaveProductAlert() {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถบันทึกข้อมูลสินค้าได้ กรุณาลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showSaveProductSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "บันทึกข้อมูลสำเร็จ",
      text: "บันทึกข้อมูลสินค้าลงในระบบสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListProductScreen()));
        });
      }
    );
  }

  void showMnCertWasRejectedError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มสินค้าได้ เนื่องจากใบรับรองผู้ผลิตของท่านถูกปฏิเสธโดยผู้ดูแลระบบเนื่องจากข้อมูลที่ไม่ถูกต้อง กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingManufacturerCertificateScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showMnCertIsWaitAcceptError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มสินค้าได้ เนื่องจากใบรับรองผู้ผลิตของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingManufacturerCertificateScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showMnCertExpireError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มสินค้าได้ เนื่องจากใบรับรองผู้ผลิตของท่านหมดอายุ กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RequestRenewingManufacturerCertificateScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void fetchManufacturerCertificate () async {
    setState(() {
      isLoaded = false;
    });
    String username = await SessionManager().get("username");
    var response = await manufacturerCertificateController.getLastestManufacturerCertificateByManufacturerUsername(username);
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(response);
    print("EXPIRE DATE : ${manufacturerCertificate?.mnCertExpireDate}");
    print("DATE NOW : ${DateTime.now()}");
    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true && !(manufacturerCertificate?.mnCertExpireDate?.difference(DateTime.now()).inDays == 0)) {
      showMnCertExpireError();
    } else if (manufacturerCertificate?.mnCertStatus == "รอการอนุมัติ") {
      showMnCertIsWaitAcceptError();
    } else if (manufacturerCertificate?.mnCertStatus == "ไม่อนุมัติ") {
      showMnCertWasRejectedError();
    }
    setZeroToNutrientFields();
    setState(() {
      isLoaded = true;
    });
  }

  void setZeroToNutrientFields () {
    saturatedFatTextController.text = "0";
    cholesteralTextController.text = "0";
    proteinTextController.text = "0";
    sodiumTextController.text = "0";
    fiberTextController.text = "0";
    sugarTextController.text = "0";
    ironTextController.text = "0";
    vitATextController.text = "0";
    vitB1TextController.text = "0";
    vitB2TextController.text = "0";
    calciumTextController.text = "0";
  }

  @override
  void initState() {
    super.initState();
    fetchManufacturerCertificate();
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
                                                return const ListProductScreen();
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
                                              "กลับไปหน้ารายการสินค้า",
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
                                    "เพิ่มสินค้า",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontFamily: 'Itim',
                                      color: Color.fromARGB(255, 4, 92, 89),
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 22),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ข้อมูลสินค้า",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Itim',
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: productNameTextController,
                                  hintText: "ชื่อสินค้า",
                                  maxLength: 40,
                                  validator: (value) {
                                    final productNameRegEx = RegExp(r'^[ก-์a-zA-Z-()" "]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกชื่อสินค้า";
                                    }
                                    if (value.length < 5) {
                                      return "กรุณากรอกชื่อสินค้าให้มีความยาวตั้งแต่ 5 - 40 ตัวอักษร";
                                    }
                                    if (!productNameRegEx.hasMatch(value)) {
                                      return "กรุณากรอกชื่อสินค้าให้เป็นภาษาไทยหรือภาษาอังกฤษ \nหรือสามารถประกอบไปด้วยช่องว่าง - และ ()";
                                    }
                                  },
                                  icon: const Icon(Icons.compost,color: Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: netVolumeTextController,
                                  hintText: "ปริมาตรสุทธิ (กรัม)",
                                  maxLength: 5,
                                  numberOnly: true,
                                  validator: (value) {
                                     final netVolumeRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาตรสุทธิ";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาตรสุทธิต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!netVolumeRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาตรสุทธิเป็นตัวเลขจำนวนเต็มบวกเท่านั้น";
                                    }
                                    if (int.parse(value) < 100 || int.parse(value) > 10000) {
                                      return "กรุณากรอกปริมาณสุทธิให้มีค่าตั้งแต่ 100 - 10,000 กรัม";
                                    }
                                  },
                                  icon: const Icon(Icons.equalizer,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: netEnergyTextController,
                                  hintText: "พลังงานที่ได้รับสุทธิ (กิโลแคลอรี่)",
                                  maxLength: 4,
                                  numberOnly: true,
                                  validator: (value) {
                                     final netEnergyRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกพลังงานที่ได้รับสุทธิ";
                                    }
                                    if (value!.contains(" ")) {
                                      return "พลังงานที่ได้รับสุทธิต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!netEnergyRegEx.hasMatch(value)) {
                                      return "กรุณากรอกพลังงานที่ได้รับสุทธิเป็นตัวเลขจำนวนเต็มบวกเท่านั้น";
                                    }
                                    if (int.parse(value) <= 0 || int.parse(value) > 1000) {
                                      return "กรุณากรอกพลังงานที่ได้รับสุทธิให้มีค่าตั้งแต่ 0 - 1000 กิโลแคลอรี่";
                                    }
                                  },
                                  icon: const Icon(Icons.bolt,color: Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: saturatedFatTextController,
                                  hintText: "ปริมาณไขมันอิ่มตัว (%)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                     final netEnergyRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณไขมันอิ่มตัว";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณไขมันอิ่มตัวต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!netEnergyRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณไขมันอิ่มตัวเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณากรอกปริมาณไขมันอิ่มตัวให้มีค่าตั้งแต่ 0 - 100 เปอร์เซ็น";
                                    }
                                  },
                                  icon: const Icon(Icons.opacity,color: Color.fromARGB(255, 1, 73, 71),)

                                ),
                                CustomTextFormField(
                                  controller: cholesteralTextController,
                                  hintText: "ปริมาณคอเลสเตอรอล (มิลลิกรัม)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                    final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณคอเลสเตอรอล";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณคอเลสเตอรอลต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณคอเลสเตอรอลตัวเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 1000) {
                                      return "กรุณากรอกปริมาณคอเลสเตอรอลให้มีค่าตั้งแต่ 0 - 1000 มิลลิกรัม";
                                    }
                                  },
                                  icon: const Icon(Icons.water_drop,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: proteinTextController,
                                  hintText: "ปริมาณโปรตีน (กรัม)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                    final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณโปรตีน";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณโปรตีนต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณโปรตีนเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณากรอกปริมาณโปรตีนให้มีค่าตั้งแต่ 0 - 100 กรัม";
                                    }
                                  },
                                  icon: const Icon(Icons.water_drop,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: sodiumTextController,
                                  hintText: "ปริมาณโซเดียม (มิลลิกรัม)",
                                  maxLength: 4,
                                  numberOnly: true,
                                  validator: (value) {
                                     final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณโซเดียม";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณโซเดียมต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณโซเดียมเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 1000) {
                                      return "กรุณากรอกปริมาณโซเดียมให้มีค่าตั้งแต่ 0 - 1000 มิลลิกรัม";
                                    }
                                  },
                                  icon: const Icon(Icons.water_drop,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: fiberTextController,
                                  hintText: "ปริมาณใยอาหาร (กรัม)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                     final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณใยอาหาร";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณใยอาหารต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณใยอาหารเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณใยอาหารให้มีค่าตั้งแต่ 0 - 100 กรัม";
                                    }
                                  },
                                  icon: const Icon(Icons.water_drop,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: sugarTextController,
                                  hintText: "ปริมาณน้ำตาล (กรัม)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                     final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณน้ำตาล";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณน้ำตาลต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณน้ำตาลเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณน้ำตาลให้มีค่าตั้งแต่ 0 - 100 กรัม";
                                    }
                                  },
                                  icon: const Icon(Icons.water_drop,color:  Color.fromARGB(255, 1, 73, 71),)
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
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "แร่ธาตุและวิตามิน",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Itim'
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: ironTextController,
                                  hintText: "ปริมาณธาตุเหล็ก (%)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                     final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณธาตุเหล็ก";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณธาตุเหล็กต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณธาตุเหล็กเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณธาตุเหล็กให้มีค่าตั้งแต่ 0 - 100 เปอร์เซ็น";
                                    }
                                  },
                                  icon: const Icon(Icons.hdr_strong,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: vitATextController,
                                  hintText: "ปริมาณวิตามินเอ (%)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                     final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณวิตามินเอ";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณวิตามินเอต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณวิตามินเอเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณวิตามินเอให้มีค่าตั้งแต่ 0 - 100 เปอร์เซ็น";
                                    }
                                  },
                                  icon: const Icon(Icons.hub,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: vitB1TextController,
                                  hintText: "ปริมาณวิตามินบี 1 (%)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                    final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณวิตามินบี 1";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณวิตามินบี 1 ต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณวิตามินบี 1 เป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณวิตามินบี 1 ให้มีค่าตั้งแต่ 0 - 100 เปอร์เซ็น";
                                    }
                                  },
                                  icon: const Icon(Icons.hub,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: vitB2TextController,
                                  hintText: "ปริมาณวิตามินบี 2 (%)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                     final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณวิตามินบี 2";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณวิตามินบี 2 ต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณวิตามินบี 2 เป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณวิตามินบี 2 ให้มีค่าตั้งแต่ 0 - 100 เปอร์เซ็น";
                                    }
                                  },
                                  icon: const Icon(Icons.hub,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: calciumTextController,
                                  hintText: "ปริมาณแคลเซียม (%)",
                                  maxLength: 3,
                                  numberOnly: true,
                                  validator: (value) {
                                      final cholesteralRegEx = RegExp(r'^[0-9]+$');
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกปริมาณแคลเซียม";
                                    }
                                    if (value!.contains(" ")) {
                                      return "ปริมาณแคลเซียมต้องไม่ประกอบไปด้วยช่องว่าง";
                                    }
                                    if (!cholesteralRegEx.hasMatch(value)) {
                                      return "กรุณากรอกปริมาณแคลเซียมเป็นตัวเลขจำนวนเต็มบวก\nหรือจำนวนเต็มศูนย์เท่านั้น";
                                    }
                                    if (int.parse(value) < 0 || int.parse(value) > 100) {
                                      return "กรุณาปริมาณแคลเซียมให้มีค่าตั้งแต่ 0 - 100 เปอร์เซ็น";
                                    }
                                  },
                                  icon: const Icon(Icons.hdr_strong,color:  Color.fromARGB(255, 1, 73, 71),)
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
                                        print("PRESSED!");
                                        if (formKey.currentState!.validate()) {

                                          print("ADD PRODUCT!");

                                          String username = await SessionManager().get("username");

                                          http.Response response = await productController.addProduct(
                                            productNameTextController.text,
                                            int.parse(netVolumeTextController.text),
                                            int.parse(netEnergyTextController.text),
                                            int.parse(saturatedFatTextController.text),
                                            int.parse(cholesteralTextController.text),
                                            int.parse(proteinTextController.text),
                                            int.parse(sodiumTextController.text),
                                            int.parse(fiberTextController.text),
                                            int.parse(sugarTextController.text),
                                            int.parse(vitATextController.text),
                                            int.parse(vitB1TextController.text),
                                            int.parse(vitB2TextController.text),
                                            int.parse(ironTextController.text),
                                            int.parse(calciumTextController.text),
                                            username
                                          );

                                          if (response.statusCode == 500) {
                                            showFailToSaveProductAlert();
                                          } else {
                                            showSaveProductSuccessAlert();
                                          }

                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text("เพิ่มสินค้า",
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