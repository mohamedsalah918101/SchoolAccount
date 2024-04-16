import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_account/supervisor_parent/components/children_takebus_card.dart';
import 'package:school_account/supervisor_parent/components/dialogs.dart';
import 'package:school_account/supervisor_parent/components/home_drawer.dart';
import 'package:school_account/main.dart';
import 'package:school_account/supervisor_parent/screens/attendence_parent.dart';
import 'package:school_account/supervisor_parent/screens/profile_parent.dart';
import 'package:school_account/supervisor_parent/screens/track_parent.dart';
import '../components/bus_component.dart';
import '../components/child_card.dart';
import '../components/main_bottom_bar.dart';
import '../components/supervisor_card.dart';
import 'notification_parent.dart';

class HomeParentTakeBus extends StatefulWidget {
  // Function() onTapMenu;

  HomeParentTakeBus({
    Key? key,
    // required this.onTapMenu,
  }) : super(key: key);

  @override
  _HomeParentTakeBusState createState() => _HomeParentTakeBusState();
}

class _HomeParentTakeBusState extends State<HomeParentTakeBus> {


  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: HomeDrawer(),
      body: Column(
        children: [
          SizedBox(
            height: 35,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: GestureDetector(
                    onTap: () {
                      Dialoge.setReminderDialog(context);
                    },
                    child: Image.asset(
                      'assets/images/clock.png',
                      width: 27.47,
                      height: 27.5,
                    ),
                  ),
                ),
                Text.rich(
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
                        text: 'Joly',
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
                IconButton(
                  onPressed: () {
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: Color(0xff442B72),
                    size: 35,
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
                  const SizedBox(
                    height: 25,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0, right: 20),
                    child: BusComponent(),
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      'Your Children'.tr,
                      style: TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 17,
                        fontFamily: 'Poppins-SemiBold',
                        fontWeight: FontWeight.w600,
                        height: 0.94,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 7,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 19.0),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 2,
                        itemBuilder: (BuildContext context, int index) {
                          return
                            Column(
                              children: [
                              ChildrenTakeBusCard(
                              ),
                                SizedBox(height: 10,)
                              ],
                            );
                        },
                      ),

                  ),
                  const SizedBox(
                    height: 8,
                  ),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 25.0),
                     child: Text(
                      'Supervisor'.tr,
                      style: TextStyle(
                        color: Color(0xFF616161),
                        fontSize: 17,
                        fontFamily: 'Poppins-SemiBold',
                        fontWeight: FontWeight.w600,
                        height: 0.94,
                      )),
                   ),
                  const SizedBox(
                    height: 9,
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 19.0),
                      child: SupervisorCard()),
                  const SizedBox(
                    height: 44,
                  ),
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
                builder: (context) => ProfileParent(
                  // onTapMenu: onTapMenu
                )));
          },
          child: Image.asset(
            'assets/images/174237 1.png',
            height: 33,
            width: 33,
            fit: BoxFit.cover,
          ),
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
                                EdgeInsets.only(top:7 , right: 15):
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
                                              NotificationsParent()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')?
                                  EdgeInsets.only(top: 7, left: 70):
                                  EdgeInsets.only( right: 70 ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (2).png',
                                          height: 16.56,
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
                                              AttendanceParent()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')?
                                  EdgeInsets.only(top: 12 , bottom:4 ,right: 10):
                                  EdgeInsets.only(top: 10 , bottom:4 ,left: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (3).png',
                                          height: 18.75,
                                          width: 18.75
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Calendar".tr,
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
                                              TrackParent()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')?
                                  EdgeInsets.only(top: 10 , bottom: 2 ,right: 12,left: 15):
                                  EdgeInsets.only(top: 10 , bottom: 2 ,left: 12,right: 15),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (4).png',
                                          height: 18.36,
                                          width: 23.5
                                      ),
                                      SizedBox(height: 3),
                                      Text(
                                        "Track".tr,
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
