


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/manufacturing.dart';
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

  
 Future getListAllManufacturingUsername(String username)async {
    Map data = {};

    var body = json.encode(data);

    var url = Uri.parse(baseURL + '/manufacturing/listallmanufacturing/' + username);
      http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );
    print(url);
    print(response.body);
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<Manufacturing> list = jsonResponse.map((e) =>Manufacturing.fromJsonToManufacturing(e)).toList();

       return list;
  }

 Future getManufacturingById(String manufacturingId) async {

    var url = Uri.parse(baseURL + '/manufacturing/getmanufacturungs/' + manufacturingId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;

  }

  Future updateManufacturing (Manufacturing manufacturing) async {

    print("รหัส :"+"${manufacturing.manufacturingId}");
    Map<String, dynamic> data = manufacturing.fromManufacturingToJson();

    var body = json.encode(data, toEncodable: myDateSerializer);
    print(body);
    var url = Uri.parse(baseURL + '/manufacturing/update');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    print(response.body);

    return response;
  }
  dynamic myDateSerializer(dynamic object) {
  if (object is DateTime) {
    return object.toIso8601String();
  }
  return object;
}

 Future deleteManufacturing (String manufacturingId) async{
  var url = Uri.parse(baseURL + '/manufacturing/delete/' + manufacturingId);

    http.Response response = await http.get(
      url
    );
    return response;
  }
  
}