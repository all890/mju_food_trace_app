
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/manufacturer.dart';

import '../service/config_service.dart';

class ManufacturerController {

  Future addManufacturer (
    String manuftName,
    String manuftEmail,
    String factoryLatitude,
    String factoryLongitude,
    String factoryTelNo,
    String factorySupName,
    String factorySupLastname,
    String username,
    String password,
    File mnCertImg,
    String mnCertNo,
    String mnCertRegDate,
    String mnCertExpireDate,
  ) async {

    Map usernameData = {
      "username" : username
    };

    var usernameBody = json.encode(usernameData);

    var usernameUrl = Uri.parse(baseURL + '/user/iua');

    http.Response usernameResponse = await http.post(
      usernameUrl,
      headers: headers,
      body: usernameBody
    );
    //print(response.statusCode);
    //var usernameJsonResponse = jsonDecode(usernameResponse.body);

    if (usernameResponse.statusCode == 200) {
      Map data = {
        "manuftName" : manuftName,
        "manuftEmail" : manuftEmail,
        "factoryLatitude" : factoryLatitude,
        "factoryLongitude" : factoryLongitude,
        "factoryTelNo" : factoryTelNo,
        "factorySupName" : factorySupName,
        "factorySupLastname" : factorySupLastname,
        "username" : username,
        "password" : password,
        "mnCertNo" : mnCertNo,
        "mnCertRegDate" : mnCertRegDate,
        "mnCertExpireDate" : mnCertExpireDate
      };

      var path = await upload(mnCertImg);
    
      data["mnCertImg"] = path;

      print(path);

      var body = json.encode(data);
      var url = Uri.parse(baseURL + '/manuft/add');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body
      );
      //print(response.statusCode);
      return response;
    } else {
      return usernameResponse.statusCode;
    }

  }

  Future isManufacturerAvailable(String manuftName) async {
    var url = Uri.parse(baseURL + '/manuft/ismanuftavailable/' + manuftName);

    http.Response response = await http.get(
      url
    );

    return response;
  }

  Future getManufacturerDetails(String manuftId) async {

    var url = Uri.parse(baseURL + '/manuft/getmndetails/' + manuftId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;

  }

  Future getListAllManuftRegist() async {

    Map data = {};

    var body = json.encode(data);
    var url = Uri.parse(baseURL + '/manuft/listmnregist');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<Manufacturer> list = jsonResponse.map((e) => Manufacturer.fromJsonToManufacturer(e)).toList();
    return list;

  }

  Future updateMnRegistStatus (String manuftId) async {

    var url = Uri.parse(baseURL + '/manuft/updatemnregiststat/' + manuftId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    var jsonResponse = jsonDecode(response.body);
    return jsonResponse;

  }
  
  Future declineMnRegistStatus (String manuftId) async {

    var url = Uri.parse(baseURL + '/manuft/declinemnregiststat/' + manuftId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    var jsonResponse = jsonDecode(response.body);
    return jsonResponse;

  }

  Future upload(File file) async {
    if (file == null) return;

    var uri = Uri.parse(baseURL + "/manuftcertificate/upload");
    var length = await file.length();
    //print(length);
    http.MultipartRequest request = new http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        // replace file with your field name exampe: image
        http.MultipartFile('image', file.openRead(), length,
            filename: 'test.png'),
      );
    var response = await http.Response.fromStream(await request.send());
    return response.body;
  }

  Future getListAllManufacturer() async {

    Map data = {};

    var body = json.encode(data);
    var url = Uri.parse(baseURL + '/manuft/list');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<Manufacturer> list = jsonResponse.map((e) => Manufacturer.fromJsonToManufacturer(e)).toList();
    return list;

  }

 Future addmanufacturerCertificate (
   

    File mnCertImg,
 
    String mnCertNo,
    String mnCertRegDate,
    String mnCertExpireDate,
    String username

  ) async {
      Map data = {
        "mnCertImg" : mnCertImg,
        "mnCertNo" : mnCertNo,
        "mnCertRegDate" : mnCertRegDate,
        "mnCertExpireDate" : mnCertExpireDate,
        "username" : username
      };

      var path = await upload(mnCertImg);
    
      data["mnCertImg"] = path;

      print(path);

      var body = json.encode(data);
      var url = Uri.parse(baseURL + '/manuftcertificate/addmncert');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body
      );
      //print(response.statusCode);
      //var jsonResponse = jsonDecode(response.body);
      return response;
  }

    Future getManufacturerByUsername(String username) async {

    var url = Uri.parse(baseURL + '/manuft/getmnbyusername/' + username);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;
   }
}