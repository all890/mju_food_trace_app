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
  DateTime? tempManufactureDate;
  DateTime? expireDate;
  DateTime? tempExpireDate;
  bool? isLoaded;

  TextEditingController manufactureDateTextController = TextEditingController();
  TextEditingController expireDateTextController = TextEditingController();

  TextEditingController productQtyTextController = TextEditingController();
  List<String> productUnit_items = ["หน่วยของสินค้า", "หน่วย", "ถุง", "แพ็ค", "ขวด", "ชุด", "ห่อ", "กระสอบ"];
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
  bool? ableToFillRawMatShpQty = false;

  double? canUseKg;
  double? canUseGrams;

  var maxProductQty = 0;

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
      manufactureDateTextController.text = dateFormat.format(DateTime.now());
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

  void showusedRawMatShpQtyUnitIsEmptyError () {
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

  void calculateMaxProductQty () {
    double maxGrams = 0;

    if (selected_usedRawMatQtyUnit_items == "กิโลกรัม") {
      maxGrams = double.parse(usedRawMatQtyTextController.text) * 1000;
    } else {
      maxGrams = double.parse(usedRawMatQtyTextController.text);
    }
    products?.forEach((product) {
      if (product.productName == selected_productName){
        maxProductQty = maxGrams ~/ (product.netVolume ?? 0);
      }
    });
    
  }

  void checkUsedRawMatShpQtyNullState () {
    if (usedRawMatQtyTextController.text.isEmpty || selected_usedRawMatQtyUnit_items == "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า") {
      setState(() {
        productQtyTextController.text = "";
        ableToFillRawMatShpQty = false;
      });
    } else {
      setState(() {
        ableToFillRawMatShpQty = true;
        calculateMaxProductQty();
        print("MAX PROD QTY IS : ${maxProductQty}");
      });
    }
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
                                        fontSize: 22, fontFamily: 'Itim',color:Color.fromARGB(255, 4, 92, 89),fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 22),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "ข้อมูลการผลิตสินค้า",
                                      style: TextStyle(
                                          fontSize: 20, fontFamily: 'Itim',fontWeight: FontWeight.bold),
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
                                    icon: const Icon(Icons.expand_more,color: Color.fromARGB(255, 4, 92, 89),),
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
                                    onChanged: (item) {
                                      setState(() {
                                        selected_productName = item;
                                        usedRawMatQtyTextController.text = "";
                                        checkUsedRawMatShpQtyNullState();
                                        productQtyTextController.text = "";
                                        selected_usedRawMatQtyUnit_items = "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า";
                                      });
                                    },
                                            
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.compost,color:  Color.fromARGB(255, 1, 73, 71),),
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
                                          initialDate: tempManufactureDate ?? currentDate,
                                          firstDate: rawMaterialShipping?.rawMatShpDate ?? DateTime.now(),
                                          lastDate: currentDate);
                                      setState(() {
                                        if (tempDate != null) {
                                          tempManufactureDate = tempDate;
                                          manufactureDate = tempDate;
                                          manufactureDateTextController.text =
                                            dateFormat.format(manufactureDate??DateTime.now());
                                          if (manufactureDateTextController.text != "") {
                                            enableExpireDateField = true;
                                          } else {
                                            enableExpireDateField = false;
                                          }
                                        } else {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
                                      });
                                    },
                                    readOnly: true,
                                    enabled: false,
                                    controller: manufactureDateTextController,
                                    decoration: InputDecoration(
                                        labelText: "วันที่ผลิต",
                                        counterText: "",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        prefixIcon:
                                            const Icon(Icons.calendar_month,color: Color.fromARGB(255, 1, 73, 71)),
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
                                          initialDate: DateTime.now().add(Duration(days: 1)),
                                          firstDate: DateTime.now().add(Duration(days: 1)),
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        if (tempDate != null) {
                                          tempExpireDate = tempDate;
                                          expireDate = tempDate;
                                          expireDateTextController.text =
                                          dateFormat.format(expireDate??DateTime.now());
                                          print(expireDate);
                                        } else {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
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
                                            const Icon(Icons.calendar_month,color:  Color.fromARGB(255, 1, 73, 71),)),
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
                                  icon: const Icon(Icons.grass,color:  Color.fromARGB(255, 1, 73, 71),)
                                ),
                                CustomTextFormField(
                                  controller: usedRawMatQtyTextController,
                                  hintText: "จำนวนของผลผลิตที่ใช้ในการผลิตสินค้า",
                                  hT: "ไม่เกิน ${canUseKg} กิโลกรัม หรือ ${canUseGrams} กรัม",
                                  maxLength: 50,
                                  numberOnly: true,
                                  onChanged: (value) {
                                    checkUsedRawMatShpQtyNullState();
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "กรุณากรอกจำนวนของผลผลิตที่ใช้ในการผลิตสินค้า";
                                    }

                                    if (double.parse(value) <= 0) {
                                      return "กรุณากรอกจำนวนของผลผลิตที่ใช้ในการผลิตสินค้าให้มีค่ามากกว่า 0";
                                    }

                                    double actualGrams = 0;

                                    if (selected_usedRawMatQtyUnit_items == "กิโลกรัม") {
                                      actualGrams = double.parse(value) * 1000;
                                    } else {
                                      actualGrams = double.parse(value);
                                    }

                                    /*
                                    if (selected_usedRawMatQtyUnit_items == "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า") {
                                      showUsedRawMatQtyIsEmptyError();
                                      return "กรุณาเลือกหน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า";
                                    }
                                    */

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
                                  icon: const Icon(Icons.bubble_chart,color:  Color.fromARGB(255, 1, 73, 71),)
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
                                    icon: const Icon(Icons.expand_more,color:  Color.fromARGB(255, 1, 73, 71),),
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
                                    onChanged: (item) {
                                      setState(() {
                                        selected_usedRawMatQtyUnit_items = item;
                                        checkUsedRawMatShpQtyNullState();
                                      });
                                    },
                                            
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(Icons.bubble_chart,color:  Color.fromARGB(255, 1, 73, 71),),
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
                                    hT: "ปริมาณสินค้าที่ผลิตจะได้ไม่เกิน ${maxProductQty} หน่วย",
                                    maxLength: 6,
                                    numberOnly: true,
                                    enabled: ableToFillRawMatShpQty,
                                    validator: (value) {
                                      var productQtyRegEx = RegExp(r'^\d+$');
                                      if (value!.isEmpty) {
                                        return "กรุณากรอกปริมาณสินค้าที่ผลิตได้";
                                      }
                                      if (value.contains(" ")) {
                                        return "ปริมาณสินค้าต้องไม่ประกอบไปด้วยช่องว่าง";
                                      }
                                      if (!productQtyRegEx.hasMatch(value)) {
                                        return "ปริมาณสินค้าต้องเป็นตัวเลขจำนวนเต็มบวกเท่านั้น";
                                      }
                                      if (int.parse(value) > 100000 || int.parse(value) <= 0) {
                                        return "กรุณากรอกปริมาณสินค้าที่ผลิตได้ให้มีค่าตั้งแต่ 1 - 100,000";
                                      }
                                      if (int.parse(value) > maxProductQty) {
                                        return "ปริมาณสินค้าที่ผลิตได้ต้องมีค่าไม่เกิน ${maxProductQty} หน่วย";
                                      }
                                    },
                                    icon: const Icon(Icons.equalizer,color:  Color.fromARGB(255, 1, 73, 71),)),

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
                                    icon: const Icon(Icons.expand_more,color:  Color.fromARGB(255, 1, 73, 71),),
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
                                              prefixIcon: Icon(Icons.bubble_chart,color:  Color.fromARGB(255, 1, 73, 71),),
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

                                        if (formKey.currentState!.validate()) {

                                          if (selected_productUnit_items == "หน่วยของสินค้า") {
                                            return showProductUnitIsEmptyError();
                                          } else if (selected_usedRawMatQtyUnit_items == "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า") {
                                            return showusedRawMatShpQtyUnitIsEmptyError();
                                          } else {
                                            //Farmer's data insertion using farmer controller
                                            var username = await SessionManager()
                                                .get("username");
                                            products?.forEach((product) {
                                              if(product.productName == selected_productName){
                                                productId = product.productId;
                                                
                                              }
                                            });
                                          
                                            var isChainBeforeManufacturingValidResp = await manufacturingController
                                            .isChainBeforeManufacturingValid(productId??"", widget.rawMatShpId);

                                            if (isChainBeforeManufacturingValidResp == 200) {
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
                                            } else if (isChainBeforeManufacturingValidResp == 409) {
                                              showError("ไม่สามารถเพิ่มการผลิตสินค้าได้ เนื่องจากการเข้ารหัสข้อมูลก่อนหน้าไม่ตรงกัน");
                                            }

                                            
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
