import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_account/controller/local.dart';
import 'package:school_account/screens/splashScreen.dart';
import 'package:school_account/supervisor_parent/screens/add_parents.dart';
import 'package:school_account/supervisor_parent/screens/attendence_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/home_supervisor.dart';
import 'package:school_account/supervisor_parent/screens/parents_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Functions/notifications.dart';
import 'controller/local_controller.dart';

SharedPreferences? sharedpref;
Future backgroundMessage(RemoteMessage message) async{
  print('background===========================================');
  print('${message.notification!.body}');
  print('background===========================================');

}

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'school_account',
    options: FirebaseOptions(
        apiKey: "AIzaSyDid2iv9pn1QZrPDCAbXGM7zTgcg6dWI1E",
        authDomain: "loginschoolaccount.firebaseapp.com",
        projectId: "loginschoolaccount",
        storageBucket: "loginschoolaccount.appspot.com",
        messagingSenderId: "615571135320",
        appId: "1:615571135320:web:38d8b8404aed2721dea32d",
        measurementId: "G-3YG0J7RYWM"
    ),
  );
  
  FirebaseMessaging.onBackgroundMessage(backgroundMessage );
  
  
  
  sharedpref = await SharedPreferences.getInstance();
  var token = await FirebaseMessaging.instance.getToken();
  var fcm = token.toString();
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

  }
  initMessaging();

  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    MyLocalController Controller = Get.put(MyLocalController());
    return GetMaterialApp(
      locale: Controller.intialLang,
      translations: MyLocal(),
      debugShowCheckedModeBanner: false,


     home:
     // HomeForSupervisor(),


      // home:SplashScreen(),
      // AttendanceSupervisorScreen(),
      // AddParents(),
      SplashScreen(),
    );
  }
}