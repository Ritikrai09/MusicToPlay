
// ignore_for_file: use_build_context_synchronously, body_might_complete_normally_catch_error

  import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blogit/Utils/custom_toast.dart';
import 'package:blogit/controller/user_controller.dart';

import '../Utils/color_util.dart';
import '../Utils/urls.dart';
import '../main.dart';
import '../model/blog.dart';
import '../model/cms.dart';
import '../model/comment.dart';
import '../model/lang.dart';
import '../model/messages.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;
import '../utils/app_theme.dart';
import 'app_provider.dart';


 
Future<Users?> signin(Users user,BuildContext context) async {
    try {
    if (RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email.toString())) {
    final msg = jsonEncode({
      "email": user.email, 
      "player_id" : OneSignal.User.pushSubscription.id,
      "password": user.password
    });
    // print(msg);
    final  url = Uri.parse('${Urls.baseUrl}login');
    final response = await http.post(
       url,
      body: msg,
      headers: {
        HttpHeaders.contentTypeHeader : 'application/json'
      }
    );
    var res =json.decode(response.body);

    if (res['success'] == true) {
      setCurrentUser(res);
      currentUser.value = Users.fromJSON(res['data']);
      currentUser.value.isPageHome = true;
      currentUser.value.id =res['data']['id'].toString();
      if (currentUser.value.langCode != null) {
        for (var element in allLanguages) {
          if (element.language == currentUser.value.langCode) {
            languageCode.value = element;
          }
        }
      }
       showCustomToast(context,res['message']);
      return currentUser.value;
    } else {
      showCustomToast(context,res['message']);
      return null;
    }
  } else {
     return null;
  }
     
  } on SocketException {
     showCustomToast(context,'No Internet Connection');
  }catch (e) {
    // debugPrint('API request failed: $e');
  }
    return null;
  }


Future<List<SocialMedia>> socialMediaList2() async{
  try {

  final String url = '${Urls.baseUrl}social-media-list';
   var res =  await http.Client().get(Uri.parse(url),
    headers: currentUser.value.id != null ? {
         HttpHeaders.contentTypeHeader: 'application/json',
         "api-token" : currentUser.value.apiToken.toString()
    } : {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  );
 
   var response = json.decode(res.body);
    if (response['success']== true ) {
      List<SocialMedia> social=[];
      response['data'].forEach((e){
        social.add(SocialMedia.fromJson(e));
      });

      return social;
    }else{
       return [];
    }
  } on SocketException {
  //  showCustomToast(context, 'No Internet Conne');
 } on Exception {
    // debugPrint(e.toString());
}
  return [];
}

  Future<Users?> register(Users user,BuildContext context) async {
  if (RegExp(
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(user.email.toString())) {
    final msg = jsonEncode({
      "email": user.email,
      "name": user.name,
      "phone": user.phone ?? '',
      "password": user.password,
      "player_id": OneSignal.User.pushSubscription.id, 
    });
    final String url = '${Urls.baseUrl}signup';
    final response = await http.post(Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: msg,
    // ignore: data_might_complete_normally_catch_error
    ).catchError((e) {
      // debugPrint("register error $e");
    });
    
    var res = json.decode(response.body);

    if (res['success'] == true) {
     
      setCurrentUser(res);
      currentUser.value = Users.fromJSON(res['data']);
      currentUser.value.isPageHome = true;
      currentUser.value.isNewUser = true;
      return currentUser.value;
    } else {
      showCustomToast(context,res["message"]);
    }
  } 
  return null;
}



Future<Users?> appleLogin( Map<String, dynamic> appleData,BuildContext context) async {
  // final firebaseMessaging = FirebaseMessaging.instance;
  // String token = firebaseMessaging.getToken().toString();
  try {
    final msg = jsonEncode({
    "email": appleData["email"],
    "name": appleData["name"],
    "image": appleData["image"],
    "apple_token": appleData["apple_token"],
    "player_id": OneSignal.User.pushSubscription.id,
    "login_from": "apple"
  });
  // debugPrint("msg $msg");
  final String url = '${Urls.baseUrl}social-media-signup';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    //  debugPrint(decode['data'].toString());
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    currentUser.value.isPageHome = true;
    return currentUser.value;
  } else{
   return null;
  }
} on SocketException{
    showCustomToast(context,allMessages.value.noInternetConnection ?? 'No Internet Connection');
} on Exception {
    //  debugPrint(e.toString());
}
  return null;
}

Future<Users?> googleLogin( users,Users user,BuildContext context) async {
  final authentication = await users.authentication;
  // final firebaseMessaging = FirebaseMessaging.instance;
  // String token = firebaseMessaging.getToken().toString();
  try {
  final msg = jsonEncode({
    "email": users.email,
    "name": users.displayName,
    "image": users.photoUrl,
    "google_token": authentication.accessToken,
    "player_id":  OneSignal.User.pushSubscription.id,
    "login_from": "google"
  });
  // debugPrint("msg $msg");
  final String url = '${Urls.baseUrl}social-media-signup';
  final response = await http.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    // debugPrint('----------- Api Token -------------');
    //  debugPrint(decode['data'].toString());
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    currentUser.value.isPageHome = true;
    // if (currentUser.value.langCode != null) {
    //   for (var element in allLanguages) {
    //     if (element.language == currentUser.value.langCode) {
    //       languageCode.value = element;
    //     }
    //   }
    // }
    return currentUser.value;
  } else{
   return null;
  }
} on SocketException{
  //  showCustomToast(context, 'No Internet Connection');
} on Exception catch (e) {
    //  debugPrint(e.toString());
    throw Exception(e);
}
  return null;
}


