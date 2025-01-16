
import 'dart:convert';
import 'dart:io';

import 'package:blogit/Utils/image_downloader_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import '../presentation/screens/Auth/Forget_password/otp.dart';
import '../presentation/screens/Prelog/select_interest.dart';
import '../Utils/app_theme.dart';
import '../Utils/custom_toast.dart';
import '../Utils/urls.dart';
import 'app_provider.dart';
import 'repository.dart' as repository;
import '../main.dart';
import '../model/cms.dart';
import '../model/lang.dart';
import '../model/messages.dart';
import '../model/settings.dart';
import '../model/user.dart';

ValueNotifier<Messages> allMessages = ValueNotifier(Messages());
ValueNotifier<SettingModel> allSettings = ValueNotifier(SettingModel());
ValueNotifier<Users> currentUser = ValueNotifier(Users());
ValueNotifier<List<SocialMedia>> socialMedia = ValueNotifier([]);
ValueNotifier<double> defaultFontSize = ValueNotifier(14.0);
ValueNotifier<int> defaultAdsFrequency = ValueNotifier(3);
List<Language> allLanguages = [];
List<CmsModel> allCMS = [];
ValueNotifier<Language> languageCode =
    ValueNotifier(Language(id: 1,name: 'English', language: 'en',pos: 'ltr'));
String? emailData;

class UserProvider {
  final bool _isLoggedIn = false;
  Users user = Users();
  final bool _isLoading=false;
  bool get isLoggedIn => _isLoggedIn;
  GlobalKey<FormState>? loginFormKey,otpFormKey;
  GlobalKey<FormState>? updateFormKey,contactFormKey;
  GlobalKey<FormState>? signupFormKey;
  GlobalKey<FormState>? forgetFormKey;
  GlobalKey<FormState>? resetFormKey; 
   GlobalKey<FormState>? changeFormKey; 
 // fire.FirebaseMessaging? _firebaseMessaging;
final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile'
    ],
  );
  
UserProvider(){
    loginFormKey = GlobalKey<FormState>();
    updateFormKey = GlobalKey<FormState>();
    signupFormKey = GlobalKey<FormState>();
    contactFormKey= GlobalKey<FormState>();
    forgetFormKey = GlobalKey<FormState>();
    resetFormKey = GlobalKey<FormState>();
    otpFormKey  = GlobalKey<FormState>();
    changeFormKey = GlobalKey<FormState>();
    
    // _firebaseMessaging = fire.FirebaseMessaging.instance;
    // _firebaseMessaging?.getToken().then((String? _deviceToken) {
    //   // user.deviceToken = getOnesignalUserId();
    // }).catchError((e) {
    //   debugPrint('Notification not configured');
    // });
}




Future<dynamic> setContact(String text,String email,String message) async {
  try {
  if (contactFormKey!.currentState!.validate()) {
    contactFormKey!.currentState!.save();
    final msg = jsonEncode({
     "name": text,
     "email": email,
     "message": message
  });
  
  final String url = '${Urls.baseUrl}submit-query';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  // print(decode.toString());
  

  if (decode['success'] == true) {
    
    return decode;
  } 
  return decode;
  }
} on Exception catch (e) {
    // print(e.toString());
    throw Exception(e);
}
}

 getLanguageFromServer(BuildContext context) async {
    
  await checkUpdate(route: 'localisation-list?language_id=${languageCode.value.id}',
  etag: 'localisation-etag').then((value) async{
     if (value == true) {
      
     } else {
        await repository.getLocalText(context).then((value) {
        if (value != null) {
          allMessages.value = value;
        }
      }).catchError((e,stackTrace) {
      }).whenComplete(() {});
     }
    });
  }


  getAllAvialbleLanguages(BuildContext context) async {

    await checkUpdate(route: 'language-list',etag: 'lang-etag').then((value) async{
     if (value == false) {
      await repository.getAllLanguages(context).then((value) {
      allLanguages = value;
    }).catchError((e) {
    }).whenComplete(() {});
      }
    });
  }

    socialMediaList() async {
      await repository.socialMediaList2().then((value) {
       if (value.isNotEmpty) {
          socialMedia.value = value;
       }
    });
  }

  Future<bool?> checkUpdate({String route = 'setting-list',String etag='setting-etag'}) async{
   if (prefs!.containsKey('local_data')) {
      prefs = await SharedPreferences.getInstance();
   try {
      final response = await http.head(Uri.parse('${Urls.baseUrl}$route'));
    var eTag = response.headers['ETag']; 
    var prefTag = prefs!.containsKey(etag) ? prefs!.getString(etag) : '';
  
    if ((prefTag !=''|| prefTag !=null) && eTag != prefTag) {
       prefs!.setString(etag,eTag.toString());
      
      return false;
    } else if (prefTag == ''|| prefTag == null) {
      return false;
    } else { 
      return true;
    }
   } catch ( e) {
    //  debugPrint(e.toString());
    throw Exception(e);
   }
   }else{
     return false;
   }
   
  }

