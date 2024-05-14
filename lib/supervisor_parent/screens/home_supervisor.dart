import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:school_account/Functions/functions.dart';
import 'package:school_account/supervisor_parent/components/parents_card.dart';
import 'package:school_account/supervisor_parent/components/child_data_item.dart';
import 'package:school_account/supervisor_parent/components/profile_card_in_supervisor.dart';
import 'package:school_account/supervisor_parent/components/supervisor_drawer.dart';
import 'package:school_account/main.dart';
import 'package:school_account/supervisor_parent/screens/attendence_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/notification_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/profile_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/show_all_students.dart';
import 'package:school_account/supervisor_parent/screens/student_screen.dart';
import 'package:school_account/supervisor_parent/screens/track_supervisor.dart';

class HomeForSupervisor extends StatefulWidget {
  HomeForSupervisor({
    Key? key,
  }) : super(key: key);

  @override
  _HomeForSupervisor createState() => _HomeForSupervisor();
}
class _HomeForSupervisor extends State<HomeForSupervisor> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<ChildDataItem> children = [];
  List<QueryDocumentSnapshot> data = [];
  List<QueryDocumentSnapshot> dataSupervisor = [];
  final _firestore = FirebaseFirestore.instance;



  getData()async{
    QuerySnapshot querySnapshot= await FirebaseFirestore.instance.collection('parent').get();
    data.addAll(querySnapshot.docs);
    setState(() {
    });
  }
  getDataForSupervisor()async{
    QuerySnapshot querySnapshot= await FirebaseFirestore.instance.collection('supervisor').get();
    dataSupervisor.addAll(querySnapshot.docs);
    setState(() {
    });
  }

  @override
  void initState() {
    getData();
    getDataForSupervisor();
    checkIfNumberExistsForSearch('phoneNumber');
    super.initState();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
          key: _scaffoldKey,
          endDrawer: SupervisorDrawer(),
          body: Column(
            children: [
              SizedBox(height: 35),
              // Expanded(
              //   child: Center(
              //     child:Padding(
              //       padding: const EdgeInsets.only(left: 60),
              //       child:
              //       FutureBuilder(
              //         future: _firestore.collection('schooldata').doc(sharedpref!.getString('id')).get(),
              //         builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              //           if (snapshot.hasError) {
              //             return Text('Something went wrong');
              //           }
              //
              //           if (snapshot.connectionState == ConnectionState.done) {
              //             Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
              //             return Text(
              //               data['nameEnglish'] ?? '',
              //               style: TextStyle(
              //                 color: Color(0xFF993D9A),
              //                 fontSize: 16,
              //                 fontWeight: FontWeight.bold,
              //                 fontFamily: 'Poppins-Bold',
              //               ),
              //             );
              //           }
              //
              //           return CircularProgressIndicator();
              //         },
              //       ),
              //
              //       // Text(
              //       //                   "Salam Language School".tr,
              //       //                   style: TextStyle(
              //       //                     color: Color(0xFF993D9A),
              //       //                     fontSize: 16,
              //       //                     fontFamily: 'Poppins-Bold',
              //       //                     fontWeight: FontWeight.w700,
              //       //                     height: 0.64,
              //       //                   ),
              //       //                 ),
              //     ),
              //   ),
              // ),
              Container(
                // Fixed row
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 55),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Welcome, '.tr,
                              style: TextStyle(
                                color: Color(0xFF993D9A),
                                fontSize: 16,
                                fontFamily: 'Poppins-Bold',
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                            TextSpan(
                              text: '${dataSupervisor?[0]['name'] }',
                              style: TextStyle(
                                color: Color(0xFF993D9A),
                                fontSize: 16,
                                fontFamily: 'Poppins-Bold',
                                fontWeight: FontWeight.w700,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: IconButton(
                        onPressed: () {
                          _scaffoldKey.currentState!.openEndDrawer();
                        },
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: Color(0xff442B72),
                          size: 35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: ProfileCardInSupervisor(),
                      ),
                      SizedBox(height: 25),
                      Container(
                        height: 2,
                        width: 276,
                        color: Color(0xff442B72).withOpacity(0.11),
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: ParentsCard(),
                      ),
                      SizedBox(height: 25),
                      Container(
                        height: 2,
                        width: 276,
                        color: Color(0xff442B72).withOpacity(0.11),
                      ),
                      SizedBox(height: 15),
                      Padding(
                        padding: (sharedpref?.getString('lang') == 'ar')
                            ? EdgeInsets.symmetric(horizontal: 30.0)
                            : EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Children'.tr,
                              style: TextStyle(
                                color: Color(0xFF442B72),
                                fontSize: 16,
                                fontFamily: 'Poppins-SemiBold',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              width: (sharedpref?.getString('lang') == 'ar') ? 190 : 168,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ShowAllStudents()),
                                );
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'Show all'.tr,
                                    style: TextStyle(
                                      color: Color(0xFF442B72),
                                      fontSize: 15,
                                      fontFamily: 'Poppins-Light',
                                      fontWeight: FontWeight.w400,
                                      height: 0.85,
                                    ),
                                  ),
                                  Container(
                                    height: 1,
                                    width: (sharedpref?.getString('lang') == 'ar') ? 55 : 62,
                                    color: Color(0xff442B72),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 25.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => StudentScreen()),
                            );
                          },
                          child: Column(
                            children: [
                              SizedBox(
                                height: 330,
                                width: double.infinity,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: data.length-3,
                                  // data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          height:  92,
                                          child: Card(
                                            elevation: 8,
                                            color: Colors.white,
                                            surfaceTintColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8.0),
                                            ),
                                            child: Padding(
                                              padding: (sharedpref?.getString('lang') == 'ar')?
                                              EdgeInsets.only(top: 15.0 , right: 12,):
                                              EdgeInsets.only(top: 15.0 , left: 12,),
                                              child:  Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 8.0),
                                                    child: Image.asset('assets/images/Ellipse 1.png',
                                                      width: 36,
                                                      height: 36,),
                                                  ),
                                                  SizedBox(width: 12,),
                                                  Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('${data[index]['childern']?[0]['name'] }',
                                                      // Text('${data[index]['childern']?[0-3]['name'] }',
                                                        style: TextStyle(
                                                          color: Color(0xff442B72),
                                                          fontSize: 15,
                                                          fontFamily: 'Poppins-SemiBold',
                                                          fontWeight: FontWeight.w600,
                                                          // height: 1,
                                                        ),),
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'Grade: '.tr,
                                                              style: TextStyle(
                                                                color: Color(0xFF919191),
                                                                fontSize: 12,
                                                                fontFamily: 'Poppins-Light',
                                                                fontWeight: FontWeight.w400,
                                                                // height: 1.33,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: '${data[index]['childern']?[0]['grade'] }',
                                                              style: TextStyle(
                                                                color: Color(0xFF442B72),
                                                                fontSize: 12,
                                                                fontFamily: 'Poppins-Light',
                                                                fontWeight: FontWeight.w400,
                                                                // height: 1.33,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Text.rich(
                                                        TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: 'Address: '.tr,
                                                              style: TextStyle(
                                                                color: Color(0xFF919191),
                                                                fontSize: 12,
                                                                fontFamily: 'Poppins-Light',
                                                                fontWeight: FontWeight.w400,
                                                                height: 1.33,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: '16 Khaled st,Asyut,Egypt',
                                                              style: TextStyle(
                                                                color: Color(0xFF442B72),
                                                                fontSize: 12,
                                                                fontFamily: 'Poppins-Light',
                                                                fontWeight: FontWeight.w400,
                                                                height: 1.33,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),),

                                          ),
                                        ),
                                        SizedBox(height: 10,)
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 44),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // extendBody: true,
          resizeToAvoidBottomInset: false,
          floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
          backgroundColor: Color(0xff442B72),
          onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfileSupervisorScreen(
          )));
          },
          child:
          Image.asset(
          'assets/images/174237 1.png',
          height: 33,
          width: 33,
              fit: BoxFit.cover,
            )
          ),
          bottomNavigationBar: Directionality(
              textDirection: Get.locale == Locale('ar')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  child: BottomAppBar(
                      padding: EdgeInsets.symmetric(vertical: 3),
                      height: 60,
                      color: const Color(0xFF442B72),
                      clipBehavior: Clip.antiAlias,
                      shape: const AutomaticNotchedShape(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(38.5),
                                  topRight: Radius.circular(38.5))),
                          RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(50)))),
                      notchMargin: 7,
                      child: SizedBox(
                          height: 10,
                          child: SingleChildScrollView(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')?
                                  EdgeInsets.only(top:7 , right: 5):
                                  EdgeInsets.only(left: 15),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (6).png',
                                          height: 20,
                                          width: 20
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Home".tr,
                                        style: TextStyle(
                                          fontFamily: 'Poppins-Regular',
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontSize: 8,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                AttendanceSupervisorScreen()),
                                      );
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                    (sharedpref?.getString('lang') == 'ar')?
                                    EdgeInsets.only(top: 9, left: 50):
                                    EdgeInsets.only( right: 50, top: 2 ),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                            'assets/images/icons8_checklist_1 1.png',
                                            height: 19,
                                            width: 19
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "Attendance".tr,
                                          style: TextStyle(
                                            fontFamily: 'Poppins-Regular',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                NotificationsSupervisor()),
                                      );
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                    (sharedpref?.getString('lang') == 'ar')?
                                    EdgeInsets.only(top: 12 , bottom:4 ,right: 0):
                                    EdgeInsets.only(top: 8 , bottom:4 ,left: 20),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                            'assets/images/Vector (2).png',
                                            height: 17,
                                            width: 16.2
                                        ),
                                        Image.asset(
                                            'assets/images/Vector (5).png',
                                            height: 4,
                                            width: 6
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          "Notifications".tr,
                                          style: TextStyle(
                                            fontFamily: 'Poppins-Regular',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TrackSupervisor()),
                                      );
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                    (sharedpref?.getString('lang') == 'ar')?
                                    EdgeInsets.only(top: 10 , bottom: 2 ,right: 0,left: 0):
                                    EdgeInsets.only(top: 8 , bottom: 2 ,left: 0,right: 10),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                            'assets/images/Vector (4).png',
                                            height: 18.36,
                                            width: 23.5
                                        ),
                                        SizedBox(height: 3),
                                        Text(
                                          "Buses".tr,
                                          style: TextStyle(
                                            fontFamily: 'Poppins-Regular',
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )))))
      ),
    );
  }
}
