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
import 'package:mju_food_trace_app/screen/manufacturer/add_product_manufacturer_screen.dart';
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
  final double? remQtyOfRms;
  const AddManufacturingScreen({Key? key, required this.rawMatShpId, this.remQtyOfRms})
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

  bool? enableExpireDateField = false;

  double? canUseKg;
  double? canUseGrams;

  void showErrorToAddManufacturingBecauseProductIsEmpty () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "คุณไม่สามารถเพิ่มข้อมูลการผลิตสินค้าได้เนื่องจากคุณไม่มีสินค้าอยู่ในระบบ กรุณาเพิ่มสินค้าอย่างน้อย 1 ชิ้น",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: ((context) => AddProductScreen())));
        
      }
    );
  }

  void fetchData(String rawMatShpId) async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
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
    if (products?.length == 0) {
      showErrorToAddManufacturingBecauseProductIsEmpty();
    } else {
      fetchName();
    }
    canUseKg = widget.remQtyOfRms! / 1000;
    canUseGrams = widget.remQtyOfRms;
    setState(() {
      isLoaded = true;
    });
  }

  void fetchName() {
    products?.forEach((product) {
      print(product.productName);
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
    print(widget.remQtyOfRms);
  }

  //showUsedRawMatQtyIsEmptyError

  void showUsedRawMatQtyIsEmptyError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "กรุณาเลือกหน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showProductUnitIsEmptyError () {
    QuickAlert.show(
      context: context,
      title: "เกิดข้อผิดพลาด",
      text: "กรุณาเลือกหน่วยของสินค้า",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
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
          body: isLoaded == false? 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                ],
              ):
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
                                            value: selected_productName,
                                    icon: const Icon(Icons.expand_more),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                   
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
                                            
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.compost),
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
                                    icon: const Icon(Icons.equalizer)),

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
                                            value: selected_productUnit_items,
                                    icon: const Icon(Icons.expand_more),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                 
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
                                  child: TextFormField(
                                    onTap: () async {
                                      DateTime? tempDate = await showDatePicker(
                                          context: context,
                                          initialDate: currentDate,
                                          firstDate: rawMaterialShipping?.rawMatShpDate ?? DateTime.now(),
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        manufactureDate = tempDate;
                                        manufactureDateTextController.text =
                                            dateFormat.format(manufactureDate??DateTime.now());
                                        if (manufactureDateTextController.text != "") {
                                          enableExpireDateField = true;
                                        } else {
                                          enableExpireDateField = false;
                                        }
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
                                    enabled: enableExpireDateField,
                                    onTap: () async {
                                      DateTime? tempDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateFormat('dd-MM-yyyy').parse(manufactureDateTextController.text).add(Duration(days: 1)),
                                          firstDate: DateFormat('dd-MM-yyyy').parse(manufactureDateTextController.text).add(Duration(days: 1)),
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        expireDate = tempDate;
                                        expireDateTextController.text =
                                            dateFormat.format(expireDate??DateTime.now());
                                        print(expireDate);
                                      });
                                      
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
                                  enabled: false,
                                  validator: (value) {
                                    if (value!.isNotEmpty) {
                                      return null;
                                    } else {
                                      return "กรุณากรอกผลผลิตที่นำมาใช้";
                                    }
                                  },
                                  icon: const Icon(Icons.grass)
                                ),
                                CustomTextFormField(
                                  controller: usedRawMatQtyTextController,
                                  hintText: "จำนวนของผลผลิตที่ใช้ในการผลิตสินค้า",
                                  hT: "ไม่เกิน ${canUseKg} กิโลกรัม หรือ ${canUseGrams} กรัม",
                                  maxLength: 50,
                                  numberOnly: true,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกจำนวนของผลผลิตที่ใช้ในการผลิตสินค้า";
                                    }

                                    double actualGrams = 0;

                                    if (selected_usedRawMatQtyUnit_items == "กิโลกรัม") {
                                      actualGrams = double.parse(value) * 1000;
                                    } else {
                                      actualGrams = double.parse(value);
                                    }

                                    if (selected_usedRawMatQtyUnit_items == "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า") {
                                      showUsedRawMatQtyIsEmptyError();
                                      return "กรุณาเลือกหน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า";
                                    }

                                    double rmsNetQuantityGrams = 0;
                                    if (selected_usedRawMatQtyUnit_items == "กิโลกรัม") {
                                      rmsNetQuantityGrams = (widget.remQtyOfRms??0) / 1000.0;
                                    } else {
                                      rmsNetQuantityGrams = (widget.remQtyOfRms??0);
                                    }

                                    print("KILOGRAMS : ${actualGrams/1000} <> ${rmsNetQuantityGrams}");
                                    print("GRAMS : ${actualGrams} <> ${rmsNetQuantityGrams*1000}");

                                    print("NORMAL : ${actualGrams} <> ${rmsNetQuantityGrams}");

                                    if (selected_usedRawMatQtyUnit_items == "กิโลกรัม" && actualGrams/1000 > rmsNetQuantityGrams) {
                                      return "ปริมาณผลผลิตที่ใช้ต้องไม่เกินปริมาณผลผลิตที่มีอยู่";
                                    }
                                    else if (selected_usedRawMatQtyUnit_items == "กรัม" && actualGrams > rmsNetQuantityGrams*1000) {
                                      return "ปริมาณผลผลิตที่ใช้ต้องไม่เกินปริมาณผลผลิตที่มีอยู่";
                                    }
                                    else {
                                      return null;
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
                                           value: selected_usedRawMatQtyUnit_items,
                                    icon: const Icon(Icons.arrow_downward),
                                    elevation: 5,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontFamily: 'Itim',
                                    ),
                                    isExpanded: true,
                                   
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
                                                  kClipPathColorMN)),
                                      onPressed: () async {

                                        if (selected_productUnit_items == "หน่วยของสินค้า") {
                                          return showProductUnitIsEmptyError();
                                        }

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
