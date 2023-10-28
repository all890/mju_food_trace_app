
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/controller/product_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';
import 'package:mju_food_trace_app/model/product.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';
import 'package:mju_food_trace_app/screen/manufacturer/update_product_manufacturer_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:http/http.dart' as http;

import '../../constant/constant.dart';
import '../../controller/manufacturer_certificate_controller.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {

  ProductController productController = ProductController();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  bool? isLoaded;

  List<Product>? products = [];

  List<Product>? notManufacturedProducts = [];
  List<Product>? manufacturedProducts = [];

  Map<String, dynamic>? productExisting;

  ManufacturerCertificate? manufacturerCertificate;

  void showFailToDeleteProductAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถทำการลบข้อมูลสินค้าได้ กรุณาลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () async {
        Navigator.pop(context);
      }
    );
  }

  void showFailToDeleteProductBecauseConflictAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถทำการลบข้อมูลสินค้าได้ เนื่องจากสินค้าชิ้นนี้ถูกบันทึกในการผลิตแล้ว",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () async {
        Navigator.pop(context);
      }
    );
  }

  void showDeleteProductSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "ลบข้อมูลสำเร็จ",
      text: "ลบข้อมูลสินค้าสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListProductScreen()));
        });
      }
    );
  }

  void showConfirmToDeleteAlert (String productId) async {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะลบสินค้า",
      type: QuickAlertType.warning,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("Accept!");
        http.Response deleteProductResponse = await productController.deleteProduct(productId);
        if (deleteProductResponse.statusCode == 500) {
          Navigator.pop(context);
          showFailToDeleteProductAlert();
        } else if (deleteProductResponse.statusCode == 409) {
          showFailToDeleteProductBecauseConflictAlert();
        } else {
          Navigator.pop(context);
          showDeleteProductSuccessAlert();
        }
      }
    );
  }

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    String username = await SessionManager().get("username");
    products = await productController.getListProduct(username);
    var productJson = await productController.getProductExistingByManuftUsername(username);
    productExisting = json.decode(productJson);
    var responseMnCert = await manufacturerCertificateController.getLastestManufacturerCertificateByManufacturerUsername(username);
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(responseMnCert);
    splitProductByType();
    setState(() {
      isLoaded = true;
    });
  }

  void showErrorToUpdateBecauseMnCertIsExpire () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถแก้ไขข้อมูลสินค้าได้เนื่องจากใบรับรองการผลิตของท่านหมดอายุ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void showErrorToUpdateBecauseMnCertIsWaitToAccept () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถแก้ไขข้อมูลสินค้าได้เนื่องจากใบรับรองผู้ผลิตของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void showErrorToDeleteBecauseMnCertIsExpire () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถลบข้อมูลสินค้าได้เนื่องจากใบรับรองการผลิตของท่านหมดอายุ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void showErrorToDeleteBecauseMnCertIsWaitToAccept () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถลบข้อมูลสินค้าได้เนื่องจากใบรับรองผู้ผลิตของท่านกำลังอยู่ในระหว่างการตรวจสอบโดยผู้ดูแลระบบ",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        
        Navigator.pop(context);
      }
    );
  }

  void splitProductByType () {
    products?.forEach((product) {
      if (productExisting?.containsKey(product.productId) == true) {
        manufacturedProducts?.add(product);
      } else {
        notManufacturedProducts?.add(product);
      }
    });
    print("Manufactured : ${manufacturedProducts?.length}");
    print("Not manufactured : ${notManufacturedProducts?.length}");
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: DefaultTabController(
        length: 2,
        child: SafeArea(
          child: Scaffold(
            drawer: ManufacturerNavbar(),
            appBar: AppBar(
              title:Text("รายการสินค้า",
                      style: TextStyle(
                        fontFamily: 'Itim',
                        shadows: [
                        Shadow(
                          color: Color.fromARGB(255, 0, 0, 0)
                              .withOpacity(0.5), // สีของเงา
                          offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                          blurRadius: 3, // ความคมของเงา
                        ),
                      ],
                      ),),
              bottom: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      "ยังไม่ถูกผลิต",
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 16,
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
                      "ผลิตแล้ว",
                      style: TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 16,
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
            TabBarView(
              children: [
                notManufacturedProducts?.isNotEmpty == true? Container(
                  padding: EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: notManufacturedProducts?.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                               SizedBox(
                  width: 50,
                  height: 50,
                  child: Image(
                    image: AssetImage('images/pack-products.png'),
                  ),
                ),
                            ],
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${notManufacturedProducts?[index].productName}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              ),
                              Text(
                                "ปริมาตรสุทธิ : "+"${notManufacturedProducts?[index].netVolume} กรัม",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              ),
                              Text(
                                "พลังงานสุทธิ : "+"${notManufacturedProducts?[index].netEnergy} กิโลแคลอรี่",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                          
                          trailing: SizedBox(
                            width: 70,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    print("Edit Pressed!");
                                    if ((manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true && !(manufacturerCertificate?.mnCertExpireDate?.difference(DateTime.now()).inDays == 0)) || manufacturerCertificate?.mnCertStatus == "ไม่อนุมัติ") {
                                      showErrorToUpdateBecauseMnCertIsExpire();
                                    } else if (manufacturerCertificate?.mnCertStatus == "รอการอนุมัติ") {
                                      showErrorToUpdateBecauseMnCertIsWaitToAccept();
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => UpdateProductScreen(productId: notManufacturedProducts?[index].productId ?? "")),
                                      );
                                    }
                                  },
                                  child: Icon(Icons.edit,color: Color.fromARGB(255, 4, 92, 89),)
                                ),
                                
                                GestureDetector(
                                  onTap: () {
                                    print("Delete Pressed!");
                                    if ((manufacturerCertificate?.mnCertExpireDate?.isBefore(DateTime.now()) == true && !(manufacturerCertificate?.mnCertExpireDate?.difference(DateTime.now()).inDays == 0)) || manufacturerCertificate?.mnCertStatus == "ไม่อนุมัติ") {
                                      showErrorToDeleteBecauseMnCertIsExpire();
                                    } else if (manufacturerCertificate?.mnCertStatus == "รอการอนุมัติ") {
                                      showErrorToDeleteBecauseMnCertIsWaitToAccept();
                                    } else {
                                      showConfirmToDeleteAlert(notManufacturedProducts?[index].productId ?? "");
                                    }
                                  },
                                  child: Icon(Icons.delete,color: Color.fromARGB(255, 151, 7, 7),)
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ) :
                Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 350,
                          width: 350,
                          image: AssetImage("images/bean_action1.png"),
                        ),
                        Text(
                          "ไม่มีสินค้าที่ยังไม่ถูกผลิต",
                          style:
                              TextStyle(fontFamily: "Itim", fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                manufacturedProducts?.isNotEmpty == true? Container(
                  padding: EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: manufacturedProducts?.length,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                  SizedBox(
                  width: 50,
                  height: 50,
                  child: Image(
                    image: AssetImage('images/pack-products.png'),
                  ),
                ),
                            ],
                          ),
                          title: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${manufacturedProducts?[index].productName}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              ),
                                Text(
                                "ปริมาตรสุทธิ : "+"${manufacturedProducts?[index].netVolume} กรัม",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              ),
                              Text(
                                "พลังงานสุทธิ : "+"${manufacturedProducts?[index].netEnergy} กิโลแคลอรี่",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ) :
                Center(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          height: 350,
                          width: 350,
                          image: AssetImage("images/bean_action2.png"),
                        ),
                        Text(
                          "ไม่มีสินค้าที่ถูกผลิต",
                          style:
                              TextStyle(fontFamily: "Itim", fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}