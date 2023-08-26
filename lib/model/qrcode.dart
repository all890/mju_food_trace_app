// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:mju_food_trace_app/model/manufacturing.dart';

class QRCode {

  String? qrcodeId;
  String? qrcodeImg;
  DateTime? generateDate;
  Manufacturing? manufacturing;
  
  QRCode({
    this.qrcodeId,
    this.qrcodeImg,
    this.generateDate,
    this.manufacturing,
  });

  Map<String, dynamic> fromQRCodeToJson() {
    return <String, dynamic>{
      'qrcodeId': qrcodeId,
      'qrcodeImg': qrcodeImg,
      'generateDate': generateDate?.toIso8601String(),
      'manufacturing': manufacturing?.fromManufacturingToJson(),
    };
  }

  factory QRCode.fromJsonToQRCode(Map<String, dynamic> json) {
    return QRCode(
      qrcodeId: json["qrcodeId"],
      qrcodeImg: json["qrcodeImg"],
      generateDate: DateTime.parse(json["generateDate"]),
      manufacturing: Manufacturing.fromJsonToManufacturing(json["manufacturing"])
    );
  }

}
