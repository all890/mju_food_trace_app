
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
  String? fmCertPrevBlockHash;
  String? fmCertCurrBlockHash;

  Farmer? farmer;

  FarmerCertificate({
    this.fmCertId,
    this.fmCertImg,
    this.fmCertUploadDate,
    this.fmCertNo,
    this.fmCertRegDate,
    this.fmCertExpireDate,
    this.fmCertStatus,
    this.fmCertPrevBlockHash,
    this.fmCertCurrBlockHash,
    this.farmer,
  });

  factory FarmerCertificate.fromJsonToFarmerCertificate(Map<String, dynamic> json) => FarmerCertificate(
    fmCertId: json["fmCertId"],
    fmCertImg: json["fmCertImg"],
    fmCertUploadDate: DateTime.parse(json["fmCertUploadDate"]).toLocal(),
    fmCertNo: json["fmCertNo"],
    fmCertRegDate: DateTime.parse(json["fmCertRegDate"]).toLocal(),
    fmCertExpireDate: DateTime.parse(json["fmCertExpireDate"]).toLocal(),
    fmCertStatus: json["fmCertStatus"],
    fmCertPrevBlockHash: json["fmCertPrevBlockHash"],
    fmCertCurrBlockHash: json["fmCertCurrBlockHash"],
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
      'fmCertPrevBlockHash': fmCertPrevBlockHash,
      'fmCertCurrBlockHash': fmCertCurrBlockHash,
      'farmer': farmer?.user?.username
    };
  }

}