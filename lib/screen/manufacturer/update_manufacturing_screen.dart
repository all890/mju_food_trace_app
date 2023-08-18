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


  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
  List<String> usedRawMatQtyUnit_items = ["หน่วยของสินค้า", "กรัม", "กิโลกรัม"];
  String? selected_usedRawMatQtyUnit_items = "หน่วยของสินค้า";

  void fetchData(String manufacturingId) async {
    var username = await SessionManager().get("username");
    setState(() {
      var isLoaded = false;
    });
    var response = await manufacturingController.getManufacturingById(manufacturingId);
    manufacturing = Manufacturing.fromJsonToManufacturing(response);
    products = await productController.getListProduct(username);
    //  print(rawMaterialShipping?.planting?.plantName);
    
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

  }


   void showUpdateManufacturingSuccessAlert() {
    QuickAlert.show(
      context: context,
      title: "แก้ไขข้อมูลสำเร็จ",
      text: "แก้ไขข้อมูลการผลิตสินค้า",
      type: QuickAlertType.success,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        WidgetsBinding.instance!.addPostFrameCallback((_) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManufacturingScreen()));
        });
      }
    );
  }
  void showConfirmToUpdateManufacturingAlert ()  {
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
            manuftPrevBlockHash: "",
            manuftCurrBlockHash: "",
            rawMaterialShipping: manufacturing?.rawMaterialShipping,
            product:product
          );

          http.Response response = await manufacturingController.updateManufacturing(manufacturings);

          if (response.statusCode == 500) {
            //showFailToSaveProductAlert();
            print("Failed to update!");
          } else {
            showUpdateManufacturingSuccessAlert();
            print("Update successfully!");
          }
      
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
                                    hintText: "ปริมาณผลผลิตสุทธิ",
                                    maxLength: 50,
                                    numberOnly: true,
                                    validator: (value) {
                                      if (value!.isNotEmpty) {
                                        return null;
                                      } else {
                                        return "กรุณากรอกปริมาณผลผลิตสุทธิ";
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
                         /*     Padding(
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
                                ), */
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
