import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:school_account/Functions/functions.dart';
import 'package:school_account/components/main_bottom_bar.dart';
import 'package:school_account/main.dart';
import 'package:school_account/screens/homeScreen.dart';
import 'package:school_account/screens/schoolData.dart';
import '../classes/loading.dart';
import '../components/elevated_simple_button.dart';
import '../supervisor_parent/screens/accept_invitation_parent.dart';
import '../supervisor_parent/screens/accept_invitation_supervisor.dart';
import '../supervisor_parent/screens/final_invitation_parent.dart';
import '../supervisor_parent/screens/final_invitation_supervisor.dart';
import '../supervisor_parent/screens/home_parent.dart';
import '../supervisor_parent/screens/home_supervisor.dart';
import '../supervisor_parent/screens/map_parent.dart';
import '../supervisor_parent/screens/no_invitation.dart';
//import '../components/main_bottom_bar.dart';

class OtpScreenLogin extends StatefulWidget {
  // const OtpScreenLogin({super.key});
  //new code
  final String verificationId;
  final String phoneNumer;

  OtpScreenLogin(
      {Key? key, required this.verificationId, required this.phoneNumer})
      : super(key: key);

  @override
  State<OtpScreenLogin> createState() => _OtpScreenLoginState();
}

class _OtpScreenLoginState extends State<OtpScreenLogin> {


