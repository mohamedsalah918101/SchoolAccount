
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:school_account/classes/dropdownRadiobutton.dart';
import 'package:school_account/classes/dropdowncheckboxitem.dart';
import 'package:school_account/supervisor_parent/components/elevated_simple_button.dart';
import 'package:school_account/supervisor_parent/components/supervisor_drawer.dart';
import 'package:school_account/main.dart';
import 'package:school_account/supervisor_parent/screens/add_parents.dart';
import 'package:school_account/supervisor_parent/screens/attendence_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/edit_add_parent.dart';
import 'package:school_account/supervisor_parent/screens/home_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/notification_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/profile_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/track_supervisor.dart';
class ShowAllStudents extends StatefulWidget {
  @override
  _ShowAllStudentsState createState() => _ShowAllStudentsState();
}

class _ShowAllStudentsState extends State<ShowAllStudents> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<DropdownCheckboxItem> selectedItems = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedValueAccept;
  String? selectedValueDecline;
  String? selectedValueWaiting;
  String? currentFilter;
  bool isAcceptFiltered = false;
  bool isDeclineFiltered = false;
  bool isWaitingFiltered = false;
  bool isFiltered = false;
  bool _isLoading = false;
  bool _hasMoreData = true;
  DocumentSnapshot? _lastDocument;
  int _limit = 8;
  String searchQuery = "";
  List<DocumentSnapshot> _documents = [];
  List<Map<String, dynamic>> childrenData = [];

  String getJoinText(Timestamp joinDate) {
    final now = DateTime.now();
    final joinDateTime = joinDate.toDate();
    final difference = now.difference(joinDateTime).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${joinDateTime.day}/${joinDateTime.month}/${joinDateTime.year}';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _searchController.addListener(_onSearchChanged);
    _fetchMoreData();
  }

  Future<void> _fetchMoreData() async {
    if (_isLoading || !_hasMoreData) return;

    setState(() {
      _isLoading = true;
    });
    String? supervisorId = sharedpref!.getString('id');

    Query query = _firestore.collection('parent')
        .where('supervisor', isEqualTo: supervisorId)
        .where('state', isEqualTo: 1)
        .where('address', isNull: false)
        .limit(_limit);

    if (_lastDocument != null) {
      query = query.startAfterDocument(_lastDocument!);
    }

    try {
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        _lastDocument = querySnapshot.docs.last;
        List<Map<String, dynamic>> allChildren = [];
        for (var parentDoc in querySnapshot.docs) {
          List<dynamic> children = parentDoc['children'];
          allChildren.addAll(children.map((child) => child as Map<String, dynamic>).toList());
        }
        setState(() {
          _documents.addAll(querySnapshot.docs);
          childrenData.addAll(allChildren);
          if (querySnapshot.docs.length < _limit) {
            _hasMoreData = false;
          }
        });
      } else {
        setState(() {
          _hasMoreData = false;
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> getData({String query = ""}) async {
    try {
      String? supervisorId = sharedpref!.getString('id');
      if (supervisorId == null) {
        print('Supervisor ID is null');
        return;
      }

      print('Supervisor ID: $supervisorId');
      QuerySnapshot querySnapshot;

      print('Querying documents by supervisorId');
      querySnapshot = await FirebaseFirestore.instance
          .collection('parent')
          .where('supervisor', isEqualTo: supervisorId)
          .get();

      List<QueryDocumentSnapshot> filteredDocuments = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        var state = data['state'];
        var address = data['address'];
        var children = data['children'] as List<dynamic>?;

        if (state == 1 && address != null && address.isNotEmpty) {
          // Check if there's a query and filter by children's names
          if (query.isEmpty || (query.isNotEmpty && children != null && children.any((child) {
            var childData = child as Map<String, dynamic>;
            var name = childData['name'] as String?;
            return name != null && name.toLowerCase().contains(query.toLowerCase());
          }))) {
            filteredDocuments.add(doc);
            // Add children data to childrenData
            if (children != null) {
              childrenData.addAll(children.map((child) => child as Map<String, dynamic>).toList());
            }
          }
        }
      }

      setState(() {
        _documents = filteredDocuments;
      });

      print('Fetched ${filteredDocuments.length} documents');
      for (var doc in filteredDocuments) {
        print(doc.data());
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        // Handle error state if needed
      });
    }
  }
  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.trim();
      print('Search query changed: $searchQuery');
    });
    getData(query: searchQuery);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
      _fetchMoreData();
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        endDrawer: SupervisorDrawer(),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              SizedBox(height: 35),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState!.openEndDrawer();
                        },
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
              SizedBox(height: 20,),
              //                     onChanged: (value) {
              //                       _onSearchChanged();
              //                     },
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xffF1F1F1),
                    hintText: 'Search Name'.tr,
                    hintStyle: TextStyle(
                      color: const Color(0xffC2C2C2),
                      fontSize: 12,
                      fontFamily: 'Poppins-Bold',
                      fontWeight: FontWeight.w700,
                    ),
                    prefixIcon: Padding(
                      padding: (sharedpref?.getString('lang') ==
                          'ar')
                          ? EdgeInsets.only(
                          right: 6, top: 14.0, bottom: 9)
                          : EdgeInsets.only(
                          left: 3, top: 14.0, bottom: 9),
                      child: Image.asset(
                        'assets/images/Vector (12)search.png',
                      ),),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(21),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: childrenData.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/Group 237684.png',

                      ),
                      Text('No Data Found'.tr,
                        style: TextStyle(
                          color: Color(0xff442B72),
                          fontFamily: 'Poppins-Regular',
                          fontWeight: FontWeight.w500,
                          fontSize: 19,
                        ),
                      ),
                      Text('You haven’t added any \n '
                          'children yet'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xffBE7FBF),
                          fontFamily: 'Poppins-Light',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),),
                      SizedBox(height: 80,)
                    ],
                  ),
                )
                    : ListView.builder(
                  controller: _scrollController,
                  itemCount: childrenData.length,
                  itemBuilder: (context, index) {
                    print('Building item for index: $index, List length: ${childrenData.length}');

                    if (index < 0 || index >= childrenData.length) {
                      print('Index $index is out of bounds');
                      return SizedBox.shrink();
                    }

                    var child = childrenData[index];
                    var parent = _documents[index % _documents.length];

                    return Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Handle item tap
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 28.0,),

                            child:   Column(
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 0.0),
                                      child:
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Color(
                                            0xff442B72),
                                        child: CircleAvatar(
                                          backgroundImage: AssetImage('assets/images/Group 237679 (2).png'),
                                          // Replace with your default image path
                                          radius: 25,
                                        ),
                                      ),
                                      // FutureBuilder(future: _firestore.collection(
                                      //       'supervisor').doc(sharedpref!.getString('id')).get(),
                                      //   builder: (BuildContext context,
                                      //       AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                                      //     if (snapshot.hasError) {
                                      //       return Text('Something went wrong');
                                      //     }
                                      //
                                      //     if (snapshot.connectionState == ConnectionState.done) {
                                      //       if (!snapshot.hasData || snapshot.data == null ||
                                      //           snapshot.data!.data() == null || snapshot.data!.data()!['busphoto'] ==
                                      //           null || snapshot.data!.data()!['busphoto'].toString().trim().isEmpty) {
                                      //         return CircleAvatar(
                                      //           radius: 25,
                                      //           backgroundColor: Color(
                                      //               0xff442B72),
                                      //           child: CircleAvatar(
                                      //             backgroundImage: AssetImage('assets/images/Group 237679 (2).png'),
                                      //             // Replace with your default image path
                                      //             radius: 25,
                                      //           ),
                                      //         );
                                      //       }
                                      //
                                      //       Map<String, dynamic>? data = snapshot.data?.data();
                                      //       if (data != null && data['busphoto'] != null) {
                                      //         return CircleAvatar(radius: 25,
                                      //           backgroundColor: Color(
                                      //               0xff442B72),
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
                                      width: 5,
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          child['name'] ?? 'Unknown',

                                          // '${_documents[index]['name'] ??
                                          //   '' }'

                                          style: TextStyle(
                                            color: Color(0xFF442B72),
                                            fontSize: 17,
                                            fontFamily: 'Poppins-SemiBold',
                                            fontWeight: FontWeight
                                                .w600,
                                            height: 1.07,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Padding(
                                          padding: (sharedpref
                                              ?.getString('lang') == 'ar')
                                              ? EdgeInsets.only(right: 3.0) : EdgeInsets.all(0.0),
                                          child:
                                          Text(
                                            // state == 'waiting'
                                            // ? 'Waiting'
                                            //     :
                                            // getJoinText(parent['joinDate']),

                                            'Added from ${   getJoinText(parent['joinDate'])}',

                                            style: TextStyle(
                                              color: Color(0xFF0E8113).withOpacity(0.7),
                                              fontSize: 13,
                                              fontFamily: 'Poppins-Regular',
                                              fontWeight: FontWeight
                                                  .w400,
                                              height: 1.23,
                                            ),),
                                          // Text(
                                          //   'Joined ${getJoinText(data[index]['joinDate'] ?? DateTime.now())}',
                                          //  // '${data[index]['joinDate']}',
                                          //
                                          //   style: TextStyle(
                                          //     color: Color(0xFF0E8113),
                                          //     fontSize: 13,
                                          //     fontFamily: 'Poppins-Regular',
                                          //     fontWeight: FontWeight.w400,
                                          //     height: 1.23,),),
                                        ),
                                      ],),
                                    // SizedBox(width: 103,),
                                  ],),
                                SizedBox(height: 25,)  ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              if (_isLoading) Center(child: CircularProgressIndicator()),
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
                  builder: (context) => ProfileSupervisorScreen(
                    // onTapMenu: onTapMenu
                  )));
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
                                              NotificationsSupervisor()),
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
                                          builder: (context) =>
                                              TrackSupervisor()),
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