Future<void> checkSettingUpdate() async {
  // Send a HEAD request to retrieve the etag header
  //    await checkUpdate().then((etag) async{
  //  try {
  //   if (etag == true) {
  //       getMessageAndSetting();
  //   } else {
     try {
  final conditionalResponse = await http.get(
  Uri.parse('${Urls.baseUrl}setting-list'),
   headers:{ 
   HttpHeaders.contentTypeHeader: 'application/json',
   "language-code" : languageCode.value.language ?? '',
   },
      );
  var res = json.decode(conditionalResponse.body);
      // print(res.toString());
  if (res['success'] == true) {
    allSettings.value = SettingModel.fromJson(res['data']);
    appThemeModel.value.primaryColor.value = hexToRgb(allSettings.value.primaryColor);
    prefs!.setString('setting',json.encode(res['data']));

      await ImageDownloader.getImageFile(prefs!.containsKey('splash_logo') ? prefs!.getString('splash_logo') ?? "" : "noimage.png",
       imagefileName: "${allSettings.value.appSplashScreen}",
      url:"${allSettings.value.baseImageUrl}/${allSettings.value.appSplashScreen}", localName: 'splash_logo');
     
      await ImageDownloader.getImageFile(
        prefs!.containsKey('app_logo') ? prefs!.getString('app_logo') ?? "" : "noimage2.png",
       imagefileName: "${allSettings.value.appLogo}",
        url:"${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}", localName: 'app_logo');
     
     
     await ImageDownloader.getImageFile(prefs!.containsKey('rect_logo') ? prefs!.getString('rect_logo') ?? "" : "noimage3.png",
       imagefileName: "${allSettings.value.rectangualrAppLogo}",
      url:"${allSettings.value.baseImageUrl}/${allSettings.value.rectangualrAppLogo}", localName: 'rect_logo');
     
   }
 } on Exception catch (e) {
    // print(e.toString());
    throw Exception(e);
  }
//}
   
  //  } catch ( e,stackTrace) {
  //   debugPrint(stackTrace.toString());
  //  }
   // } );
  // Check the response status code
}



  void appleLogin(BuildContext context,{List<Scope> scopes = const [Scope.email, Scope.fullName],ValueChanged? onChanged}) async {
   
     onChanged!(true);
      try {
        // 1. perform the sign-in request
        final result = await TheAppleSignIn.performRequests(
            [AppleIdRequest(requestedScopes: scopes)]);
        // 2. check the result
        switch (result.status) {
          case AuthorizationStatus.authorized:
            final appleIdCredential = result.credential;
           // final oAuthProvider = OAuthProvider('apple.com');
            /*   final credential = oAuthProvider.credential(
            idToken: String.fromCharCodes(appleIdCredential.identityToken),
            accessToken:
                String.fromCharCodes(appleIdCredential.authorizationCode),
          );*/

            Map<String, dynamic> resultData = {
              "name": (appleIdCredential?.fullName?.givenName ?? "") +
                  (appleIdCredential?.fullName?.familyName ?? ""),
              "email": appleIdCredential?.email,
              "image": "",
              "apple_token": appleIdCredential?.user,
            };

            repository.appleLogin(resultData,context).then((value) async {
              var provider = Provider.of<AppProvider>(context, listen: false);
               if (value != null) {
              if (currentUser.value.isNewUser == true) {
                provider.addUserSession(isSocialSignup: true);
                showCustomToast(context, 'You are Signed-up successfully');
                Navigator.pushNamedAndRemoveUntil(context,'/SaveInterests',(route) => false,arguments: false);
              } else {
                provider.addUserSession(isSocialSignup: false);
                 showCustomToast(context, 'You are logged-in successfully');
                provider.getCategory().whenComplete(() {
                    onChanged(false);
                    Navigator.pushNamedAndRemoveUntil(context,'/MainPage',(route) => false,arguments: 1);
                  });
              }
          }
            }).catchError((e) {
               onChanged(false);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(allMessages.value.emailNotExist.toString()),
              ));
            }).whenComplete(() {
             
            });
            break;
          case AuthorizationStatus.error:
         onChanged(false);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result.error.toString()),
            ));
            break;

          case AuthorizationStatus.cancelled:
           onChanged(false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Sign in aborted by user'),
            ));
            break;
          default:
             onChanged(false);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Something went wrong'),
            ));
            break;
        }
      } catch (e) {
        onChanged(false);
        throw Exception(e);
        // BotToast.showCustomText(toastBuilder: (void Function() cancelFunc) {
        //   return Container(height: 10,width: double.infinity,color: Colors.red,);
        // });
      }
    
  }


