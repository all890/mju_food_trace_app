import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/screen/admin/list_farmer_registration_admin_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/add_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer/list_planting_farmer_screen.dart';
import 'package:mju_food_trace_app/screen/farmer_register_screen.dart';
import 'package:mju_food_trace_app/screen/login_screen.dart';
import 'package:mju_food_trace_app/screen/manufacturer_register_screen.dart';
import 'package:mju_food_trace_app/screen/register_selection_screen.dart';
import 'package:mju_food_trace_app/screen/register_success_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen()
    );
  }
}
