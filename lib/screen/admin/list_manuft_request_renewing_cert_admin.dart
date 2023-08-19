
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/controller/manufacturer_certificate_controller.dart';
import 'package:mju_food_trace_app/model/manufacturer_certificate.dart';

import '../../constant/constant.dart';
import '../../controller/farmer_certificate_controller.dart';
import 'navbar_admin.dart';

class ListManuftRequestRenewingCertificateScreen extends StatefulWidget {
  const ListManuftRequestRenewingCertificateScreen({super.key});

  @override
  State<ListManuftRequestRenewingCertificateScreen> createState() => _ListManuftRequestRenewingCertificateScreenState();
}

class _ListManuftRequestRenewingCertificateScreenState extends State<ListManuftRequestRenewingCertificateScreen> {
  
  ManufacturerCertificateController manufacturerCertificateController = ManufacturerCertificateController();

  bool? isLoaded;

  List<ManufacturerCertificate>? manufacturerCertificates;

  void fetchData () async {
    setState(() {
      isLoaded = false;
    });
    manufacturerCertificates = await manufacturerCertificateController.getListAllMnRequestRenewCert();
    setState(() {
      isLoaded = true;
    });
    print(manufacturerCertificates?.length);
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
              itemCount: manufacturerCertificates?.length,
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
                          "${manufacturerCertificates?[index].manufacturer?.manuftName}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 22
                          ),
                        ),
                        Text(
                          "${manufacturerCertificates?[index].manufacturer?.manuftEmail}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          ),
                        ),
                        Text(
                          "${manufacturerCertificates?[index].mnCertUploadDate}",
                          style: const TextStyle(
                            fontFamily: 'Itim',
                            fontSize: 18
                          )
                        )
                      ],
                    ),
                    trailing: const Icon(Icons.zoom_in),
                    onTap: () {
                      print("Go to farmer ${manufacturerCertificates?[index].mnCertId} details page!");
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