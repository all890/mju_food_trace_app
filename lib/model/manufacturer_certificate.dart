
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';

class ManufacturerCertificate {

  String? mnCertId;
  String? mnCertImg;
  DateTime? mnCertUploadDate;
  String? mnCertNo;
  DateTime? mnCertRegDate;
  DateTime? mnCertExpireDate;
  String? mnCertStatus;

  Manufacturer? manufacturer;

  ManufacturerCertificate({
    this.mnCertId,
    this.mnCertImg,
    this.mnCertUploadDate,
    this.mnCertNo,
    this.mnCertRegDate,
    this.mnCertExpireDate,
    this.mnCertStatus,
    this.manufacturer
  });

  factory ManufacturerCertificate.fromJsonToManufacturerCertificate(Map<String, dynamic> json) => ManufacturerCertificate(
    mnCertId: json["mnCertId"],
    mnCertImg: json["mnCertImg"],
    mnCertUploadDate: DateTime.parse(json["mnCertUploadDate"]).toLocal(),
    mnCertNo: json["mnCertNo"],
    mnCertRegDate: DateTime.parse(json["mnCertRegDate"]).toLocal(),
    mnCertExpireDate: DateTime.parse(json["mnCertExpireDate"]).toLocal(),
    mnCertStatus: json["mnCertStatus"],
    manufacturer: json["manufacturer"] == null ? null : Manufacturer.fromJsonToManufacturer(json["manufacturer"])
  );

  Map<String, dynamic> fromManufacturerCertificateToJson() {
    return <String, dynamic> {
      'mnCertId': mnCertId,
      'mnCertImg': mnCertImg,
      'mnCertUploadDate': mnCertUploadDate,
      'mnCertNo': mnCertNo,
      'mnCertRegDate': mnCertRegDate,
      'mnCertExpireDate': mnCertExpireDate,
      'mnCertStatus': mnCertStatus,
      'manufacturer': manufacturer?.fromManufacturerToJson()
    };
  }

}