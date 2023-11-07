
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/controller/raw_material_shipping_controller.dart';
import 'package:mju_food_trace_app/model/farmer.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/model/qrcode.dart';
import 'dart:ui' as ui;

import 'package:mju_food_trace_app/screen/user/navbar_user.dart';
import 'package:mju_food_trace_app/service/config_service.dart';

import '../../controller/farmer_certificate_controller.dart';
import '../../controller/farmer_controller.dart';
import '../../controller/manufacturer_certificate_controller.dart';
import '../../controller/manufacturer_controller.dart';
import '../../controller/manufacturing_controller.dart';
import '../../controller/planting_controller.dart';
import '../../controller/product_controller.dart';
import '../../controller/qrcode_controller.dart';
import '../../model/manufacturer_certificate.dart';
import '../../widgets/buddhist_year_converter.dart';

class TraceProductByQRCodeSecondScreen extends StatefulWidget {

  final QRCode? qrCode;
  final ManufacturerCertificate? manufacturerCertificate;
  final FarmerCertificate? farmerCertificate;
  const TraceProductByQRCodeSecondScreen({super.key, required this.qrCode, this.manufacturerCertificate, this.farmerCertificate});

  @override
  State<TraceProductByQRCodeSecondScreen> createState() => _TraceProductByQRCodeSecondScreenState();
}

class _TraceProductByQRCodeSecondScreenState extends State<TraceProductByQRCodeSecondScreen> {

  late GoogleMapController mapController;
  Map<String, Marker> markers = {};
  
  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  Completer<GoogleMapController> _cameraController = Completer();

  Set<Polyline> polylines = Set<Polyline>();
  List<LatLng> points = [];
  PolylinePoints polylinePoints = PolylinePoints();

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  
  bool? isLoaded;

  int? page = 0;
  int? mnPage = 0;

  final double iconSize = 70;

  String? imgFmCertFileName = "";
  String? imgPlantingName = "";
  String? imgMnCertFileName = "";

  int? totalCarb = 0;

  double? midX;
  double? midY;

  String? strokeStatus = "";
   var dateFormat = DateFormat('dd-MMM-yyyy');

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  bool? showFarmerDetails = true;
  bool? showFarmerCertificateDetails = true;
  bool? showPlantingDetails = true;
  bool? showRawMaterialShippingDetails = true;

  bool? showManufacturerDetails = true;
  bool? showManufacturerCertificateDetails = true;
  bool? showManufacturingDetails = true;

  bool? showProductDetails = true;

  Map<String, dynamic>? incorrectPoint;

  FarmerController farmerController = FarmerController();
  FarmerCertificateController farmerCertificateController = FarmerCertificateController();
  PlantingController plantingController = PlantingController();
  RawMaterialShippingController rawMaterialShippingController = RawMaterialShippingController();
  ManufacturerController manufacturerController = ManufacturerController();
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();
  ManufacturingController manufacturingController = ManufacturingController();
  ProductController productController = ProductController();
  QRCodeController qrCodeController = QRCodeController();

  bool? farmerIncorrect = false;
  bool? rmsIncorrect = false;
  bool? manuftIncorrect = false;

  void checkHashToDetermineDataVisibility () async {
    var incorrectPointJson = await qrCodeController.isChainValid(widget.qrCode?.qrcodeId ?? "");
    incorrectPoint = json.decode(incorrectPointJson);

    List<String> farmerSession = ["1", "2", "3", "4", "5"];
    List<String> rmsSession = ["6", "7"];
    List<String> manufacturerSession = ["8", "9", "10", "11", "12", "13", "14", "15"];

    if (incorrectPoint?.isNotEmpty == true) {
      farmerSession.forEach((element) {
        if (incorrectPoint?.containsKey(element) == true) {
          setState(() {
            farmerIncorrect = true;
            print("FARMER IS INCORRECT");
          });
        }
      });
      
      rmsSession.forEach((element) {
        if (incorrectPoint?.containsKey(element) == true) {
          setState(() {
            rmsIncorrect = true;
            print("RMS IS INCORRECT");
          });
        }
      });
      
      manufacturerSession.forEach((element) {
        if (incorrectPoint?.containsKey(element) == true) {
          setState(() {
            manuftIncorrect = true;
            print("MANUFT IS INCORRECT");
          });
        }
      });
      
    }
  }

