
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
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

  List<Planting>? didNotSentPlantings = [];
  List<Planting>? sendPlantings = [];

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
      if (planting.ptCurrBlockHash == null) {
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
    length: 2,
    child: SafeArea(
      child: Scaffold(
        drawer: FarmerNavbar(),
        appBar: AppBar(
          title: const Text("รายการปลูกผลผลิต"),
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  "ผลผลิตที่รอส่ง",
                  style: TextStyle(
                    fontFamily: 'Itim'
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "ผลผลิตที่ส่งแล้ว",
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
                            "${didNotSentPlantings?[index].farmer?.farmName}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            ),
                          ),
                          Text(
                            "${didNotSentPlantings?[index].plantDate}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          )
                        ],
                      ),
                      trailing: SizedBox(
                      width: 100,
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
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_circle)
                        ],
                      ),
                      title: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${sendPlantings?[index].plantingId}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 22
                            ),
                          ),
                          Text(
                            "${sendPlantings?[index].plantName}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            ),
                          ),
                          Text(
                            "${sendPlantings?[index].plantDate}",
                            style: const TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 18
                            )
                          )
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