
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../service/config_service.dart';

class UserController {

  Future userLogin (
    String username,
    String password
  ) async {

    Map data = {
      "username" : username,
      "password" : password
    };

    var body = json.encode(data);
    var url = Uri.parse(baseURL + '/user/login');

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    return response;

  }

}