  Timer? _timer; // Variable to store the timer
  int _seconds = 60;
  String verificationId = '';
  TextEditingController _pinCodeController = TextEditingController();
  String enteredPhoneNumber = '';
  bool _isLoading = false;
  bool timeout = false;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _phoneNumberEntered = false;
  String txt="Didn't receive the OTP".tr;
  // Function to start the timer
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--; // Decrement the seconds remaining
        } else {
          timeout = true;
          timer.cancel(); // Cancel the timer when countdown ends
          // You can perform any additional actions here when the timer ends
        }
      });
    });
  }

  // void _addDataToSupervisorFirestore() async {
  //   //if (_formKey.currentState!.validate()) {
  //   // Define the data to add
  //   Map<String, dynamic> data = {
  //     'name': widget.name,
  //     'phoneNumber': widget.phone,
  //   };
  //
  //   // Add the data to the Firestore collection
  //   await _firestore.collection('supervisor').add(data).then((docRef) {
  //     print('Data added with document ID: ${docRef.id}');
  //     // showSnackBarFun(context);
  //   }).catchError((error) {
  //     print('Failed to add data: $error');
  //   });
  // }

  @override
  void initState() {
    super.initState();
    verificationId = widget.verificationId;
    startTimer();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  // Future<void> verifyPhoneNumber(String phoneNumber) async {
  //   await _auth.verifyPhoneNumber(
  //     phoneNumber: phoneNumber,
  //     verificationCompleted: (PhoneAuthCredential credential) async {
  //       // Auto-retrieve verification code
  //       await _auth.signInWithCredential(credential);
  //
  //     },
  //     verificationFailed: (FirebaseAuthException e) {
  //       // Verification failed
  //     },
  //     codeSent: (String verificationId, int? resendToken) async {
  //       // Save the verification ID for future use
  //       String smsCode ='_pinCodeController' ; // Code input by the user
  //       PhoneAuthCredential credential = PhoneAuthProvider.credential(
  //         verificationId: verificationId,
  //         smsCode: smsCode,
  //       );
  //       // Sign the user in with the credential
  //       await _auth.signInWithCredential(credential);
  //       Navigator.push(context, MaterialPageRoute(builder: (context)=>SchoolData()));
  //     },
  //     codeAutoRetrievalTimeout: (String verificationId) {},
  //     timeout: Duration(seconds: 60),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFFFFFFF),
          body: LayoutBuilder(builder: (context, constrains) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constrains.maxHeight,
                minWidth: constrains.maxWidth,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage("assets/imgs/school/Group 237669.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: AlignmentDirectional.topStart,
                                child: InkWell(
                                  onTap: () => Navigator.pop(context),
                                  child: const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 23,
                                    color: Color(0xff442B72),
                                  ),
                                ),
                              ),

                              //Expanded(child: Container()),
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  'OTP'.tr,
                                  style: TextStyle(
                                    color: Color(0xFF442B72),
                                    fontSize: 25,
                                    fontFamily: 'Poppins-Bold',
                                    fontWeight: FontWeight.w700,
                                    height: 0.64,
                                  ),
                                ),
                              ),
                              //Expanded(child: Container())
                            ],
                          ),
                        ),
                        // Center(
                        //   child: Text(
                        //    'OTP'.tr,
                        //    style: TextStyle(
                        //      color: Color(0xFF442B72),
                        //      fontSize: 25,
                        //      fontFamily: 'Poppins-Bold',
                        //      fontWeight: FontWeight.w700,
                        //      height: 0.64,
                        //    ),
                        //                     ),
                        // ),
                        const SizedBox(
                          height: 35,
                        ),
                        Center(
                          child: Image.asset(
                            'assets/imgs/school/Rating 1.png',
                            width: constrains.maxWidth / 1.77,
                            height: constrains.maxWidth / 1.77,
                          ),
                        ),
                        Center(
                          child: Text(
                            'Enter Verification Code'.tr,
                            style: TextStyle(
                              color: Color(0xFF442B72),
                              fontSize: 19,
                              fontFamily: 'Poppins-SemiBold',
                              fontWeight: FontWeight.w600,
                              height: 0.84,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Text(
                            'You Receive SMS have Code'.tr,
                            style: TextStyle(
                              color: Color(0xFF442B72),
                              fontSize: 11,
                              fontFamily: 'Poppins-Regular',
                              fontWeight: FontWeight.w400,
                              height: 1.45,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        Column(
                          children: [
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                ),
                                child:
                                    //start
                                    PinCodeTextField(
                                      onChanged: (val){
                                        if(_phoneNumberEntered){
                                        _phoneNumberEntered =false;
                                        txt="Didn't receive the OTP".tr;

                                        setState(() {

                                        });}
                                      },
                                  controller: _pinCodeController,
                                  textStyle:  TextStyle(
                                    fontSize: 24,
                                    fontFamily: 'Inter-SemiBold',color: _phoneNumberEntered ?  Colors.red:Color(0xff001D4A)
                                  ),
                                  hintCharacter: '0',
                                  hintStyle:  TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 24,
                                      fontFamily: 'Inter-SemiBold',
                                      color: _phoneNumberEntered ?  Colors.red:Color(0xff8198A5)),
                                  appContext: context,
                                  length: 6,
                                  blinkWhenObscuring: true,
                                  animationType: AnimationType.fade,
                                  pinTheme: PinTheme(
                                      shape: PinCodeFieldShape.underline,
                                      fieldHeight: 50,
                                      fieldWidth: 40,
                                      activeFillColor: Colors.white,
                                      inactiveColor: _phoneNumberEntered ? Colors.red: Color(0xff8198A5),
                                      selectedColor:  _phoneNumberEntered ?Colors.red: Color(0xff001D4A),
                                      activeColor: _phoneNumberEntered ? Colors.red: Color(0xff8198A5),
                                      selectedFillColor: Colors.white),
                                  cursorColor: const Color(0xff001D4A),
                                  animationDuration:
                                      const Duration(milliseconds: 300),
                                  keyboardType: TextInputType.number,
                                ),

                                //end
                              ),
                            ),

                            Align(
                              alignment: AlignmentDirectional.topStart,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 30),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            //color: Colors.black, // Setting default text color to black
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: txt,
                                              style: TextStyle(
                                                  color:  _phoneNumberEntered ?  Colors.red:Color(0xff263238)),
                                            ),
                                            TextSpan(
                                              text: " Resend OTP?".tr,
                                              style: TextStyle(
                                                  color: timeout
                                                      ? Color(0xff442B72)
                                                      : Color(0xff9b9a9d)),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () async {
                                        if (timeout) {
                                          timeout = false;
                                          _seconds = 60;
                                          startTimer();
                                          setState(() {});
                                          await _auth.verifyPhoneNumber(
                                            phoneNumber: widget.phoneNumer,
                                            verificationCompleted:
                                                (PhoneAuthCredential
                                                    credential) async {
                                              // Auto-retrieve verification code
                                              //   await _auth.signInWithCredential(credential);
                                              //   Navigator.push(context,MaterialPageRoute(builder: (context)=>OtpScreen(verificationId: phoneNumber)) );
                                            },
                                            verificationFailed:
                                                (FirebaseAuthException e) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              // Verification failed
                                            },
                                            codeSent: (String verificationId,
                                                int? resendToken) async {
                                              // Save the verification ID for future use
                                              String smsCode =
                                                  'xxxxxx'; // Code input by the user
                                              setState(() {
                                                _isLoading = false;
                                              });
                                            },
                                            codeAutoRetrievalTimeout:
                                                (String verificationId) {},
                                            timeout: Duration(seconds: 60),
                                          );
                                        }
                                      },
                                    ),
                                    //Text("1 s".tr,style: TextStyle(fontSize: 12,fontFamily: 'Poppins',fontWeight: FontWeight.bold,color: Color(0xff263238)),)
                                    Text(
                                      '$_seconds s',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff263238)),
                                    ),
                                    // SizedBox(width: 55,),
                                    // Text("1 s".tr,style: TextStyle(fontSize: 12,fontFamily: 'Poppins',fontWeight: FontWeight.bold),
                                    // )
                                  ],
                                ),
                              ),
                              // Container(child: Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 20),
                              //   child: Text("Didn't receive the Otp".tr),
                              // ),
                              // ),
                            ),
                          ],
                        ),
                        Flexible(child: Container()),
                        Center(
                          child: SizedBox(
                            width: constrains.maxWidth / 1.4,
                            child: Center(
                              child: ClipRect(
                                child: ElevatedSimpleButton(
                                  txt: 'Verify'.tr,
                                  width: constrains.maxWidth / 1.4,
                                  color: timeout
                                      ? Color(0xff9b9a9d)
                                      : Color(0xFF442B72),
                                  hight: 48,
                                  onPress: () async {
                                    if (!timeout) {
                                      setState(() {
                                        _isLoading = true;
                                      });

                                      //erifyPhoneNumber(enteredPhoneNumber);
                                      //my code
                                      try {
                                        _phoneNumberEntered =false;
                                        txt="Didn't receive the OTP".tr;
                                        PhoneAuthCredential credential =
                                            PhoneAuthProvider.credential(
                                          verificationId: verificationId,
                                          smsCode: _pinCodeController.text,
                                        );
                                        // Sign the user in with the credential
                                        await _auth
                                            .signInWithCredential(credential);
                                        await sharedpref!
                                            .setString('type', loginType);
                                        await sharedpref!.setString('id', id);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => openPage()));
                                        // Navigator.pushReplacement(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (context) => sharedpref!
                                        //                     .getString('type')
                                        //                     .toString() ==
                                        //                 'schooldata'
                                        //             ? sharedpref!.getInt(
                                        //                         'allData') ==
                                        //                     1
                                        //                 ? HomeScreen()
                                        //                 : SchoolData()
                                        //             : sharedpref!
                                        //                         .getString(
                                        //                             'type')
                                        //                         .toString() ==
                                        //                     'parent'
                                        //                 ? sharedpref!.getInt(
                                        //                             'invit') ==
                                        //                         1
                                        //                     ? sharedpref!.getInt(
                                        //                                 'invitstate') ==
                                        //                             1
                                        //                         ? HomeParent()
                                        //                         : FinalAcceptInvitationParent()
                                        //                     : NoInvitation(
                                        //                         selectedImage:
                                        //                             3)
                                        //                 : sharedpref!.getInt(
                                        //                             'invit') ==
                                        //                         1
                                        //                     ? sharedpref!.getInt(
                                        //                                 'invitstate') ==
                                        //                             1
                                        //                         ? HomeForSupervisor()
                                        //                         : FinalAcceptInvitationSupervisor()
                                        //                     : NoInvitation(
                                        //                         selectedImage:
                                        //                             2)));
                                      } catch (e) {
                                        setState(() {
                                          _isLoading = false;
                                          _phoneNumberEntered =true;
                                          txt="Invalid OTP".tr;

                                        });


                                      }

                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) => MainBottomNavigationBar(
                                      //           pageNum: 0,
                                      //         )));
                                    }
                                  },
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 44,
                        ),
                      ],
                    ),
                  ),
                  //loader
                  (_isLoading == true)
                      ? const Positioned(top: 0, child: Loading())
                      : Container(),
                ],
              ),
            );
          })),
    );
  }
  StatefulWidget openPage() {
    if(sharedpref!.getString('type').toString() == 'schooldata'){
      if(sharedpref!.getInt('allData') == 1)
        return HomeScreen();
      else return SchoolData();
    }else if(sharedpref!.getString('type').toString() == 'parent'){
      if( sharedpref!.getInt('invit') == 0 ){
        if(sharedpref!.getInt('skip') == 1)
          return HomeParent();
        else
          return NoInvitation(selectedImage: 3);

      }else{
        if(sharedpref!.getInt('invitstate') == 1){
          if (sharedpref!.getInt('address') == 1)
            return  HomeParent();
          else
            return  MapParentScreen();


        }
        else
          return  AcceptInvitationParent();
      }
    }else{
      if( sharedpref!.getInt('invit') == 0 ){
        if(sharedpref!.getInt('skip') == 1)
          return  HomeForSupervisor();
        else
          return   NoInvitation(selectedImage: 2);

      }else{
        if(sharedpref!.getInt('invitstate') == 1)
          return   HomeForSupervisor();
        else
          return   AcceptInvitationSupervisor();
      }
    }





  }
}
