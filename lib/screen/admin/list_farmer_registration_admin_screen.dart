
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/screen/admin/view_farmer_regist_details_admin_screen.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_controller.dart';
import '../../model/farmer.dart';
import '../../widgets/buddhist_year_converter.dart';
import 'navbar_admin.dart';

class ListFarmerRegistrationScreen extends StatefulWidget {
  const ListFarmerRegistrationScreen({super.key});

  @override
  State<ListFarmerRegistrationScreen> createState() => _ListFarmerRegistrationScreenState();
}

class _ListFarmerRegistrationScreenState extends State<ListFarmerRegistrationScreen> {

  FarmerController farmerController = FarmerController();
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  bool? isLoaded;

  List<Farmer>? farmers;
  var dateFormat = DateFormat('dd-MMM-yyyy');

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    farmers = await farmerController.getListAllFarmerRegist();
    setState(() {
      isLoaded = true;
    });
    print(farmers?.length);
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
          drawer: AdminNavbar(),
          appBar: AppBar(
            title: Text("รายการลงทะเบียนเกษตรกร",style: TextStyle(fontFamily: 'Itim',shadows: [
                  Shadow(
                    color: Color.fromARGB(255, 0, 0, 0)
                        .withOpacity(0.5), // สีของเงา
                    offset: Offset(2, 2), // ตำแหน่งเงา (X, Y)
                    blurRadius: 3, // ความคมของเงา
                  ),
                ],),),
            backgroundColor: kClipPathColorAM,
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
          farmers?.isNotEmpty == true? Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: farmers?.length,
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
                        SizedBox(
                  width: 50,
                  height: 50,
                  child: Image(
                    image: AssetImage('images/farmer_icon.png'),
                  ),
                ),
                      ],
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${farmers?[index].farmerName} ${farmers?[index].farmerLastname}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontWeight: FontWeight.bold,
                            fontSize: 22,color: Color.fromARGB(255, 118, 77, 2)
                          ),
                        ),
                        Text(
                          "${farmers?[index].farmerEmail}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              "วันที่ลงทะเบียน : ",
                              style: const TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )
                            ),
                            Text(
                              "${buddhistYearConverter.convertDateTimeToBuddhistDate(farmers?[index].farmerRegDate ?? DateTime.now())}",
                              style: const TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 18
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in,color: Color.fromARGB(255, 71, 46, 2),),
                    onTap: () {
                      print("Go to farmer ${farmers?[index].farmerId} details page!");
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewFarmerRegistDetailsScreen(farmerId: farmers?[index].farmerId??"")));
                      });
                    },
                  ),
                );
              },
            ),
          ) : 
          Center(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    height: 350,
                    width: 350,
                    image: AssetImage("images/rice_action5.png"),
                  ),
                  Text(
                    "ไม่มีการลงทะเบียนของเกษตรกร",
                    style:
                        TextStyle(fontFamily: "Itim", fontSize: 20),
                  ),
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}