
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

import '../../constant/constant.dart';
import '../../model/manufacturer.dart';
import '../../service/config_service.dart';
import 'list_manuft_registration_admin_screen.dart';

class ViewManuftRegistDetailsScreen extends StatefulWidget {

  final String manuftId;

  const ViewManuftRegistDetailsScreen({Key? key, required this.manuftId}) : super(key: key);

  @override
  State<ViewManuftRegistDetailsScreen> createState() => _ViewManuftRegistDetailsScreenState();
}

class _ViewManuftRegistDetailsScreenState extends State<ViewManuftRegistDetailsScreen> {

  ManufacturerController manufacturerController = ManufacturerController();

  TextEditingController manuftNameTextController = TextEditingController();
  TextEditingController manuftEmailTextController = TextEditingController();

  TextEditingController factoryLatitudeTextController = TextEditingController();
  TextEditingController factoryLongitudeTextController = TextEditingController();
  TextEditingController factoryTelNoTextController = TextEditingController();
  TextEditingController factorySupNameTextController = TextEditingController();
  TextEditingController factorySupLastnameTextController = TextEditingController();

  TextEditingController manuftCertImgTextController = TextEditingController();
  TextEditingController manuftCertNoTextController = TextEditingController();
  TextEditingController manuftCertRegDateTextController = TextEditingController();
  TextEditingController manuftCertExpireDateTextController = TextEditingController();

  TextEditingController manuftUsernameTextController = TextEditingController();

  bool? isLoaded;

  String? imgCertFileName;

  var dateFormat = DateFormat('dd-MM-yyyy');

  late GoogleMapController mapController;
  Map<String, Marker> markers = {};

  ManufacturerCertificate? manufacturerCertificate;

  void showUpdateManuftRegistStatusFailAlert () {
    QuickAlert.show(
      context: context,
      title: "อัปเดตสถานะไม่สำเร็จ",
      text: "ไม่สามารถอัปเดตสถานะการลงทะเบียนของผู้ผลิตได้",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }

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
        var updateManufacturerResponse = await manufacturerController.updateMnRegistStatus(manufacturerCertificate?.manufacturer?.manuftId ?? "");
        if (updateManufacturerResponse["code"] == 500) {
          Navigator.pop(context);
          showUpdateManuftRegistStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRegistrationScreen()));
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
       var declineManufacturerResponse = await manufacturerController.declineMnRegistStatus(manufacturerCertificate?.manufacturer?.manuftId ?? "");
        if (declineManufacturerResponse["code"] == 500) {
          Navigator.pop(context);
          showUpdateManuftRegistStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRegistrationScreen()));
          });
        }
      }
    );
  }

  void fetchData (String manuftId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await manufacturerController.getManufacturerDetails(manuftId);
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(response);
    String filePath = manufacturerCertificate?.mnCertImg ?? "";
    imgCertFileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length);
    setTextToData();
    setState(() {
      isLoaded = true;
    });
  }

  void setTextToData () {
    manuftNameTextController.text = manufacturerCertificate?.manufacturer?.manuftName ?? "";
    manuftEmailTextController.text = manufacturerCertificate?.manufacturer?.manuftEmail ?? "";

    factoryLatitudeTextController.text = manufacturerCertificate?.manufacturer?.factoryLatitude ?? "";
    factoryLongitudeTextController.text = manufacturerCertificate?.manufacturer?.factoryLongitude ?? "";
    factoryTelNoTextController.text = manufacturerCertificate?.manufacturer?.factoryTelNo ?? "";
    factorySupNameTextController.text = manufacturerCertificate?.manufacturer?.factorySupName ?? "";
    factorySupLastnameTextController.text = manufacturerCertificate?.manufacturer?.factorySupLastname ?? "";

    manuftCertImgTextController.text = manufacturerCertificate?.mnCertImg ?? "";
    manuftCertNoTextController.text = manufacturerCertificate?.mnCertNo ?? "";
    manuftCertRegDateTextController.text = dateFormat.format(manufacturerCertificate?.mnCertRegDate ?? DateTime.now());
    manuftCertExpireDateTextController.text = dateFormat.format(manufacturerCertificate?.mnCertExpireDate ?? DateTime.now());

    manuftUsernameTextController.text = manufacturerCertificate?.manufacturer?.user!.username ?? "";
  }

  @override
  void initState() {
    super.initState();
    fetchData(widget.manuftId);
    setTextToData();
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
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRegistrationScreen()));
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
                      "ข้อมูลผู้ผลิต",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: manuftNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      controller: manuftEmailTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "อีเมลผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      "ข้อมูลโรงงานผู้ผลิต",
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
                      controller: factoryTelNoTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "เบอร์โทรศัพท์โรงงานผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      controller: factorySupNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ดูแลโรงงานผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      controller: factorySupLastnameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "นามสกุลผู้ดูแลโรงงานผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 400,
                      height: 400,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(double.parse(manufacturerCertificate?.manufacturer?.factoryLatitude ?? ""), double.parse(manufacturerCertificate?.manufacturer?.factoryLongitude ?? "")),
                          zoom: 17
                        ),
                        onMapCreated: (controller) {
                          mapController = controller;
                          addMarker("test", LatLng(double.parse(manufacturerCertificate?.manufacturer?.factoryLatitude ?? ""), double.parse(manufacturerCertificate?.manufacturer?.factoryLongitude ?? "")));
                        },
                        markers: markers.values.toSet(),
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
                      "ข้อมูลใบรับรองมาตรฐานผู้ผลิต",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Image.network(baseURL + '/manuftcertificate/' + imgCertFileName!),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: manuftCertNoTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "หมายเลขใบรับรองมาตรฐานผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      controller: manuftCertRegDateTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      controller: manuftCertExpireDateTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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
                      "ข้อมูลชื่อผู้ใช้และรหัสผ่าน",
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
                      controller: manuftUsernameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ใช้ระบบ",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Colors.black
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