
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

  final double iconSize = 70;

  String? imgFmCertFileName = "";
  String? imgMnCertFileName = "";

  double? midX;
  double? midY;

  String? strokeStatus = "";

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  Future openFmDialog() => showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        actions: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
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
              ),
              Padding(
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
              ),
            ],
          ),
        ],
        title: Text("เกษตรกร"),
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
          child: Text('1'),
        ) : 
        Container(
          width: MediaQuery.of(context).size.width,
          child: Text('2')
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
          page = 0;
          await openFmDialog();
        } else {
          
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
                              onTap: () {
                                print("Product pressed!");
                              },
                              child: SizedBox(
                                width: iconSize,
                                height: iconSize,
                                child: Image(
                                  image: AssetImage('images/factory_icon.png'),
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