Future googleLogin(BuildContext context,{required ValueChanged onChanged }) async {
       onChanged(true);
       var provider  = Provider.of<AppProvider>(context,listen: false); 
      try {
        GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
        repository.googleLogin(googleSignInAccount!,user,context).then((Users? value) async {
          if (value != null) {
              if (currentUser.value.isNewUser == true) {
                showCustomToast(context, 'You are Signed-up successfully');
                provider.addUserSession(isSocialSignup: true);
                Navigator.pushAndRemoveUntil(context,CupertinoPageRoute(
                  builder: (context) => const SelectInterest()),(route) => false);
              } else {
                showCustomToast(context, 'You are logged-in successfully');
                provider.addUserSession(isSocialSignup: false);
                provider.getCategory().whenComplete(() {
                  onChanged(false);
                   Navigator.pushAndRemoveUntil(context,CupertinoPageRoute(
                   builder: (context) => const HomeWrapper(isInitial: true)),(route) => false);
                  });
              }
          }
        }).catchError((e) {
            onChanged(false);
        }).whenComplete(() {
      });
      } catch (e) {
        onChanged(false);
      }
  
  }
  
  Future<void> signin(BuildContext context,{required ValueChanged onChanged}) async {
    // if (user.password != "") {
        if (loginFormKey!.currentState!.validate()) {
          loginFormKey!.currentState!.save();
          repository.signin(user,context).then((value) async {
            var provider = Provider.of<AppProvider>(context, listen: false);
            // await provider.getLatestBlog();

            if (value != null) {
              provider.addUserSession(isSignin: true);
               showCustomToast(context, 'You are logged in successfully');
               provider.getCategory().whenComplete(() {
                 onChanged(false);
                 Navigator.push(context,MaterialPageRoute(builder: (context) => const HomeWrapper()));
               });
            } else {
              onChanged(false);
            }
          }).catchError((e) {
            onChanged(false);
            showCustomToast(context, e.toString());
            
          }).whenComplete(() {
          });
        } else {
            onChanged(false);
        }
    
  }
   
  Future<void> signup(BuildContext context,{ required ValueChanged onChanged }) async {
    if (signupFormKey!.currentState!.validate()) {
        signupFormKey!.currentState!.save();
        
        repository.register(user,context).then((value) {
          var provider = Provider.of<AppProvider>(context,listen: false);
          if (value != null && value.apiToken != null) {
            provider.clearLists();
             provider.addUserSession(isSignup: true);
            showCustomToast(context, 'Signup successfully done',isSuccess: true,islogo: false);
            Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) => const SelectInterest()),(route) => false);
          } else {  
            onChanged(false);
            }
          }).catchError((e) {
              onChanged(false);
              showCustomToast(context, e.toString() ?? allMessages.value.emailNotExist.toString());
        }).whenComplete(() {
            onChanged(false);
        });
      }else{
         onChanged(false);
      }
  }


  void forgetPassword(BuildContext context,{required ValueChanged onChanged}) async {
    
      try {
  if (forgetFormKey!.currentState!.validate()) {
     onChanged(true);
    forgetFormKey!.currentState!.save();
    repository.forgetPassword(user, context).then((value) async {
      if (value==true) {
         onChanged(false);
        showCustomToast(context, allMessages.value.otpSent ?? "OTP sent to your email address",);
         Navigator.push(context,MaterialPageRoute(builder:
         (context) =>  OtpScreen(mail: user.email.toString(),))); 
      } else {
        // print("else ");
        onChanged(false);
      }
    }).whenComplete(() {
       onChanged(false);
    });
     }
   }on SocketException{
       onChanged(false);
    } on Exception catch (e) {
       onChanged(false);
      // debugPrint(e.toString());
      throw Exception(e);
    }
  
  }

   getCMS(BuildContext context) async {
    await checkUpdate(route: 'cms-list',etag: 'cms-etag').then((value) async{
    // if (value == false) {
      await repository.getCMS().then((value) {
         allCMS = value;
     }).catchError((e) {
      //  debugPrint(e);
     }).whenComplete(() {});
    // } 
   });
  }

  Future resetPass(BuildContext context, String email,{required  ValueChanged onChanged }) async {
   
      if (resetFormKey!.currentState!.validate()) {
        resetFormKey!.currentState!.save();
        repository.resetPassword(user,context, email).then((value) async {
          if (value != null && value == true) {
            onChanged(false);
            Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:
             (context) => Login(prefilled: true,email:email)),(route) => false);
          } else {
            onChanged(false);
            //showCustomToast(context, "Something went wrong",);
          }
        }).whenComplete(() {
           onChanged(false);
        });
      }
    
  }

  

  void profile(BuildContext context,{required ValueChanged onChanged}) async {
      if (updateFormKey!.currentState!.validate()) {
        updateFormKey!.currentState!.save();
         onChanged(true);
        repository.update(user, context).then((value) {
          if (value != null && value.apiToken != null) {
            onChanged(false);
             currentUser.value  = value;
             showCustomToast(context,allMessages.value.profileUpdatedSuccessfully ?? 'Profile updated successfully');
             Navigator.pop(context);
          }
        }).catchError((e) {
          onChanged(false);
          showCustomToast(context,'Something went wrong!!');
        }).whenComplete(() {
          onChanged(false);
        });
      }
  }

  void updateLanguage(BuildContext context) async {
      repository.updateLanguage().then((value) {
        if (value != null && value.apiToken != null) {
        
          showCustomToast(context,allMessages.value.profileUpdated.toString());
        }
      }).catchError((e) {
        // debugPrint(e);
      }).whenComplete(() {});
    }


  void changePassword(BuildContext context,{
      required String conPass,
      required String newPass,
      required String oldPass,
      required ValueChanged onChanged}) async {
     
      if (changeFormKey!.currentState!.validate()) {
        changeFormKey!.currentState!.save();
        onChanged(true);
      if (oldPass.isNotEmpty) {
      //  if(newPass != conPass) {
        onChanged(false);
      //    showCustomToast(context, allMessages.value.newpasswordAndConfirmPasswordNotSame ??'New password can\'t be same as the old password.'); 
     
     if (newPass == conPass && conPass == oldPass && newPass == oldPass) {
        showCustomToast(context,allMessages.value.newPasswordOldPasswordNotSame ??'New password can\'t be same as the old password.');
      } else {
       repository.changePassword(context,
              oldPass: oldPass, newPass: newPass, conPass: conPass)
          .then((value) {
              onChanged(false);
              
         if (value['success'] == false ) {
            showCustomToast(context,value['message']);
         } 
             else {
               showCustomToast(context,value['message']);
               Navigator.pop(context);
          
         }
          }).catchError((e) {
            
             onChanged(false);
            showCustomToast(context,allMessages.value.somethingWentWrong ?? 'Something went wrong!!');
      }).whenComplete(() {
         onChanged(false);
      });
      }
      } else if (oldPass.isEmpty) {
        onChanged(false);
          showCustomToast(context, 'Old Password is Empty');
       } 
      }
  }

