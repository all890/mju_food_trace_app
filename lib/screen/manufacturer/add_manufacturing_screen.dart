import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturing_controller.dart';
import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/controller/product_controller.dart';
import 'package:mju_food_trace_app/controller/raw_material_shipping_controller.dart';
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_all_sent_agricultural_products_screen.dart';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/screen/manufacturer/list_manufacturing.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import '../../constant/constant.dart';
import '../../model/product.dart';
import '../../widgets/custom_text_form_field_widget.dart';

class AddManufacturingScreen extends StatefulWidget {
  final String rawMatShpId;
  const AddManufacturingScreen({Key? key, required this.rawMatShpId})
      : super(key: key);

  @override
  State<AddManufacturingScreen> createState() => _AddManufacturingState();
}

class _AddManufacturingState extends State<AddManufacturingScreen> {
  final ManufacturingController manufacturingController =
      ManufacturingController();
  final ProductController productController = ProductController();
  final RawMaterialShippingController rawMaterialShippingController =
      RawMaterialShippingController();

  var dateFormat = DateFormat('dd-MM-yyyy');
  DateTime currentDate = DateTime.now();
  DateTime? manufactureDate;
  DateTime? expireDate;
  bool? isLoaded;

  TextEditingController manufactureDateTextController = TextEditingController();
  TextEditingController expireDateTextController = TextEditingController();

  TextEditingController productQtyTextController = TextEditingController();
  List<String> productUnit_items = ["หน่วยของสินค้า", "กรัม", "กิโลกรัม"];
  String? selected_productUnit_items = "หน่วยของสินค้า";

  TextEditingController plantNameTextController = TextEditingController();
  TextEditingController usedRawMatQtyTextController = TextEditingController();
  List<String> usedRawMatQtyUnit_items = ["หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า", "กรัม", "กิโลกรัม"];
  String? selected_usedRawMatQtyUnit_items = "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า";

  String? selected_productName;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RawMaterialShipping? rawMaterialShipping;

  List<Product>? products;
  List<String>? productNames = [];
  String? productId;

  void fetchData(String rawMatShpId) async {
    var username = await SessionManager().get("username");
    setState(() {
      var isLoaded = false;
    });
    var response = await rawMaterialShippingController
        .getRawMaterialShippingDetails(rawMatShpId);
    //var response = await plantingController.getPlantingrDetails(plantingId);
    rawMaterialShipping =
        RawMaterialShipping.fromJsonToRawMaterialShipping(response);
    products = await productController.getListProduct(username);
    //  print(rawMaterialShipping?.planting?.plantName);
    plantNameTextController.text =
        rawMaterialShipping?.planting?.plantName ?? "";
    fetchName();
    //setTextToData();
    setState(() {
      isLoaded = true;
    });
  }

  void fetchName() {
    products?.forEach((product) {
      String productName = product.productName ?? "";
      productNames?.add(productName);
    });

    selected_productName = productNames?[0];

    print(productNames?.length);
  }

