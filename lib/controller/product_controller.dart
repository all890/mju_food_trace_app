
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/product.dart';

import '../service/config_service.dart';

class ProductController {

  Future addProduct (
    String productName,
    int netVolume,
    int netEnergy,
    int saturatedFat,
    int cholesterol,
    int protein,
    int sodium,
    int fiber,
    int sugar,
    int vitA,
    int vitB1,
    int vitB2,
    int iron,
    int calcium,
    String username
  ) async {

    print("add product controller");

    Map data = {
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
      'username' : username
    };

    var body = json.encode(data);
    var url = Uri.parse(baseURL + '/product/add');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );
    //print(response.statusCode);
    //var jsonResponse = jsonDecode(response.body);
    return response;
  }

  Future getProductExistingByManuftUsername (String username) async {

    var url = Uri.parse(baseURL + '/product/getprodexists/' + username);

    http.Response response = await http.get(url);

    return response.body;

  }

  Future getProductById (String productId) async {
    var url = Uri.parse(baseURL + '/product/getprodbyid/' + productId);
    http.Response response = await http.get(
      url
    );
    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    print(jsonResponse);
    return jsonResponse;
  }

  Future updateProduct (Product product) async {

    Map<String, dynamic> data = product.fromProductToJson();

    print("UPDATE PROD IN CONTROLLER!!!");
    print(data);

    var body = json.encode(data);
    print(body);
    var url = Uri.parse(baseURL + '/product/update');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    print(response.body);

    return response;
  }

  Future deleteProduct (String productId) async {
    var url = Uri.parse(baseURL + '/product/delete/' + productId);
    http.Response response = await http.get(
      url
    );
    return response;
  }

  Future getListProduct (
    String username
  ) async {

    var url = Uri.parse(baseURL + '/product/getlistprodbyusername/' + username);

    http.Response response = await http.get(
      url
    );

    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<Product> list = jsonResponse.map((e) => Product.fromJsonToProduct(e)).toList();
    return list;

  }

}