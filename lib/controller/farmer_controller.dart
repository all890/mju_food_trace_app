
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/farmer.dart';

import '../service/config_service.dart';

class FarmerController {

  Future addFarmer (
    String farmerName,
    String farmerLastname,
    String farmerEmail,
    String farmerMobileNo,
    String farmName,
    String farmLatitude,
    String farmLongitude,
    String username,
    String password,
    File fmCertImg,
    String fmCertNo,
    String fmCertRegDate,
    String fmCertExpireDate,
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
        "farmerName" : farmerName,
        "farmerLastname" : farmerLastname,
        "farmerEmail" : farmerEmail,
        "farmerMobileNo" : farmerMobileNo,
        "farmName" : farmName,
        "farmLatitude" : farmLatitude,
        "farmLongitude" : farmLongitude,
        "username" : username,
        "password" : password,
        "fmCertNo" : fmCertNo,
        "fmCertRegDate" : fmCertRegDate,
        "fmCertExpireDate" : fmCertExpireDate
      };

      var path = await upload(fmCertImg);
    
      data["fmCertImg"] = path;

      print(path);

      var body = json.encode(data);
      var url = Uri.parse(baseURL + '/farmer/add');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body
      );
      //print(response.statusCode);
      //var jsonResponse = jsonDecode(response.body);
      return response;
    } else {
      return usernameResponse;
    }

  }

  Future getListAllFarmerRegist() async {

    Map data = {};

    var body = json.encode(data);
    var url = Uri.parse(baseURL + '/farmer/listfmregist');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<Farmer> list = jsonResponse.map((e) => Farmer.fromJsonToFarmer(e)).toList();
    return list;

  }

  Future getFarmerDetails(String farmerId) async {

    var url = Uri.parse(baseURL + '/farmer/getfmdetails/' + farmerId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;

  }
   Future getFarmerByUsername(String username) async {

    var url = Uri.parse(baseURL + '/farmer/getfmbyusername/' + username);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;
   }

  Future updateFmRegistStatus (String farmerId) async {

    var url = Uri.parse(baseURL + '/farmer/updatefmregiststat/' + farmerId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    return response;

  }

  Future upload(File file) async {
    if (file == null) return;

    var uri = Uri.parse(baseURL + "/farmercertificate/upload");
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
    //var jsonResponse = jsonDecode(response.body);
    return response.body;
  }

 Future addfarmerCertificate (
   

    File fmCertImg,
 
    String fmCertNo,
    String fmCertRegDate,
    String fmCertExpireDate,
    String username

  ) async {
      Map data = {
        "fmCertImg" : fmCertImg,
        "fmCertNo" : fmCertNo,
        "fmCertRegDate" : fmCertRegDate,
        "fmCertExpireDate" : fmCertExpireDate,
        "username" : username
      };

      var path = await upload(fmCertImg);
    
      data["fmCertImg"] = path;

      print(path);

      var body = json.encode(data);
      var url = Uri.parse(baseURL + '/farmercertificate/addfmcert');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body
      );
      //print(response.statusCode);
      //var jsonResponse = jsonDecode(response.body);
      return response;
  }

  //Add comment
}