import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:intl/intl.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer.dart';
import 'package:mju_food_trace_app/screen/admin/list_manuft_request_renewing_cert_admin.dart';

import '../../constant/constant.dart';
import '../../model/manufacturer_certificate.dart';

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

  bool? isLoaded;

  String? imgCertFileName;

  var dateFormat = DateFormat('dd-MM-yyyy');
  ManufacturerCertificate? manufacturerCertificate;

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
    //farmerLastnameTextController.text = farmerCertificate?.farmer?.farmerLastname ?? "";
  
   // farmerCertNoTextController.text = farmerCertificate?.fmCertNo ?? "";
   // farmerCertRegDateTextController.text = dateFormat.format(farmerCertificate?.fmCertRegDate ?? DateTime.now());
   // farmerCertExpireDateTextController.text = dateFormat.format(farmerCertificate?.fmCertExpireDate ?? DateTime.now());

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
                      controller: manuftNameTextController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "ชื่อผู้ผลิค",
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

              ]),
            ),
          ),
        )
    ));
  }
}