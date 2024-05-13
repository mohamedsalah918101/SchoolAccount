import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:school_account/supervisor_parent/components/check_in_card.dart';
import 'package:school_account/supervisor_parent/components/child_data_item.dart';
import 'package:school_account/supervisor_parent/components/supervisor_drawer.dart';
import 'package:school_account/main.dart';
import 'package:school_account/supervisor_parent/screens/home_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/notification_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/profile_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/track_supervisor.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


class AttendanceSupervisorScreen extends StatefulWidget {
  AttendanceSupervisorScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AttendanceSupervisorScreen createState() => _AttendanceSupervisorScreen();
}
class _AttendanceSupervisorScreen extends State<AttendanceSupervisorScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isStarting = false;
  List<ChildDataItem> children = [];

//   getToken() async{
//       String? myToken = await FirebaseMessaging.instance.getToken();
//       print('object Attendance');
//       print(myToken);
// }

  getToken() async {
    try {
      String? myToken = await FirebaseMessaging.instance.getToken();
      print('object Attendance');
      print(myToken);
    } on PlatformException catch (e) {
      if (e.code == 'ERROR_GET_TOKEN') {
        print('Failed to get FCM token with error: ${e.message}');
      }
    }
  }


@override
  void initState() {
     getToken();
     super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        endDrawer: SupervisorDrawer(),
        body: Column(
          children: [
            SizedBox(
              height: 35,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child:  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 17.0),
                      child: Image.asset(
                        (sharedpref?.getString('lang') == 'ar')?
                        'assets/images/Layer 1.png':
                        'assets/images/fi-rr-angle-left.png',
                        width: 20,
                        height: 22,),
                    ),
                  ),
                  Text(
                    'Attendance'.tr,
                    style: TextStyle(
                      color: Color(0xFF993D9A),
                      fontSize: 16,
                      fontFamily: 'Poppins-Bold',
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _scaffoldKey.currentState!.openEndDrawer();
                    },
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: const Icon(
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      SizedBox(height: 20,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: Image.asset('assets/images/Ellipse 2.png',
                              width: 60,
                              height: 60,),
                            ),
                            SizedBox(width: 10,),
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'El Salam \nSchool'.tr,
                                    style: TextStyle(
                                      color: Color(0xFF993D9A),
                                      fontSize: 20,
                                      fontFamily: 'Poppins-Bold',
                                      fontWeight: FontWeight.w700,
                                      // height: 1.07,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '\n.',
                                    style: TextStyle(
                                      color: Color(0xffFFC53E),
                                      fontSize: 20,
                                      fontFamily: 'Poppins-Light',
                                      fontWeight: FontWeight.w300,
                                      height: 1.07,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 25,),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 25.0),
                              child: SizedBox(
                                width: 119,
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      padding:  EdgeInsets.all(0),
                                      backgroundColor: Color(0xFF442B72),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)
                                    )
                                  ),
                                  onPressed: () async {
                                    // getToken();
                                    isStarting =
                                    // children.isNotEmpty?
                                    true;
                                     // no data
                                    // : false;
                                    setState(() {
                                    });
    // // Send a notification
    // final message = {
    // 'notification': {
    // 'title': 'Trip Started',
    // 'body': 'Your trip has started',
    // },
    // 'token': 'your_device_token_here', // replace with the actual device token
    // };
    //
    // try {
    // await FirebaseMessaging.instance.send(message);
    // } catch (e) {
    // print('Error sending notification: $e');
    // }
    // },
    //                                 getToken();

                                  },
                                  child: Text( isStarting? 'End Your trip'.tr:'Start your trip'.tr,
                                  style: TextStyle(
                                    fontFamily: 'Poppins-SemiBold',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontSize: 13
                                  ),),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 15,),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28.0),
                        child: Text('Attendances'.tr,
                          style: TextStyle(
                            color: Color(0xFF771F98),
                            fontSize: 19,
                            fontFamily: 'Poppins-Bold',
                            fontWeight: FontWeight.w700,
                          ),),
                      ),

                      // children.isNotEmpty?
                      Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          height: 450,
                          width: double.infinity,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 3,
                            itemBuilder: (BuildContext context, int index) {
                              return
                                Column(
                                  children: [
                                    CheckInCard(),
                                    SizedBox(height: 15,)
                                  ],
                                );
                            },
                          ),
                        ),
                      ),
                      //no data
                      //     :
                      // Column(
                      //   children: [
                      //     SizedBox(height: 50,),
                      //     Image.asset('assets/images/Group 237684.png',
                      //     ),
                      //     Text('No Data Found'.tr,
                      //       style: TextStyle(
                      //         color: Color(0xff442B72),
                      //         fontFamily: 'Poppins-Regular',
                      //         fontWeight: FontWeight.w500,
                      //         fontSize: 19,
                      //       ),
                      //     ),
                      //     Text('You haven’t added any \n '
                      //         'dates yet'.tr,
                      //       textAlign: TextAlign.center,
                      //       style: TextStyle(
                      //         color: Color(0xffBE7FBF),
                      //         fontFamily: 'Poppins-Light',
                      //         fontWeight: FontWeight.w400,
                      //         fontSize: 12,
                      //       ),)
                      //   ],
                      // ),
                      const SizedBox(
                        height: 44,
                      ),

                    ],
                  )
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomeForSupervisor()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')?
                                  EdgeInsets.only(top:7 , right: 15):
                                  EdgeInsets.only(left: 15),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (7).png',
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
                              ),
                              GestureDetector(
                                onTap: () {
                                  // setState(() {
                                  //   Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             AttendanceSupervisorScreen()),
                                  //   );
                                  // });
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
                                  EdgeInsets.only(top: 12 , bottom:4 ,right: 10):
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
                                  EdgeInsets.only(top: 10 , bottom: 2 ,right: 10,left: 0):
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
    );
  }
}
