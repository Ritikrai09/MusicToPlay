import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Auth/Forget_password/reset_password.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';

import '../../../../Utils/color_util.dart';
import 'package:pinput/pinput.dart';
import '../../../../Utils/custom_toast.dart';
import '../../../../controller/repository.dart';
import '../../../../controller/user_controller.dart';
import '../../../widgets/button.dart';

class OtpScreen extends StatefulWidget {
 final String mail;

  const OtpScreen({super.key,this.mail="mail@gmail.com"});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {

int remainingTime = 60;
Timer? timer;
late UserProvider userProvider;
 String d1='',d2='',d3='',d4='';
  bool isLoad=false;

  @override
  void initState() {
    super.initState();
    userProvider = UserProvider();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      if (mounted) {
    setState(() {
      remainingTime--;
    });
  
  if (remainingTime == 0) {
    timer.cancel();
  } 
  //else {
  //   print("Time's up!");
  // }
}
    });
  }


 @override
  void dispose() {
     timer!.cancel();
    super.dispose();
  }

  var controller = TextEditingController();
 var controller2 = TextEditingController();
  var controller3 = TextEditingController();
   var controller4 = TextEditingController();
   var controller5 = TextEditingController();

   FocusNode focus=FocusNode(),
   focus1=FocusNode(),
   focus2=FocusNode(),
   focus3=FocusNode(),
   focus4=FocusNode();

  bool isPop = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
   var otp = json.decode(emailData.toString())['data']['otp'];


    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async{
         exitotp(context);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          // padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 6),
          child: Form(
            // key: userProvider.resetFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BackbUT(
                        onTap: () {
                            exitotp(context);
                        },
                      ),
                  ]),
                ),
                const Spacer(),
                Image.asset('asset/Images/Logo/splash_logo.png',width: 100,height: 100),
                 const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text( allMessages.value.otp ?? 'Verify OTP',
                         style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: dark(context)?Colors.white : Colors.black,
                          letterSpacing: 0.5
                         )
                      ),
                ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(  allMessages.value.otpDescription  ?? 'Please enter the code we just sent to ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w500,
                           )
                        ),
                        const SizedBox(height: 4),
                           Text(widget.mail,
                            textAlign: TextAlign.center,
                             style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor
                           ))
                      ],
                    ),
                  ),
                    const SizedBox(height: 50),
                    Container(
                      width:size.width,
                      height: 60,
                       padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: otppinfields())
                    // SizedBox(
                    //   width:size.width,
                    //   child: Row(
                    //     mainAxisAlignment:MainAxisAlignment.spaceEvenly,
                    //     children: [
                    //       Expanded(
                    //         flex: 1,
                    //         child: Container(
                    //           height: 60,
                    //           padding: const EdgeInsets.all(4.0),
                    //           child: TextFormField(
                    //             textAlign: TextAlign.center,
                    //             onChanged: (value) {
                    //             if (value.length == 1) {
                    //                setState(() { 
                    //                  d1 = value.toString();
                    //                  });
                    //               FocusScope.of(context).nextFocus();
                    //             } else {
                    //                setState(() { 
                    //                   d1 ='';
                    //                });
                    //               FocusScope.of(context).previousFocus();
                    //             }},
                    //             focusNode: focus,
                    //               style: textStyle,
                    //             decoration: InputDecoration(
                    //               counterText: '',
                            
                    //               enabledBorder: OutlineInputBorder(
                    //                  borderSide: BorderSide(width: 1,color: Theme.of(context).dividerColor),
                    //                 borderRadius: BorderRadius.circular(12)
                    //               ),
                    //               border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(12)
                    //               ),
                    //             ),
                    //             maxLength: 1,
                    //             keyboardType:  TextInputType.number,
                    //             controller: controller,
                                 
                    //           ),
                    //         ),
                    //       ),
                    //      Expanded(
                    //       flex: 1,
                    //         child: Container(
                    //           height: 60,
                    //           padding: const EdgeInsets.all(4.0),
                    //           child: TextFormField(
                    //             textAlign: TextAlign.center,
                    //             onChanged: (value) {
                    //             if (value.length == 1) {
                    //                  setState(() { 
                    //                     d2 = value.toString();
                    //                  });
                    //               FocusScope.of(context).nextFocus();
                    //             } else {
                    //               setState(() { 
                    //                   d2 ='';
                    //                });
                    //               FocusScope.of(context).previousFocus();
                    //             }},
                    //             focusNode: focus1,
                    //             style: textStyle,
                    //             decoration: InputDecoration(
                    //               counterText: '',
                    //                enabledBorder: OutlineInputBorder(
                    //                  borderSide: BorderSide(width: 1,color: Theme.of(context).dividerColor),
                    //                 borderRadius: BorderRadius.circular(12),
                    //                ),
                    //                  border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(12)
                    //               ),
                    //             ),
                    //             maxLength: 1,
                    //             keyboardType:  TextInputType.number,
                    //             controller: controller2,
                                
                    //           ),
                    //         ),
                    //       ),
                    //      Expanded(
                    //       flex: 1,
                    //         child: Container(
                    //           height: 60,
                    //           padding: const EdgeInsets.all(4.0),
                    //           child: TextFormField(
                    //             textAlign: TextAlign.center,
                    //             onChanged: (value) {
                    //             if (value.length == 1) {
                    //                 setState(() { 
                    //                     d3 = value.toString();
                    //                  });
                    //               FocusScope.of(context).nextFocus();
                    //             } else {
                    //                setState(() { 
                    //                   d3 ='';
                    //                });
                    //               FocusScope.of(context).previousFocus();
                    //             }},
                    //             focusNode: focus2,
                    //              style: textStyle,
                    //             decoration: InputDecoration(
                    //               counterText: '',
                    //                enabledBorder: OutlineInputBorder(
                    //                  borderSide: BorderSide(width: 1,color: Theme.of(context).dividerColor),
                    //                 borderRadius: BorderRadius.circular(12)
                    //                ),
                    //                  border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(12)
                    //               ),
                    //             ),
                    //             maxLength: 1,
                    //             keyboardType:  TextInputType.number,
                    //             controller: controller3,
                                
                    //           ),
                    //         ),
                    //       ),Expanded(
                    //         flex: 1,
                    //         child:Container(
                    //           height: 60,
                    //           padding: const EdgeInsets.all(4.0),
                    //           child: TextFormField(
                    //             textAlign: TextAlign.center,
                    //             onChanged: (value) {
                    //               if (value.length == 1) {
                    //                   setState(() { 
                    //                     d4 = value.toString();
                    //                  });
                    //                 FocusScope.of(context).nextFocus();
                    //               } else {
                    //                  setState(() { 
                    //                     d4 ='';
                    //                  });
                    //                 FocusScope.of(context).previousFocus();
                    //               }},
                    //             focusNode: focus4,
                    //             decoration: InputDecoration(
                    //               counterText: '',
                    //                enabledBorder: OutlineInputBorder(
                    //                  borderSide: BorderSide(width: 1,color: Theme.of(context).dividerColor),
                    //                 borderRadius: BorderRadius.circular(12)
                    //                ),
                    //                  border: OutlineInputBorder(
                    //                 borderRadius: BorderRadius.circular(12)
                    //               ),
                    //             ),
                    //             maxLength: 1,
                    //             keyboardType:  TextInputType.number,
                    //             controller: controller4,
                    //              style: textStyle,
                    //           ),
                    //         ),
                    //       ),
                          // Expanded(
                          //   flex: 1,
                          //   child:Padding(
                          //     padding: const EdgeInsets.all(4.0),
                          //     child: TextFormField(
                          //       textAlign: TextAlign.center,
                          //       onChanged: (value) {
                          //         if (value.length == 1) {
                          //          setState(() { 
                          //            userProvider.user.otp += value.toString();
                          //            });
                          //           FocusScope.of(context).nextFocus();
                          //         } else {
                          //           FocusScope.of(context).previousFocus();
                          //       }},
                          //       focusNode: focus3,
                          //        style: textStyle,
                          //       decoration: InputDecoration(
                          //         counterText: '',
                          //          enabledBorder: OutlineInputBorder(
                          //            borderSide: BorderSide(width: 1,color: Theme.of(context).dividerColor),
                          //           borderRadius: BorderRadius.circular(12)
                          //          ),
                          //            border: OutlineInputBorder(
                          //           borderRadius: BorderRadius.circular(12)
                          //         ),
                          //       ),
                          //       maxLength: 1,
                          //       keyboardType:  TextInputType.number,
                          //       controller: controller5,
                          //        validator: (v) {
                          //         if (v!.isEmpty && v.length < 5) {
                          //           return allMessages.value.enterAValidOtp ?? 'Enter 5 digits';
                          //         }
                          //         return null;
                          //       },
                          //       onSaved: (v) {
                          //         setState(() {
                          //           userProvider.user.otp += v.toString();
                          //         });
                          //       },
                          //     ),
                          //   ),
                          // ),
                    //     ],
                    //   ),
                    // ),
                    ,
                    const SizedBox(height: 16),
                    Padding(
                       padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           RichText(
                            text: TextSpan(
                              text:  isLoad == true ? 
                              allMessages.value.loadingOTP ?? 'Preparing OTP...' :
                              remainingTime == 0 ?  allMessages.value.resendCode?? 'Resend Code ?' : 
                               "${allMessages.value.resendCodeIn} ",
                               
                               style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w500,
                                height: 1.2,
                             ),
                               children: [
                                WidgetSpan(child:  isLoad == true  ? const SizedBox() :  GestureDetector(
                                onTap: () {
                                  userProvider.user.email= widget.mail;
                                  isLoad = true;
                                  setState(() {   });
                                  forgetPassword(userProvider.user,context).then((value) {
                                       if (value == true) {
                                         remainingTime = 60;
                                         userProvider.user.otp ='';
                                         startTimer();
                                         isLoad=false;
                                         showCustomToast(context,allMessages.value.otpSent ?? 'OTP sent');
                                         setState(() {});
                                       }
                                  });
                                },
                                   child:  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                   children: [
                                     Container(
                                      width:  remainingTime == 0 ? null :20,
                                       alignment: Alignment.centerLeft,
                                       child: Text(remainingTime == 0 ? "  ${allMessages.value.sendAgain ??'Send Again'}" :
                                       remainingTime == 60  ? '1 : ' : '0 : ',
                                        textAlign: TextAlign.left,
                                         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                         height: 1.25,
                                        color: Theme.of(context).primaryColor
                                       )),),
                                       if(remainingTime != 0)
                                       Container(
                                      width: remainingTime == 0 ? 50 :30,
                                      alignment: Alignment.centerLeft,
                                       child: Text( remainingTime == 0 ? '' : remainingTime == 60  ? '00' : remainingTime < 10  ? ' 0$remainingTime' :' $remainingTime',
                                        textAlign: TextAlign.center,
                                         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.w600,
                                           height: 1.25,
                                        color: Theme.of(context).primaryColor
                                       ))
                                     ),
                                   ],
                                 ),
                               ))
                               ]
                           ))
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Button(
                      edgePadding: const EdgeInsets.symmetric(horizontal: 24),
                      onTap: ()async {
                       userProvider.user.otp = _enterOtp.text;
                       setState(() {  });
            
                       if(remainingTime == 0){
                            showCustomToast(context,  allMessages.value.otpExpired  ?? 'OTP is expired');
                          }else if (userProvider.user.otp == otp.toString()) {
                             showCustomToast(context,  allMessages.value.otpVerified  ??'OTP verified');
            
                            Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => ResetPassword(mail:widget.mail,isReset: true)));
            
                          }else if(userProvider.user.otp.length == 4 && userProvider.user.otp != otp.toString()){
                            showCustomToast(context, allMessages.value.invalidOtpEntered  ?? 'Invalid OTP');
                          }else{
                            showCustomToast(context,  allMessages.value.enterAValidOtp  ??'Enter 4 digits');
                          }
                          // userProvider.resetPass(context,widget.mail,onChanged: (value) {
                            
                          // }).then((value) {
                          //   remainingTime=60;
                          //   setState(() {});
                          // });
                        
                    },tittle:  allMessages.value.otpButton ?? 'Continue'),
                    if(kDebugMode)
                    Text('otp for testing : $otp',style: const TextStyle(fontSize: 12,height: 2)),
                    const Spacer(flex: 4)
              ],
            ),
          ),
        ),
      ),
    );
  }

  void exitotp(BuildContext context) {
     showCustomDialog(context: context,
    title: allMessages.value.exitOtp ?? "EXIT",
    text: allMessages.value.exitmessageotp ?? "EXIT OTP",
    onTap: () {
      Navigator.pop(context);
      Navigator.pop(context);
    },
    isTwoButton: true
   );
  }
 final TextEditingController _enterOtp = TextEditingController();
