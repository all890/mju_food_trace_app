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
import '../../model/manufacturing.dart';
import '../../model/product.dart';
import '../../widgets/custom_text_form_field_widget.dart';

class UpdateManufacturingScreen extends StatefulWidget {
  final String manufacturingId;
  const UpdateManufacturingScreen({Key? key, required this.manufacturingId}) : super(key: key);
  

  @override
  State<UpdateManufacturingScreen> createState() => _UpdateManufacturingScreenState();
}

class _UpdateManufacturingScreenState extends State<UpdateManufacturingScreen> {
  
  final ManufacturingController manufacturingController = ManufacturingController();
  final ProductController productController = ProductController();
  final RawMaterialShippingController rawMaterialShippingController = RawMaterialShippingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  double? remQtyOfRms;
  double? canUseKg;
  double? canUseGrams;

  var dateFormat = DateFormat('dd-MM-yyyy');
  DateTime currentDate = DateTime.now();
  DateTime? manufactureDate;
  DateTime? expireDate;
  bool? isLoaded;

  String? selected_productName;
  List<Product>? products;
  List<String>? productNames = [];
  String? productId;

  Manufacturing? manufacturing;
  Product? product;

 TextEditingController manufactureDateTextController = TextEditingController();
  TextEditingController expireDateTextController = TextEditingController();

  TextEditingController productQtyTextController = TextEditingController();
  List<String> productUnit_items = ["หน่วยของสินค้า", "กรัม", "กิโลกรัม"];
  String? selected_productUnit_items = "หน่วยของสินค้า";

  TextEditingController plantNameTextController = TextEditingController();
  TextEditingController usedRawMatQtyTextController = TextEditingController();
  List<String> usedRawMatQtyUnit_items = ["หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า", "กรัม", "กิโลกรัม"];
  String? selected_usedRawMatQtyUnit_items = "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า";

  void fetchData(String manufacturingId) async {
    var username = await SessionManager().get("username");
    setState(() {
       isLoaded = false;
    });
    var response = await manufacturingController.getManufacturingById(manufacturingId);
    manufacturing = Manufacturing.fromJsonToManufacturing(response);
    products = await productController.getListProduct(username);
    var remQtyResponse = await rawMaterialShippingController.getRemQtyOfRmsIndivByManufacturingId(manufacturing?.manufacturingId ?? "");
    remQtyOfRms = double.parse(remQtyResponse);
    print("REMQTYOFRMS : ${remQtyOfRms}");
    canUseGrams = remQtyOfRms;
    canUseKg = remQtyOfRms! / 1000;
    print("GRAMS : ${canUseGrams}");
    print("KGS : ${canUseKg}");
    fetchName();
    setTextToData();
    setState(() {
      isLoaded = true;
    });
  }

  void fetchName() {
    products?.forEach((product) {
      String productName = product.productName ?? "";
      productNames?.add(productName);
    });

    

    print(productNames?.length);
  }

  void setTextToData(){
    selected_productName = manufacturing?.product?.productName??"";
    productQtyTextController.text =  (manufacturing?.productQty ?? 0).toString();
    selected_productUnit_items = manufacturing?.productUnit??"";
    manufactureDateTextController.text =  dateFormat.format(manufacturing?.manufactureDate?? DateTime.now());
    expireDateTextController.text = dateFormat.format(manufacturing?.expireDate?? DateTime.now());
    plantNameTextController.text = manufacturing?.rawMaterialShipping?.planting?.plantName??"";
    usedRawMatQtyTextController.text =  (manufacturing?.usedRawMatQty ?? 0.0).toString();
    selected_usedRawMatQtyUnit_items = manufacturing?.usedRawMatQtyUnit??"";
    setState(() {
      manufactureDate = manufacturing?.manufactureDate;
      expireDate = manufacturing?.expireDate;
    });
  }


