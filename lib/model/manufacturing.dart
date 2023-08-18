// ignore_for_file: public_member_api_docs, sort_constructors_first



import 'dart:convert';

import 'package:mju_food_trace_app/model/product.dart';
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';

class Manufacturing {
  String? manufacturingId;
  DateTime? manufactureDate;
  DateTime? expireDate;
  int? productQty;
  String? productUnit;
  double? usedRawMatQty;
  String? usedRawMatQtyUnit;
  String? manuftPrevBlockHash;
  String? manuftCurrBlockHash;
  RawMaterialShipping? rawMaterialShipping;
  Product? product;
  
  Manufacturing({
    this.manufacturingId,
    this.manufactureDate,
    this.expireDate,
    this.productQty,
    this.productUnit,
    this.usedRawMatQty,
    this.usedRawMatQtyUnit,
    this.manuftPrevBlockHash,
    this.manuftCurrBlockHash,
    this.rawMaterialShipping,
    this.product,
  });
  

  Map<String, dynamic> fromManufacturingToJson() {
    return <String, dynamic>{
      'manufacturingId': manufacturingId,
      'manufactureDate': manufactureDate?.toIso8601String(),
      'expireDate': expireDate?.toIso8601String(),
      'productQty': productQty,
      'productUnit': productUnit,
      'usedRawMatQty': usedRawMatQty,
      'usedRawMatQtyUnit': usedRawMatQtyUnit,
      'manuftPrevBlockHash': manuftPrevBlockHash,
      'manuftCurrBlockHash': manuftCurrBlockHash,
      'rawMaterialShipping': rawMaterialShipping?.fromRawMaterialShippingToJson(),
      'product': product?.fromProductToJson(),
    };
  }

  factory Manufacturing.fromJsonToManufacturing(Map<String, dynamic> json) {
    return Manufacturing(
      manufacturingId : json["manufacturingId"],
      manufactureDate: DateTime.parse(json["manufactureDate"]),
      expireDate:  DateTime.parse(json["expireDate"]),
      productQty: json["productQty"],
      productUnit: json["productUnit"],
      usedRawMatQty: json["usedRawMatQty"],
      usedRawMatQtyUnit: json["usedRawMatQtyUnit"],
      manuftPrevBlockHash: json["manuftPrevBlockHash"],
      manuftCurrBlockHash: json["manuftCurrBlockHash"],
      rawMaterialShipping: RawMaterialShipping.fromJsonToRawMaterialShipping(json["rawMaterialShipping"]),
      product: Product.fromJsonToProduct(json["product"]),
    );
  }

  
}
