import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/model/manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/update_manufacturing_screen.dart';

import '../../constant/constant.dart';
import '../../controller/manufacturing_controller.dart';
import 'navbar_manufacturer.dart';

class ListManufacturingScreen extends StatefulWidget {
  const ListManufacturingScreen({super.key});

  @override
  State<ListManufacturingScreen> createState() => _ListManufacturingScreenState();
}

class _ListManufacturingScreenState extends State<ListManufacturingScreen> {
   ManufacturingController manufacturingController = ManufacturingController();

  bool? isLoaded;

  List<Manufacturing>? manufacurings;

  var dateFormat = DateFormat('dd-MM-yyyy');

  void fetchData() async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    manufacurings = await manufacturingController.getListAllManufacturingUsername(username);
    setState(() {
      isLoaded = true;
    });
    print(manufacurings?.length);
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
            title: const Text("LIST MANUFACTURINGS"),
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
          manufacurings?.length == 0?
          Container(
            child: Text("ยังไม่มีสินค้าของคุณ")
          ) :
          Column(
            children: [
               const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "รายการการผลิตสินค้า",
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
                    itemCount: manufacurings?.length,
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
                                "${manufacurings?[index].product?.productName}",
                                style: const TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 22
                                ),
                              ),
                                 Text(
                                "${dateFormat.format(manufacurings?[index].manufactureDate ?? DateTime.now())}",
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
                                      MaterialPageRoute(builder: (context) => UpdateManufacturingScreen(manufacturingId: manufacurings?[index].manufacturingId ?? "")),
                                    );
                                  },
                                  child: Icon(Icons.edit)
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("Delete Pressed!");
                                  //  showConfirmToDeleteAlert(products?[index].productId ?? "");
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
                ),
              ),
            ],
          )
        ),
      ),
    );;
  }
}