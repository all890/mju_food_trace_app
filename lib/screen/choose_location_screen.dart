
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_google_location_picker/flutter_google_location_picker.dart';
import 'package:flutter_google_location_picker/model/lat_lng_model.dart';
import 'package:geolocator/geolocator.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {

    double? currentLatitude;
    double? currentLongitude;

    Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
  
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    return await Geolocator.getCurrentPosition();
  }

  void getCurrentPosition () async {
    Position position = await _determinePosition();
    currentLatitude = position.latitude;
    currentLongitude = position.longitude;
    print(position.latitude);
    print(position.longitude);
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return currentLatitude == null && currentLongitude == null?
    Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        )
    ) : 
    Scaffold(
        body: FlutterGoogleLocationPicker(
          textStyle: TextStyle(color: Colors.white.withOpacity(0.0)),
        center: LatLong(latitude: currentLatitude!, longitude: currentLongitude!),
        showZoomButtons: true,
        buttonWidget: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)
          ),
          color: Colors.blueAccent,
          child: const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "เลือกตำแหน่งปัจจุบัน",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        onPicked: (pickedData) {
          print(pickedData.latLong.latitude);
          print(pickedData.latLong.longitude);
          print(pickedData.address);
          Navigator.pop(
            context,
            [{'latitude': pickedData.latLong.latitude}, {'longitude': pickedData.latLong.longitude}]
          );
        }
      )
    );
  }
}