
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/screen/admin/view_farmer_regist_details_admin_screen.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_controller.dart';
import '../../model/farmer.dart';
import 'navbar_admin.dart';

class ListFarmerRegistrationScreen extends StatefulWidget {
  const ListFarmerRegistrationScreen({super.key});

  @override
  State<ListFarmerRegistrationScreen> createState() => _ListFarmerRegistrationScreenState();
}

class _ListFarmerRegistrationScreenState extends State<ListFarmerRegistrationScreen> {

  FarmerController farmerController = FarmerController();

  bool? isLoaded;

  List<Farmer>? farmers;

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
            title: const Text("LIST FM REGIST"),
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
                        Icon(Icons.account_circle)
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
                            fontSize: 22
                          ),
                        ),
                        Text(
                          "${farmers?[index].farmerEmail}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "${farmers?[index].farmerRegDate}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in),
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
          )
        ),
      ),
    );
  }
}