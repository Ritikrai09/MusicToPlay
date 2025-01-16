import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:blogit/controller/user_controller.dart';

import '../Utils/custom_toast.dart';
import '../Utils/urls.dart';
import '../main.dart';
import '../model/news.dart';

 List<ENews> eNews = [];
 List<LiveNews> liveNews = [];

Future<bool?> checkUpdate({String route = 'epaper-list',String etag='enews-tag',bool headCall=true}) async{
    
    if (headCall == true) {
  final response = await http.head(Uri.parse('${Urls.baseUrl}$route'),
   headers: currentUser.value.id != null ?{
        "api-token" : currentUser.value.apiToken.toString()
      }: {
        
       }
  );
  var eTag = response.headers['ETag']; 
  var prefTag = prefs!.containsKey(etag) ? prefs!.getString(etag) : '';

  if ((prefTag !=''|| prefTag !=null) && eTag != prefTag) {
     prefs!.setString(etag,eTag.toString());
    //  print('new update');
    return false;
  } else if (prefTag == ''|| prefTag == null) {
    return false;
  }else{ 
    return true;
  }
}else{
  return false;
}
  }


Future<List<ENews>> getENews(BuildContext context) async {
     
  try {
     await checkUpdate().then((value) async{
      if (value == true) {
          eNews = [];
       json.decode(prefs!.get('enews').toString())['data'].forEach((e){
          eNews.add(ENews.fromJson(e));
       });
       return eNews;
    } else {
      final String url = '${Urls.baseUrl}epaper-list';
    final client = http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      eNews = [];
      json.decode(response.body)['data'].forEach((e) {
        eNews.add(ENews.fromJson(e));
      });
      prefs!.setString('enews', response.body);
      return eNews;
    }
    }
   });
  } on SocketException {
      showCustomToast(context, allMessages.value.noInternetConnection ?? '');
  }
  return [];
}

Future<List<LiveNews>> getliveNews(BuildContext context) async {
  
  try {
     await checkUpdate(route: 'live-news-list',etag: 'live-news-tag').then((value) async{
      if (value == true) {
        liveNews = [];
       if (prefs!.containsKey('livenews')) {
          json.decode(prefs!.get('livenews').toString())['data'].forEach((e){
          liveNews.add(LiveNews.fromJson(e));
       });
       }
       return liveNews;
    } else {
    final String url = '${Urls.baseUrl}live-news-list';
    final client = http.Client();
    final response = await client.get(
      Uri.parse(url),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if (response.statusCode == 200) {
      liveNews = [];
      var decode = json.decode(response.body);
      debugPrint(decode.toString());
      decode['data'].forEach((e) {
        liveNews.add(LiveNews.fromJson(e));
      });
      // debugPrint(liveNews[0].toString());
       prefs!.setString('livenews', response.body);
       
      return liveNews;
    }
    }
     });
  } on SocketException {
      showCustomToast(context, allMessages.value.noInternetConnection ?? '');
  }  catch(e) {
      debugPrint(e.toString());
  }
  return [];
}