final _pinPutFocusNode = FocusNode();

Widget otppinfields(){
 final PinTheme pinPutDecoration = PinTheme(
   textStyle: const TextStyle(fontFamily: 'QuickSand',
   fontSize: 18,fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
      color: Theme.of(context).brightness != Brightness.light
          ? const Color.fromRGBO(50,50,50,1)
          : Colors.grey.shade200,
      borderRadius: BorderRadius.circular(12.0),
    ));
final PinTheme focusedDecoration = PinTheme(
  textStyle:  TextStyle(fontFamily: 'QuickSand',
  fontSize: 18,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),
      decoration: BoxDecoration(

      color: Theme.of(context).brightness != Brightness.light
          ? const Color.fromRGBO(50,50,50,1)
          : Colors.grey.shade200,
      border: Border.all(width: 1.5,color: dark(context) ? Colors.white 
      : Theme.of(context).primaryColor),
      borderRadius: BorderRadius.circular(12.0),
    ));
return Pinput(
      isCursorAnimationEnabled: true,
      length: 4,
      focusNode: _pinPutFocusNode,
      controller: _enterOtp,
      submittedPinTheme: pinPutDecoration,
      focusedPinTheme:focusedDecoration,
      onChanged: (value) {
        setState(() { 
        userProvider.user.otp = value;
        });
      },
      autofocus: true,
      autofillHints:const [AutofillHints.oneTimeCode],
      followingPinTheme: pinPutDecoration,
      pinAnimationType: PinAnimationType.scale,
      defaultPinTheme:pinPutDecoration ,
      errorTextStyle:TextStyle(color : dark(context) ?  Colors.red : Colors.black,
       fontSize: 20.0),
    );
}
}

