
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../service/config_service.dart';

class AdministratorController {

  Future getAdminByUsername(String username) async {

    var url = Uri.parse(baseURL + '/administrator/getadminbyusername/' + username);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;
  }

}