Future<dynamic> resetPassword(Users user,BuildContext context ,String email) async {
  var userData = json.decode(emailData!)['data'];
 if (user.password != user.cpassword) {
    showCustomToast(context,allMessages.value.passwordAndConfirmPasswordShouldBeSame  ?? 'Password is not matching');
  } else {
    final msg = jsonEncode({
      "id": userData['id'],
      "otp": userData['otp'],
      "email": email,
      "cpassword": user.cpassword,
      "password": user.password
    });
    //final String url =
    //'${GlobalConfiguration().getValue('api_base_url')}reset-password';
    final String url = '${Urls.baseUrl}reset-password';
    final client = http.Client();
    final response = await client.post(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: msg,
    );
    var res =json.decode(response.body);
    
    if(res['success'] == true) {
      showCustomToast( context, res['message']);
      return true;
    } else {
      showCustomToast(context ,res['message']);
        return null;
    }
  }
  return null;
}

Future<bool?> forgetPassword(Users user, BuildContext context) async {
  final msg = jsonEncode({"email": user.email});
  //final String url =
  //'${GlobalConfiguration().getValue('api_base_url')}forgot-password';
  final String url = '${Urls.baseUrl}forget-password';
  final client  = http.Client();
  final response = await client.post(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
    var res = jsonDecode(response.body);
  if (res['success'] == true) {
    emailData = response.body;
    return true;
  // ignore: duplicate_ignore
  } else {
    //  showToast(json.decode(response.data)['message']);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)
        ),
        backgroundColor: Theme.of(context).cardColor,
        contentPadding: const EdgeInsets.all(16),
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 12,
            backgroundColor: Colors.red,
            child: Icon(Icons.close,
            color: Colors.white,
            size: 18)),
          const SizedBox(width: 8),Text(
        allMessages.value.somethingWentWrong ?? "Error ocurred!",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.merge(
                const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Roboto',
                    fontSize: 19.0,
                    fontWeight: FontWeight.w600),
              ),
        )
       ]),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
              children: [
               
                    Text(
                       json.decode(response.body)['message'].toString(),
                        style:  TextStyle(
                            fontSize: 16,
                            height: 1.4,
                            fontFamily: "QuickSand",
                            fontWeight: FontWeight.w500,
                            color: dark(context) ?Colors.grey.shade200 : Colors.grey.shade500)),
                  
                 const SizedBox(height: 12),
                Text(
                  ' ${user.email}.',
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: "QuickSand",
                      color: dark(context)
                          ? Colors.white
                          : Colors.black,
                      fontWeight:FontWeight.w500,
                      height: 1.4),
                )
              ],
            ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(allMessages.value.ok ?? 'Ok' ),
          ),
        ],
      ),
    );
  }
  return null;
}



Future<void> logout() async {
  currentUser.value = Users();

  SharedPreferences? prefs =  await SharedPreferences.getInstance();
  await prefs.remove('current_user');
  prefs.setBool("isUserLoggedIn", false);
}

void setCurrentUser(jsonString) async {
  SharedPreferences? prefs = await SharedPreferences.getInstance();
  if (jsonString['data'] != null) {
    prefs.setBool("isUserLoggedIn", true);
    await prefs.setString(
        'current_user', json.encode(jsonString['data']));
    currentUser.value =Users.fromJSON(json.decode(prefs.get('current_user').toString()));

    // debugPrint("Current User id ${currentUser.value.id}");
  }
}

Future<Users> getCurrentUser() async {
  SharedPreferences preferences =await SharedPreferences.getInstance();
  //appThemeModel.value.
  if (currentUser.value.id == null &&
     preferences.containsKey('current_user')) {
    currentUser.value = Users.fromJSON(json.decode(preferences.get('current_user').toString()));
    currentUser.value.auth = true;
  } else {
    currentUser.value.auth = false;
  }
  return currentUser.value;
}

