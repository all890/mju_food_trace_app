
import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/model/qrcode.dart';
import 'dart:ui' as ui;

import 'package:mju_food_trace_app/screen/user/navbar_user.dart';
import 'package:mju_food_trace_app/service/config_service.dart';

import '../../model/manufacturer_certificate.dart';

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

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future openProductDialog() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Center(child: Text("ข้อมูลทางโภชนาการของสินค้า")),
        content: Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "${widget.qrCode?.manufacturing?.product?.productName}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ปริมาตรสุทธิ : ${widget.qrCode?.manufacturing?.product?.netVolume} กรัม"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "คุณค่าทางโภชนาการต่อหนึ่งหน่วยบริโภค"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "พลังงานที่จะได้รับสุทธิ : ${widget.qrCode?.manufacturing?.product?.netEnergy} kcal"
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: Colors.black,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ไขมันทั้งหมด ${widget.qrCode?.manufacturing?.product?.saturatedFat} g : ไขมันอิ่มตัว ${widget.qrCode?.manufacturing?.product?.saturatedFat} g"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "โปรตีน ${widget.qrCode?.manufacturing?.product?.protein} g"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "โซเดียม ${widget.qrCode?.manufacturing?.product?.sodium} mg"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "คอเลสเตอรอล ${widget.qrCode?.manufacturing?.product?.cholesterol} mg"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "คาร์โบไฮเดรตทั้งหมด ${totalCarb} mg"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใยอาหาร ${widget.qrCode?.manufacturing?.product?.fiber} g  น้ำตาล ${widget.qrCode?.manufacturing?.product?.sugar} g"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "แร่ธาตุและวิตามิน"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "แคลเซียม ${widget.qrCode?.manufacturing?.product?.calcium} %  เหล็ก ${widget.qrCode?.manufacturing?.product?.iron} %"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วิตามินบี2 ${widget.qrCode?.manufacturing?.product?.vitB2} %  วิตามินเอ ${widget.qrCode?.manufacturing?.product?.vitA} %"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วิตามินบี1 ${widget.qrCode?.manufacturing?.product?.vitB1} %"
                  ),
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
              mnPage != 1 ?Padding(
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
        title: Center(child: Text("ผู้ผลิต")),
        content: mnPage == 0? Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลผู้ผลิต"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อผู้ผลิต : ${widget.qrCode?.manufacturing?.product?.manufacturer?.manuftName}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อผู้ดูแล : ${widget.qrCode?.manufacturing?.product?.manufacturer?.factorySupName} ${widget.qrCode?.manufacturing?.product?.manufacturer?.factorySupLastname}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "เบอร์โทรศัพท์ : ${widget.qrCode?.manufacturing?.product?.manufacturer?.factoryTelNo}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "อีเมลผู้ผลิต : ${widget.qrCode?.manufacturing?.product?.manufacturer?.manuftEmail}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ตำแหน่ง : ${widget.manufacturerCertificate?.manufacturer?.factoryLatitude}, ${widget.manufacturerCertificate?.manufacturer?.factoryLongitude}"
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใบรับรอง GMP"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รหัสใบรับรอง : ${widget.manufacturerCertificate?.mnCertNo}"
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 430,
                  child: Image.network(baseURL + '/manuftcertificate/' + imgMnCertFileName!),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ทำการอัปโหลด : ${widget.manufacturerCertificate?.mnCertUploadDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ออกใบรับรอง : ${widget.manufacturerCertificate?.mnCertRegDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ใบรับรองหมดอายุ : ${widget.manufacturerCertificate?.mnCertExpireDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "สถานะการอนุมัติ : ${widget.manufacturerCertificate?.mnCertStatus}"
                  ),
                ),
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
                    "รายละเอียดการผลิต"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ผลิตสินค้า : ${widget.qrCode?.manufacturing?.manufactureDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่หมดอายุของสินค้า : ${widget.qrCode?.manufacturing?.expireDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนสินค้าที่ผลิตได้ : ${widget.qrCode?.manufacturing?.productQty} ${widget.qrCode?.manufacturing?.productUnit}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนของผลผลิตที่ใช้ในการผลิตสินค้า : ${widget.qrCode?.manufacturing?.usedRawMatQty} ${widget.qrCode?.manufacturing?.usedRawMatQtyUnit}"
                  ),
                ),
              ]
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
        title: Center(child: Text("เกษตรกร")),
        content: page == 0? Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ข้อมูลเกษตรกร"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อฟาร์ม : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmName}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อเกษตรกร : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmerName}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "เบอร์โทร : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmerMobileNo}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "อีเมล : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmerEmail}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ตำแหน่ง : ${widget.farmerCertificate?.farmer?.farmLatitude}, ${widget.farmerCertificate?.farmer?.farmLongitude}"
                  ),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ใบรับรอง IFOAM"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รหัสใบรับรอง : ${widget.farmerCertificate?.fmCertNo}"
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 430,
                  child: Image.network(baseURL + '/farmercertificate/' + imgFmCertFileName!),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ทำการอัปโหลด : ${widget.farmerCertificate?.fmCertUploadDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ออกใบรับรอง : ${widget.farmerCertificate?.fmCertRegDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ใบรับรองหมดอายุ : ${widget.farmerCertificate?.fmCertExpireDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "สถานะการอนุมัติ : ${widget.farmerCertificate?.fmCertStatus}"
                  ),
                ),
              ],
            ),
          ),
        ) : page == 1?
        Container(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รายละเอียดการปลูก"
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 430,
                  child: Image.network(baseURL + '/planting/' + imgPlantingName!),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ชื่อของผลผลิตที่ปลูก : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantName}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ปลูกผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ประเภทของน้ำหมัก : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.bioextract}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วิธีการปลูกผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.plantingMethod}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่คาดว่าจะเก็บเกี่ยวผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.approxHarvDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ปริมาณผลผลิตสุทธิ : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.netQuantity} ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.netQuantityUnit}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนตารางเมตร : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.squareMeters} ตารางเมตร"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนตารางวา : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.squareYards} ตารางวา"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนไร่ : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.rai} ไร่"
                  ),
                ),
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
                    "การส่งผลผลิต"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "รหัสการส่งผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpId}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "วันที่ส่งผลผลิต : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpDate}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "จำนวนผลผลิตที่ส่ง : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpQty} ${widget.qrCode?.manufacturing?.rawMaterialShipping?.rawMatShpQtyUnit}"
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    "ผู้รับผลผลิตปลายทาง : ${widget.qrCode?.manufacturing?.rawMaterialShipping?.manufacturer?.manuftName}"
                  ),
                ),
              ],
            ),
          )
        ),
      ),
    )
  );

  void addMarker (String markerId, String type, LatLng location) async {
    final Uint8List farmerMarkerIcon = await getBytesFromAsset('images/farmer_icon.png', 100);
    final Uint8List factoryMarkerIcon = await getBytesFromAsset('images/factory_icon.png', 100);

    var marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      icon: BitmapDescriptor.fromBytes(type == "FM" ? farmerMarkerIcon : factoryMarkerIcon),
      onTap: () async {

        if (type == "FM") {
          setState(() {
            strokeStatus = "FM";
          });
          page = 0;
          await openFmDialog();
        } else {
          setState(() {
            strokeStatus = "MN";
          });
          mnPage = 0;
          await openMnDialog();
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
    midX = (double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? "") + double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLatitude ?? "")) / 2;
    midY = (double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "") + double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLongitude ?? "")) / 2;
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
        PointLatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLongitude ?? "")));

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
    points.add(LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLongitude ?? "")));
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
                  zoom: 14
                ),
                onMapCreated: (controller) {
                  mapController = controller;
                  _cameraController.complete(controller);
                  addMarker("1", "MN", LatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")));
                  addMarker("2", "FM", LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLongitude ?? "")));
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
                        width: MediaQuery.of(context).size.width / 3,
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
                                    target: LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLongitude ?? "")),
                                    zoom: 15
                                  )
                                ));
                                setState(() {
                                  strokeStatus = "FM";
                                });
                                await openFmDialog();
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
                        width: MediaQuery.of(context).size.width / 3,
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
                                print('Factory pressed!');
                                GoogleMapController googleMapController = await _cameraController.future;
                                googleMapController.animateCamera(CameraUpdate.newCameraPosition(
                                  CameraPosition(
                                    target: LatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")),
                                    zoom: 15
                                  )
                                ));
                                setState(() {
                                  strokeStatus = "MN";
                                });
                                await openMnDialog();
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
                        width: MediaQuery.of(context).size.width / 3,
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
                                await openProductDialog();
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