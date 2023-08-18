import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';
import '../service/config_service.dart';


class RawMaterialShippingController{

 Future getListAllSentAgriByUsername(String username)async {
    Map data = {};

    var body = json.encode(data);

    var url = Uri.parse(baseURL + '/rms/listallsentagri/' + username);
      http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );
    print(url);
    print(response.body);
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<RawMaterialShipping> list = jsonResponse.map((e) =>RawMaterialShipping.fromJsonToRawMaterialShipping(e)).toList();

       return list;
  }



}