


import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/config_service.dart';

class ManufacturingController {

    Future addManufacturing (
    String manufactureDate,
    String expireDate,
    String productQty,
    String productUnit,
    String usedRawMatQty,
    String usedRawMatQtyUnit,
    String rawMaterialShippingId,
    String productId
  ) async {

    Map Data = {
      "manufactureDate" : manufactureDate,
        "expireDate" : expireDate,
        "productQty" : productQty,
        "productUnit" : productUnit,
        "usedRawMatQty" : usedRawMatQty,
         "usedRawMatQtyUnit" : usedRawMatQtyUnit,
        "rawMaterialShippingId" : rawMaterialShippingId,
         "productId" : productId
    };

    var Body = json.encode(Data);
    var Url = Uri.parse(baseURL + '/manufacturing/add');

    http.Response response = await http.post(
      Url,
      headers: headers,
      body: Body
    );
 
      return response;
  }

  

  
}