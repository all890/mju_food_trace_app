
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/model/user.dart';

class Farmer {

  String? farmerId;
  String? farmerName;
  String? farmerLastname;
  String? farmerEmail;
  String? farmerMobileNo;
  DateTime? farmerRegDate;
  String? farmerRegStatus;
  String? farmName;
  String? farmLatitude;
  String? farmLongitude;

  User? user;
 

  Farmer({
    this.farmerId,
    this.farmerName,
    this.farmerLastname,
    this.farmerEmail,
    this.farmerMobileNo,
    this.farmerRegDate,
    this.farmerRegStatus,
    this.farmName,
    this.farmLatitude,
    this.farmLongitude,
    this.user,
  });

  factory Farmer.fromJsonToFarmer(Map<String, dynamic> json) {

    return Farmer(
      farmerId: json["farmerId"],
      farmerName: json["farmerName"],
      farmerLastname: json["farmerLastname"],
      farmerEmail: json["farmerEmail"],
      farmerMobileNo: json["farmerMobileNo"],
      farmerRegDate: DateTime.parse(json["farmerRegDate"]),
      farmerRegStatus: json["farmerRegStatus"],
      farmName: json["farmName"],
      farmLatitude: json["farmLatitude"].toString(),
      farmLongitude: json["farmLongitude"].toString(),
      user: json["user"] == null ? null : User.fromJsonToUser(json["user"]),
    );
  }

  Map<String, dynamic> fromFarmerToJson() {
    return <String, dynamic>{
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerLastname': farmerLastname,
      'farmerEmail': farmerEmail,
      'farmerMobileNo': farmerMobileNo,
      'farmerRegDate': farmerRegDate?.toIso8601String(),
      'farmerRegStatus': farmerRegStatus,
      'farmName': farmName,
      'farmLatitude': farmLatitude,
      'farmLongitude': farmLongitude,
      'user': user?.fromUserToJson()
    };
  }

}