  @override
  void initState() {
    super.initState();
    fetchData(widget.rawMatShpId);
  }
  void showFailToSaveManufacuringAlert() {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "ไม่สามารถบันทึกข้อมูลการผลิตสินค้าได้ กรุณาลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

   void showSaveManufacuringSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "บันทึกข้อมูลสำเร็จ",
      text: "บันทึกข้อมูลการผลิตสินค้าลงในระบบสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManufacturingScreen()));
        });
      }
    );
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
                          borderRadius: BorderRadius.circular(10)),
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
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return const ListAllSentAgriculturalProductsScreen();
                                          }));
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_back),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "กลับไปผลผลิตที่ส่งมาจากเกษตรกร",
                                              style: TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 20),
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
                                    "เพิ่มการผลิตสินค้า",
                                    style: TextStyle(
                                        fontSize: 22, fontFamily: 'Itim',color: Color.fromARGB(255, 33, 82, 35)),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ข้อมูลการผลิตสินค้า",
                                      style: TextStyle(
                                          fontSize: 22, fontFamily: 'Itim'),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: DropdownButton<String>(
                                    value: selected_productName,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 3,
                                      color: Color.fromARGB(255, 51, 149, 158),
                                    ),
                                    items: productNames
                                        ?.map(
                                          (String item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item)),
                                        )
                                        .toList(),
                                    onChanged: (item) => setState(
                                        () => selected_productName = item),
                                  ),
                                ),
                                CustomTextFormField(
                                    controller: productQtyTextController,
                                    hintText: "ปริมาณสินค้าที่ผลิตได้",
                                    maxLength: 50,
                                    numberOnly: true,
                                    validator: (value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "กรุณากรอกปริมาณสินค้าที่ผลิตได้";
                                      }
                                    },
                                    icon: const Icon(Icons.account_circle)),
                                Center(
                                  child: DropdownButton<String>(
                                    value: selected_productUnit_items,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 3,
                                      color: Color.fromARGB(255, 51, 149, 158),
                                    ),
                                    items: productUnit_items
                                        .map(
                                          (String item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item)),
                                        )
                                        .toList(),
                                    onChanged: (item) => setState(() =>
                                        selected_productUnit_items = item),
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
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        manufactureDate = tempDate;
                                        manufactureDateTextController.text =
                                            dateFormat.format(manufactureDate!);
                                      });
                                      print(manufactureDate);
                                    },
                                    readOnly: true,
                                    controller: manufactureDateTextController,
                                    decoration: InputDecoration(
                                        labelText: "วันที่ผลิต",
                                        counterText: "",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        prefixIcon:
                                            const Icon(Icons.calendar_month),
                                        prefixIconColor: Colors.black),
                                    style: const TextStyle(
                                        fontFamily: 'Itim', fontSize: 18),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "กรุณาเลือกวันวันที่ผลิต";
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
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        expireDate = tempDate;
                                        expireDateTextController.text =
                                            dateFormat.format(expireDate!);
                                      });
                                      print(expireDate);
                                    },
                                    readOnly: true,
                                    controller: expireDateTextController,
                                    decoration: InputDecoration(
                                        labelText: "วันหมดอายุของสินค้า",
                                        counterText: "",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        prefixIcon:
                                            const Icon(Icons.calendar_month),
                                        prefixIconColor: Colors.black),
                                    style: const TextStyle(
                                        fontFamily: 'Itim', fontSize: 18),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "กรุณาเลือกวันหมดอายุของสินค้า";
                                      }
                                    },
                                  ),
                                ),
                                CustomTextFormField(
                                    controller: plantNameTextController,
                                    hintText: "ผลผลิตที่นำมาใช้",
                                    maxLength: 50,
                                    numberOnly: false,
                                    validator: (value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "กรุณากรอกผลผลิตที่นำมาใช้";
                                      }
                                    },
                                    icon: const Icon(Icons.account_circle)),
                                CustomTextFormField(
                                    controller: usedRawMatQtyTextController,
                                    hintText: "จำนวนของผลผลิตที่ใช้ในการผลิตสินค้า",
                                    maxLength: 50,
                                    numberOnly: true,
                                    validator: (value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "กรุณากรอกจำนวนของผลผลิตที่ใช้ในการผลิตสินค้า";
                                      }
                                    },
                                    icon: const Icon(Icons.bubble_chart)),
                                Center(
                                  child: DropdownButton<String>(
                                    value: selected_usedRawMatQtyUnit_items,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                    underline: Container(
                                      height: 3,
                                      color: Color.fromARGB(255, 51, 149, 158),
                                    ),
                                    items: usedRawMatQtyUnit_items
                                        .map(
                                          (String item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: Text(item)),
                                        )
                                        .toList(),
                                    onChanged: (item) => setState(() =>
                                        selected_usedRawMatQtyUnit_items =
                                            item),
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
                                                      BorderRadius.circular(
                                                          50.0))),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.green)),
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
                                          var username = await SessionManager()
                                              .get("username");
                                          products?.forEach((product) {
                                            if(product.productName == selected_productName){
                                              productId = product.productId;
                                              
                                            }
                                     
                                            
                                          });
                                         
                                          http.Response response =
                                              await manufacturingController
                                                  .addManufacturing(
                                                     manufactureDateTextController.text,
                                                     expireDateTextController.text,
                                                     productQtyTextController.text,
                                                     selected_productUnit_items!,
                                                     usedRawMatQtyTextController.text,
                                                     selected_usedRawMatQtyUnit_items!,
                                                     widget.rawMatShpId,
                                                      productId??"");

                                          //print("Status code is " + code.toString());

                                          if (response.statusCode == 500) {
                                            print("Error!");
                                            //showUsernameDuplicationAlert();
                                          } else {
                                            print(
                                                "Add manufacuring successfully!");
                                            // showSavePlantingSuccessAlert();
                                            showSaveManufacuringSuccessAlert();
                                          }
                                        }
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Text("เพิ่มการผลิตสินค้า",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Itim')),
                                        ],
                                      ),
                                    ),
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
