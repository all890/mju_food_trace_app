


import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/model/planting.dart';

class RawMaterialShipping {

  String? rawMatShpId;
  DateTime? rawMatShpDate;
  double? rawMatShpQty;
  String? rawMatShpQtyUnit;
  String? rmsPrevBlockHash;
  String? rmsCurrBlockHash;
  Planting? planting;
  Manufacturer?manufacturer;

  RawMaterialShipping({
    this.rawMatShpId,
    this.rawMatShpDate,
    this.rawMatShpQty,
    this.rawMatShpQtyUnit,
    this.rmsPrevBlockHash,
    this.rmsCurrBlockHash,
    this.planting,
    this.manufacturer
  });

  Map<String, dynamic> fromRawMaterialShippingToJson() {
    return <String, dynamic>{
      'rawMatShpId': rawMatShpId,
      'rawMatShpDate': rawMatShpDate?.toIso8601String(),
      'rawMatShpQty': rawMatShpQty,
      'rawMatShpQtyUnit': rawMatShpQtyUnit,
      'rmsPrevBlockHash': rmsPrevBlockHash,
      'rmsCurrBlockHash': rmsCurrBlockHash,
      'planting': planting?.fromPlantingToJson(),
       'manufacturer': manufacturer?.fromManufacturerToJson(),
    };
  }

  factory RawMaterialShipping.fromJsonToRawMaterialShipping(Map<String, dynamic> json) {
    return RawMaterialShipping(
      rawMatShpId: json["rawMatShpId"],
      rawMatShpDate: DateTime.parse(json["rawMatShpDate"]),
      rawMatShpQty: json["rawMatShpQty"],
      rawMatShpQtyUnit: json["rawMatShpQtyUnit"],
      rmsPrevBlockHash: json["rmsPrevBlockHash"],
      rmsCurrBlockHash: json["rmsCurrBlockHash"],
      planting: Planting.fromJsonToPlanting(json["planting"]),
      manufacturer: Manufacturer.fromJsonToManufacturer(json["manufacturer"])
    );
  }

}