// class _ParentsViewState extends State<ParentsView> {
//
//   _ParentsViewState();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   // int numberOfNames = 0; // declare the variable here
//   bool Accepted = false;
//   bool Declined = false;
//   bool Waiting = false;
//   String? selectedValueAccept;
//   String? selectedValueDecline;
//   String? selectedValueWaiting;
//   List<DropdownCheckboxItem> selectedItems = [];
//   int get dataLength => data.length;
//   List<QueryDocumentSnapshot> data = [];
//   bool isAcceptFiltered = false;
//   bool isDeclineFiltered = false;
//   bool isWaitingFiltered = false;
//   bool isFiltered  = false;
//   final _firestore = FirebaseFirestore.instance;
//   String? currentFilter;
//   TextEditingController _searchController = TextEditingController();
//   String SearchQuery = '';
//
//   String getJoinText(Timestamp joinDate) {
//     final now = DateTime.now();
//     final joinDateTime = joinDate.toDate();
//     final difference = now.difference(joinDateTime).inDays;
//
//     if (difference == 0) {
//       return 'Today';
//     } else if (difference == 1) {
//       return 'Yesterday';
//     } else if (difference < 7) {
//       return '${difference} days ago';
//     } else {
//       return '${joinDateTime.day}/${joinDateTime.month}/${joinDateTime.year}';
//     }
//   }
//
//
//    // DateTime? joinDate;
//
//   // String getJoinText(DateTime? joinDate) {
//   //   if (joinDate == null) {
//   //     return 'join date is not available';
//   //   }
//   //
//   //   final now = DateTime.now();
//   //   final difference = now.difference(joinDate).inDays;
//   //
//   //   if (difference == 0) {
//   //     return 'joined today';
//   //   } else if (difference == 1) {
//   //     return 'joined yesterday';
//   //   } else {
//   //     return 'joined $difference days ago';
//   //   }
//   // }
//
//
//
//
//   void _deleteSupervisorDocument(String documentId) {
//     FirebaseFirestore.instance
//         .collection('parent')
//         .doc(documentId)
//         .delete()
//         .then((_) {
//       setState(() {
//         // Update UI by removing the deleted document from the data list
//         data.removeWhere((document) => document.id == documentId);
//       });
//       // ScaffoldMessenger.of(context).showSnackBar(
//       //   showSnackBarFun(context),
//       //   // SnackBar(content: Text('Document deleted successfully')),
//       // );
//     })
//         .catchError((error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to delete document: $error')),
//       );
//     });
//   }
//
//   getDataForDeclinedFilter()async{
//     CollectionReference parent = FirebaseFirestore.instance.collection('parent');
//     QuerySnapshot parentData = await parent.where('state' , isEqualTo: 1).get();
//     // parentData.docs.forEach((element) {
//     //   data.add(element);
//     // }
//     // );
//     setState(() {
//       data = parentData.docs;
//       isFiltered = true;
//     });
//   }
//
//   getDataForWaitingFilter()async{
//     CollectionReference parent = FirebaseFirestore.instance.collection('parent');
//     QuerySnapshot parentData = await parent.where('state' , isEqualTo: 2).get();
//     // parentData.docs.forEach((element) {
//     //   data.add(element);
//     // }
//     // );
//     setState(() {
//       data = parentData.docs;
//       isFiltered = true;
//     });
//   }
//
//   getDataForAcceptFilter()async{
//     CollectionReference parent = FirebaseFirestore.instance.collection('parent');
//     QuerySnapshot parentData = await parent.where('state' , isEqualTo: 0 ).get();
//     // parentData.docs.forEach((element) {
//     //   data.add(element);
//     // }
//     // );
//     setState(() {
//       data = parentData.docs;
//       isFiltered = true;
//     });
//   }
//
//   // getData()async{
//   //   QuerySnapshot querySnapshot= await FirebaseFirestore.instance.collection('parent').get();
//   //   // data.addAll(querySnapshot.docs);
//   //   setState(() {
//   //     data = querySnapshot.docs;
//   //
//   //   });
//   // }
//
//   @override
//   void initState() {
//     _searchController.addListener(_onSearchChanged);
//     getData();
//     // getDataForAcceptFilter();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // _onSearchChanged() {
//   //   setState(() {
//   //     SearchQuery = _searchController.text.trim();
//   //   });
//   //   getData(query: SearchQuery);
//   // }
//
//   _onSearchChanged() {
//     setState(() {
//       SearchQuery = _searchController.text.trim();
//     });
//     getData(query: SearchQuery);
//   }
//
//
//   Future<void> getData({String query = ""}) async {
//     try {
//       String? supervisorId = sharedpref!.getString('id');
//       if (supervisorId == null) {
//         print('jessysupervisorId is null');
//         return;
//       }
//
//       print('jessysupervisorId: $supervisorId');
//       QuerySnapshot querySnapshot;
//
//       if (query.isEmpty) {
//         print('jessyQuery is empty, searching by supervisorId only');
//         querySnapshot = await FirebaseFirestore.instance.collection('parent')
//             .where('supervisor', isEqualTo: supervisorId)
//             .get();
//       } else {
//         print('jessySearching by supervisorId and name');
//         querySnapshot = await FirebaseFirestore.instance
//             .collection('parent')
//             .where('supervisor', isEqualTo: supervisorId)
//             .where('name', isGreaterThanOrEqualTo: query)
//             .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//             .get();
//       }
//
//       setState(() {
//         data = querySnapshot.docs;
//       });
//
//       print('jessyFetched ${querySnapshot.docs.length} documents');
//       for (var doc in querySnapshot.docs) {
//         print(doc.data());
//       }
//     } catch (e) {
//       print('jessyErrorl: $e');
//       setState(() {
//         // errorMessage = e.toString();
//       });
//     }
//   }
//   // Future<void> getData({String query = ""}) async {
//   //   try {
//   //     String? supervisorId = sharedpref!.getString('id');
//   //     QuerySnapshot querySnapshot;
//   //
//   //     if (query.isEmpty) {
//   //       print('ifdone');
//   //       querySnapshot = await FirebaseFirestore.instance.collection('parent')
//   //           .where('supervisor', isEqualTo: supervisorId)
//   //           .get();
//   //     } else {
//   //       print('elsedone');
//   //       querySnapshot = await FirebaseFirestore.instance
//   //           .collection('parent')
//   //           .where('name', isGreaterThanOrEqualTo: query)
//   //           .where('name', isLessThanOrEqualTo: query + '\uf8ff')
//   //           .get();
//   //     }
//   //
//   //     setState(() {
//   //       data = querySnapshot.docs;
//   //     });
//   //
//   //     print('Fetched ${querySnapshot.docs.length} documents');
//   //   } catch (e) {
//   //     print('Errorggg: $e');
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//
//     // String getJoinText(dynamic joinDate) {
//     //   final now = DateTime.now();
//     //   late final DateTime joinDateTime;
//     //   if (joinDate is Timestamp) {
//     //     joinDateTime = joinDate.toDate();
//     //   } else if (joinDate is DateTime) {
//     //     joinDateTime = joinDate;
//     //   } else {
//     //     return 'Invalid date';
//     //   }
//     //
//     //   final difference = now.difference(joinDateTime).inDays;
//     //
//     //   if (difference == 0) {
//     //     return 'Today';
//     //   } else if (difference == 1) {
//     //     return 'Yesterday';
//     //   } else if (difference < 7) {
//     //     return '${difference} days ago';
//     //   } else {
//     //     return '${joinDateTime.day}/${joinDateTime.month}/${joinDateTime.year}';
//     //   }
//     // }
//
//     return Scaffold(
//         key: _scaffoldKey,
//         endDrawer: SupervisorDrawer(),
//         body: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           child: Stack(
//             children: [
//
//               Column(
//                 children: [
//                   SizedBox(
//                     height: 35,
//                   ),
//                   Container(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             Navigator.of(context).pop();
//                           },
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(horizontal: 17.0),
//                             child: Image.asset(
//                               (sharedpref?.getString('lang') == 'ar')
//                                   ? 'assets/images/Layer 1.png'
//                                   : 'assets/images/fi-rr-angle-left.png',
//                               width: 20,
//                               height: 22,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           'Parents'.tr,
//                           style: TextStyle(
//                             color: Color(0xFF993D9A),
//                             fontSize: 16,
//                             fontFamily: 'Poppins-Bold',
//                             fontWeight: FontWeight.w700,
//                             height: 1,
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () {
//                             _scaffoldKey.currentState!.openEndDrawer();
//                           },
//                           icon: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                             child: const Icon(
//                               Icons.menu_rounded,
//                               color: Color(0xff442B72),
//                               size: 35,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: 20,
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 SizedBox(
//                                   width: 271,
//                                   height: 42,
//                                   child: TextField(
//                                     controller: _searchController,
//                                     onChanged: (value) {
//                                       _onSearchChanged();
//                                     },
//                                     decoration: InputDecoration(
//                                       filled: true,
//                                       fillColor: Color(0xffF1F1F1),
//                                       border: OutlineInputBorder(
//                                         borderRadius: BorderRadius.circular(21),
//                                         borderSide: BorderSide.none,
//                                       ),
//                                       hintText: "Search Name".tr,
//                                       hintStyle: TextStyle(
//                                         color: const Color(0xffC2C2C2),
//                                         fontSize: 12,
//                                         fontFamily: 'Poppins-Bold',
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                       prefixIcon: Padding(
//                                         padding: (sharedpref?.getString('lang') ==
//                                             'ar')
//                                             ? EdgeInsets.only(
//                                             right: 6, top: 14.0, bottom: 9)
//                                             : EdgeInsets.only(
//                                             left: 3, top: 14.0, bottom: 9),
//                                         child: Image.asset(
//                                           'assets/images/Vector (12)search.png',
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 // SizedBox(
//                                 //   width: 20
//                                 // ),
//                                 PopupMenuButton<String>(
//                                   child: Image(
//                                     image: AssetImage("assets/imgs/school/icons8_slider 2.png"),
//                                     width: 29,
//                                     height: 29,
//                                     color: Color(0xFF442B72), // Optionally, you can set the color of the image
//                                   ),
//
//                                   itemBuilder: (BuildContext context) {
//                                     return [
//                                       PopupMenuItem<String>(
//                                         value: 'custom',
//                                         child:
//                                         Column(
//                                           children: [
//                                             Container(
//                                               child:  DropdownRadiobutton(
//                                                 items: [
//                                                   DropdownCheckboxItem(label: 'Accepted'),
//                                                   DropdownCheckboxItem(label: 'Declined'),
//                                                   DropdownCheckboxItem(label: 'Waiting'),
//                                                 ],
//                                                 selectedItems: selectedItems,
//                                                 onSelectionChanged: (items) {
//                                                   setState(() {
//                                                     selectedItems = items;
//                                                     if (items.first.label == 'Accepted') {
//                                                       selectedValueAccept = 'Accepted';
//                                                       selectedValueDecline = null;
//                                                       selectedValueWaiting = null;
//                                                     } else if (items.first.label == 'Declined') {
//                                                       selectedValueAccept = null;
//                                                       selectedValueDecline = 'Declined';
//                                                       selectedValueWaiting = null;
//                                                     } else if (items.first.label == 'Waiting') {
//                                                       selectedValueAccept = null;
//                                                       selectedValueDecline = null;
//                                                       selectedValueWaiting = 'Waiting';
//                                                     }
//                                                   });
//                                                 },
//                                               ),
//                                             ),
//                                             Row(
//                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                               children: [
//                                                 SizedBox(
//                                                   width:100,
//                                                   child: ElevatedButton(
//
//                                                     onPressed: () {
//                                                       // Handle cancel action
//                                                       Navigator.pop(context);
//                                                     },
//                                                     style: ButtonStyle(
//                                                       backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF442B72)),
//                                                       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
//                                                         RoundedRectangleBorder(
//                                                           borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     child: GestureDetector(
//                                                       child: Text('Apply',style: TextStyle(fontSize:18),),
//                                                       onTap: (){
//                                                         if (selectedValueAccept != null) {
//                                                           currentFilter = 'Accepted';
//                                                           getDataForAcceptFilter();
//                                                           Navigator.pop(context);
//                                                           print('0');
//                                                         }else  if (selectedValueDecline != null) {
//                                                           currentFilter = 'Declined';
//                                                           getDataForDeclinedFilter();
//                                                           Navigator.pop(context);
//                                                           print('1');
//                                                         }else  if (selectedValueWaiting != null) {
//                                                           currentFilter = 'Waiting';
//                                                           getDataForWaitingFilter();
//                                                           Navigator.pop(context);
//                                                           print('2');
//                                                         }
//                                                       },),
//                                                   ),
//                                                 ),
//                                                 SizedBox(width: 3,),
//                                                 GestureDetector(
//                                                   child: Padding(
//                                                     padding: const EdgeInsets.all(5.0),
//                                                     child: Text("Reset",style: TextStyle(color: Color(0xFF442B72),fontSize: 20),),
//                                                   ), onTap: (){
//                                                   Navigator.pop(context);
//                                                 },
//                                                 )
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ];
//                                   },
//
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 28.0),
//                             child:
//                             ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: data.length,
//                               physics: NeverScrollableScrollPhysics(),
//                               itemBuilder: (context, index) {
//                                 final joinDate = DateTime.now();
//                                 // String state = 'waiting';
//
//                                 // if (data[index]['supervisor'] == sharedpref!.getString('id').toString())
//                                   // numberOfNames = data.where((element) => element['supervisor'] == sharedpref!.getString('id').toString()).length;
//                                     {
//                                       print('objectjj');
//                                   return Column(
//                                     children: [
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment
//                                             .spaceBetween,
//                                         children: [
//                                           Row(
//                                             children: [
//                                               Padding(
//                                                 padding:
//                                                 const EdgeInsets.only(
//                                                     top: 12.0),
//                                                 child: FutureBuilder(
//                                                   future: _firestore.collection(
//                                                       'supervisor').doc(
//                                                       sharedpref!.getString(
//                                                           'id')).get(),
//                                                   builder: (
//                                                       BuildContext context,
//                                                       AsyncSnapshot<
//                                                           DocumentSnapshot<Map<
//                                                               String,
//                                                               dynamic>>> snapshot) {
//                                                     if (snapshot.hasError) {
//                                                       return Text(
//                                                           'Something went wrong');
//                                                     }
//
//                                                     if (snapshot
//                                                         .connectionState ==
//                                                         ConnectionState.done) {
//                                                       if (!snapshot.hasData ||
//                                                           snapshot.data ==
//                                                               null ||
//                                                           snapshot.data!
//                                                               .data() == null ||
//                                                           snapshot.data!
//                                                               .data()!['busphoto'] ==
//                                                               null || snapshot
//                                                           .data!
//                                                           .data()!['busphoto']
//                                                           .toString()
//                                                           .trim()
//                                                           .isEmpty) {
//                                                         return CircleAvatar(
//                                                           radius: 25,
//                                                           backgroundColor: Color(
//                                                               0xff442B72),
//                                                           child: CircleAvatar(
//                                                             backgroundImage: AssetImage(
//                                                                 'assets/images/Group 237679 (2).png'),
//                                                             // Replace with your default image path
//                                                             radius: 25,
//                                                           ),
//                                                         );
//                                                       }
//
//                                                       Map<String,
//                                                           dynamic>? data = snapshot
//                                                           .data?.data();
//                                                       if (data != null &&
//                                                           data['busphoto'] !=
//                                                               null) {
//                                                         return CircleAvatar(
//                                                           radius: 25,
//                                                           backgroundColor: Color(
//                                                               0xff442B72),
//                                                           child: CircleAvatar(
//                                                             backgroundImage: NetworkImage(
//                                                                 '${data['busphoto']}'),
//                                                             radius: 25,
//                                                           ),
//                                                         );
//                                                       }
//                                                     }
//
//                                                     return Container();
//                                                   },
//                                                 ),
//                                               ),
//                                               const SizedBox(
//                                                 width: 5,
//                                               ),
//                                               Column(
//                                                 mainAxisAlignment: MainAxisAlignment
//                                                     .start,
//                                                 crossAxisAlignment: CrossAxisAlignment
//                                                     .start,
//
//                                                 children: [
//                                                   Text('${data[index]['name'] ??
//                                                       '' }',
//                                                     style: TextStyle(
//                                                       color: Color(0xFF442B72),
//                                                       fontSize: 17,
//                                                       fontFamily: 'Poppins-SemiBold',
//                                                       fontWeight: FontWeight
//                                                           .w600,
//                                                       height: 1.07,
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 5,
//                                                   ),
//                                                   Padding(
//                                                     padding: (sharedpref
//                                                         ?.getString('lang') ==
//                                                         'ar')
//                                                         ? EdgeInsets.only(
//                                                         right: 3.0)
//                                                         : EdgeInsets.all(0.0),
//                                                     child:
//                                                     Text(
//                                                       // state == 'waiting'
//                                                       // ? 'Waiting'
//                                                       //     :
//                                                       'Joined ${getJoinText(
//                                                           data[index]['joinDate'] ??
//                                                               DateTime.now())}',
//                                                       style: TextStyle(
//                                                         color: Color(0xFF0E8113).withOpacity(0.7),
//                                                         fontSize: 13,
//                                                         fontFamily: 'Poppins-Regular',
//                                                         fontWeight: FontWeight
//                                                             .w400,
//                                                         height: 1.23,
//                                                       ),),
//                                                     // Text(
//                                                     //   'Joined ${getJoinText(data[index]['joinDate'] ?? DateTime.now())}',
//                                                     //  // '${data[index]['joinDate']}',
//                                                     //
//                                                     //   style: TextStyle(
//                                                     //     color: Color(0xFF0E8113),
//                                                     //     fontSize: 13,
//                                                     //     fontFamily: 'Poppins-Regular',
//                                                     //     fontWeight: FontWeight.w400,
//                                                     //     height: 1.23,),),
//                                                   ),
//                                                 ],),
//                                               // SizedBox(width: 103,),
//                                             ],),
//                                           PopupMenuButton<String>(
//                                             padding: EdgeInsets.zero,
//                                             shape: RoundedRectangleBorder(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(6)),
//                                             ),
//                                             constraints: BoxConstraints
//                                                 .tightFor(
//                                                 width: 111, height: 100),
//                                             color: Colors.white,
//                                             surfaceTintColor: Colors
//                                                 .transparent,
//                                             offset: Offset(0, 30),
//                                             itemBuilder: (
//                                                 BuildContext context) =>
//                                             <PopupMenuEntry<String>>[
//                                               PopupMenuItem<String>(
//                                                 value: 'item1',
//                                                 child: Row(
//                                                   children: [
//                                                     Image.asset(
//                                                       (sharedpref?.getString(
//                                                           'lang') == 'ar')
//                                                           ? 'assets/images/edittt_white_translate.png'
//                                                           : 'assets/images/edittt_white.png',
//                                                       width: 12.81,
//                                                       height: 12.76,),
//                                                     SizedBox(width: 7,),
//                                                     Text('Edit'.tr,
//                                                       style: TextStyle(
//                                                         fontFamily: 'Poppins-Light',
//                                                         fontWeight: FontWeight
//                                                             .w400,
//                                                         fontSize: 17,
//                                                         color: Color(
//                                                             0xFF432B72),),),
//                                                   ],),),
//                                               PopupMenuItem<String>(
//                                                   value: 'item2', child: Row(
//                                                 children: [
//                                                   Image.asset(
//                                                     'assets/images/delete.png',
//                                                     width: 12.77,
//                                                     height: 13.81,),
//                                                   SizedBox(width: 7,),
//                                                   Text('Delete'.tr,
//                                                       style: TextStyle(
//                                                         fontFamily: 'Poppins-Light',
//                                                         fontWeight: FontWeight
//                                                             .w400,
//                                                         fontSize: 15,
//                                                         color: Color(
//                                                             0xFF432B72),)),
//                                                 ],)),
//                                             ],
//                                             onSelected: (String value) {
//                                               if (value == 'item1') {
//                                                 Navigator.push(context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           EditAddParents(
//                                                             docid: data[index]
//                                                                 .id,
//                                                             oldNumber: data[index]
//                                                                 .get(
//                                                                 'phoneNumber'),
//                                                             oldName: data[index]
//                                                                 .get('name'),
//                                                             oldNumberOfChildren: data[index]
//                                                                 .get(
//                                                                 'numberOfChildren')
//                                                                 .toString(),
//                                                             oldType: data[index]
//                                                                 .get(
//                                                                 'typeOfParent'),
//                                                             oldNameOfChild: 'test',
//                                                             oldGradeOfChild: 'test',
//                                                             // oldNameOfChild: data[index].childrenData[index]['grade'],
//                                                             // oldGradeOfChild: ['l;']
//                                                             // oldGradeOfChild: data[index]['childern'].get('grade'),
//                                                           )),);
//                                               } else if (value == 'item2') {
//                                                 void DeleteParentSnackBar(
//                                                     context, String message,
//                                                     {Duration? duration}) {
//                                                   ScaffoldMessenger.of(context)
//                                                       .showSnackBar(
//                                                     SnackBar(
//                                                       dismissDirection: DismissDirection
//                                                           .up,
//                                                       duration: duration ??
//                                                           const Duration(
//                                                               milliseconds: 1000),
//                                                       backgroundColor: Colors
//                                                           .white,
//                                                       margin: EdgeInsets.only(
//                                                         bottom: MediaQuery
//                                                             .of(context)
//                                                             .size
//                                                             .height - 150,
//                                                       ),
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius: BorderRadius
//                                                             .circular(10),),
//                                                       behavior: SnackBarBehavior
//                                                           .floating,
//                                                       content: Row(
//                                                         mainAxisAlignment: MainAxisAlignment
//                                                             .center,
//                                                         crossAxisAlignment: CrossAxisAlignment
//                                                             .center,
//                                                         children: [
//                                                           Image.asset(
//                                                             'assets/images/saved.png',
//                                                             width: 30,
//                                                             height: 30,),
//                                                           SizedBox(width: 15,),
//                                                           Text(
//                                                             'Parent deleted successfully'
//                                                                 .tr,
//                                                             style: const TextStyle(
//                                                               color: Color(
//                                                                   0xFF4CAF50),
//                                                               fontSize: 16,
//                                                               fontFamily: 'Poppins-Bold',
//                                                               fontWeight: FontWeight
//                                                                   .w700,
//                                                               height: 1.23,
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }
//                                                 showDialog(
//                                                   context: context,
//                                                   barrierDismissible: false,
//                                                   builder: (ctx) =>
//                                                       Dialog(
//                                                           backgroundColor: Colors
//                                                               .white,
//                                                           surfaceTintColor: Colors
//                                                               .transparent,
//                                                           // contentPadding: const EdgeInsets.all(20),
//                                                           shape: RoundedRectangleBorder(
//                                                             borderRadius: BorderRadius
//                                                                 .circular(
//                                                               30,
//                                                             ),
//                                                           ),
//                                                           child: SizedBox(
//                                                             width: 304,
//                                                             height: 182,
//                                                             child: Padding(
//                                                               padding: const EdgeInsets
//                                                                   .symmetric(
//                                                                   vertical: 10,
//                                                                   horizontal: 15),
//                                                               child: Column(
//                                                                 crossAxisAlignment: CrossAxisAlignment
//                                                                     .center,
//                                                                 mainAxisAlignment: MainAxisAlignment
//                                                                     .center,
//                                                                 children: [
//                                                                   Row(
//                                                                     mainAxisAlignment: MainAxisAlignment
//                                                                         .start,
//                                                                     children: [
//                                                                       const SizedBox(
//                                                                         width: 8,
//                                                                       ),
//                                                                       Flexible(
//                                                                         child: Column(
//                                                                           children: [
//                                                                             GestureDetector(
//                                                                               onTap: () =>
//                                                                                   Navigator
//                                                                                       .pop(
//                                                                                       context),
//                                                                               child: Image
//                                                                                   .asset(
//                                                                                 'assets/images/Vertical container.png',
//                                                                                 width: 27,
//                                                                                 height: 27,
//                                                                               ),
//                                                                             ),
//                                                                             const SizedBox(
//                                                                               height: 25,
//                                                                             )
//                                                                           ],
//                                                                         ),
//                                                                       ),
//                                                                       Expanded(
//                                                                         flex: 3,
//                                                                         child: Text(
//                                                                           'Delete'
//                                                                               .tr,
//                                                                           textAlign: TextAlign
//                                                                               .center,
//                                                                           style: TextStyle(
//                                                                             color: Color(
//                                                                                 0xFF442B72),
//                                                                             fontSize: 18,
//                                                                             fontFamily: 'Poppins-SemiBold',
//                                                                             fontWeight: FontWeight
//                                                                                 .w600,
//                                                                             height: 1.23,
//                                                                           ),
//                                                                         ),
//                                                                       ),
//                                                                     ],
//                                                                   ),
//                                                                   Center(
//                                                                     child: Text(
//                                                                       'Are You Sure you want to \n'
//                                                                           'delete this parent ?'
//                                                                           .tr,
//                                                                       textAlign: TextAlign
//                                                                           .center,
//                                                                       style: TextStyle(
//                                                                         color: Color(
//                                                                             0xFF442B72),
//                                                                         fontSize: 16,
//                                                                         fontFamily: 'Poppins-Light',
//                                                                         fontWeight: FontWeight
//                                                                             .w400,
//                                                                         height: 1.23,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                     height: 15,
//                                                                   ),
//                                                                   Row(
//                                                                     mainAxisAlignment: MainAxisAlignment
//                                                                         .center,
//                                                                     children: [
//                                                                       SizedBox(
//                                                                         child: ElevatedSimpleButton(
//                                                                           txt: 'Delete'
//                                                                               .tr,
//                                                                           width: 107,
//                                                                           hight: 38,
//                                                                           onPress: () async {
//                                                                             setState(() {
//                                                                               _deleteSupervisorDocument(
//                                                                                   data[index]
//                                                                                       .id);
//                                                                             });
//                                                                             DeleteParentSnackBar(
//                                                                                 context,
//                                                                                 'message');
//                                                                             Navigator
//                                                                                 .pop(
//                                                                                 context);
//                                                                           },
//                                                                           color: const Color(
//                                                                               0xFF442B72),
//                                                                           fontSize: 16,
//                                                                           fontFamily: 'Poppins-Regular',
//                                                                         ),
//                                                                       ),
//                                                                       // const Spacer(),
//                                                                       SizedBox(
//                                                                         width: 15,),
//                                                                       SizedBox(
//                                                                         width: 107,
//                                                                         height: 38,
//                                                                         child: ElevatedButton(
//                                                                           style: ElevatedButton
//                                                                               .styleFrom(
//                                                                             backgroundColor: Colors
//                                                                                 .white,
//                                                                             surfaceTintColor: Colors
//                                                                                 .transparent,
//                                                                             shape: RoundedRectangleBorder(
//                                                                                 side: BorderSide(
//                                                                                   color: Color(
//                                                                                       0xFF442B72),
//                                                                                 ),
//                                                                                 borderRadius: BorderRadius
//                                                                                     .circular(
//                                                                                     10)
//                                                                             ),
//                                                                           ),
//                                                                           child: Text(
//                                                                               'Cancel'
//                                                                                   .tr,
//                                                                               textAlign: TextAlign
//                                                                                   .center,
//                                                                               style: TextStyle(
//                                                                                   color: Color(
//                                                                                       0xFF442B72),
//                                                                                   fontFamily: 'Poppins-Regular',
//                                                                                   fontWeight: FontWeight
//                                                                                       .w500,
//                                                                                   fontSize: 16)
//                                                                           ),
//                                                                           onPressed: () {
//                                                                             Navigator
//                                                                                 .pop(
//                                                                                 context);
//                                                                           },
//                                                                         ),
//                                                                       ),
//
//                                                                     ],
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                             ),
//                                                           )),
//                                                 );
//                                               }
//                                             },
//                                             child: Image.asset(
//                                               'assets/images/more.png',
//                                               width: 20.8, height: 20.8,),),
//                                         ],
//                                       ),
//                                       SizedBox(height: 25,)],);
//                                 }
//
//                                 },),
//                           ),
//                           SizedBox(height: 44,)
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               (sharedpref?.getString('lang') == 'ar')
//                   ? Positioned(
//                 bottom: 20,
//                 left: 25,
//                 child: FloatingActionButton(
//                   shape: const CircleBorder(),
//                   onPressed: () {
//                     print('object');
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AddParents()));
//                   },
//                   backgroundColor: Color(0xFF442B72),
//                   child: Icon(
//                     Icons.add,
//                     color: Colors.white,
//                     size: 35,
//                   ),
//                 ),
//               )
//                   : Positioned(
//                 bottom: 20,
//                 right: 25,
//                 child: FloatingActionButton(
//                   shape: const CircleBorder(),
//                   onPressed: () {
//                     setState(() {
//
//                     });
//                     print('object');
//                     Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => AddParents()));
//                   },
//                   backgroundColor: Color(0xFF442B72),
//                   child: Icon(
//                     Icons.add,
//                     color: Colors.white,
//                     size: 35,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // extendBody: true,
//         resizeToAvoidBottomInset: false,
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         floatingActionButton: FloatingActionButton(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(100)),
//             backgroundColor: Color(0xff442B72),
//             onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => ProfileSupervisorScreen(
//                     // onTapMenu: onTapMenu
//                   )));
//             },
//             child: Image.asset(
//               'assets/images/174237 1.png',
//               height: 33,
//               width: 33,
//               fit: BoxFit.cover,
//             )),
//         bottomNavigationBar: Directionality(
//             textDirection: Get.locale == Locale('ar')
//                 ? TextDirection.rtl
//                 : TextDirection.ltr,
//             child: ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(25),
//                   topRight: Radius.circular(25),
//                 ),
//                 child: BottomAppBar(
//                     padding: EdgeInsets.symmetric(vertical: 3),
//                     height: 60,
//                     color: const Color(0xFF442B72),
//                     clipBehavior: Clip.antiAlias,
//                     shape: const AutomaticNotchedShape(
//                         RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(38.5),
//                                 topRight: Radius.circular(38.5))),
//                         RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.all(Radius.circular(50)))),
//                     notchMargin: 7,
//                     child: SizedBox(
//                         height: 10,
//                         child: SingleChildScrollView(
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               HomeForSupervisor( )),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(top: 7, right: 15)
//                                       : EdgeInsets.only(left: 15),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/Vector (7).png',
//                                           height: 20,
//                                           width: 20),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "Home".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               AttendanceSupervisorScreen()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(top: 9, left: 50)
//                                       : EdgeInsets.only(right: 50, top: 2),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/icons8_checklist_1 1.png',
//                                           height: 19,
//                                           width: 19),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "Attendance".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               NotificationsSupervisor()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(
//                                       top: 12, bottom: 4, right: 10)
//                                       : EdgeInsets.only(
//                                       top: 8, bottom: 4, left: 20),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/Vector (2).png',
//                                           height: 17,
//                                           width: 16.2),
//                                       Image.asset(
//                                           'assets/images/Vector (5).png',
//                                           height: 4,
//                                           width: 6),
//                                       SizedBox(height: 2),
//                                       Text(
//                                         "Notifications".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               TrackSupervisor()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(
//                                       top: 10,
//                                       bottom: 2,
//                                       right: 10,
//                                       left: 0)
//                                       : EdgeInsets.only(
//                                       top: 8,
//                                       bottom: 2,
//                                       left: 0,
//                                       right: 10),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/Vector (4).png',
//                                           height: 18.36,
//                                           width: 23.5),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "Buses".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ))))));
//   }
// }










// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:loadmore/loadmore.dart';
//
// import 'package:flutter/material.dart';
// import 'package:school_account/supervisor_parent/components/added_child_card.dart';
// import 'package:school_account/supervisor_parent/screens/attendence_supervisor.dart';
// import 'package:school_account/supervisor_parent/screens/home_supervisor.dart';
// import 'package:school_account/supervisor_parent/screens/notification_parent.dart';
// import 'package:school_account/supervisor_parent/screens/profile_supervisor.dart';
// import 'package:school_account/supervisor_parent/screens/track_parent.dart';
//
// import '../../main.dart';
//
// class ShowAllStudents extends StatefulWidget {
//   @override
//   _ShowAllStudentsState createState() => _ShowAllStudentsState();
// }
//
// class _ShowAllStudentsState extends State<ShowAllStudents> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final int _limit = 8; // Number of documents to fetch per page
//   DocumentSnapshot? _lastDocument;
//   bool _isLoading = false;
//   bool _hasMoreData = true;
//   List<DocumentSnapshot> _documents = [];
//   final ScrollController _scrollController = ScrollController();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   TextEditingController _searchController = TextEditingController();
//   String searchQuery = '';
//
//   List<Map<String, dynamic>> childrenData = [];
//
//
//
//   String getJoinText(Timestamp? timestamp) {
//     if (timestamp == null) {
//       return 'Unknown date';
//     }
//
//     DateTime dateTime = timestamp.toDate();
//     Duration difference = DateTime.now().difference(dateTime);
//
//     if (difference.inDays > 1) {
//       return 'Added ${difference.inDays} days ago';
//     } else if (difference.inDays == 1) {
//       return 'Added yesterday';
//     } else if (difference.inHours >= 1) {
//       return 'Added ${difference.inHours} hours ago';
//     } else if (difference.inMinutes >= 1) {
//       return 'Added ${difference.inMinutes} minutes ago';
//     } else {
//       return 'Added just now';
//     }
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//     _scrollController.addListener(_scrollListener);
//     _fetchData();
//   }
//
//   Future<void> _fetchData({String query = ""}) async {
//     if (_isLoading || !_hasMoreData) return;
//
//     setState(() {
//       _isLoading = true;
//     });
//
//     Query query = _firestore.collection('parent').limit(_limit);
//     if (_lastDocument != null) {
//       query = query.startAfterDocument(_lastDocument!);
//     }
//
//     final QuerySnapshot snapshot = await query.get();
//     if (snapshot.docs.isEmpty) {
//       setState(() {
//         _hasMoreData = false;
//       });
//     } else {
//
//       // List<Map<String, dynamic>> filteredChildrenData = childrenData.where((child) {
//       //   return child['name'].toLowerCase().contains(searchQuery.toLowerCase());
//       // }).toList();
//       List<Map<String, dynamic>> allChildren = [];
//       for (var parentDoc in snapshot.docs) {
//         List<dynamic> children = parentDoc['children'];
//         allChildren.addAll(children.map((child) => child as Map<String, dynamic>).toList());
//       }
//
//       setState(() {
//         _lastDocument = snapshot.docs.last;
//         _documents.addAll(snapshot.docs);
//         childrenData.addAll(allChildren);
//       });
//     }
//
//     setState(() {
//       _isLoading = false;
//     });
//   }
//
//   // Future<void> _fetchData({String query = ""}) async {
//   //   if (_isLoading || !_hasMoreData) return;
//   //   setState(() {
//   //     _isLoading = true;
//   //   });
//   //   Query query = _firestore.collection('parent').limit(_limit);
//   //   if (_lastDocument != null) {
//   //     query = query.startAfterDocument(_lastDocument!);
//   //   }
//   //   final QuerySnapshot snapshot = await query.get();
//   //   if (snapshot.docs.isEmpty) {
//   //     setState(() {
//   //       _hasMoreData = false;
//   //     });
//   //   } else {
//   //     setState(() {
//   //       _lastDocument = snapshot.docs.last;
//   //       _documents.addAll(snapshot.docs);
//   //     });
//   //   }
//   //   setState(() {
//   //     _isLoading = false;
//   //   });
//   // }
//   void _onSearchChanged() {
//     setState(() {
//       searchQuery = _searchController.text.trim();
//       print('Search query changed: $searchQuery');
//     });
//     _fetchData(query: searchQuery);
//   }
//
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollListener() {
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
//       _fetchData();
//     }
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Paginated List'),
//       // ),
//         body: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 35,
//               ),
//               Container(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 17.0),
//                         child: Image.asset(
//                           (sharedpref?.getString('lang') == 'ar')
//                               ? 'assets/images/Layer 1.png'
//                               : 'assets/images/fi-rr-angle-left.png',
//                           width: 20,
//                           height: 22,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       'Students'.tr,
//                       style: TextStyle(
//                         color: Color(0xFF993D9A),
//                         fontSize: 16,
//                         fontFamily: 'Poppins-Bold',
//                         fontWeight: FontWeight.w700,
//                         height: 1,
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () {
//                         _scaffoldKey.currentState!.openEndDrawer();
//                       },
//                       icon: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 5.0),
//                         child: const Icon(
//                           Icons.menu_rounded,
//                           color: Color(0xff442B72),
//                           size: 35,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               Column(
//                 children: [
//                   SizedBox(
//                     height: 15,
//                   ),
//                 ],
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 17.0),
//                 child: SizedBox(
//                   height: 42,
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Color(0xffF1F1F1),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(21),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintText: "Search Name".tr,
//                       hintStyle: TextStyle(
//                         color: const Color(0xffC2C2C2),
//                         fontSize: 12,
//                         fontFamily: 'Poppins-Bold',
//                         fontWeight: FontWeight.w700,
//                       ),
//                       prefixIcon: Padding(
//                         padding: (sharedpref?.getString('lang') == 'ar')
//                             ? EdgeInsets.only(
//                             right: 6, top: 14.0, bottom: 9)
//                             : EdgeInsets.only(
//                             left: 3, top: 14.0, bottom: 9),
//                         child: Image.asset(
//                           'assets/images/Vector (12)search.png',
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(
//                 height: 20,
//               ),
//
//               // SizedBox(height: 100,),
//               // SizedBox(height: 200,),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 33.0),
//                   child: ListView.builder(
//                     // physics:  NeverScrollableScrollPhysics(),
//                     controller: _scrollController,
//                     itemCount: _documents.length + 1,
//                     itemBuilder: (context, index) {
//                       if (index == _documents.length) {
//                         return _isLoading
//                             ? Center(child: CircularProgressIndicator())
//                             : Center(child: Container()
//                         // Text('No more data')
//                         );
//                       }
//                       final DocumentSnapshot doc = _documents[index];
//                       final data = doc.data() as Map<String, dynamic>;
//                       var child = _documents[index];
//                       Timestamp? joinDateTimestamp = child['joinDateChild'] as Timestamp?;
//
//                       return Column(
//                         children: [
//                           Row(
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 0.0),
//                                 child:
//                                 CircleAvatar(
//                                   backgroundImage: AssetImage('assets/images/Group 237679 (2).png'),
//                                   radius: 25,
//                                 ),
//                                 // FutureBuilder(
//                                 //   future: FirebaseFirestore.instance
//                                 //       .collection('supervisor')
//                                 //       .doc(sharedpref!.getString('id'))
//                                 //       .get(),
//                                 //   builder: (BuildContext context,
//                                 //       AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
//                                 //     if (snapshot.hasError) {
//                                 //       return Text('Something went wrong');
//                                 //     }
//                                 //
//                                 //     if (snapshot.connectionState == ConnectionState.done) {
//                                 //       if (!snapshot.hasData ||
//                                 //           snapshot.data == null ||
//                                 //           snapshot.data!.data() == null ||
//                                 //           snapshot.data!.data()!['busphoto'] == null ||
//                                 //           snapshot.data!.data()!['busphoto'].toString().trim().isEmpty) {
//                                 //         return CircleAvatar(
//                                 //           radius: 25,
//                                 //           backgroundColor: Color(0xff442B72),
//                                 //           child: CircleAvatar(
//                                 //             backgroundImage: AssetImage('assets/images/Group 237679 (2).png'),
//                                 //             radius: 25,
//                                 //           ),
//                                 //         );
//                                 //       }
//                                 //
//                                 //       Map<String, dynamic>? data = snapshot.data?.data();
//                                 //       if (data != null && data['busphoto'] != null) {
//                                 //         return CircleAvatar(
//                                 //           radius: 25,
//                                 //           backgroundColor: Color(0xff442B72),
//                                 //           child: CircleAvatar(
//                                 //             backgroundImage: NetworkImage('${data['busphoto']}'),
//                                 //             radius: 25,
//                                 //           ),
//                                 //         );
//                                 //       }
//                                 //     }
//                                 //
//                                 //     return Container();
//                                 //   },
//                                 // ),
//                               ),
//                               const SizedBox(
//                                 width: 10,
//                               ),
//                               Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text('${_documents[index]['name'] ??
//                                       '' }',
//                                     style: TextStyle(
//                                       color: Color(0xFF442B72),
//                                       fontSize: 17,
//                                       fontFamily: 'Poppins-SemiBold',
//                                       fontWeight: FontWeight.w600,
//                                       height: 1.07,
//                                     ),
//                                   ),
//                                   SizedBox(
//                                     height: 5,
//                                   ),
//                                   Text(
//                                     // 'lll',
//                                     '${getJoinText(joinDateTimestamp)}',
//                                     style: TextStyle(
//                                       color: Color(0xFF0E8113),
//                                       fontSize: 13,
//                                       fontFamily: 'Poppins-Regular',
//                                       fontWeight: FontWeight.w400,
//                                       height: 1.23,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           SizedBox(
//                             height: 20,
//                           )
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//         resizeToAvoidBottomInset: false,
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//         floatingActionButton: FloatingActionButton(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(100)),
//             backgroundColor: Color(0xff442B72),
//             onPressed: () {
//               Navigator.of(context).push(MaterialPageRoute(
//                   builder: (context) => ProfileSupervisorScreen()));
//             },
//             child: Image.asset(
//               'assets/images/174237 1.png',
//               height: 33,
//               width: 33,
//               fit: BoxFit.cover,
//             )),
//         bottomNavigationBar: Directionality(
//             textDirection: Get.locale == Locale('ar')
//                 ? TextDirection.rtl
//                 : TextDirection.ltr,
//             child: ClipRRect(
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(25),
//                   topRight: Radius.circular(25),
//                 ),
//                 child: BottomAppBar(
//                     padding: EdgeInsets.symmetric(vertical: 3),
//                     height: 60,
//                     color: const Color(0xFF442B72),
//                     clipBehavior: Clip.antiAlias,
//                     shape: const AutomaticNotchedShape(
//                         RoundedRectangleBorder(
//                             borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(38.5),
//                                 topRight: Radius.circular(38.5))),
//                         RoundedRectangleBorder(
//                             borderRadius:
//                             BorderRadius.all(Radius.circular(50)))),
//                     notchMargin: 7,
//                     child: SizedBox(
//                         height: 10,
//                         child: SingleChildScrollView(
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.spaceAround,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               HomeForSupervisor()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(top: 7, right: 15)
//                                       : EdgeInsets.only(left: 15),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/Vector (7).png',
//                                           height: 20,
//                                           width: 20),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "Home".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               AttendanceSupervisorScreen()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(top: 9, left: 50)
//                                       : EdgeInsets.only(right: 50, top: 2),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/icons8_checklist_1 1.png',
//                                           height: 19,
//                                           width: 19),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "Attendance".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) =>
//                                               NotificationsParent()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(
//                                       top: 12, bottom: 4, right: 10)
//                                       : EdgeInsets.only(
//                                       top: 8, bottom: 4, left: 20),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/Vector (2).png',
//                                           height: 17,
//                                           width: 16.2),
//                                       Image.asset(
//                                           'assets/images/Vector (5).png',
//                                           height: 4,
//                                           width: 6),
//                                       SizedBox(height: 2),
//                                       Text(
//                                         "Notifications".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     Navigator.push(
//                                       context,
//                                       MaterialPageRoute(
//                                           builder: (context) => TrackParent()),
//                                     );
//                                   });
//                                 },
//                                 child: Padding(
//                                   padding:
//                                   (sharedpref?.getString('lang') == 'ar')
//                                       ? EdgeInsets.only(
//                                       top: 10,
//                                       bottom: 2,
//                                       right: 10,
//                                       left: 0)
//                                       : EdgeInsets.only(
//                                       top: 8,
//                                       bottom: 2,
//                                       left: 0,
//                                       right: 10),
//                                   child: Column(
//                                     children: [
//                                       Image.asset(
//                                           'assets/images/Vector (4).png',
//                                           height: 18.36,
//                                           width: 23.5),
//                                       SizedBox(height: 3),
//                                       Text(
//                                         "Buses".tr,
//                                         style: TextStyle(
//                                           fontFamily: 'Poppins-Regular',
//                                           fontWeight: FontWeight.w500,
//                                           color: Colors.white,
//                                           fontSize: 8,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )))))
//     );
//   }
// }
//