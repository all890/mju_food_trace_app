
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/service/config_service.dart';

class FarmerCertificateController {

  Future getListAllFmRequestRenewCert () async {

    var url = Uri.parse(baseURL + '/farmercertificate/getlistfmcertrenewreq');

    http.Response response = await http.get(url);
    
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<FarmerCertificate> list = jsonResponse.map((e) => FarmerCertificate.fromJsonToFarmerCertificate(e)).toList();
    return list;
  }

  Future getFmRequestRenewById (String fmCertId) async {

    var url = Uri.parse(baseURL + '/farmercertificate/getfmcertbyid/' + fmCertId);

    http.Response response = await http.get(url);

    return response;

  }

}