
import 'package:flutter/material.dart';
import 'package:mju_food_trace_app/model/raw_material_shipping.dart';

import '../../constant/constant.dart';
import '../../widgets/buddhist_year_converter.dart';
import 'list_planting_farmer_screen.dart';

class ShowSendResultScreen extends StatefulWidget {

  final RawMaterialShipping? rawMaterialShipping;

  const ShowSendResultScreen({super.key, required this.rawMaterialShipping});

  @override
  State<ShowSendResultScreen> createState() => _ShowSendResultScreenState();
}

class _ShowSendResultScreenState extends State<ShowSendResultScreen> {

  BuddhistYearConverter buddhistYearConverter = BuddhistYearConverter();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder:
                                          (BuildContext context) {
                                    return const ListPlantingScreen();
                                  }));
                                },
                                child: Row(
                                  children: [
                                    Icon(Icons.arrow_back),
                                    SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      "กลับไปหน้ารายการปลูก",
                                      style: TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 20),
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
                          padding: EdgeInsets.only(top: 5),
                          child: Text(
                            "ผลการส่งผลผลิต",
                            style: TextStyle(
                                fontSize: 22, fontFamily: 'Itim',fontWeight: FontWeight.bold,color: Color.fromARGB(255, 93, 43, 1)),
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          height: 300,
                          child: Image(image: AssetImage('images/truckrun.gif')),
                        ),
                        Stack(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Card(
                                elevation: 10,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              "ผลผลิตที่ส่ง : ",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                             Text(
                                              "${widget.rawMaterialShipping?.planting?.plantName}",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              "วันที่ส่งผลผลิต : ",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                             Text(
                                              "${buddhistYearConverter.convertDateTimeToBuddhistDate(widget.rawMaterialShipping?.rawMatShpDate)}",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              "ปริมาณผลผลิตที่ส่ง : ",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                              Text(
                                              "${widget.rawMaterialShipping?.rawMatShpQty} ${widget.rawMaterialShipping?.rawMatShpQtyUnit}",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50, bottom: 30),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Row(
                                          children: [
                                            Text(
                                              "ผู้รับปลายทาง : ",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            Text(
                                              "${widget.rawMaterialShipping?.manufacturer?.manuftName}",
                                              style: TextStyle(
                                                fontFamily: 'Itim',
                                                fontSize: 16
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: Card(
                                elevation: 10,
                                color: Colors.orange,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "ส่งผลผลิตสำเร็จ",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Itim',
                                          fontSize: 24,
                                          color: Colors.white
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.brown
                                      )
                                    ],
                                  ),
                                )
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }
}