
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/model/product.dart';

import 'package:http/http.dart' as http;
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../controller/product_controller.dart';
import '../../widgets/custom_text_form_field_widget.dart';
import 'list_product_manufacturer_screen.dart';
import 'main_manufacturer_screen.dart';

class UpdateProductScreen extends StatefulWidget {

  final String productId;

  const UpdateProductScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {

  ProductController productController = ProductController();

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

  Product? product;

  bool? isLoaded;

  void fetchData (String productId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await productController.getProductById(productId);
    //print("response" + response);
    product = Product.fromJsonToProduct(response);
    setDataToText();
    setState(() {
      isLoaded = true;
    });
  }

  void setDataToText () {
    productNameTextController.text = product?.productName ?? "";
    netVolumeTextController.text = product?.netVolume.toString() ?? "";
    netEnergyTextController.text = product?.netEnergy.toString() ?? "";
    saturatedFatTextController.text = product?.saturatedFat.toString() ?? "";
    cholesteralTextController.text = product?.cholesterol.toString() ?? "";
    proteinTextController.text = product?.protein.toString() ?? "";
    sodiumTextController.text = product?.sodium.toString() ?? "";
    fiberTextController.text = product?.fiber.toString() ?? "";
    sugarTextController.text = product?.sugar.toString() ?? "";
    vitATextController.text = product?.vitA.toString() ?? "";
    vitB1TextController.text = product?.vitB1.toString() ?? "";
    vitB2TextController.text = product?.vitB2.toString() ?? "";
    ironTextController.text = product?.iron.toString() ?? "";
    calciumTextController.text = product?.calcium.toString() ?? "";
  }

  void showConfirmToUpdateProductAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะแก้ไขข้อมูลสินค้า",
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

          print("UPDATE PRODUCT!");

          String username = await SessionManager().get("username");

          Product productUpdate = Product(
            productId: product?.productId,
            productName: productNameTextController.text,
            netVolume: int.parse(netVolumeTextController.text),
            netEnergy: int.parse(netEnergyTextController.text),
            saturatedFat: int.parse(saturatedFatTextController.text),
            cholesterol: int.parse(cholesteralTextController.text),
            protein: int.parse(proteinTextController.text),
            sodium: int.parse(sodiumTextController.text),
            fiber: int.parse(fiberTextController.text),
            sugar: int.parse(sugarTextController.text),
            vitA: int.parse(vitATextController.text),
            vitB1: int.parse(vitB1TextController.text),
            vitB2: int.parse(vitB2TextController.text),
            iron: int.parse(ironTextController.text),
            calcium: int.parse(calciumTextController.text),
            manufacturer: product?.manufacturer
          );

          http.Response response = await productController.updateProduct(
            productUpdate
          );

          if (response.statusCode == 500) {
            //showFailToSaveProductAlert();
            print("Failed to update!");
          } else {
            showUpdateProductSuccessAlert();
            print("Update successfully!");
          }

        }
      }
    );
  }

  void showUpdateProductSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "แก้ไขข้อมูลสำเร็จ",
      text: "แก้ไขข้อมูลสินค้าสำเร็จ",
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
  void initState() {
    super.initState();
    fetchData(widget.productId);
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
                                    "แก้ไขสินค้า",
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
                                            backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
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
                                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListProductScreen()));
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
                                ),
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