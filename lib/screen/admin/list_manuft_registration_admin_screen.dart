
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/admin/main_admin_screen.dart';
import 'package:mju_food_trace_app/screen/admin/view_manuft_regist_details_admin_screen.dart';

import '../../constant/constant.dart';

import '../../widgets/buddhist_year_converter.dart';
import 'navbar_admin.dart';

class ListManuftRegistrationScreen extends StatefulWidget {
  const ListManuftRegistrationScreen({super.key});

  @override
  State<ListManuftRegistrationScreen> createState() => _ListManuftRegistrationScreenState();
}

class _ListManuftRegistrationScreenState extends State<ListManuftRegistrationScreen> {
  ManufacturerController manufacturerController = ManufacturerController();
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  bool? isLoaded;

  List<Manufacturer>? manufacturers;
  var dateFormat = DateFormat('dd-MMM-yyyy');

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    manufacturers = await manufacturerController.getListAllManuftRegist();
    setState(() {
      isLoaded = true;
    });
    print(manufacturers?.length);
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
            title:Text("รายการลงทะเบียนผู้ผลิต",style: TextStyle(fontFamily: 'Itim',shadows: [
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
          manufacturers?.isNotEmpty == true? Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: manufacturers?.length,
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
                    image: AssetImage('images/factory_icon.png'),
                  ),
                ),
                      ],
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${manufacturers?[index].manuftName}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color:  Color.fromARGB(255, 5, 68, 95),
                          ),
                        ),
                        Text(
                          "${manufacturers?[index].manuftEmail}",
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
                              "${buddhistYearConverter.convertDateTimeToBuddhistDate(manufacturers?[index].manuftRegDate ?? DateTime.now())}",
                              style: const TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 18
                              )
                            ),
                          ],
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in,color: Color.fromARGB(255, 5, 40, 61),),
                    onTap: () {
                      print("Go to farmer ${manufacturers?[index].manuftId} details page!");
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewManuftRegistDetailsScreen(manuftId: manufacturers?[index].manuftId??"")));
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
                    image: AssetImage("images/bean_action5.png"),
                  ),
                  Text(
                    "ไม่มีการลงทะเบียนของผู้ผลิต",
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