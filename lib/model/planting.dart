// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';
import 'dart:ffi';

import 'farmer.dart';

class Planting {

  String? plantingId;
  String? plantName;
  DateTime? plantDate;
  String? plantingImg;
  String? bioextract;
  DateTime? approxHarvDate;
  String? plantingMethod;
  double? netQuantity;
  String? netQuantityUnit;
  int? squareMeters;
  int? squareYards;
  int? rai;
  String? ptPrevBlockHash;
  String? ptCurrBlockHash;

  Farmer? farmer;

  Planting({
    this.plantingId,
    this.plantName,
    this.plantDate,
    this.plantingImg,
    this.bioextract,
    this.approxHarvDate,
    this.plantingMethod,
    this.netQuantity,
    this.netQuantityUnit,
    this.squareMeters,
    this.squareYards,
    this.rai,
    this.ptPrevBlockHash,
    this.ptCurrBlockHash,
    this.farmer,
  });

  Map<String, dynamic> fromPlantingToJson() {
    return <String, dynamic>{
      'plantingId': plantingId,
      'plantName': plantName,
      'plantDate': plantDate?.toIso8601String(),
      'plantingImg': plantingImg,
      'bioextract': bioextract,
      'approxHarvDate': approxHarvDate?.toIso8601String(),
      'plantingMethod': plantingMethod,
      'netQuantity': netQuantity,
      'netQuantityUnit': netQuantityUnit,
      'squareMeters': squareMeters,
      'squareYards': squareYards,
      'rai': rai,
      'ptPrevBlockHash': ptPrevBlockHash,
      'ptCurrBlockHash': ptCurrBlockHash,
      'farmer': farmer?.fromFarmerToJson(),
    };
  }

  factory Planting.fromJsonToPlanting(Map<String, dynamic> json) {

    
    return Planting(
      plantingId: json["plantingId"],
      plantName: json["plantName"],
      plantDate: DateTime.parse(json["plantDate"]),
      plantingImg: json["plantingImg"],
      bioextract: json["bioextract"],
      approxHarvDate:DateTime.parse(json["approxHarvDate"]),
      plantingMethod: json["plantingMethod"],
      netQuantity: json["netQuantity"],
      netQuantityUnit: json["netQuantityUnit"],
      squareMeters: json["squareMeters"],
      squareYards: json["squareYards"],
      rai: json["rai"],
      ptPrevBlockHash: json["ptPrevBlockHash"],
      ptCurrBlockHash: json["ptCurrBlockHash"],
      farmer: Farmer.fromJsonToFarmer(json["farmer"])
    );
  }

}
