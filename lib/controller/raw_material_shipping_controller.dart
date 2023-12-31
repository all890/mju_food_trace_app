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

  Future getRemQtyOfRmsByManufacturerUsername (String username) async {

    var url = Uri.parse(baseURL + '/rms/getremqtyofrms/' + username);

    http.Response response = await http.get(url);

    return response.body;

  }

  Future isRmsAndPlantingChainValid (String rawMatShpId) async {

    var url = Uri.parse(baseURL + '/rms/isrmsandptcv/' + rawMatShpId);

    http.Response response = await http.get(url);

    return response.statusCode;

  }

  Future getRemQtyOfRmsIndivByManufacturingId (String manufacturingId) async {
    var url = Uri.parse(baseURL + '/rms/getremqtyofrmsindiv/' + manufacturingId);

    http.Response response = await http.get(url);

    return response.body;
  }

  Future getRmsExistInManufacturingByManutftUsername (String username) async {

    var url = Uri.parse(baseURL + '/rms/getrmsexists/' + username);

    http.Response response = await http.get(url);

    return response.body;

  }

  Future getRawMaterialShippingDetails(String rawMatShpId) async {

    var url = Uri.parse(baseURL + '/rms/getrmsdetails/' + rawMatShpId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;

  }

  Future getNewRmsCurrBlockHash (String rawMatShpId) async {

    var url = Uri.parse(baseURL + '/rms/getnewrmscurrblockhash/' + rawMatShpId);

    http.Response response = await http.get(
      url
    );

    return response.body;

  }

  Future getListAllSentAgriByFarmerUsername(String farmerUsername)async {
    Map data = {};

    var body = json.encode(data);

    var url = Uri.parse(baseURL + '/rms/listallsentagribyfmusername/' + farmerUsername);
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



  Future addRawMaterialShipping (String manuftId, String rawMatShpDate,
            double rawMatShpQty, String rawMatShpQtyUnit, String plantingId) async {
    
    var url = Uri.parse(baseURL + '/rms/add');
    var data = {
      "manuftId": manuftId,
      "rawMatShpDate": rawMatShpDate,
      "rawMatShpQty": rawMatShpQty,
      "rawMatShpQtyUnit": rawMatShpQtyUnit,
      "plantingId": plantingId
    };

    var body = json.encode(data);

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    return response;

  }

  Future acceptRms(String rawMatShpId) async {

    var url = Uri.parse(baseURL + '/rms/acceptrms/' + rawMatShpId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    return response.statusCode;

  }

  Future declineRms(String rawMatShpId) async {

    var url = Uri.parse(baseURL + '/rms/declinerms/' + rawMatShpId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    return response.statusCode;

  }

  Future isChainBeforeRmsValid (String plantingId, String manuftId) async {
    
    var url = Uri.parse(baseURL + '/rms/ischainbefrmsval');
    var data = {
      "manuftId": manuftId,
      "plantingId": plantingId
    };

    var body = json.encode(data);

    http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );

    return response.statusCode;

  }

  Future isChainBeforeAcceptRmsValid(String rawMatShpId) async {

    var url = Uri.parse(baseURL + '/rms/ischainbefaccrmsval/' + rawMatShpId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    return response.statusCode;

  }

}