
import 'dart:convert';

import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';

import '../service/config_service.dart';
import 'package:http/http.dart' as http;

class ManufacturerCertificateController {

  Future getListAllMnRequestRenewCert () async {

    var url = Uri.parse(baseURL + '/manuftcertificate/getlistmncertrenewreq');

    http.Response response = await http.get(url);
    
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<ManufacturerCertificate> list = jsonResponse.map((e) => ManufacturerCertificate.fromJsonToManufacturerCertificate(e)).toList();
    return list;
  }
  
  Future getMnCertsByManuftUsername (String username) async {

    var url = Uri.parse(baseURL + '/manuftcertificate/getmncertsbyusername/' + username);

    http.Response response = await http.get(url);
    
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<ManufacturerCertificate> list = jsonResponse.map((e) => ManufacturerCertificate.fromJsonToManufacturerCertificate(e)).toList();
    return list;
  }
   Future hasCertWaitToAccept (String username) async {
    var url = Uri.parse(baseURL + '/manuftcertificate/haswaittoacceptcert/' + username);

    http.Response response = await http.get(url);

    return response.statusCode;
  }

  Future getLastestManufacturerCertificateByManufacturerUsername (String username) async {
    var url = Uri.parse(baseURL + '/manuftcertificate/getlatestmncertbyusername/' + username);

    http.Response response = await http.get(url);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;
  }
  

  Future getNewMnCertCurrBlockHash (String mnCertId) async {

    var url = Uri.parse(baseURL + '/manuftcertificate/getnewmncertcurrblockhash/' + mnCertId);

    http.Response response = await http.get(
      url
    );

    return response.body;

  }

  Future isChainBeforeMnCertValid (String username) async {

    var url = Uri.parse(baseURL + '/manuftcertificate/ischainvalbefmncert/' + username);

    http.Response response = await http.get(
      url
    );

    return response.statusCode;

  }


    Future getManuftCertDetails(String mnCertId) async {
    var url = Uri.parse(baseURL + '/manuftcertificate/getmncertdetails/' + mnCertId);
    http.Response response = await http.get(
      url
    );
   // print(response.body);
    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;

  }
  Future updateMnRenewingRequestCertStatus(String mnCertId) async {

    var url = Uri.parse(baseURL + '/manuftcertificate/updatemnrenewingrequestcert/' + mnCertId);
    http.Response response = await http.get(
      url
    );
    print(response.body);
    return response;

  }
   Future declineMnRenewingRequestCertStatus(String mnCertId) async {

    var url = Uri.parse(baseURL + '/manuftcertificate/declinemnrenewingrequestcert/' + mnCertId);
    http.Response response = await http.get(
      url
    );
    print(response.body);
    return response;

  }

}