  Future openRmsDialog() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Center(child: Text("การส่งผลผลิต",style: TextStyle(fontFamily: 'Itim',fontSize: 20),)),
        content: showProductDetails == true?
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รายละเอียดการส่งผลผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รหัสการส่งผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpId}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ส่งผลผลิต : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่รับผลผลิต : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.qrCode?.manufacturing?.rawMaterialShipping?.receiveDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนผลผลิตที่ส่ง : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpQty} ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpQtyUnit}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ผู้รับผลผลิตปลายทาง : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.manufacturer?.manuftName}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ],
            ),
          ),
        ) : Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "การส่งผลผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลการส่งผลผลิตไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ) ,
      ),
    )
  );

  Future openProductDialog() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Center(child: Text("ข้อมูลทางโภชนาการของสินค้า",style: TextStyle(fontFamily: 'Itim',fontSize: 20),)),
        content: showProductDetails == true?
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${widget.qrCode?.manufacturing?.product?.productName}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 18),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ปริมาตรสุทธิ : ${widget.qrCode?.manufacturing?.product?.netVolume} กรัม",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "คุณค่าทางโภชนาการต่อหนึ่งหน่วยบริโภค",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "พลังงานที่จะได้รับสุทธิ : ${widget.qrCode?.manufacturing?.product?.netEnergy} kcal",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: Colors.black,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ไขมันทั้งหมด ${widget.qrCode?.manufacturing?.product?.saturatedFat} g : ไขมันอิ่มตัว ${widget.qrCode?.manufacturing?.product?.saturatedFat} g",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "โปรตีน ${widget.qrCode?.manufacturing?.product?.protein} g",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "โซเดียม ${widget.qrCode?.manufacturing?.product?.sodium} mg",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "คอเลสเตอรอล ${widget.qrCode?.manufacturing?.product?.cholesterol} mg",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "คาร์โบไฮเดรตทั้งหมด ${totalCarb} มิลลิกรัม",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใยอาหาร ${widget.qrCode?.manufacturing?.product?.fiber} g  น้ำตาล ${widget.qrCode?.manufacturing?.product?.sugar} g",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "แร่ธาตุและวิตามิน",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "แคลเซียม ${widget.qrCode?.manufacturing?.product?.calcium} %  เหล็ก ${widget.qrCode?.manufacturing?.product?.iron} %",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วิตามินบี2 ${widget.qrCode?.manufacturing?.product?.vitB2} %  วิตามินเอ ${widget.qrCode?.manufacturing?.product?.vitA} %",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วิตามินบี1 ${widget.qrCode?.manufacturing?.product?.vitB1} %",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ],
            ),
          ),
        ) : Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลทางโภชนาการของสินค้า",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลทางโภชนาการของสินค้าไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    )
  );

  Future openMnDialog() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        actions: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              mnPage != 0 ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (!(mnPage! <= 0)) {
                        mnPage = mnPage! - 1;
                      }
                      print("MNPAGE : ${mnPage}");
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(100.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0))
                  ),
                  child: const Icon(
                    Icons.arrow_left,
                    color: Colors.white,
                  ),
                ),
              ) : Container(),
              mnPage != 2 ?Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (!(mnPage! > 1)) {
                        mnPage = mnPage! + 1;
                      }
                      print("mnPAGE : ${mnPage}");
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(100.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0))
                  ),
                  child: const Icon(
                    Icons.arrow_right,
                    color: Colors.white,
                  ),
                ),
              ) : Container(),
            ],
          ),
        ],
        title: Center(child: Text("ผู้ผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),)),
        content:
        mnPage == 0 && showManufacturerDetails == true? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลผู้ผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อผู้ผลิต : ${widget.qrCode?.manufacturing?.product?.manufacturer?.manuftName}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อผู้ดูแล : ${widget.qrCode?.manufacturing?.product?.manufacturer?.factorySupName} ${widget.qrCode?.manufacturing?.product?.manufacturer?.factorySupLastname}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "เบอร์โทรผู้ผลิต : ${widget.qrCode?.manufacturing?.product?.manufacturer?.factoryTelNo}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "อีเมลผู้ผลิต : ${widget.qrCode?.manufacturing?.product?.manufacturer?.manuftEmail}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ตำแหน่ง : ${widget.manufacturerCertificate?.manufacturer?.factoryLatitude}, ${widget.manufacturerCertificate?.manufacturer?.factoryLongitude}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ],
            ),
          ),
        ) : mnPage == 0 && showManufacturerDetails == false? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลผู้ผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลผู้ผลิตไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ) : mnPage == 1 && showManufacturerCertificateDetails == true? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใบรับรอง GMP",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รหัสใบรับรอง : ${widget.manufacturerCertificate?.mnCertNo}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  child: Image.network(baseURL + '/manuftcertificate/' + imgMnCertFileName!),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ทำการอัปโหลด : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.manufacturerCertificate?.mnCertUploadDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ออกใบรับรอง : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.manufacturerCertificate?.mnCertRegDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ใบรับรองหมดอายุ :  ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.manufacturerCertificate?.mnCertExpireDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "สถานะการอนุมัติ : ${widget.manufacturerCertificate?.mnCertStatus}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ]
            ),
          ),
        ) : mnPage == 1 && showManufacturerDetails == false? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใบรับรอง GMP",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลใบรับรองผู้ผลิตไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ) : mnPage == 2 && showManufacturingDetails == true? Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รายละเอียดการผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ผลิตสินค้า :   ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.qrCode?.manufacturing?.manufactureDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่หมดอายุของสินค้า :   ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.qrCode?.manufacturing?.expireDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนสินค้าที่ผลิตได้ : ${widget.qrCode?.manufacturing?.productQty} ${widget.qrCode?.manufacturing?.productUnit}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนของผลผลิตที่ใช้ในการผลิตสินค้า : ${widget.qrCode?.manufacturing?.usedRawMatQty} ${widget.qrCode?.manufacturing?.usedRawMatQtyUnit}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ]
            ),
          ),
        ) : Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รายละเอียดการผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลการผลิตไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    )
  );

  Future openFmDialog() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        actions: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              page != 0 ? Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (!(page! <= 0)) {
                        page = page! - 1;
                      }
                      print("PAGE : ${page}");
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(100.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0))
                  ),
                  child: const Icon(
                    Icons.arrow_left,
                    color: Colors.white,
                  ),
                ),
              ) : Container(),
              page != 2 ?Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (!(page! > 1)) {
                        page = page! + 1;
                      }
                      print("PAGE : ${page}");
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(100.0))),
                    backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 0, 0, 0))
                  ),
                  child: const Icon(
                    Icons.arrow_right,
                    color: Colors.white,
                  ),
                ),
              ) : Container(),
            ],
          ),
        ],
        title: Center(child: Text("เกษตรกร",style: TextStyle(fontFamily: 'Itim'),)),
        content: page == 0 && showFarmerDetails == true? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลเกษตรกร",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อฟาร์ม : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmName}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อเกษตรกร : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmerName}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "เบอร์โทร : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmerMobileNo}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "อีเมล : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmerEmail}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ตำแหน่ง : ${widget.farmerCertificate?.farmer?.farmLatitude}, ${widget.farmerCertificate?.farmer?.farmLongitude}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ],
            ),
          ),
        ) : page == 0 && showFarmerDetails == false? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลเกษตรกร",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลเกษตรกรไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ) : page == 1 && showFarmerCertificateDetails == true?
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใบรับรอง IFOAM",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รหัสใบรับรอง : ${widget.farmerCertificate?.fmCertNo}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  child: Image.network(baseURL + '/farmercertificate/' + imgFmCertFileName!),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ทำการอัปโหลด : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.farmerCertificate?.fmCertUploadDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ออกใบรับรอง : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.farmerCertificate?.fmCertRegDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ใบรับรองหมดอายุ : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.farmerCertificate?.fmCertExpireDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "สถานะการอนุมัติ : ${widget.farmerCertificate?.fmCertStatus}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ]
            ),
          ),
        ) : page == 1 && showFarmerCertificateDetails == false? 
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใบรับรอง IFOAM",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลใบรับรองเกษตรกรไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ) : page == 2 && showPlantingDetails == true?
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รายละเอียดการปลูกผลผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                 // height: 430,
                  child: Image.network(baseURL + '/planting/' + imgPlantingName!),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อของผลผลิตที่ปลูก : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantName}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ปลูกผลผลิต : ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ประเภทของน้ำหมัก : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.bioextract}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วิธีการปลูกผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantingMethod}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่คาดว่าจะเก็บเกี่ยวผลผลิต :  ${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.approxHarvDate ?? DateTime.now())}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
               
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ปริมาณผลผลิตสุทธิ : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.netQuantity} ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.netQuantityUnit}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนตารางเมตร : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.squareMeters} ตารางเมตร",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนตารางวา : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.squareYards} ตารางวา",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนไร่ : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.rai} ไร่",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      "Verified by blockchain",
                      style: TextStyle(fontFamily: 'Itim',fontSize: 16)
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.check_circle, color: Colors.green,),
                  ],
                )
              ]
            ),
          ),
        ) :
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รายละเอียดการปลูกผลผลิต",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 20),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                Text(
                  "ข้อมูลการปลูกผลผลิตไม่ตรงกับการเข้ารหัส\nจึงไม่สามารถแสดงข้อมูลได้ ณ ขณะนี้",
                  style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )
      ),
    )
  );

  Future openDataWasTamperedDialog(String? header,String? prompt) => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Center(child: Text("${header}",style: TextStyle(fontFamily: 'Itim',fontSize: 20),)),
        content:
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Image(
                    image: AssetImage('images/error_icon.png'),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    "${prompt}",
                    style: TextStyle(fontFamily: 'Itim',fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    )
  );

  void addMarker (String markerId, String type, LatLng location) async {
    final Uint8List farmerMarkerIcon = await getBytesFromAsset('images/farmer_icon.png', 100);
    final Uint8List factoryMarkerIcon = await getBytesFromAsset('images/factory_icon.png', 100);
    final Uint8List rmsMarkerIcon = await getBytesFromAsset('images/rms_icon.png', 100);

    var marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      icon: BitmapDescriptor.fromBytes(type == "FM" ? farmerMarkerIcon : type == "SENDING"? rmsMarkerIcon : factoryMarkerIcon),
      onTap: () async {

        if (type == "FM") {
          setState(() {
            strokeStatus = "FM";
          });
          if (farmerIncorrect == false) {
            page = 0;
            await openFmDialog();
          } else {
            await openDataWasTamperedDialog("เกษตรกร", "ไม่สามารถแสดงข้อมูลเกษตรกรได้\nเนื่องจากข้อมูลถูกแก้ไข");
          }
        } else if (type == "SENDING") {
          setState(() {
            strokeStatus = "RMS";
          });
          if (farmerIncorrect == false && rmsIncorrect == false) {
            await openRmsDialog();
          } else {
            if (farmerIncorrect == true) {
              await openDataWasTamperedDialog("การส่งผลผลิต", "ไม่สามารถแสดงข้อมูลการส่งผลผลิตได้เนื่องจากข้อมูลเกษตรกรถูกแก้ไข");
            } else {
              await openDataWasTamperedDialog("การส่งผลผลิต", "ไม่สามารถแสดงข้อมูลการส่งผลผลิตได้เนื่องจากข้อมูลถูกแก้ไข");
            }
          }
        } else {
          setState(() {
            strokeStatus = "MN";
          });
          if (farmerIncorrect == false && (rmsIncorrect == false && manuftIncorrect == false)) {
            mnPage = 0;
            await openMnDialog();
          } else {
            if (farmerIncorrect == true) {
              await openDataWasTamperedDialog("ผู้ผลิต", "ไม่สามารถแสดงข้อมูลผู้ผลิตได้เนื่องจากข้อมูลเกษตรกรถูกแก้ไข");
            } else if (rmsIncorrect == true) {
              await openDataWasTamperedDialog("ผู้ผลิต", "ไม่สามารถแสดงข้อมูลผู้ผลิตได้เนื่องจากข้อมูลการส่งผลผลิตถูกแก้ไข");
            } else {
              await openDataWasTamperedDialog("ผู้ผลิต", "ไม่สามารถแสดงข้อมูลผู้ผลิตได้เนื่องจากข้อมูลถูกแก้ไข");
            }
          }
        }

      }
    );

    markers[markerId] = marker;
    setState(() {});
  }

  void findMidpoint () {
    setState(() {
      isLoaded = false;
    });
    midX = (double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? "") + double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLatitude ?? "")) / 2;
    midY = (double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "") + double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLongitude ?? "")) / 2;
    setPicture();
    setState(() {
      isLoaded = true;
    });
  }

  void setPicture () {
    String? filePath = widget.farmerCertificate?.fmCertImg;
    imgFmCertFileName = filePath?.substring(filePath.lastIndexOf('/')+1, filePath.length);
    String? filePath2 = widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantingImg;
    imgPlantingName = filePath2?.substring(filePath2.lastIndexOf('/')+1, filePath2.length);
    String? filePath3 = widget.manufacturerCertificate?.mnCertImg;
    imgMnCertFileName = filePath3?.substring(filePath3.lastIndexOf('/')+1, filePath3.length);
    setState(() {
      totalCarb = int.parse(widget.qrCode?.manufacturing?.product?.sugar.toString() ?? "") + int.parse(widget.qrCode?.manufacturing?.product?.fiber.toString() ?? "");
    });
  }

  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyBaFEmOMkYo_MvZVEb3CJO8ALE7M6hFYys",
        PointLatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")),
        PointLatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLongitude ?? "")));

    if (result.status == 'OK') {
      result.points.forEach((PointLatLng point) {
        points.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        polylines.add(Polyline(
            width: 10,
            polylineId: PolylineId('polyLine'),
            color: Color(0xFF08A5CB),
            points: points));
      });
    }
  }

  void setStraightPolyline () {
    points.add(LatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")));
    points.add(LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLongitude ?? "")));
    polylines.add(Polyline(
      color: Colors.black,
      width: 4,
      visible: true,
      points: points,
      polylineId: PolylineId("distance"),
    ));
  }

  @override
  void initState() {
    super.initState();
    findMidpoint();
    checkHashToDetermineDataVisibility();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _globalKey,
        backgroundColor: kBackgroundColor,
        drawer: UserNavbar(),
        floatingActionButton: IconButton(
          icon: Icon(Icons.menu_rounded),
          iconSize: 40.0,
          onPressed: () {
            _globalKey.currentState?.openDrawer();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: isLoaded == false?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        ) :
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: (MediaQuery.of(context).size.height / 3.8) * 3,
              child: GoogleMap(
                polylines: polylines,
                initialCameraPosition: CameraPosition(
                  target: LatLng(midX ?? 0.0, midY ?? 0.0),
                  zoom: 16
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                  _cameraController.complete(controller);
                  addMarker("1", "MN", LatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")));
                  addMarker("2", "FM", LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLongitude ?? "")));
                  addMarker("3", "SENDING", LatLng(midX ?? 0, midY ?? 0));
                  setStraightPolyline();
                },
                markers: markers.values.toSet(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - ((MediaQuery.of(context).size.height / 3.8) * 3) - (MediaQuery.of(context).size.height / 33.33),
              color: Color.fromRGBO(121, 180, 93, 2),
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 300,
                      child: Divider(
                        color: Colors.yellow,
                        thickness: 4,
                      )
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "จุดที่ 1",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                print('Farmer pressed!');
                                GoogleMapController googleMapController = await _cameraController.future;
                                googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmerCertificate?.farmer?.farmLongitude ?? "")),
                                    zoom: 16
                                  )
                                ));
                                setState(() {
                                  strokeStatus = "FM";
                                  page = 0;
                                });
                                if (farmerIncorrect == false) {
                                  await openFmDialog();
                                } else {
                                  await openDataWasTamperedDialog("เกษตรกร", "ไม่สามารถแสดงข้อมูลเกษตรกรได้เนื่องจากข้อมูลถูกแก้ไข");
                                }
                              },
                              child: Container(
                                decoration: strokeStatus == "FM" ? BoxDecoration(
                                  border: Border.all(width: 5, color: Colors.yellow),
                                  borderRadius: BorderRadius.circular(100), //<-- SEE HERE
                                ) : null,
                                width: iconSize,
                                height: iconSize,
                                child: Image(
                                  image: AssetImage('images/farmer_icon.png'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "เกษตรกร",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "จุดที่ 2",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                print('Rms pressed!');
                                GoogleMapController googleMapController = await _cameraController.future;
                                googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(midX ?? 0, midY ?? 0),
                                    zoom: 16
                                  )
                                ));
                                setState(() {
                                  strokeStatus = "RMS";
                                });
                                if (farmerIncorrect == false && rmsIncorrect == false) {
                                  await openRmsDialog();
                                } else {
                                  if (farmerIncorrect == true) {
                                    await openDataWasTamperedDialog("การส่งผลผลิต", "ไม่สามารถแสดงข้อมูลการส่งผลผลิตได้เนื่องจากข้อมูลเกษตรกรถูกแก้ไข");
                                  } else {
                                    await openDataWasTamperedDialog("การส่งผลผลิต", "ไม่สามารถแสดงข้อมูลการส่งผลผลิตได้เนื่องจากข้อมูลถูกแก้ไข");
                                  }
                                }
                              },
                              child: Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: strokeStatus == "RMS" ? BoxDecoration(
                                  border: Border.all(width: 5, color: Colors.yellow),
                                  borderRadius: BorderRadius.circular(100), //<-- SEE HERE
                                ) : null,
                                child: Image(
                                  image: AssetImage('images/rms_icon.png'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "การส่งผลผลิต",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "จุดที่ 3",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                print('Factory pressed!');
                                GoogleMapController googleMapController = await _cameraController.future;
                                googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")),
                                    zoom: 16
                                  )
                                ));
                                setState(() {
                                  strokeStatus = "MN";
                                  mnPage = 0;
                                });
                                if (farmerIncorrect == false && (rmsIncorrect == false && manuftIncorrect == false)) {
                                  await openMnDialog();
                                } else {
                                  if (farmerIncorrect == true) {
                                    await openDataWasTamperedDialog("ผู้ผลิต", "ไม่สามารถแสดงข้อมูลผู้ผลิตได้เนื่องจากข้อมูลเกษตรกรถูกแก้ไข");
                                  } else if (rmsIncorrect == true) {
                                    await openDataWasTamperedDialog("ผู้ผลิต", "ไม่สามารถแสดงข้อมูลผู้ผลิตได้เนื่องจากข้อมูลการส่งผลผลิตถูกแก้ไข");
                                  } else {
                                    await openDataWasTamperedDialog("ผู้ผลิต", "ไม่สามารถแสดงข้อมูลผู้ผลิตได้เนื่องจากข้อมูลถูกแก้ไข");
                                  }
                                }
                              },
                              child: Container(
                                width: iconSize,
                                height: iconSize,
                                decoration: strokeStatus == "MN" ? BoxDecoration(
                                  border: Border.all(width: 5, color: Colors.yellow),
                                  borderRadius: BorderRadius.circular(100), //<-- SEE HERE
                                ) : null,
                                child: Image(
                                  image: AssetImage('images/factory_icon.png'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "ผู้ผลิต",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                "จุดสิ้นสุด",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (farmerIncorrect == false && (rmsIncorrect == false && manuftIncorrect == false)) {
                                  await openProductDialog();
                                } else {
                                  if (farmerIncorrect == true) {
                                    await openDataWasTamperedDialog("ข้อมูลสินค้า", "ไม่สามารถแสดงข้อมูลสินค้าได้เนื่องจากข้อมูลเกษตรกรถูกแก้ไข");
                                  } else if (rmsIncorrect == true) {
                                    await openDataWasTamperedDialog("ข้อมูลสินค้า", "ไม่สามารถแสดงข้อมูลสินค้าได้เนื่องจากข้อมูลการส่งผลผลิตถูกแก้ไข");
                                  } else {
                                    await openDataWasTamperedDialog("ข้อมูลสินค้า", "ไม่สามารถแสดงข้อมูลสินค้าได้เนื่องจากข้อมูลผู้ผลิตถูกแก้ไข");
                                  }
                                }
                              },
                              child: SizedBox(
                                width: iconSize,
                                height: iconSize,
                                child: Image(
                                  image: AssetImage('images/organic_food_icon.png'),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                "สินค้า",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 16,
                                  color: Colors.white
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}