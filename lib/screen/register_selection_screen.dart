
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/screen/farmer_register_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer_register_screen.dart';

class RegisterSelectionScreen extends StatelessWidget {
  const RegisterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                print("Select farmer");
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const FarmerRegisterScreen();
                    }
                  )
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/2-50,
                  child: Card(
                    elevation: 10,
                    color: Colors.green,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Image(
                            image: AssetImage('images/farmer_icon.png')
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "เกษตรกร (Farmer)",
                            style: TextStyle(
                              fontSize: 22, fontFamily: 'Itim',color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Select manufacturer");
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const ManufacturerRegisterScreen();
                    }
                  )
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height/2,
                  child: Card(
                    elevation: 10,
                    color: Colors.blue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: Image(
                            image: AssetImage('images/factory_icon.png')
                          )
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                            "ผู้ผลิต (Manufacturer)",
                            style: TextStyle(
                              fontSize: 22, fontFamily: 'Itim',color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ]
        ),
      ),
    );
  }
}