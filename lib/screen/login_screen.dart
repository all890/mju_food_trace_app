
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/user_controller.dart';
import 'package:mju_food_trace_app/screen/admin/main_admin_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer/list_manufacturing.dart';
import 'package:mju_food_trace_app/screen/manufacturer/main_manufacturer_screen.dart';
import 'package:mju_food_trace_app/screen/register_selection_screen.dart';
import 'package:mju_food_trace_app/screen/user/navbar_user.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../widgets/custom_text_form_field_widget.dart';
import 'admin/list_farmer_registration_admin_screen.dart';
import 'farmer/main_farmer_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  UserController userController = UserController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  TextEditingController usernameTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  void showUsernameOrPasswordAreWrongAlert () {
    QuickAlert.show(
      context: context,
      title: "เข้าสู่ระบบไม่สำเร็จ",
      text: "กรุณากรอกชื่อผู้ใช้หรือรหัสผ่านให้ถูกต้อง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showErrorAlert () {
    QuickAlert.show(
      context: context,
      title: "เข้าสู่ระบบไม่สำเร็จ",
      text: "ระบบเกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

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
          body: Form(
            key: formKey,
            child: SingleChildScrollView(
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
                              "ลงชื่อเข้าใช้บัญชีของคุณ",
                              style: TextStyle(
                                fontFamily: 'Itim',
                                fontSize: 24
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: CustomTextFormField(
                              controller: usernameTextController,
                              hintText: "ชื่อผู้ใช้งาน",
                              maxLength: 50,
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "กรุณากรอกชื่อผู้ใช้งาน";
                                }
                              },
                              icon: const Icon(Icons.account_circle),
                            ),
                          ),
                          SizedBox(
                            width: 350,
                            child: CustomTextFormField(
                              controller: passwordTextController,
                              hintText: "รหัสผ่าน",
                              maxLength: 50,
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "กรุณากรอกรหัสผ่าน";
                                }
                              },
                              icon: const Icon(Icons.lock),
                              obscureText: true,
                              maxLines: 1,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                            child: SizedBox(
                              height: 53,
                              width: 200,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                          BorderRadius.circular(50.0))),
                                        backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                                ),
                                onPressed: () async {
            
                                  if (formKey.currentState!.validate()) {
                                    http.Response response = await userController.userLogin(
                                      usernameTextController.text,
                                      passwordTextController.text
                                    );
            
                                    if (response.statusCode == 403) {
                                      print("User not found naja eiei");
                                      showUsernameOrPasswordAreWrongAlert();
                                    } else if (response.statusCode == 500) {
                                      print("Error naja eiei");
                                      showErrorAlert();
                                    } else {
                                      var jsonResponse = jsonDecode(response.body);
                                      String userType = jsonResponse["userType"];
                                      if (userType == "FARMER") {
                                        print("สวัสดีจอนชาวไร่");
                                        await SessionManager().set("username", jsonResponse["username"].toString());
                                        // await SessionManager().set("userType", jsonResponse["userType"].toString());
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return const ListPlantingScreen();
                                            }
                                          )
                                        );
                                      } else if (userType == "MANUFT") {
                                          print("สวัสดีนายทุน");
                                        await SessionManager().set("username", jsonResponse["username"].toString());
                                        // await SessionManager().set("userType", jsonResponse["userType"].toString());
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return const ListManufacturingScreen();
                                            }
                                          )
                                        );
                                      } else {
                                        print("สวัสดีแอดมิน");
                                        await SessionManager().set("username", jsonResponse["username"].toString());
                                        // await SessionManager().set("userType", jsonResponse["userType"].toString());
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) {
                                              return const ListFarmerRegistrationScreen();
                                            }
                                          )
                                        );
                                      }
                                    }
                                  }
            
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text("เข้าสู่ระบบ",
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
                            child: InkWell(
                              child: Text(
                                "สมัครบัญชีผู้ใช้",
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
                                      return const RegisterSelectionScreen();
                                    }
                                  )
                                );
                                print("Go to register selection");
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
      ),
    );
  }
}