// class OtpWrap extends StatefulWidget {
//   const OtpWrap({super.key});

//   @override
//   State<OtpWrap> createState() => _OtpWrapState();
// }

// class _OtpWrapState extends State<OtpWrap> {
//   TextEditingController otp1 = TextEditingController();
//   TextEditingController otp2 = TextEditingController();
//   TextEditingController otp3 = TextEditingController();
//   TextEditingController otp4 = TextEditingController();
//   TextEditingController otp5 = TextEditingController();

//   @override
//   void dispose() {
//     otp1.dispose();
//     otp2.dispose();
//     otp3.dispose();
//     otp4.dispose();
//     otp5.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               OtpInput(
//                 controller: otp1,
//                 autoFocus: true,
//                  onvalidate: (p0) {
//                   return null;
//                 },
//               ),
//               OtpInput(
//                 controller: otp2,
//                 autoFocus: false,
//                 onvalidate: (p0) {
//                   return null;
//                 },
//                 onsaved: (p0) {
//                   setState(() {});
//                 },
//               ),
//               OtpInput(
//                 controller: otp3,
//                 autoFocus: false,
//                 onvalidate: (p0) {
//                   return null;
//                 },
//               ),
//               OtpInput(
//                 controller: otp4,
//                 onvalidate: (v) {
//                   if (v != null) {
//                     if (v.isEmpty) {
//                       return '';
//                     }
//                   }

//                   return null;
//                 },
//                 onsaved: (value) {
//                   setState(() {});
//                 },
//                 autoFocus: false,
//                    ),
//               OtpInput(
//                 controller: otp5,
//                 onvalidate: (v) {
//                   if (v != null) {
//                     if (v.isEmpty) {
//                       return '';
//                     }
//                   }

//                   return null;
//                 },
//                 onsaved: (value) {
//                   setState(() {});
//                 },
//                 autoFocus: false,
//               ),
//             ],
//           ),
//         ) ]);
//   }}