setOnesignalUserId(String id){
  prefs!.setString('player_id',id);
}

String? getOnesignalUserId()  {
  
    if (prefs!.containsKey('player_id')) {
        final str = prefs!.getString('player_id');
        currentUser.value.deviceToken = str;
        return str;
     }
    return currentUser.value.deviceToken;
}

Future<Users?> update(Users user, BuildContext context) async {
  final msg = jsonEncode({
    "email": user.email,
    "name": user.name,
    "id": currentUser.value.id,
    "phone": user.phone,
    "password": user.password
  });

  final String url = '${Urls.baseUrl}update-profile';

  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      'api-token' : currentUser.value.apiToken.toString()
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  
  if (decode['success'] == true) {
    setCurrentUser(decode);
    currentUser.value = Users.fromJSON(decode['data']);
    return currentUser.value;
  } 
  return null;
}

Future<CommentModel?> getComment(int id) async {
  final msg = jsonEncode({
    "blog_id": id
  });

  try {
  final String url = '${Urls.baseUrl}get-comments';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    print(decode.toString());
    var data  = CommentModel.fromJson(decode);
    return data;
  } 
  return null;
} on Exception catch (e) {
   log(e.toString());
}
  return null;

}


Future<dynamic> setComment(String text,int id) async {
  try {
  final msg = jsonEncode({
    "blog_id": id,
    "comment": text
  });
  
  // print(msg);
  
  final String url = '${Urls.baseUrl}add-comment';
  var headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token": currentUser.value.apiToken.toString(),
    };
  
  // print(headers);
  final response = await http.post(
   Uri.parse(url),
    headers: headers,
    body: msg,
  );
  
  var decode = jsonDecode(response.body);
  
   print(decode);
  
  if (decode['success'] == true) {
    
    return decode;
  } 
  return decode;
} on Exception catch (e) {
   log(e.toString());
}
}

Future<dynamic> reportComment(int id) async {
  final msg = jsonEncode({
    "comment_id": id
  });

  final String url = '${Urls.baseUrl}report-comment';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token": currentUser.value.apiToken.toString(),
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  //  print(decode.toString());
  // if (decode['success'] == true) {
  //   return decode;
  // } 
  return decode;
}

Future<bool?> deleteComment(int id) async {
  try {
  final msg = jsonEncode({
    "id": id
  });
  
  final String url = '${Urls.baseUrl}delete-comment';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token": currentUser.value.apiToken.toString(),
    },
    
    body: msg,
  );
  var decode = json.decode(response.body);
  //  print(decode.toString());
  if (decode['success'] == true) {
    return true;
  } 
  return false;
} on Exception catch (e) {
  log(e.toString());
}
  return null;
}




Future<Users?> updateLanguage() async {
  final msg = jsonEncode({
    "lang-code": languageCode.value.language,
    "email": currentUser.value.email,
    "name": currentUser.value.name,
    "id": currentUser.value.id,
    "phone": currentUser.value.phone,
  });

  final String url = '${Urls.baseUrl}update-profile';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  if (decode['success'] == true) {
    setCurrentUser(response.body);
    currentUser.value = Users.fromJSON(decode['data']);
    return currentUser.value;
  } 
  return null;
}

Future<dynamic> changePassword(BuildContext context,
    {required String conPass,
    required String newPass,
    required String oldPass
    }) async {

  try {
  final msg = jsonEncode({
    "old_password": oldPass,
    "password": newPass,
    "cpassword": conPass,
  });
  
  final String url = '${Urls.baseUrl}change-password';
  final response = await http.post(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token" : currentUser.value.apiToken.toString()
    },
    body: msg,
  );
  var decode = json.decode(response.body);
  // ignore: duplicate_ignore
  // print(decode);
 
  return decode;
    //showCustomToast(context,decode['message'].toString());
    //Navigator.pop(context);

}on SocketException{
   showCustomToast(context,allMessages.value.noInternetConnection ?? 'No Internet Connection');
}  on Exception {
  // TODO
}
 return false;
}

Future<Messages?> getLocalText(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String url;
  try {
    url ="${Urls.baseUrl}localisation-list?language_id=${languageCode.value.id}";
  
  final response = await http.get(
    Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
  );

  var res= jsonDecode(response.body);
  if (res['success'] == true) {
    prefs.setString("local_data", json.encode(res['data']));
   allMessages.value = Messages.fromJson(res['data']);
  
    return Messages.fromJson(res['data']);
  }
}on SocketException{
   showCustomToast(context , allMessages.value.noInternetConnection ??  'No Internet Connection');
}  on Exception catch (e) {
  // debugPrint(e.toString());
  throw Exception(e);
}
  return null;

}

