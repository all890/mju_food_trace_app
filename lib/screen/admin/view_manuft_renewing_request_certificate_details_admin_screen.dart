import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/admin/list_manuft_request_renewing_cert_admin.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:http/http.dart' as http;
import '../../constant/constant.dart';
import '../../model/manufacturer_certificate.dart';
import '../../service/config_service.dart';

class ViewManuftRenewingRequestCertDetailsAdminScreen extends StatefulWidget {
    final String mnCertId;

  const  ViewManuftRenewingRequestCertDetailsAdminScreen({Key? key, required this.mnCertId}) : super(key: key);

  @override
  State<ViewManuftRenewingRequestCertDetailsAdminScreen> createState() => _ViewManuftRenewingRequestCertDetailsAdminScreenState();
}

class _ViewManuftRenewingRequestCertDetailsAdminScreenState extends State<ViewManuftRenewingRequestCertDetailsAdminScreen> {
 
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();
 
  TextEditingController manuftIDTextController = TextEditingController();
  TextEditingController manuftNameTextController = TextEditingController();
  TextEditingController factorySupnameTextController = TextEditingController();
  TextEditingController factorySupLastnameTextController = TextEditingController();
  TextEditingController manuftCertRegDateTextController = TextEditingController();
  TextEditingController manuftCertExpireDateTextController = TextEditingController();
  TextEditingController manuftCertNoTextController = TextEditingController();

  bool? isLoaded;

  String? imgCertFileName;

  var dateFormat = DateFormat('dd-MM-yyyy');
  ManufacturerCertificate? manufacturerCertificate;

   void showUpdateManuftRenewingReqCertStatusFailAlert () {
    QuickAlert.show(
      context: context,
      title: "อัปเดตสถานะไม่สำเร็จ",
      text: "ไม่สามารถอัปเดตสถานะการลงทะเบียนใบรับรองฉบับใหม่ของผู้ผลิตได้",
      type: QuickAlertType.error,
      confirmBtnText: "ตกลง",
      onConfirmBtnTap: () {
        Navigator.pop(context);
      }
    );
  }
   void showAcceptMnRenewingRequestCertAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะอนุมัติการลงทะเบียนใบรับรองฉบับใหม่ของผู้ผลิต",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async {
        print("Accept!");
      
        http.Response updateManuftCertResponse = await manufacturerCertificateController.updateMnRenewingRequestCertStatus(manufacturerCertificate?.mnCertId??"");
        if (updateManuftCertResponse.statusCode == 500) {
          Navigator.pop(context);
          showUpdateManuftRenewingReqCertStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRequestRenewingCertificateScreen()));
          });
        }
      }
    );
  }
    void showDeclineMnRenewingRequestCertAlert () {
    QuickAlert.show(
      context: context,
      showCancelBtn: true,
      title: "คุณแน่ใจหรือไม่?",
      text: "ว่าต้องการที่จะปฎิเสธการขออนุมัติการลงทะเบียนใบรับรองฉบับใหม่ของผู้ผลิต",
      type: QuickAlertType.confirm,
      confirmBtnText: "ตกลง",
      cancelBtnText: "ยกเลิก",
      confirmBtnColor: Colors.green,
      onCancelBtnTap: (){
        Navigator.pop(context);
      },
      onConfirmBtnTap: () async{
        print("Accept!");
         http.Response updateDeclineManuftCertResponse = await manufacturerCertificateController.declineMnRenewingRequestCertStatus(manufacturerCertificate?.mnCertId??"");
        if (updateDeclineManuftCertResponse.statusCode == 500) {
          Navigator.pop(context);
          showUpdateManuftRenewingReqCertStatusFailAlert();
        } else {
          Navigator.pop(context);
          WidgetsBinding.instance!.addPostFrameCallback((_) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRequestRenewingCertificateScreen()));
          });
        }
      }
    );
  }

    void fetchData (String mnCertId) async {
    setState(() {
      isLoaded = false;
    });
    var response = await manufacturerCertificateController.getManuftCertDetails(mnCertId);
    manufacturerCertificate = ManufacturerCertificate.fromJsonToManufacturerCertificate(response);
    String filePath = manufacturerCertificate?.mnCertImg?? "";
   
    imgCertFileName = filePath.substring(filePath.lastIndexOf('/')+1, filePath.length);
    setTextToData();
    setState(() {
      isLoaded = true;
    });
  }
     void setTextToData () {
    manuftIDTextController.text =  manufacturerCertificate?.manufacturer?.manuftId?? "";
    manuftNameTextController.text = manufacturerCertificate?.manufacturer?.manuftName ?? "";
    factorySupLastnameTextController.text = manufacturerCertificate?.manufacturer?.factorySupLastname ?? "";
    factorySupnameTextController.text = manufacturerCertificate?.manufacturer?.factorySupName ?? "";
    manuftCertNoTextController.text = manufacturerCertificate?.mnCertNo ?? "";
    manuftCertRegDateTextController.text = dateFormat.format(manufacturerCertificate?.mnCertRegDate ?? DateTime.now());
    manuftCertExpireDateTextController.text = dateFormat.format(manufacturerCertificate?.mnCertExpireDate ?? DateTime.now());

  }

    @override
  void initState() {
    super.initState();
    fetchData(widget.mnCertId);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:Scaffold(
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
              child: Column(children: [
                Row(
                  children: [
                    Expanded(
                        flex: 4,
                        child: InkWell(
                          onTap: () {
                            WidgetsBinding.instance!.addPostFrameCallback((_) {
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ListManuftRequestRenewingCertificateScreen()));
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
                                "กลับไปหน้ารายการร้องขอใบรับรอง",
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
                      "รายละเอียดคำร้องขอต่ออายุ",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "ใบรับรองของผู้ผลิต",
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: 'Itim'
                      ),
                    ),
                  ),

                   Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "วันที่ทำการร้องขอต่ออายุ : " +
                            "${dateFormat.format(manufacturerCertificate?.mnCertUploadDate ?? DateTime.now())}",
                        style: TextStyle(fontSize: 18, fontFamily: 'Itim'),
                      ),
                    ),
                  ),
                    Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: manuftIDTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "รหัสผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.key),
                        prefixIconColor: Color.fromARGB(255, 5, 40, 61)
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
                      controller: manuftNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ผลิค",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.home_filled),
                        prefixIconColor: Color.fromARGB(255, 5, 40, 61)
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
                      controller: factorySupnameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ดูแลโรงงาน",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Color.fromARGB(255, 5, 40, 61)
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
                        labelText: "นามสกุลผู้ดูแลโรงงาน",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.account_circle),
                        prefixIconColor: Color.fromARGB(255, 5, 40, 61)
                      ),
                      style: const TextStyle(
                        fontFamily: 'Itim',
                        fontSize: 18
                      ),
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
                        prefixIcon: const Icon(Icons.description),
                        prefixIconColor:  Color.fromARGB(255, 5, 40, 61)
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
                        labelText: "วันที่ลงทะเบียนใบรับรองมาตรฐานขิงผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.calendar_month),
                        prefixIconColor: Color.fromARGB(255, 5, 40, 61)
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
                        labelText: "วันหมดอายุใบรับรองมาตรฐานของผู้ผลิต",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.calendar_month),
                        prefixIconColor:  Color.fromARGB(255, 5, 40, 61)
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
                              showAcceptMnRenewingRequestCertAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("อนุมัติ",
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
                              showDeclineMnRenewingRequestCertAlert();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text("ปฎิเสธการอนุมัติ",
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

              ]),
            ),
          ),
        )
    ));
  }
}