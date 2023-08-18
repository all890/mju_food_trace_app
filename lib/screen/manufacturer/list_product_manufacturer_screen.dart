
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/controller/product_controller.dart';
import 'package:mju_food_trace_app/model/product.dart';
import 'package:mju_food_trace_app/screen/manufacturer/navbar_manufacturer.dart';
import 'package:mju_food_trace_app/screen/manufacturer/update_product_manufacturer_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import 'package:http/http.dart' as http;

import '../../constant/constant.dart';

class ListProductScreen extends StatefulWidget {
  const ListProductScreen({super.key});

  @override
  State<ListProductScreen> createState() => _ListProductScreenState();
}

class _ListProductScreenState extends State<ListProductScreen> {

  ProductController productController = ProductController();

  bool? isLoaded;

  List<Product>? products;

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
    setState(() {
      isLoaded = true;
    });
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
      child: SafeArea(
        child: Scaffold(
          drawer: ManufacturerNavbar(),
          appBar: AppBar(
            title: const Text("LIST PRODUCTS"),
            backgroundColor: Colors.green,
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
          products?.length == 0?
          Container(
            child: Text("ยังไม่มีสินค้าของคุณ")
          ) :
          Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: products?.length,
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
                        Icon(Icons.place)
                      ],
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${products?[index].productName}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22
                          ),
                        ),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("Edit Pressed!");
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => UpdateProductScreen(productId: products?[index].productId ?? "")),
                              );
                            },
                            child: Icon(Icons.edit)
                          ),
                          GestureDetector(
                            onTap: () {
                              print("Delete Pressed!");
                              showConfirmToDeleteAlert(products?[index].productId ?? "");
                            },
                            child: Icon(Icons.delete)
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ),
      ),
    );
  }
}