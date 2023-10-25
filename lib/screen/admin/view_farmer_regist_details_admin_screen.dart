
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_google_location_picker/flutter_google_location_picker.dart';
import 'package:flutter_google_location_picker/model/lat_lng_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/farmer_controller.dart';
import 'package:mju_food_trace_app/model/farmer.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/service/config_service.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../widgets/buddhist_year_converter.dart';
import 'list_farmer_registration_admin_screen.dart';


class ViewFarmerRegistDetailsScreen extends StatefulWidget {

  final String farmerId;

  const ViewFarmerRegistDetailsScreen({Key? key, required this.farmerId}) : super(key: key);

  @override
  State<ViewFarmerRegistDetailsScreen> createState() => _ViewFarmerRegistDetailsScreenState();
}

class _ViewFarmerRegistDetailsScreenState extends State<ViewFarmerRegistDetailsScreen> {

  FarmerController farmerController = FarmerController();

  TextEditingController farmerNameTextController = TextEditingController();
  TextEditingController farmerLastnameTextController = TextEditingController();
  TextEditingController farmerEmailTextController = TextEditingController();
  TextEditingController farmerMobileNoTextController = TextEditingController();

  TextEditingController farmNameTextController = TextEditingController();
  TextEditingController farmLatitudeTextController = TextEditingController();
  TextEditingController farmLongitudeTextController = TextEditingController();

  TextEditingController farmerCertImgTextController = TextEditingController();
  TextEditingController farmerCertNoTextController = TextEditingController();
  TextEditingController farmerCertRegDateTextController = TextEditingController();
  TextEditingController farmerCertExpireDateTextController = TextEditingController();

  TextEditingController farmerUsernameTextController = TextEditingController();

  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  bool? isLoaded;

  String? imgCertFileName;

  var dateFormat = DateFormat('dd-MM-yyyy');
  var newDateFormat = DateFormat('dd-MMM-yyyy');

  FarmerCertificate? farmerCertificate;

  late GoogleMapController mapController;
  Map<String, Marker> markers = {};

  void addMarker (String markerId, LatLng location) {
    var marker = Marker(
      markerId: MarkerId(markerId),
      position: location,
      infoWindow: const InfoWindow(
        title: "THIS IS A PONG!",
        snippet: "this is on the map boiis"
      )
    );

    markers[markerId] = marker;
    setState(() {});
  }

  void showUpdateFarmerRegistStatusFailAlert () {
    QuickAlert.show(
      context: context,
      title: "อัปเดตสถานะไม่สำเร็จ",
      text: "ไม่สามารถอัปเดตสถานะการลงทะเบียนของเกษตรกรได้",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

  void showAcceptRegistrationAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะอนุมัติการลงทะเบียนของเกษตรกร",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("Accept!");
        http.Response updateFarmerResponse = await farmerController.updateFmRegistStatus(farmerCertificate?.farmer?.farmerId ?? "");
        if (updateFarmerResponse.statusCode == 500) {
          Navigator.pop(context);
          showUpdateFarmerRegistStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListFarmerRegistrationScreen()));
          });
        }
      }
    );
  }

  void showDeclineRegistrationAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะปฎิเสธการลงทะเบียนของเกษตรกร",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async{
        print("Accept!");
         http.Response declineFarmerResponse = await farmerController.declineFmRegistStatus(farmerCertificate?.farmer?.farmerId ?? "");
        if (declineFarmerResponse.statusCode == 500) {
          Navigator.pop(context);
          showUpdateFarmerRegistStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListFarmerRegistrationScreen()));
          });
        }
      }
    );
  }

  void fetchData (String farmerId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await farmerController.getFarmerDetails(farmerId);

    farmerCertificate = FarmerCertificate.fromJsonToFarmerCertificate(response);

    String filePath = farmerCertificate?.fmCertImg ?? "";

    imgCertFileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length);
    setTextToData();
    setState(() {
      isLoaded = true;
    });
  }

  void setTextToData () {
    farmerNameTextController.text = farmerCertificate?.farmer?.farmerName ?? "";
    farmerLastnameTextController.text = farmerCertificate?.farmer?.farmerLastname ?? "";
    farmerEmailTextController.text = farmerCertificate?.farmer?.farmerEmail ?? "";
    farmerMobileNoTextController.text = farmerCertificate?.farmer?.farmerMobileNo ?? "";
    farmNameTextController.text = farmerCertificate?.farmer?.farmName ?? "";

    farmerCertNoTextController.text = farmerCertificate?.fmCertNo ?? "";
    farmerCertRegDateTextController.text = buddhistYearConverter.convertDateTimeToBuddhistDate(farmerCertificate?.fmCertRegDate ?? DateTime.now());
    farmerCertExpireDateTextController.text = buddhistYearConverter.convertDateTimeToBuddhistDate(farmerCertificate?.fmCertExpireDate ?? DateTime.now());

    farmerUsernameTextController.text = farmerCertificate?.farmer?.user!.username ?? "";
  }

  @override
  void initState() {
    super.initState();
    fetchData(widget.farmerId);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: isLoaded == false?
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ),
          ],
        ) : 
        SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: InkWell(
                          onTap: () {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListFarmerRegistrationScreen()));
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Text(
                                "กลับไปหน้ารายการลงทะเบียน",
                                style: TextStyle(
                                  fontFamily: 'Itim',
                                  fontSize: 20
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Image(
                          image: AssetImage('images/logo.png'),
                          width: 50,
                          height: 50,
                        ),
                      )
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ข้อมูลเกษตรกร",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "วันที่ทำการสมัคร "+"${buddhistYearConverter.convertDateTimeToBuddhistDate(farmerCertificate?.farmer?.farmerRegDate ?? DateTime.now())}",
                        style: TextStyle(
                          fontFamily: 'Itim',
                          fontSize: 16
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerLastnameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "นามสกุลเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor:  Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerEmailTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "อีเมลเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.email),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerMobileNoTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "เบอร์โทรศัพท์มือถือเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.call),
                        prefixIconColor:  Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ข้อมูลฟาร์ม / สถานที่เพาะปลูกผลผลิต",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 400,
                      height: 400,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(double.parse(farmerCertificate?.farmer?.farmLatitude ?? ""), double.parse(farmerCertificate?.farmer?.farmLongitude ?? "")),
                          zoom: 17
                        ),
                        onMapCreated: (controller) {
                          mapController = controller;
                          addMarker("test", LatLng(double.parse(farmerCertificate?.farmer?.farmLatitude ?? ""), double.parse(farmerCertificate?.farmer?.farmLongitude ?? "")));
                        },
                        markers: markers.values.toSet(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อฟาร์ม",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.gite),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ข้อมูลใบรับรองมาตรฐานเกษตรกร",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Image.network(baseURL + '/farmercertificate/' + imgCertFileName!),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerCertNoTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "หมายเลขใบรับรองมาตรฐานเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.description),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerCertRegDateTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.calendar_month),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerCertExpireDateTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "วันที่หมดอายุใบรับรองมาตรฐานเกษตรกร",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.calendar_month),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      color: Colors.black,
                      thickness: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ข้อมูลชื่อผู้ใช้",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: farmerUsernameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ใช้ระบบ",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Color.fromARGB(255, 71, 46, 2)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 200,
                          height: 53,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green)
                            ),
                            onPressed: () {
                              showAcceptRegistrationAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("ยอมรับ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 200,
                          height: 53,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(50.0))),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.redAccent)
                            ),
                            onPressed: () {
                              showDeclineRegistrationAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("ปฎิเสธ",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'Itim'
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}