// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:convert';

import 'package:mju_food_trace_app/model/manufacturer.dart';

class Product {

  String? productId;
  String? productName;
  int? netVolume;
  int? netEnergy;
  int? saturatedFat;
  int? cholesterol;
  int? protein;
  int? sodium;
  int? fiber;
  int? sugar;
  int? vitA;
  int? vitB1;
  int? vitB2;
  int? iron;
  int? calcium;
  String? pdPrevBlockHash;
  String? pdCurrBlockHash;

  Manufacturer? manufacturer;

  Product({
    this.productId,
    this.productName,
    this.netVolume,
    this.netEnergy,
    this.saturatedFat,
    this.cholesterol,
    this.protein,
    this.sodium,
    this.fiber,
    this.sugar,
    this.vitA,
    this.vitB1,
    this.vitB2,
    this.iron,
    this.calcium,
    this.pdPrevBlockHash,
    this.pdCurrBlockHash,
    this.manufacturer,
  });

  factory Product.fromJsonToProduct(Map<String, dynamic> json) {
    return Product(
      productId: json["productId"],
      productName: json["productName"],
      netVolume: json["netVolume"],
      netEnergy: json["netEnergy"],
      saturatedFat: json["saturatedFat"],
      cholesterol: json["cholesterol"],
      protein: json["protein"],
      sodium: json["sodium"],
      fiber: json["fiber"],
      sugar: json["sugar"],
      vitA: json["vitA"],
      vitB1: json["vitB1"],
      vitB2: json["vitB2"],
      iron: json["iron"],
      calcium: json["calcium"],
      pdPrevBlockHash: json["pdPrevBlockHash"],
      pdCurrBlockHash: json["pdCurrBlockHash"],
      manufacturer: Manufacturer.fromJsonToManufacturer(json["manufacturer"])
    );
  }

  Map<String, dynamic> fromProductToJson() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'netVolume': netVolume,
      'netEnergy': netEnergy,
      'saturatedFat': saturatedFat,
      'cholesterol': cholesterol,
      'protein': protein,
      'sodium': sodium,
      'fiber': fiber,
      'sugar': sugar,
      'vitA': vitA,
      'vitB1': vitB1,
      'vitB2': vitB2,
      'iron': iron,
      'calcium': calcium,
      'pdPrevBlockHash': pdPrevBlockHash,
      'pdCurrBlockHash': pdCurrBlockHash,
      'manufacturer': manufacturer?.fromManufacturerToJson(),
    };
  }

}
