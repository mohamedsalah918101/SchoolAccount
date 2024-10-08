import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_account/supervisor_parent/components/children_card.dart';
import 'package:school_account/supervisor_parent/components/child_data_item.dart';
import 'package:school_account/supervisor_parent/components/dialogs.dart';
import 'package:school_account/supervisor_parent/components/parent_drawer.dart';
import 'package:school_account/main.dart';
import 'package:school_account/supervisor_parent/screens/attendence_parent.dart';
import 'package:school_account/supervisor_parent/screens/home_parent_takebus.dart';
import 'package:school_account/supervisor_parent/screens/home_parent.dart';
import 'package:school_account/supervisor_parent/screens/profile_parent.dart';
import 'package:school_account/supervisor_parent/screens/supervisor_screen.dart';
import 'package:school_account/supervisor_parent/screens/track_parent.dart';
import '../../model/ParentModel.dart';
import '../../model/SupervisorsModel.dart';
import '../components/bus_component.dart';
import '../components/child_card.dart';
import '../components/main_bottom_bar.dart';
import '../components/supervisor_card.dart';
import 'notification_parent.dart';

class children extends StatefulWidget {
  // Function() onTapMenu;


  children({
    Key? key,
    // required this.onTapMenu,
  }) : super(key: key);

  @override
  _childrenState createState() => _childrenState();
}

class _childrenState extends State<children> {
  // List<ChildDataItem> children = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _firestore = FirebaseFirestore.instance;

  List<ParentModel> childrenData = [];
  getData()async{
    try {
      DocumentSnapshot documentSnapshot = await _firestore.collection('parent').doc(sharedpref!.getString('id')).get();
      if (documentSnapshot.exists) {
        List<dynamic> children =  documentSnapshot.get('children');
        for(int i =0; i<children.length ;i++){
          DocumentSnapshot busSnapshot = await _firestore.collection('busdata').doc(children[i]['bus_id']).get();
          if (busSnapshot.exists) {
            List<dynamic> supervisors =  busSnapshot.get('supervisors');
            List<SupervisorsModel> supervisorsData =[];
            String busNumber='';
            busNumber =  busSnapshot.get('busnumber');

            for(int x =0; x<supervisors.length ;x++){
              supervisorsData.add(SupervisorsModel(name: supervisors[x]['name'],phone: supervisors[x]['phone'],id: supervisors[x]['id'],lat: supervisors[x]['lat'],lang:supervisors[x]['lang']));
            }
            childrenData.add(ParentModel(child_name: children[i]['name'],class_name: children[i]['grade'],bus_number: busNumber,supervisors: supervisorsData));

          }else{
            childrenData.add(ParentModel(child_name: children[i]['name'],class_name: children[i]['grade'],bus_number: '',supervisors: []));

          }

        }
        setState(() {

        });
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (e) {
      print("Error getting document: $e");
      return null;
    }
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: ParentDrawer(),
      key: _scaffoldKey,
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
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      (sharedpref?.getString('lang') == 'ar')?
                      'assets/images/Layer 1.png':
                      'assets/images/fi-rr-angle-left.png',
                      width: 22,
                      height: 22,),
                  ),
                ),
                Text(
                  'My Children'.tr,
                  style: TextStyle(
                    color: Color(0xFF993D9A),
                    fontSize: 16,
                    fontFamily: 'Poppins-Bold',
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
                IconButton(
                  onPressed:(){
                    _scaffoldKey.currentState!.openEndDrawer();
                  },
                  // onTapMenu,
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
                // children.isNotEmpty?
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: childrenData.length,
                      itemBuilder: (BuildContext context, int index) {
                        return
                          Column(
                            children: [
                              ChildrenCard(childrenData[index]),
                              SizedBox(height: 20,)
                            ],
                          );
                      },
                    ),
                    ),


                const SizedBox(
                  height: 44,
                )
               // :
               //  Column(
               //    children: [
               //      SizedBox(height: 170,),
               //      Image.asset('assets/images/Group 237684.png',
               //      ),
               //      Text('No Data Found'.tr,
               //        style: TextStyle(
               //          color: Color(0xff442B72),
               //          fontFamily: 'Poppins-Regular',
               //          fontWeight: FontWeight.w500,
               //          fontSize: 19,
               //        ),
               //      ),
               //      Text('You haven’t added any \n '
               //          'children yet'.tr,
               //        textAlign: TextAlign.center,
               //        style: TextStyle(
               //          color: Color(0xffBE7FBF),
               //          fontFamily: 'Poppins-Light',
               //          fontWeight: FontWeight.w400,
               //          fontSize: 12,
               //        ),)
               //    ],
               //  ),
                ],
              ),
            ),
          ),
        ],
      ),
        extendBody: true,
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
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomeParent()),
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
