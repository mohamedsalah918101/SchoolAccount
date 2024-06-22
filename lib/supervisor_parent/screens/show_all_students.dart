import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:loadmore/loadmore.dart';

import 'package:flutter/material.dart';
import 'package:school_account/supervisor_parent/components/added_child_card.dart';
import 'package:school_account/supervisor_parent/screens/attendence_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/home_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/notification_parent.dart';
import 'package:school_account/supervisor_parent/screens/profile_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/track_parent.dart';

import '../../main.dart';

class ShowAllStudents extends StatefulWidget {
  @override
  _ShowAllStudentsState createState() => _ShowAllStudentsState();
}

class _ShowAllStudentsState extends State<ShowAllStudents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _limit = 8; // Number of documents to fetch per page
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _hasMoreData = true;
  List<DocumentSnapshot> _documents = [];
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  List<Map<String, dynamic>> childrenData = [];



  String getJoinText(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'Unknown date';
    }

    DateTime dateTime = timestamp.toDate();
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 1) {
      return 'Added ${difference.inDays} days ago';
    } else if (difference.inDays == 1) {
      return 'Added yesterday';
    } else if (difference.inHours >= 1) {
      return 'Added ${difference.inHours} hours ago';
    } else if (difference.inMinutes >= 1) {
      return 'Added ${difference.inMinutes} minutes ago';
    } else {
      return 'Added just now';
    }
  }


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController.addListener(_scrollListener);
    _fetchData();
  }

  Future<void> _fetchData({String query = ""}) async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });

    Query query = _firestore.collection('parent').limit(_limit);
    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    final QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isEmpty) {
      setState(() {
        _hasMoreData = false;
      });
    } else {

      // List<Map<String, dynamic>> filteredChildrenData = childrenData.where((child) {
      //   return child['name'].toLowerCase().contains(searchQuery.toLowerCase());
      // }).toList();
      List<Map<String, dynamic>> allChildren = [];
      for (var parentDoc in snapshot.docs) {
        List<dynamic> children = parentDoc['children'];
        allChildren.addAll(children.map((child) => child as Map<String, dynamic>).toList());
      }

      setState(() {
        _lastDocument = snapshot.docs.last;
        _documents.addAll(snapshot.docs);
        childrenData.addAll(allChildren);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> _fetchData({String query = ""}) async {
  //   if (_isLoading || !_hasMoreData) return;
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   Query query = _firestore.collection('parent').limit(_limit);
  //   if (_lastDocument != null) {
  //     query = query.startAfterDocument(_lastDocument!);
  //   }
  //   final QuerySnapshot snapshot = await query.get();
  //   if (snapshot.docs.isEmpty) {
  //     setState(() {
  //       _hasMoreData = false;
  //     });
  //   } else {
  //     setState(() {
  //       _lastDocument = snapshot.docs.last;
  //       _documents.addAll(snapshot.docs);
  //     });
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }
  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.trim();
      print('Search query changed: $searchQuery');
    });
    _fetchData(query: searchQuery);
  }


  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _fetchData();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Paginated List'),
      // ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              SizedBox(
                height: 35,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 17.0),
                        child: Image.asset(
                          (sharedpref?.getString('lang') == 'ar')
                              ? 'assets/images/Layer 1.png'
                              : 'assets/images/fi-rr-angle-left.png',
                          width: 20,
                          height: 22,
                        ),
                      ),
                    ),
                    Text(
                      'Students'.tr,
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

              Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 17.0),
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xffF1F1F1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(21),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Search Name".tr,
                      hintStyle: TextStyle(
                        color: const Color(0xffC2C2C2),
                        fontSize: 12,
                        fontFamily: 'Poppins-Bold',
                        fontWeight: FontWeight.w700,
                      ),
                      prefixIcon: Padding(
                        padding: (sharedpref?.getString('lang') == 'ar')
                            ? EdgeInsets.only(
                            right: 6, top: 14.0, bottom: 9)
                            : EdgeInsets.only(
                            left: 3, top: 14.0, bottom: 9),
                        child: Image.asset(
                          'assets/images/Vector (12)search.png',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),

              // SizedBox(height: 100,),
              // SizedBox(height: 200,),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 33.0),
                  child: ListView.builder(
                    // physics:  NeverScrollableScrollPhysics(),
                    controller: _scrollController,
                    itemCount: _documents.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _documents.length) {
                        return _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : Center(child: Container()
                        // Text('No more data')
                        );
                      }
                      final DocumentSnapshot doc = _documents[index];
                      final data = doc.data() as Map<String, dynamic>;
                      var child = childrenData[index];
                      Timestamp? joinDateTimestamp = child['joinDateChild'] as Timestamp?;

                      return Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 0.0),
                                child:
                                CircleAvatar(
                                  backgroundImage: AssetImage('assets/images/Group 237679 (2).png'),
                                  radius: 25,
                                ),
                                // FutureBuilder(
                                //   future: FirebaseFirestore.instance
                                //       .collection('supervisor')
                                //       .doc(sharedpref!.getString('id'))
                                //       .get(),
                                //   builder: (BuildContext context,
                                //       AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                                //     if (snapshot.hasError) {
                                //       return Text('Something went wrong');
                                //     }
                                //
                                //     if (snapshot.connectionState == ConnectionState.done) {
                                //       if (!snapshot.hasData ||
                                //           snapshot.data == null ||
                                //           snapshot.data!.data() == null ||
                                //           snapshot.data!.data()!['busphoto'] == null ||
                                //           snapshot.data!.data()!['busphoto'].toString().trim().isEmpty) {
                                //         return CircleAvatar(
                                //           radius: 25,
                                //           backgroundColor: Color(0xff442B72),
                                //           child: CircleAvatar(
                                //             backgroundImage: AssetImage('assets/images/Group 237679 (2).png'),
                                //             radius: 25,
                                //           ),
                                //         );
                                //       }
                                //
                                //       Map<String, dynamic>? data = snapshot.data?.data();
                                //       if (data != null && data['busphoto'] != null) {
                                //         return CircleAvatar(
                                //           radius: 25,
                                //           backgroundColor: Color(0xff442B72),
                                //           child: CircleAvatar(
                                //             backgroundImage: NetworkImage('${data['busphoto']}'),
                                //             radius: 25,
                                //           ),
                                //         );
                                //       }
                                //     }
                                //
                                //     return Container();
                                //   },
                                // ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${child['name']}',
                                    style: TextStyle(
                                      color: Color(0xFF442B72),
                                      fontSize: 17,
                                      fontFamily: 'Poppins-SemiBold',
                                      fontWeight: FontWeight.w600,
                                      height: 1.07,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    // 'lll',
                                    '${getJoinText(joinDateTimestamp)}',
                                    style: TextStyle(
                                      color: Color(0xFF0E8113),
                                      fontSize: 13,
                                      fontFamily: 'Poppins-Regular',
                                      fontWeight: FontWeight.w400,
                                      height: 1.23,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        resizeToAvoidBottomInset: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100)),
            backgroundColor: Color(0xff442B72),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ProfileSupervisorScreen()));
            },
            child: Image.asset(
              'assets/images/174237 1.png',
              height: 33,
              width: 33,
              fit: BoxFit.cover,
            )),
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
                                  (sharedpref?.getString('lang') == 'ar')
                                      ? EdgeInsets.only(top: 7, right: 15)
                                      : EdgeInsets.only(left: 15),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (7).png',
                                          height: 20,
                                          width: 20),
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
                                              AttendanceSupervisorScreen()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')
                                      ? EdgeInsets.only(top: 9, left: 50)
                                      : EdgeInsets.only(right: 50, top: 2),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/icons8_checklist_1 1.png',
                                          height: 19,
                                          width: 19),
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
                                              NotificationsParent()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')
                                      ? EdgeInsets.only(
                                      top: 12, bottom: 4, right: 10)
                                      : EdgeInsets.only(
                                      top: 8, bottom: 4, left: 20),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (2).png',
                                          height: 17,
                                          width: 16.2),
                                      Image.asset(
                                          'assets/images/Vector (5).png',
                                          height: 4,
                                          width: 6),
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
                                          builder: (context) => TrackParent()),
                                    );
                                  });
                                },
                                child: Padding(
                                  padding:
                                  (sharedpref?.getString('lang') == 'ar')
                                      ? EdgeInsets.only(
                                      top: 10,
                                      bottom: 2,
                                      right: 10,
                                      left: 0)
                                      : EdgeInsets.only(
                                      top: 8,
                                      bottom: 2,
                                      left: 0,
                                      right: 10),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                          'assets/images/Vector (4).png',
                                          height: 18.36,
                                          width: 23.5),
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