   void showUpdateManufacturingSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "แก้ไขข้อมูลสำเร็จ",
      text: "แก้ไขข้อมูลการผลิตสินค้าสำเร็จ",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManufacturingScreen()));
        });
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

  void showConfirmToUpdateManufacturingAlert ()  {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะแก้ไขข้อมูลการผลิตสินค้า",
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

          if (selected_productUnit_items == "หน่วยของสินค้า") {
            return showProductUnitIsEmptyError();
          } else if (selected_usedRawMatQtyUnit_items == "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า") {
            return showusedRawMatShpQtyUnitIsEmptyError();
          } else {
            print("UPDATE MANUFACTURING!");
          //String username = await SessionManager().get("username");
            products?.forEach((p) {
               if(p.productName == selected_productName){
                 product = p;

               }              
            });
            print("สินค้า :" +"${product}");                          

            DateFormat dateFormat = DateFormat('dd-MM-yyyy');

            Manufacturing manufacturings = Manufacturing(
              manufacturingId: widget.manufacturingId,
              manufactureDate: dateFormat.parse(manufactureDateTextController.text),
              expireDate:  dateFormat.parse(expireDateTextController.text),
              productQty: int.parse(productQtyTextController.text),
              productUnit: selected_productUnit_items??"",
              usedRawMatQty: double.parse(usedRawMatQtyTextController.text),
              usedRawMatQtyUnit: selected_usedRawMatQtyUnit_items??"",
              manuftPrevBlockHash: manufacturing?.manuftPrevBlockHash,
              manuftCurrBlockHash: null,
              rawMaterialShipping: manufacturing?.rawMaterialShipping,
              product:product
            );

            http.Response response = await manufacturingController.updateManufacturing(manufacturings);

            if (response.statusCode == 500) {
              //showFailToSaveProductAlert();
              print("Failed to update!");
            } else {
              Navigator.pop(context);
              showUpdateManufacturingSuccessAlert();
              print("Update successfully!");
            }
          }
        } else {
          Navigator.pop(context);
        }
      }
      
    );
        }
  
  

   @override
  void initState() {
    super.initState();
    fetchData(widget.manufacturingId);
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
          body:isLoaded == false
                ? Column(
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
                                            return const ListManufacturingScreen();
                                          }));
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_back),
                                            SizedBox(
                                              width: 5.0,
                                            ),
                                            Text(
                                              "กลับไปยังหน้าการผลิตสินค้า",
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
                                    "แก้ไขการผลิตสินค้า",
                                    style: TextStyle(
                                        fontSize: 22, fontFamily: 'Itim'),
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
                                    maxLength: 6,
                                    numberOnly: true,
                                    validator: (value) {
                                      var productQtyRegEx = RegExp(r'^\d+$');
                                      if (value!.isEmpty) {
                                        return "กรุณากรอกปริมาณสินค้าที่ผลิตได้";
                                      }
                                      if (!productQtyRegEx.hasMatch(value)) {
                                        return "ปริมาณสินค้าที่ผลิตได้ต้องไม่ประกอบไปด้วยช่องว่าง";
                                      }
                                      if (int.parse(value) > 100000 || int.parse(value) <= 0) {
                                        return "กรุณากรอกปริมาณสินค้าที่ผลิตได้ให้มีค่าตั้งแต่ 1 - 100,000";
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
                                          initialDate: manufacturing?.manufactureDate ?? DateTime.now(),
                                          firstDate: manufacturing?.manufactureDate ?? DateTime.now(),
                                          lastDate: currentDate);
                                      setState(() {
                                        if (tempDate != null) {
                                          manufactureDate = tempDate;
                                          manufactureDateTextController.text =
                                            dateFormat.format(manufactureDate!);
                                          if (manufactureDate!.isAfter(expireDate ?? DateTime.now()) || manufactureDate!.isAtSameMomentAs(expireDate ?? DateTime.now())) {
                                            expireDate = manufactureDate!.add(Duration(days: 1));
                                            expireDateTextController.text = dateFormat.format(expireDate ?? DateTime.now());
                                          }
                                        } else {
                                          print("TEST 123");
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
                                      });
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
                                          initialDate: expireDate ?? DateTime.now(),
                                          firstDate: manufactureDate!.add(Duration(days: 1)),
                                          lastDate: DateTime(2100));
                                      setState(() {
                                        if (tempDate != null) {
                                          expireDate = tempDate;
                                          expireDateTextController.text =
                                          dateFormat.format(expireDate!);
                                        } else {
                                          print("TEST 1234");
                                          FocusManager.instance.primaryFocus?.unfocus();
                                        }
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
                                    enabled: false,
                                    validator: (value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "กรุณากรอกผลผลิตที่นำมาใช้";
                                      }
                                    },
                                    icon: const Icon(Icons.grass)),
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

                                    /*
                                    if (selected_usedRawMatQtyUnit_items == "หน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า") {
                                      showUsedRawMatQtyIsEmptyError();
                                      return "กรุณาเลือกหน่วยของจำนวนผลผลิตที่ใช้ผลิตสินค้า";
                                    }
                                    */

                                    double rmsNetQuantityGrams = 0;
                                    if (selected_usedRawMatQtyUnit_items == "กิโลกรัม") {
                                      rmsNetQuantityGrams = (remQtyOfRms??0) / 1000.0;
                                    } else {
                                      rmsNetQuantityGrams = (remQtyOfRms??0);
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
                                    icon: const Icon(Icons.expand_more),
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
                              showConfirmToUpdateManufacturingAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("บันทึกการแก้ไข",
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
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManufacturingScreen()));
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
