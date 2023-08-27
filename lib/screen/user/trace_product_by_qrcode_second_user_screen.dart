
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mju_food_trace_app/constant/constant.dart';
import 'package:mju_food_trace_app/model/planting.dart';
import 'package:mju_food_trace_app/model/qrcode.dart';
import 'dart:ui' as ui;

import 'package:mju_food_trace_app/screen/user/navbar_user.dart';

class TraceProductByQRCodeSecondScreen extends StatefulWidget {

  final QRCode? qrCode;
  const TraceProductByQRCodeSecondScreen({super.key, required this.qrCode});

  @override
  State<TraceProductByQRCodeSecondScreen> createState() => _TraceProductByQRCodeSecondScreenState();
}

class _TraceProductByQRCodeSecondScreenState extends State<TraceProductByQRCodeSecondScreen> {

  late GoogleMapController mapController;
  Map<String, Marker> markers = {};

  Set<Polyline> polylines = Set<Polyline>();
  List<LatLng> points = [];
  PolylinePoints polylinePoints = PolylinePoints();

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  
  bool? isLoaded;

  double? midX;
  double? midY;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  }

  void addMarker (String markerId, String type, LatLng location) async {
    final Uint8List farmerMarkerIcon = await getBytesFromAsset('images/farmer_icon.png', 100);
    final Uint8List factoryMarkerIcon = await getBytesFromAsset('images/factory_icon.png', 100);

    var marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      infoWindow: const InfoWindow(
        title: "THIS IS A PONG!",
        snippet: "this is on the map boiis"
      ),
      icon: BitmapDescriptor.fromBytes(type == "FM" ? farmerMarkerIcon : factoryMarkerIcon)
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
    setState(() {
      isLoaded = true;
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
          icon: Icon(Icons.menu),
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
                  addMarker("1", "MN", LatLng(double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.product?.manufacturer?.factoryLongitude ?? "")));
                  addMarker("2", "FM", LatLng(double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLatitude ?? ""), double.parse(widget.qrCode?.manufacturing?.rawMaterialShipping?.planting?.farmer?.farmLongitude ?? "")));
                  setStraightPolyline();
                  print(MediaQuery.of(context).size.height);
                },
                markers: markers.values.toSet(),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - ((MediaQuery.of(context).size.height / 3.8) * 3) - (MediaQuery.of(context).size.height / 33.33),
              color: Colors.green,
            )
          ],
        ),
      ),
    );
  }
}