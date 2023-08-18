
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/admin/main_admin_screen.dart';
import 'package:mju_food_trace_app/screen/admin/view_manuft_regist_details_admin_screen.dart';

import '../../constant/constant.dart';
import 'navbar_admin.dart';

class ListManuftRegistrationScreen extends StatefulWidget {
  const ListManuftRegistrationScreen({super.key});

  @override
  State<ListManuftRegistrationScreen> createState() => _ListManuftRegistrationScreenState();
}

class _ListManuftRegistrationScreenState extends State<ListManuftRegistrationScreen> {
  ManufacturerController manufacturerController = ManufacturerController();

  bool? isLoaded;

  List<Manufacturer>? manufacturers;

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
            title: const Text("LIST MN REGIST"),
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
          Container(
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
                        Icon(Icons.account_circle)
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
                            fontSize: 22
                          ),
                        ),
                        Text(
                          "${manufacturers?[index].manuftEmail}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "${manufacturers?[index].manuftRegDate}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in),
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
          )
        ),
      ),
    );
  }
}