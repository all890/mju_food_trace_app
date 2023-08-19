
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/planting_controller.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/screen/farmer/navbar_farmer.dart';
import 'package:mju_food_trace_app/screen/farmer/send_agricultural_products.dart';
import 'package:mju_food_trace_app/screen/farmer/update_planting_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/view_planting_details_screen.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';

class ListPlantingScreen extends StatefulWidget {
  const ListPlantingScreen({super.key});

  @override
  State<ListPlantingScreen> createState() => _ListPlantingScreenState();
}

class _ListPlantingScreenState extends State<ListPlantingScreen> {

  PlantingController plantingController = PlantingController();

  bool? isLoaded;

  List<Planting>? plantings;

  List<Planting>? cannotSentPlantings = [];
  List<Planting>? didNotSentPlantings = [];
  List<Planting>? sendPlantings = [];

  var dateFormat = DateFormat('dd-MM-yyyy');

 void showConfirmToDeleteAlert (String plantingId) {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "แจ้งเตือน",
      text: "คุณต้องการลบการปลูกนี้หรือไม่",
      type: QuickAlertType.warning,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      onConfirmBtnTap: () async{
        print(plantingId);
       http.Response response = await plantingController.deletePlanting(plantingId);
        Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListPlantingScreen()));
          });
      }
     
    );
  }

  void fetchData () async {
    var username = await SessionManager().get("username");
    setState(() {
      isLoaded = false;
    });
    plantings = await plantingController.getListPlantingById(username);
    splitPlantingBySending();
    setState(() {
      isLoaded = true;
    });
    print(plantings?.length);
  }

  void splitPlantingBySending () {
    plantings?.forEach((planting) {
      final now = DateTime.now();
      if (planting.approxHarvDate?.compareTo(now) == 1 || planting.approxHarvDate?.compareTo(now) == 0) {
        cannotSentPlantings?.add(planting);
      } else if (planting.ptCurrBlockHash == "") {
        didNotSentPlantings?.add(planting);
      } else {
        sendPlantings?.add(planting);
      }
    });

    print("Length of didNotSentPlantings : ${didNotSentPlantings?.length}");
    print("Length of sendPlantings : ${sendPlantings?.length}");
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: SafeArea(
      child: Scaffold(
        drawer: FarmerNavbar(),
        appBar: AppBar(
          title: const Text("รายการปลูกผลผลิต"),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  "ไม่สามารถส่งได้",
                  style: TextStyle(
                    fontFamily: 'Itim'
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "สามารถส่งได้",
                  style: TextStyle(
                    fontFamily: 'Itim'
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "ส่งแล้ว",
                  style: TextStyle(
                    fontFamily: 'Itim'
                  ),
                ),
              ),
            ],
          ),
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
        TabBarView(
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: cannotSentPlantings?.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      title: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${cannotSentPlantings?[index].plantName}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 22
                            ),
                          ),
                          Text(
                            "วันที่ปลูก : " + dateFormat.format(cannotSentPlantings?[index].plantDate??DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                          Text(
                            "วันที่คาดว่าจะเก็บเกี่ยว : " + dateFormat.format(cannotSentPlantings?[index].approxHarvDate??DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                          Text(
                            "ปริมาณผลผลิตสุทธิ : ${cannotSentPlantings?[index].netQuantity} ${cannotSentPlantings?[index].netQuantityUnit}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                      width: 100,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("Delete Pressed!");
                               showConfirmToDeleteAlert(didNotSentPlantings?[index].plantingId ?? "");
                              },
                              child: Icon(Icons.delete)
                            ),
                            GestureDetector(
                              onTap: () {
                                print("Edit Pressed!");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => UpdatePlantingScreen(plantingId: didNotSentPlantings?[index].plantingId ?? "")),
                               );
                              },
                              child: Icon(Icons.edit)
                            ),
                          ],
                        ),
                      ),
                    )
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: didNotSentPlantings?.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      title: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${didNotSentPlantings?[index].plantName}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 22
                            ),
                          ),
                          Text(
                            "วันที่ปลูก : " + dateFormat.format(didNotSentPlantings?[index].plantDate??DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                          Text(
                            "วันที่คาดว่าจะเก็บเกี่ยว : " + dateFormat.format(didNotSentPlantings?[index].approxHarvDate??DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                          Text(
                            "ปริมาณผลผลิตสุทธิ : ${didNotSentPlantings?[index].netQuantity} ${didNotSentPlantings?[index].netQuantityUnit}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                      width: 100,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("Delete Pressed!");
                               showConfirmToDeleteAlert(didNotSentPlantings?[index].plantingId ?? "");
                              },
                              child: Icon(Icons.delete)
                            ),
                            GestureDetector(
                              onTap: () {
                                print("Edit Pressed!");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => UpdatePlantingScreen(plantingId: didNotSentPlantings?[index].plantingId ?? "")),
                               );
                              },
                              child: Icon(Icons.edit)
                            ),
                          
                             GestureDetector(
                              onTap: () {
                                print("Send Pressed!");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SendAgriculturalProducts(plantingId: didNotSentPlantings?[index].plantingId ?? "")),
                               );
                              },
                              child: Icon(Icons.send)
                            )
                          ],
                        ),
                      ),
                    )
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: ListView.builder(
                itemCount: sendPlantings?.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: ListTile(
                      title: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${sendPlantings?[index].plantName}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 22
                            ),
                          ),
                          Text(
                            "วันที่ปลูก : " + dateFormat.format(sendPlantings?[index].plantDate??DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                          Text(
                            "วันที่คาดว่าจะเก็บเกี่ยว : " + dateFormat.format(sendPlantings?[index].approxHarvDate??DateTime.now()),
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                          Text(
                            "ปริมาณผลผลิตคงเหลือ : BLAH",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          ),
                        ],
                      ),
                      trailing: SizedBox(
                      width: 100,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [    
                           Center(
                             child: GestureDetector(
                              onTap: () {
                                print("Send Pressed!");
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => SendAgriculturalProducts(plantingId: sendPlantings?[index].plantingId ?? "")),
                               );
                              },
                              child: Icon(Icons.send)
                                                     ),
                           )
                        ],
                      ),
                    )
                    ),
                  );
                },
              ),
            )
          ]
        ),
      ),
    )
  );
}