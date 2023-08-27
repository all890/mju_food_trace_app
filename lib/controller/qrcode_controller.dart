
import 'package:http/http.dart' as http;
import 'package:mju_food_trace_app/service/config_service.dart';

class QRCodeController {

  Future generateQRCode (String manufacturingId) async {

    var url = Uri.parse(baseURL + '/qrcode/generate/' + manufacturingId);

    http.Response response = await http.get(url);

    return response.body;

  }

  Future getProductDetailsByQRCodeId (String qrcodeId) async {
    var url = Uri.parse(baseURL + '/qrcode/getproddetails/' + qrcodeId);

    http.Response response = await http.get(url);

    return response.statusCode;
  }

}