void logout(BuildContext context)async{
  var provider = Provider.of<AppProvider>(context,listen: false);
  showCustomDialog(context: context,title:allMessages.value.signOut  ??  'Sign Out',
      text:  allMessages.value.doYouWantSigOut  ?? 'Do you want to sign out ?',
    isTwoButton:true,
    onTap: () async {
        provider.clearLists();
        provider.addUserSession(isSignup: false,isSocialSignup: true );
        provider.getAnalyticData();
        prefs!.remove('current_user');
        prefs!.remove('bookmarks');
        prefs!.remove('isBookmark');
        
        _googleSignIn.signOut();
        currentUser.value = Users();
        await Future.delayed(const Duration(milliseconds: 100));
        Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder:(context) => const Login(isFromHome: false)),(route) => false);
    }
  );
}
}

  showCustomDialog(
      { required BuildContext context,
      String? title,
      String? text,
      VoidCallback? onNoTap,
      VoidCallback? onTap,isTwoButton = false}) async {
     Platform.isIOS ? 
      showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        // title: Text(""),
        content: Text(text.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16.0,
        fontWeight: FontWeight.w500)),
        actions: [
          if (isTwoButton == true)
          CupertinoDialogAction(
            onPressed: onNoTap ?? () => Navigator.of(context).pop(false),
            child: Text(allMessages.value.no ?? 'No',
            style: TextStyle(color:Theme.of(context).disabledColor)),
          ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onTap,
          textStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16.0,
          color : isTwoButton ? Colors.red : Theme.of(context).primaryColor ,
          fontWeight: FontWeight.w600),
          child: Text(isTwoButton == false  ? 'Ok' :
           allMessages.value.yes ?? 'Yes'),
        ),
        ],
        
      ))
      : await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        shape: RoundedRectangleBorder(
        borderRadius:BorderRadius.circular(16)
        ),
        // title: Row(
        //   children: [
        //     Icon(Icons.logout,color: Theme.of(context).disabledColor),
        //     const SizedBox(width: 6),
        //     Text(
        //       title.toString(),
        //       style: Theme.of(context).textTheme.bodyLarge?.merge(
        //             TextStyle(
        //                 color: Theme.of(context).primaryColor,
        //                 fontFamily: 'QuickSand',
        //                 fontSize: 18.0,
        //                 fontWeight: FontWeight.w600),
        //           ),
        //     ),
        //   ],
        // ),
        content: Padding(
          padding:  EdgeInsets.only(top: 16.h),
          child: Text(text.toString(),
           textAlign: TextAlign.center,
          style: const TextStyle(
                      fontFamily: 'QuickSand',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500)),
        ),
        actions: <Widget>[
         isTwoButton == false ? const SizedBox() :  TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text( allMessages.value.no ?? 'No',
            style: const TextStyle(
                        color: Colors.grey,
                        fontFamily: 'QuickSand',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500)),
          ),  
          TextButton(
            onPressed: onTap,
            child: Text(isTwoButton == false  ? 'Ok' 
            : allMessages.value.yes ?? 'Yes',
            style:  TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: 'QuickSand',
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }