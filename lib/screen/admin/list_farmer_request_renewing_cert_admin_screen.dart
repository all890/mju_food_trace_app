
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/model/farmer_certificate.dart';
import 'package:mju_food_trace_app/screen/admin/view_farmer_request_renewing_cert_admin.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_certificate_controller.dart';
import '../../controller/farmer_controller.dart';
import 'navbar_admin.dart';

class ListFarmerRequestRenewingCertificateScreen extends StatefulWidget {
  const ListFarmerRequestRenewingCertificateScreen({super.key});

  @override
  State<ListFarmerRequestRenewingCertificateScreen> createState() => _ListFarmerRequestRenewingCertificateScreenState();
}

class _ListFarmerRequestRenewingCertificateScreenState extends State<ListFarmerRequestRenewingCertificateScreen> {

  FarmerCertificateController farmerCertificateController = FarmerCertificateController();

  bool? isLoaded;

  List<FarmerCertificate>? farmerCertificates;

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    farmerCertificates = await farmerCertificateController.getListAllFmRequestRenewCert();
    setState(() {
      isLoaded = true;
    });
    print(farmerCertificates?.length);
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          drawer: AdminNavbar(),
          appBar: AppBar(
            title: const Text("LIST FM REGIST"),
            backgroundColor: Colors.green,
          ),
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
          Container(
            padding: EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: farmerCertificates?.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: ListTile(
                    leading: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_circle)
                      ],
                    ),
                    title: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${farmerCertificates?[index].farmer?.farmerName} ${farmerCertificates?[index].farmer?.farmerLastname}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22
                          ),
                        ),
                        Text(
                          "${farmerCertificates?[index].farmer?.farmerEmail}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "${farmerCertificates?[index].fmCertUploadDate}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in),
                    onTap: () {
                      print("Go to farmer ${farmerCertificates?[index].fmCertId} details page!");
                      /*
                      WidgetsBinding.instance!.addPostFrameCallback((_) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ViewFarmerRequestRenewingCertificateScreen(fmCertId: farmerCertificates?[index].fmCertId??"")));
                      });
                      */
                    },
                  ),
                );
              },
            ),
          )
        ),
      ),
    );
  }
}