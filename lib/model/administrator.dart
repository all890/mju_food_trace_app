// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:mju_food_trace_app/model/user.dart';

class Administrator {

  String? adminId;
  String? adminName;
  String? adminLastname;
  String? adminMobileNo;
  User? user;

  Administrator({
    this.adminId,
    this.adminName,
    this.adminLastname,
    this.adminMobileNo,
    this.user,
  });

  factory Administrator.fromJsonToAdministrator(Map<String, dynamic> json) {
    return Administrator(
      adminId: json['adminId'],
      adminName: json['adminName'],
      adminLastname: json['adminLastname'],
      adminMobileNo: json['adminMobileNo'],
      user: json["user"] == null ? null : User.fromJsonToUser(json["user"]),
    );
  }

  Map<String, dynamic> fromAdministratorToJson() {
    return <String, dynamic>{
      'adminId': adminId,
      'adminName': adminName,
      'adminLastname': adminLastname,
      'adminMobileNo': adminMobileNo,
      'user': user?.fromUserToJson(),
    };
  }

}
