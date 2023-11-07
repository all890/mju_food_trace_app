
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/model/planting.dart';
import '../service/config_service.dart';

class PlantingController {

 Future addPlanting (
    String plantName,
    String  plantDate,
    File plantingImg,
    String bioextract,
    String approxHarvDate,
    String plantingMethod,
    String netQuantity,
    String netQuantityUnit,
    String squareMeters,
    String squareYards,
    String rai,
    String username
  ) async {
      Map data = {
        "plantName" : plantName,
        "plantDate" : plantDate,
        "plantingImg" : plantingImg,
        "bioextract" : bioextract,
        "approxHarvDate" : approxHarvDate,
        "plantingMethod" : plantingMethod,
        "netQuantity" : netQuantity,
        "netQuantityUnit" : netQuantityUnit,
        "squareMeters" : squareMeters,
        "squareYards" : squareYards,
        "rai" : rai,
        "username" : username
      };

      var path = await upload(plantingImg);
    
      data["plantingImg"] = path;

      print(path);

      var body = json.encode(data);
      var url = Uri.parse(baseURL + '/planting/add');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: body
      );
      //print(response.statusCode);
      //var jsonResponse = jsonDecode(response.body);
      return response;
  }

  

  Future upload(File file) async {
    if (file == null) return;

    var uri = Uri.parse(baseURL + "/planting/uploadimg");
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
  
  Future getListPlantingById(String farmerId)async {
    Map data = {};

    var body = json.encode(data);

    var url = Uri.parse(baseURL + '/planting/listplantings/' + farmerId);
      http.Response response = await http.post(
      url,
      headers: headers,
      body: body
    );
    print(url);
    print(response.body);
    final utf8Body = utf8.decode(response.bodyBytes);
    List<dynamic> jsonResponse = json.decode(utf8Body);
    List<Planting> list = jsonResponse.map((e) => Planting.fromJsonToPlanting(e)).toList();

       return list;
  }

  Future getNewPtCurrBlockHash (String plantingId) async {

    var url = Uri.parse(baseURL + '/planting/getnewptcurrblockhash/' + plantingId);

    http.Response response = await http.get(
      url
    );

    return response.body;

  }

  Future getRemQtyOfPtsByFarmerUsername (String username) async {

    var url = Uri.parse(baseURL + '/planting/getremqtyofpts/' + username);

    http.Response response = await http.get(url);

    return response.body;

  }
  
  Future getPlantingrDetails(String plantingId) async {

    var url = Uri.parse(baseURL + '/planting/getplantings/' + plantingId);

    http.Response response = await http.get(
      url
    );

    print(response.body);

    final utf8Body = utf8.decode(response.bodyBytes);
    var jsonResponse = json.decode(utf8Body);
    return jsonResponse;

  }

  Future updatePlanting (File? newPlantingImg, Planting planting) async {

    if (newPlantingImg != null) {
      var newFilePath = await upload(newPlantingImg);

      planting.plantingImg = newFilePath.toString();
      print("NEW FILE IS " + newFilePath.toString());
    }

    print(planting.plantDate);

    Map<String, dynamic> data = planting.fromPlantingToJson();

    print("UPDATE PROD IN CONTROLLER!!!");
    print("PLANT DATE IS : " + data["plantDate"]);

    var body = json.encode(data, toEncodable: myDateSerializer);
    print(body);
    var url = Uri.parse(baseURL + '/planting/update');

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

  Future deletePlanting(String plantingId) async{
  var url = Uri.parse(baseURL + '/planting/delete/' + plantingId);

    http.Response response = await http.get(
      url
    );
    return response;
  }

  Future isChainBeforePlantingValid (String username) async {
    var url = Uri.parse(baseURL + '/planting/ischainbefptval/' + username);

    http.Response response = await http.get(
      url
    );
    return response.statusCode;
  }

}