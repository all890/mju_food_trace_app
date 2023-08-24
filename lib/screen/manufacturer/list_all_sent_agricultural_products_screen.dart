import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/raw_material_shipping_controller.dart';
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';
import 'package:mju_food_trace_app/screen/manufacturer/add_manufacturing_screen.dart';

import '../../constant/constant.dart';
import 'navbar_manufacturer.dart';

class ListAllSentAgriculturalProductsScreen extends StatefulWidget {
  const ListAllSentAgriculturalProductsScreen({super.key});

  @override
  State<ListAllSentAgriculturalProductsScreen> createState() =>
      _ListAllSentAgriculturalProductsScreenState();
}

class _ListAllSentAgriculturalProductsScreenState
    extends State<ListAllSentAgriculturalProductsScreen> {
  RawMaterialShippingController rawMaterialShippingController =
      RawMaterialShippingController();

  bool? isLoaded;

  List<RawMaterialShipping>? raw_material_shippings;

  var dateFormat = DateFormat('dd-MM-yyyy');

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    raw_material_shippings = await rawMaterialShippingController
        .getListAllSentAgriByUsername(username);
    setState(() {
      isLoaded = true;
    });
    print(raw_material_shippings?.length);
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
                title: const Text("LIST ALL SENT AGRICULTURAL PRODUCTS"),
                backgroundColor: Colors.green,
              ),
              backgroundColor: kBackgroundColor,
              body: isLoaded == false
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
                    )
                      : Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "ผลผลิตที่ส่งมาจากเกษตรกร",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontFamily: 'Itim',
                                    color: Color.fromARGB(255, 33, 82, 35)),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                child: ListView.builder(
                                  itemCount: raw_material_shippings?.length,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: ListTile(
                                        title: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "ส่ง : " +
                                                  "${raw_material_shippings?[index].planting?.plantName}",
                                              style: const TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 22),
                                            ),
                                            Text(
                                              "รหัสการส่งผลผลิต : " +
                                                  "${raw_material_shippings?[index].planting?.plantingId}",
                                              style: const TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 22),
                                            ),
                                            Text(
                                              "จาก : " +
                                                  "${raw_material_shippings?[index].planting?.farmer?.farmName}",
                                              style: const TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 22),
                                            ),
                                            Text(
                                              "วันที่ส่ง : " +
                                                  "${dateFormat.format(raw_material_shippings?[index].rawMatShpDate ?? DateTime.now())}" +
                                                  " จำนวน : " +
                                                  "${raw_material_shippings?[index].rawMatShpQty}" +
                                                  " " +
                                                  "${raw_material_shippings?[index].rawMatShpQtyUnit}",
                                              style: const TextStyle(
                                                  fontFamily: 'Itim',
                                                  fontSize: 22),
                                            ),
                                          ],
                                        ),
                                        onTap: () {
                                          print(raw_material_shippings?[index]
                                              .rawMatShpId);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    AddManufacturingScreen(
                                                        rawMatShpId:
                                                            raw_material_shippings?[
                                                                        index]
                                                                    .rawMatShpId ??
                                                                "")),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        )),
        ),
      ),
    );
  }
}
