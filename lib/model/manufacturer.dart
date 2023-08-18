
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';
import 'package:mju_food_trace_app/model/user.dart';

class Manufacturer {

  String? manuftId;
  String? manuftName;
  String? manuftEmail;
  DateTime? manuftRegDate;
  String? manuftRegStatus;
  String? factoryLatitude;
  String? factoryLongitude;
  String? factoryTelNo;
  String? factorySupName;
  String? factorySupLastname;

  User? user;


  Manufacturer({
    this.manuftId,
    this.manuftName,
    this.manuftEmail,
    this.manuftRegDate,
    this.manuftRegStatus,
    this.factoryLatitude,
    this.factoryLongitude,
    this.factoryTelNo,
    this.factorySupName,
    this.factorySupLastname,
    this.user,
  });

  factory Manufacturer.fromJsonToManufacturer(Map<String, dynamic> json) {

    
    return Manufacturer(
      manuftId: json["manuftId"],
      manuftName: json["manuftName"],
      manuftEmail: json["manuftEmail"],
      manuftRegDate: DateTime.parse(json["manuftRegDate"]),
      manuftRegStatus: json["manuftRegStatus"],
      factoryLatitude: json["factoryLatitude"],
      factoryLongitude: json["factoryLongitude"],
      factoryTelNo: json["factoryTelNo"],
      factorySupName: json["factorySupName"],
      factorySupLastname: json["factorySupLastname"],
      user: json["user"] == null ? null : User.fromJsonToUser(json["user"]),
    );

  } 

  Map<String, dynamic> fromManufacturerToJson() {
    return <String, dynamic> {
      'manuftId': manuftId,
      'manuftName': manuftName,
      'manuftEmail': manuftEmail,
      'manuftRegDate': manuftRegDate?.toIso8601String(),
      'manuftRegStatus': manuftRegStatus,
      'factoryLatitude': factoryLatitude,
      'factoryLongitude': factoryLongitude,
      'factoryTelNo': factoryTelNo,
      'factorySupName': factorySupName,
      'factorySupLastname': factorySupLastname,
      'user': user?.fromUserToJson()
    };
  }

}