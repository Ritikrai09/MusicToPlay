import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:blogit/Utils/urls.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/main.dart';
import 'package:blogit/model/blog.dart';

import 'package:flutter_preload_videos/provider/preload_provider.dart';


List<dynamic> liveNews = [];

var shortslikesIds =[];

class ShortsApi extends ControllerMVC {

  int currentPage = 1;
  

   void setIndex(int index) {
    currentPage = index;
  }
  
  DataModel blogModel = DataModel();

  void setList(DataModel list) {
    blogModel = list;
    setState(() { });
  }

   void updateList(DataModel list) {
    shortLists.blogModel.currentPage = list.currentPage;
    shortLists.blogModel.firstPageUrl = list.firstPageUrl;
    shortLists.blogModel.lastPageUrl = list.lastPageUrl;
    shortLists.blogModel.nextPageUrl = list.nextPageUrl;
    shortLists.blogModel.to = list.to;
    shortLists.blogModel.prevPageUrl = list.prevPageUrl;
    shortLists.blogModel.lastPage = list.lastPage;
    shortLists.blogModel.from = list.from;
    shortLists.blogModel.blogs.addAll(list.blogs.toSet().toList());
  }

 final String _baseUrl = '${Urls.baseUrl}get-short-videos';
 // Adjust this based on your API pagination settings

@pragma('vm:entry-point')
Future<List<String>?> fetchShorts({String? nextPageUrl,bool isInitialLoad=false}) async {
try {
 
  // while (true) {
     
    //  if(nextPageUrl == null){
    //     shortLists.blogModel = getShortCache() ?? DataModel();
    //     setState(() { });
    //  }
  

    final response = await http.get(
      Uri.parse(nextPageUrl ?? _baseUrl),
     headers: currentUser.value.id != null ? {
      HttpHeaders.contentTypeHeader: 'application/json',
      // "api-token" : currentUser.value.apiToken.toString(),
    }: {
      HttpHeaders.contentTypeHeader: 'application/json',
      // "player-id" : OneSignal.User.pushSubscription.id ?? ""
     },
    );

     DataModel? dataModel;
  
    if (response.statusCode == 200) {

      log("Data Videos ${response.body}");
      
      final responseData = json.decode(response.body)['data'];
      
      if (nextPageUrl != null) {

         dataModel = DataModel.fromJson(responseData,isShorts: true);
         shortLists.updateList(dataModel);

      } else {

         setShortCache(responseData);
         shortLists.blogModel = DataModel.fromJson(responseData,isShorts: true);
      }

      List<String> videoList = [];
      // ignore: use_build_context_synchronously
      var provider = Provider.of<AppProvider>(navkey.currentState!.context, listen: false);

      for (var element in ( dataModel != null ? dataModel.blogs : shortLists.blogModel.blogs)) {
       if( !provider.permanentlikesIds.contains(element.id) && element.isUserLiked == 1 ){
            provider.setlike( blog: element);
        }

        if (element.videoFile != null) {
          videoList.add(element.videoFile ?? "");
        }else{
          videoList.add(element.videoUrl ?? "");
        }
      }

      if(shortLists.blogModel.nextPageUrl == null && !shortLists.blogModel.blogs.contains(
        Blog(
          id: 000000,
          title: 'Great!!',
          description: 'You have viewed all shorts! Stay tuned for later updates.'
        )
      )){
        shortLists.blogModel.blogs.add(Blog(
          id: 000000,
          title: 'Great!!',
          description: 'You have viewed all shorts! Stay tuned for later updates.'
        ));
      }

      currentPage++;
      setState(() { });

     if(nextPageUrl != null){
       log('-----\$------- ${videoList.toString()} ------------');
     }

      return videoList;

    } else {
      
      throw Exception('Failed to fetch shorts');
    }

} on Exception catch (e) {
  log("handle Exception${e.toString()}");
  throw Exception(e);
}

}



Future createIsolate(int index) async {
  // Set loading to true
  // BlocProvider.of<PreloadBloc>(context, listen: false)
  //     .add(PreloadEvent.setLoading());

  try {

  var provider = Provider.of<PreloadProvider>(navkey.currentState!.context, listen: false);
  
  ReceivePort mainReceivePort = ReceivePort();
  
  await Isolate.spawn<SendPort>(getVideosTask, mainReceivePort.sendPort);
  
  SendPort isolateSendPort = await mainReceivePort.first;
  
  ReceivePort isolateResponseReceivePort = ReceivePort();
  
  isolateSendPort.send([index, isolateResponseReceivePort.sendPort]);
  
  // final isolateResponse = await isolateResponseReceivePort.first;

  isolateResponseReceivePort.listen((e){
    
  final urls = e.first;
  
  log("Update urls ${urls.toString()}");

  provider.updateUrls = urls;

  });
  
  
  // Update new urls
  
 

} on Exception catch (e) {
   log('recieve Port $e');
}
      
}

Future getVideosTask(SendPort mySendPort) async {

  try {
    
  ReceivePort isolateReceivePort = ReceivePort();
  
  mySendPort.send(isolateReceivePort.sendPort);
  
  await for (var message in isolateReceivePort) {
    if (message is List) {
    
      //  final int index = message[0];
  
      final SendPort isolateResponseSendPort = message[1];
       
       var shortsUrls  = await fetchShorts(nextPageUrl: shortLists.blogModel.nextPageUrl);
       
      isolateResponseSendPort.send(shortsUrls);
    }
  }
} on Exception catch (e) {
  log('video Task : $e');
}
}


Future<List<dynamic>?> getLiveVideo(BuildContext context) async {
   
   try {
 
    final response = await http.get(
      Uri.parse("${Urls.baseUrl}get-live-stream"),
     headers: currentUser.value.id != null ? {
      HttpHeaders.contentTypeHeader: 'application/json',
      "api-token" : currentUser.value.apiToken.toString(),
    }: {
      HttpHeaders.contentTypeHeader: 'application/json',
      "player-id" : OneSignal.User.pushSubscription.id ?? ""
     },
    );

    if (response.statusCode == 200) {
      
      final responseData = json.decode(response.body);
      
       return responseData['data'];
       
    } else {
      
      throw Exception('Failed to fetch shorts');
    }

    } on Exception catch (e) {
      // print(e);
      throw Exception(e);
    }

    
  //  }
  }

}

setShortCache(Map<String,dynamic> map) async{
  if (prefs != null) {
     prefs!.setString('shorts', jsonEncode(map));
  }
}


DataModel? getShortCache(){
  if (prefs != null && prefs!.containsKey('shorts')) {
    return DataModel.fromJson(json.decode(prefs!.getString('shorts').toString()), isShorts: true); 
  }
  return null;
}

 ShortsApi shortLists = ShortsApi();