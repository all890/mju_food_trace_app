
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
      text: "ไม่สามารถเพิ่มสินค้าได้ เนื่องจากใบรับรองเกษตรกรของท่านถูกปฏิเสธโดยผู้ดูแลระบบเนื่องจากข้อมูลที่ไม่ถูกต้อง กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
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
      text: "ไม่สามารถเพิ่มการปลูกได้ เนื่องจากใบรับรองเกษตรกรของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListProductScreen()));
        });
        Navigator.pop(context);
      }
    );
  }

  void showMnCertExpireError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถเพิ่มการปลูกได้ เนื่องจากใบรับรองเกษตรกรของท่านหมดอายุ กรุณาทำการต่ออายุใบรับรองแล้วลองใหม่อีกครั้ง",
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
    if (manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true) {
      showMnCertExpireError();
    } else if (manufacturerCertificate?.mnCertStatus == "รอการอนุมัติ") {
      showMnCertIsWaitAcceptError();
    } else if (manufacturerCertificate?.mnCertStatus == "ไม่อนุมัติ") {
      showMnCertWasRejectedError();
    }
    setState(() {
      isLoaded = true;
    });
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
                                                return const MainManufacturerScreen();
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
                                              "กลับไปหน้าหลัก",
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
                                      color: Color.fromARGB(255, 33, 82, 35)
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ข้อมูลสินค้า",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontFamily: 'Itim'
                                      ),
                                    ),
                                  ),
                                ),
                                CustomTextFormField(
                                  controller: productNameTextController,
                                  hintText: "ชื่อสินค้า",
                                  maxLength: 50,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกชื่อสินค้า";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: netVolumeTextController,
                                  hintText: "ปริมาตรสุทธิ",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาตรสุทธิ";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: netEnergyTextController,
                                  hintText: "พลังงานที่ได้รับสุทธิ (kcal)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกพลังงานที่ได้รับสุทธิ";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: saturatedFatTextController,
                                  hintText: "ปริมาณไขมันอิ่มตัว (kcal)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณไขมันอิ่มตัว";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: cholesteralTextController,
                                  hintText: "ปริมาณคอเลสเตอรอล (มิลลิกรัม)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณคอเลสเตอรอล";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: proteinTextController,
                                  hintText: "ปริมาณโปรตีน (กรัม)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณโปรตีน";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: sodiumTextController,
                                  hintText: "ปริมาณโซเดียม (มิลลิกรัม)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณโซเดียม";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: fiberTextController,
                                  hintText: "ปริมาณใยอาหาร (กรัม)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณใยอาหาร";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: sugarTextController,
                                  hintText: "ปริมาณน้ำตาล (กรัม)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณน้ำตาล";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
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
                                  hintText: "ปริมาณเหล็ก (%)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณเหล็ก";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: vitATextController,
                                  hintText: "ปริมาณวิตามินเอ (%)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณวิตามินเอ";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: vitB1TextController,
                                  hintText: "ปริมาณวิตามินบี 1 (%)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณวิตามินบี 1";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: vitB2TextController,
                                  hintText: "ปริมาณวิตามินบี 2 (%)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณวิตามินบี 2";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
                                ),
                                CustomTextFormField(
                                  controller: calciumTextController,
                                  hintText: "ปริมาณแคลเซียม (%)",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกปริมาณแคลเซียม";
                                    }
                                  },
                                  icon: const Icon(Icons.account_circle)
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