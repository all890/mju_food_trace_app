
import 'package:intl/intl.dart';

import 'farmer.dart';

class FarmerCertificate {

  String? fmCertId;
  String? fmCertImg;
  DateTime? fmCertUploadDate;
  String? fmCertNo;
  DateTime? fmCertRegDate;
  DateTime? fmCertExpireDate;
  String? fmCertStatus;

  Farmer? farmer;

  FarmerCertificate({
    this.fmCertId,
    this.fmCertImg,
    this.fmCertUploadDate,
    this.fmCertNo,
    this.fmCertRegDate,
    this.fmCertExpireDate,
    this.fmCertStatus,
    this.farmer,
  });

  factory FarmerCertificate.fromJsonToFarmerCertificate(Map<String, dynamic> json) => FarmerCertificate(
    fmCertId: json["fmCertId"],
    fmCertImg: json["fmCertImg"],
    fmCertUploadDate: DateTime.parse(json["fmCertUploadDate"]),
    fmCertNo: json["fmCertNo"],
    fmCertRegDate: DateTime.parse(json["fmCertRegDate"]),
    fmCertExpireDate: DateTime.parse(json["fmCertExpireDate"]),
    fmCertStatus: json["fmCertStatus"],
    farmer: json["farmer"] == null ? null : Farmer.fromJsonToFarmer(json["farmer"])
  );

  Map<String, dynamic> fromFarmerCertificateToJson() {
    return <String, dynamic>{
      'fmCertId': fmCertId,
      'fmCertImg': fmCertImg,
      'fmCertUploadDate': fmCertUploadDate,
      'fmCertNo': fmCertNo,
      'fmCertRegDate': fmCertRegDate,
      'fmCertExpireDate': fmCertExpireDate,
      'fmCertStatus': fmCertStatus,
      'farmer': farmer?.user?.username
    };
  }

}