Future<List<Language>> getAllLanguages(BuildContext context) async {
  final String url = '${Urls.baseUrl}language-list';
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );

    var res = jsonDecode(response.body);

    if (res['success'] == true) {
      List<Map<String, dynamic>> jsonList = [];
      allLanguages= [];
       res['data'].forEach((language) {
        allLanguages.add(Language.fromJson(language));
        jsonList.add(language);
      });
       prefs!.setString("languages",json.encode(jsonList));
       prefs!.setString("defalut_language", json.encode(languageCode.value.toJson()));
      return allLanguages;
    } else {
      showCustomToast(context,json.decode(res)['message']);
    }
  } catch (e) {
    showCustomToast(context,e.toString());
  }
  return [];
}


Future<List<Blog>> adView() async {

  final String url = '${Urls.baseUrl}ads-list';

  try {
  final response = await http.get(
   Uri.parse(url),
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
    }
  );
  var decode = json.decode(response.body);
  
  if (decode['success'] == true) {
    // List<Blog> blogAdList=[];
    blogAds.value = [];
    decode['data'].forEach((element) { 
      blogAds.value.add(Blog.fromJson(element,isAds: true));
    });
    return blogAds.value;
  } 
} on Exception catch (e) {
 throw Exception(e);
}
  return [];
}


Future<List<CmsModel>> getCMS() async {
  final client = http.Client();
  try {
    final String url = '${Urls.baseUrl}cms-list';
    final response = await client.get(Uri.parse(url),
    );
    var decode = json.decode(response.body);
    if (decode['success'] == true) {
      allCMS = [];
      decode['data'].forEach((language) {
        allCMS.add(CmsModel.fromJson(language));
      });
        prefs!.remove('OffAds');
        prefs!.setString('OffAds',response.body);
      return allCMS;
    } else {
      // showToast('getCMS --->>>');
      // showToast(json.decode(response.body)['message']);
    }
  } on SocketException {
    if (prefs!.containsKey('OffAds')) {
      allCMS= [];
      final ads = prefs!.getString('OffAds').toString();
      json.decode(ads)['data'].forEach((language) {
        allCMS.add(CmsModel.fromJson(language));
      });
    } 
    return allCMS;
  } on Exception catch (e) {
      throw Exception(e);
      
  } finally {
       client.close();
   }
  return [];
}


Future<Users?> updateToken(Users user,String str,{bool value=true}) async {
  try {
  final msg = jsonEncode({
    "player_id": str,
    "is_notification_enabled" : value == true ?  1 : 0
  });

   // ScaffoldMessenger.of(navkey.currentState!.context).showSnackBar(SnackBar(content: Text(msg.toString())));
  final String url = '${Urls.baseUrl}update-token';
   var res =  await http.post( Uri.parse(url),
    headers: currentUser.value.id != null ? {
         HttpHeaders.contentTypeHeader: 'application/json',
         "api-token" : currentUser.value.apiToken.toString()
    } : {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
   var response = json.decode(res.body);
  //  ScaffoldMessenger.of(navkey.currentState!.context).showSnackBar(SnackBar(content: Text(response.toString())));
    if (response['success']== true && currentUser.value.id == null) {
      prefs!.setString('non-logged-in', str.toString());
    }
  } on SocketException {
  //  showCustomToast(context, 'No Internet Conne');
 } on Exception catch (e) {
   ScaffoldMessenger.of(navkey.currentState!.context).showSnackBar(SnackBar(content: Text(e.toString())));
   throw Exception(e);
    // debugPrint(e.toString());
}
  return null;
}


Future<bool?> getNotification()async{
  try {

  final msg = jsonEncode({
    "player_id": currentUser.value.deviceToken,
  });
  
  final String url = '${Urls.baseUrl}get-notification-detail';
   var res =  await http.post(Uri.parse(url),
    headers: currentUser.value.id != null ? {
         HttpHeaders.contentTypeHeader: 'application/json',
         "api-token" : currentUser.value.apiToken.toString()
    } : {
      HttpHeaders.contentTypeHeader: 'application/json',
    },
    body: msg,
  );
  //     print('---------------- Testing --------------------------');
  //  print(res.body.toString());
 
   var response = json.decode(res.body);
 
    if (response['success']== true ) {
      appThemeModel.value.isNotificationEnabled.value =  response['data']['is_notification_enabled'] == 1 ? true : false;
      return  response['data']['is_notification_enabled'] == 1 ?  true : false;
    }
  } on SocketException {
  //  showCustomToast(context, 'No Internet Conne');
 } on Exception catch (e) {
    throw Exception(e);
}
  return false;
}