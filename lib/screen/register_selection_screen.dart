
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/screen/farmer_register_screen.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer_register_screen.dart';
import 'package:mju_food_trace_app/screen/user/navbar_user.dart';


class RegisterSelectionScreen extends StatefulWidget {
  const RegisterSelectionScreen({super.key});

  @override
  State<RegisterSelectionScreen> createState() => _RegisterSelectionScreenState();
}

class _RegisterSelectionScreenState extends State<RegisterSelectionScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          key: _globalKey,
          drawer: UserNavbar(),
          backgroundColor: kBackgroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.menu_rounded),
                    iconSize: 40.0,
                    onPressed: () {
                      _globalKey.currentState?.openDrawer();
                    },
                  ),
                ),
                SizedBox(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(70),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                          child: Image(
                            image: AssetImage('images/logo.png'),
                            width: 240,
                            height: 240,
                          ),
                        ),
                        const Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: const Text(
                            "เลือกประเภทผู้ใช้งาน",
                            style: TextStyle(
                              fontFamily: 'Itim',
                              fontSize: 24
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                          BorderRadius.circular(50.0))),
                                        backgroundColor: MaterialStateProperty.all<Color>(kClipPathColorFM)
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const FarmerRegisterScreen();
                                      }
                                    )
                                  );
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 30, top: 5, bottom: 5),
                                      child: Image(
                                        image: AssetImage("images/farmer_icon.png"),
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    Text("เกษตรกร",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Itim'
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                            child: SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                          BorderRadius.circular(50.0))),
                                        backgroundColor: MaterialStateProperty.all<Color>(kClipPathColorMN)
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return const ManufacturerRegisterScreen();
                                      }
                                    )
                                  );
                                },
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 30, top: 5, bottom: 5),
                                      child: Image(
                                        image: AssetImage("images/factory_icon.png"),
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    Text("ผู้ผลิต",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontFamily: 'Itim'
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 25),
                          child: InkWell(
                            child: Text(
                              "กลับไปยังหน้าเข้าสู่ระบบ",
                              style: TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 18,
                                decoration: TextDecoration.underline
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const LoginScreen();
                                  }
                                )
                              );
                              print("Go to login");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}