import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/user_controller.dart';
import '../Utils/urls.dart';
import '../main.dart';
import '../model/analytic.dart';
import '../model/blog.dart';

DateTime? signInStart;
DateTime? signInEnd;

enum ShareType { telegram, whatsapp, mail, twitter }

ValueNotifier<List<Blog>> blogAds = ValueNotifier([]);

class AppProvider with ChangeNotifier {
  bool _load = false;
 DataCollection? _blog;
  var _blogList;
  List<int>  selectedFeed =[];
  int adFrequency =1;
  List<Map<String,dynamic>> analytics = [{
           "type" : "blog_time_spent",
           "blogs" : []
       },{
          "type" :'bookmark',
          "blog_ids": []
       },{
          "type" :'poll_share',
          "blog_ids": []
       },{
          "type" : 'share',
          "blog_ids": []
       },{
          "type" :'view',
          "blog_ids":[]
       },{
          'type' : 'sign_in',
          'start_time':'',
       },{
          "type" : "remove_bookmark",
          "blog_ids" : [] 
       },{
          "type" : "tts",
          "blog_ids" : [] 
       },{
         'type': 'like',
         'blog_ids': []
   }];
  List<Map<String,dynamic>> blogTimeSpent = [];
  List<Map<String,dynamic>> ttsTimeline = [];
  List<Blog> bookmarks = [];
  List<int> permanentIds = [], permanentlikesIds=[];
   List<int> likesIds = [];
  List<int> shareIds=[],viewIds=[],bookmarkIds=[],pollIds=[],ttsIds=[];
  DataCollection? allListCategory;
  List<Blog> feedBlogs= [],allNewsBlogs = [],featureBlogs=[],quotes=[];
  
  DataModel? feed,allNews;
  // List<Blog> ads = [];
  
  List<int> removeBookmarkIds=[];
  
  List<Category> visibility = [];

  AppProvider() {
    //_getCurrentUser();
    // getCategory();
   
    // getBlogData();
  }

  DataCollection? get blog => _blog;
  DateTime? appStartTime;
  bool isLoading = false;
  
   List<Blog>? get getFeed => feedBlogs ;
   List<String> categories=[];
  
   setAdFrequency(int i) {  
    adFrequency = i;
    notifyListeners(); 
  } 

   addAdFrequency(int i) {  
    adFrequency += i;
    notifyListeners(); 
  }

  int shortIndex = 0;

  get getShortIndex => shortIndex;

  set setShortVideo(int index){
    shortIndex = index;
    notifyListeners();
  }

  List<Category> get blogList => _blogList ?? <Category>[];

  bool get load => _load;

  clearList() {
    _blog = null;
    _blogList = null;
    notifyListeners();
  }

   appTime(DateTime? time) {
    appStartTime=time;
     notifyListeners();
  }

  setLoading({bool? load}) {
    _load = load!;
    notifyListeners();
  }

  loadQuotes(bool isExternal){
  
    if (isExternal == false) {
      quotes =[];
    }
     for (var element in allNewsBlogs) {
        if (element.type =='quote') {
          quotes.add(element);
        }
      }

      for (var element in quotes) {
        allNewsBlogs.remove(element);
      }

      quotes.sort((a, b) => a.isUserViewed == 1 ? 1 : 0);

    notifyListeners();
  }

  setBookmark({required Blog blog}) {
    // prefs!.remove('bookmarks');
    // print(blog.toJson());
     if (permanentIds.contains(blog.id)) {
        bookmarks.remove(blog);
        permanentIds.remove(blog.id!.toInt());
     } else {
        bookmarks.add(blog);
        permanentIds.add(blog.id!.toInt());
     }
  
     DataModel myModelJsonList = DataModel(blogs: bookmarks);
     var data = json.encode(myModelJsonList.toJson());
     prefs!.setString('bookmarks',data);
     notifyListeners();
  }


  setlike({required Blog blog}) {
    // prefs!.remove('bookmarks');
      if (!likesIds.contains(blog.id)) {
        likesIds.add(blog.id ?? 0);
     } 
     else {
      likesIds.remove(blog.id);
     }
     
     if (permanentlikesIds.contains(blog.id)) {
       permanentlikesIds.remove(blog.id);
     } else {
       permanentlikesIds.add(blog.id ?? 0);
     }

      analytics[8] = {
        "type": "like",
        "blog_ids": likesIds
      };
    
    // debugPrint(analytics.toString());
    //  debugPrint(analytics.toString());
     notifyListeners();
  }

   Future setAllBookmarks() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
      if (prefs!.containsKey('bookmarks')) {
        var data = json.decode(pref.getString('bookmarks').toString());
        DataModel data2 = DataModel.fromJson(data);
        bookmarks =data2.blogs;
        permanentIds = [];
        for (var element in data2.blogs) {
          permanentIds.add(element.id!.toInt());
         }
        blogListHolder2.clearList();
        blogListHolder2.setList(data2);
        blogListHolder2.setBlogType(BlogType.bookmarks);
      } 
      notifyListeners();
    }

     Future  getVisibility() async{
      var url = "${Urls.baseUrl}get-app-home-page";
      var client = http.Client();
       var result = await client.get(  
          Uri.parse(url),
          headers:{
            HttpHeaders.contentTypeHeader : "application/json",
           
          }
        );
        final data = json.decode(result.body);
       if (data['success']==true && data['data'] != []) {
        visibility =[];
         data['data'].forEach((e){
             visibility.add(Category.fromJson(e));
         });
        prefs!.setString('visibility',json.encode(data['data']));
        notifyListeners();
       }
      
    }


  Future<DataModel?>  getAllBookmarks() async{
       try {
  var url = "${Urls.baseUrl}get-bookmarks";
        var client = http.Client();
  var result = await client.get(  
     Uri.parse(url),
     headers:{
       HttpHeaders.contentTypeHeader : "application/json",
       "api-token": currentUser.value.apiToken ?? '',
        "language-code" : languageCode.value.language ?? 'en',
     }
   );
   final data = json.decode(result.body);
  if (data['success']==true) {
    // debugPrint(data.toString());
  ///  print(data['data'] );
        //  bookmarks = data['data'].map((e) =>Blog.fromJson(e)).toList();
    if (data['data'].toString() != '[]') {
       final list = DataModel.fromJson(data['data']);
     bookmarks = list.blogs;
     for (var element in list.blogs) {
     permanentIds.add(element.id!.toInt());
   }
  
     prefs!.setBool('isBookmark', true);
     prefs!.setString('bookmarks',json.encode(data['data']));
     return list;
    }else{
      setAllBookmarks();
    }
     notifyListeners();
     
  }else{
   return null;
  }
    } on Exception catch (e) {
      // print(e);
      throw Exception(e);
    }
       return null;
      
}


    Future<bool?> checkUpdate({String route = 'epaper-list',String etag='enews-tag',externalUrl='',bool headCall=true}) async{
    prefs = await SharedPreferences.getInstance();
    if (headCall == true) {
    final response = await http.head(Uri.parse(externalUrl !='' ? externalUrl :'${Urls.baseUrl}$route'),
        headers: currentUser.value.id != null ?{
        "api-token" : currentUser.value.apiToken.toString()
        }: {
        
       });
    var eTag = response.headers['ETag']; 
    var prefTag = prefs!.containsKey(etag) ? prefs!.getString(etag) : '';

   if ((prefTag !=''|| prefTag !=null) && eTag != prefTag) {
     prefs!.setString(etag,eTag.toString());
     //  print('new update');
      return false;
    } else if (prefTag == ''|| prefTag == null) {
    return false;
    } else { 
      return true;
    }
    } else { 
      return false;
    }
    }

   Future allNewsList({ int? categoryId,String? url,BlogType? type})async{
    int? catId;
    DataCollection blog2 = DataCollection();
    DataModel allblogs = DataModel(blogs: []);
        var client = http.Client();
        var result = await client.get(  
          Uri.parse(url ?? ''),
          headers:
           currentUser.value.id != null ? 
           {
            HttpHeaders.contentTypeHeader : "application/json",
            "api-token": currentUser.value.apiToken ?? '',
            "language-code" : languageCode.value.language ?? '',
          }:{
            HttpHeaders.contentTypeHeader :"application/json",
            "language-code" : languageCode.value.language ?? '',
          }
        );
          
        final data = json.decode(result.body);

        blog2 = DataCollection.fromJson(data);
        allListCategory = blog2;
        allblogs.nextPageUrl = blog2.categories![0].data!.nextPageUrl;
        allNews!.nextPageUrl =  blog2.categories![0].data!.nextPageUrl;
     
       for (var i = 0; i < blog2.categories!.length; i++) {
        for (var j = 0; j <  blog2.categories![i].data!.blogs.length; j++) {
         if (catId == null && categoryId == blog2.categories![i].id ) {
             catId = blog2.categories![i].id;
         } 
       if(type ==  BlogType.category && categoryId == blog2.categories![i].id 
           && !allblogs.blogs.contains(blog2.categories![i].data!.blogs[j])){
          
            allblogs.blogs.add(blog2.categories![i].data!.blogs[j]);
        } 

        //if(blogListHolder2.blogType == BlogType.allnews) {
          if (!allNews!.blogs.contains(blog2.categories![i].data!.blogs[j]) ) {
               allNews!.blogs.add(blog2.categories![i].data!.blogs[j]);
               
           }
         // }
        }
        }

        allNews!.blogs.sort((a, b) { 
           return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
        });

        if(type == BlogType.allnews && blogListHolder2.blogType == BlogType.category) {
           blogListHolder2.updateList(allNews as DataModel);
        }
        if(type == BlogType.allnews && blogListHolder.blogType == BlogType.category) {
          blogListHolder.updateList(allNews as DataModel);
        }

        if(type ==  BlogType.category && categoryId == catId &&  blogListHolder2.blogType == BlogType.category) {
           blogListHolder2.updateList(allblogs);
         }
         
         if(type ==  BlogType.category && categoryId == catId && blogListHolder.blogType == BlogType.category) {
          print("------ added -------");
           blogListHolder.updateList(allblogs);
         }
        //  print(catId);
        //  print(categoryId);
        
        notifyListeners();
        
  }


   Future getCategory({bool allowUpdate = true,bool headCall = true, String externalUrl='',BlogType? type}) async {
      try {
      // await checkUpdate(route:'blog-list', etag: 'blog-list-tag',headCall: externalUrl != '' ? false : headCall,externalUrl: externalUrl).then((value) async{
      //    DataCollection? blog2;
      //    if (value == true && allowUpdate == false) {
      //     getCacheBlog();
      //     // print('-------- Cache ==========');
      //     notifyListeners();
      //   } else {
         DataCollection? blog2;
        var url = externalUrl != '' ? externalUrl : "${Urls.baseUrl}blog-list";
        var client = http.Client(); 
        var result = await client.get(  
          Uri.parse(url),
          headers:
           currentUser.value.id != null ? 
           {
            HttpHeaders.contentTypeHeader : "application/json",
            "api-token": currentUser.value.apiToken ?? '',
            "language-code" : languageCode.value.language ?? '',
          }:{
            HttpHeaders.contentTypeHeader :"application/json",
            "language-code" : languageCode.value.language ?? '',
          }
        );
        final data = json.decode(result.body);
  
        if (data['success']==true) {
        // debugPrint('data.toString()');
        // debugPrint(data.toString());
        if(externalUrl == ''){
          feedBlogs = [];
          featureBlogs = [];
          allNewsBlogs = [];
          allNews =DataModel();
          selectedFeed = [];
          permanentlikesIds=[];
          categories =[];
          notifyListeners();
        }

        List<Blog> nextFeedBlogs = [];

        if (externalUrl == '') {
           _blog = DataCollection.fromJson(data);
      
           prefs!.setString('collection', result.body);    
          for (var i = 0; i < _blog!.categories!.length; i++) {
            categories.add(_blog!.categories![i].name ?? '');
            if (_blog!.categories![i].isFeed == true) {
                selectedFeed.add(_blog!.categories![i].id!.toInt());
            }
            for (var j = 0; j <  _blog!.categories![i].data!.blogs.length; j++) {
              // if (_blog!.categories![i].data!.blogs[j].type == 'ads') {
              //     ads.add(_blog!.categories![i].data!.blogs[j]);
              // }
              
              if ( _blog!.categories![i].isFeed==true && !feedBlogs.contains(_blog!.categories![i].data!.blogs[j])  && _blog!.categories![i].data!.blogs[j].type != 'ads' && _blog!.categories![i].data!.blogs[j].type != 'quote') {
                feedBlogs.add(_blog!.categories![i].data!.blogs[j]);  
              }
              if (_blog!.categories![i].data!.blogs[j].isFeatured == 1 && !featureBlogs.contains(_blog!.categories![i].data!.blogs[j])  && _blog!.categories![i].data!.blogs[j].type != 'quote') {
                featureBlogs.add( _blog!.categories![i].data!.blogs[j]);
              }
              if (!allNewsBlogs.contains( _blog!.categories![i].data!.blogs[j])) {
                  allNewsBlogs.add( _blog!.categories![i].data!.blogs[j]);
            
                  if (!permanentlikesIds.contains(_blog!.categories![i].data!.blogs[j].id) && _blog!.categories![i].data!.blogs[j].isUserLiked == 1) {
                    permanentlikesIds.add(_blog!.categories![i].data!.blogs[j].id!.toInt());
                  }
              }
             }
           }
         } else {

             blog2 = DataCollection.fromJson(data);
            
             for (var i = 0; i < blog2.categories!.length; i++) {
             for (var j = 0; j <  blog2.categories![i].data!.blogs.length; j++) {
              // if (blog2.categories![i].data!.blogs[j].type == 'ads') {
              //     ads.add(_blog!.categories![i].data!.blogs[j]);
              // }
              if ( blog2.categories![i].isFeed==true && 
             
              !feedBlogs.contains(blog2.categories![i].data!.blogs[j])  
              && blog2.categories![i].data!.blogs[j].type != 'ads'
               && !nextFeedBlogs.contains(blog2.categories![i].data!.blogs[j]) 
               && blog2.categories![i].data!.blogs[j].type != 'quote') {
                nextFeedBlogs.add(blog2.categories![i].data!.blogs[j]);  
              }
              // if (blog2.categories![i].data!.blogs[j].visibilities!.contains(1)) {
              //   featureBlogs.add( blog2.categories![i].data!.blogs[j]);
              // }
             if (!allNewsBlogs.contains( _blog!.categories![i].data!.blogs[j]) && !allNewsBlogs.contains(blog2.categories![i].data!.blogs[j]) ) {
                allNewsBlogs.add(blog2.categories![i].data!.blogs[j]);
              }
             }
             nextFeedBlogs;
           }

          //  await arrangeAds(nextFeedBlogs).then((value) {
          //    nextFeedBlogs =value;
            // feedBlogs.addAll(nextFeedBlogs);
          // });
         }
         if(externalUrl == ''){
           featureBlogs.sort((a, b) { 
            return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
          });
         }
           allNewsBlogs.sort((a, b) { 
           return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
        });

         if (externalUrl == '' && currentUser.value.id != null) {
          feedBlogs.sort((a, b) { 
            if (b.type == "ads" || a.type == "ads") {
              return -1;
            } else {
               return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
            }
           });
         }
        // 
          // allNewsBlogs = await arrangeAds(allNewsBlogs);
          if (externalUrl == '' && currentUser.value.id != null && blogAds.value.isNotEmpty) {
            feedBlogs = await arrangeAds(feedBlogs);
          } else {
            nextFeedBlogs = await arrangeAds(nextFeedBlogs);
            feedBlogs.addAll(nextFeedBlogs);
          }

          loadQuotes(externalUrl != '');
          notifyListeners();
        
         if (externalUrl != '') {
          feed = DataModel(
          currentPage:  blog2!.categories![0].data!.currentPage,
          firstPageUrl:  blog2.categories![0].data!.firstPageUrl,
          lastPageUrl: blog2.categories![0].data!.lastPageUrl,
          nextPageUrl: blog2.categories![0].data!.nextPageUrl,
          to:  blog2.categories![0].data!.to,
          lastPage: blog2.categories![0].data!.lastPage,
          from: blog2.categories![0].data!.from,
          blogs: feedBlogs
        );
        allNews = DataModel(
          currentPage:  blog2.categories![0].data!.currentPage,
          firstPageUrl:  blog2.categories![0].data!.firstPageUrl,
          lastPageUrl: blog2.categories![0].data!.lastPageUrl,
          nextPageUrl: blog2.categories![0].data!.nextPageUrl,
          to:  blog2.categories![0].data!.to,
          lastPage: blog2.categories![0].data!.lastPage,
          from: blog2.categories![0].data!.from,
          blogs: allNewsBlogs
        );
         } else {
       feed = DataModel(
          currentPage:  _blog!.categories![0].data!.currentPage,
          firstPageUrl:  _blog!.categories![0].data!.firstPageUrl,
          lastPageUrl: _blog!.categories![0].data!.lastPageUrl,
          nextPageUrl: _blog!.categories![0].data!.nextPageUrl,
          to:  _blog!.categories![0].data!.to,
          lastPage: _blog!.categories![0].data!.lastPage,
          from: _blog!.categories![0].data!.from,
          blogs: feedBlogs
        );
        allNews = DataModel(
          currentPage:  _blog!.categories![0].data!.currentPage,
          firstPageUrl:  _blog!.categories![0].data!.firstPageUrl,
          lastPageUrl: _blog!.categories![0].data!.lastPageUrl,
          nextPageUrl: _blog!.categories![0].data!.nextPageUrl,
          to:  _blog!.categories![0].data!.to,
          lastPage: _blog!.categories![0].data!.lastPage,
          from: _blog!.categories![0].data!.from,
          blogs: allNewsBlogs
        );
          notifyListeners();
         }
         
        allNews!.blogs = allNewsBlogs;
        feed!.blogs = feedBlogs;

         blogListHolder.clearList();
         blogListHolder.setList(feed!);
         blogListHolder.setBlogType(BlogType.feed);
         notifyListeners();


         }
        notifyListeners();
        //}
    //   });
       
      } on SocketException {
         getCacheBlog();
         notifyListeners(); 
      } catch (e) {

        //  final lines = stackTrace.toString().split('\n');
        // print('Exact line: $lines');
        // debugPrint(e.toString());
        // setLoading(load: false);    
        getCacheBlog();
        notifyListeners();
      }
      // if (prefs!.containsKey('Category')) {
      //   String category = prefs!.getString('Category').toString();
      //   _blog = Category.fromJson(jsonDecode(category));
      // }
    
  // Future categoryBlogs(){
  //   notifyListeners();
  // }


}


   Future getCacheBlog() async{
        feedBlogs = [];
        featureBlogs = [];
        allNewsBlogs = [];
        selectedFeed = [];
        categories=[];

      if (prefs!.containsKey('collection')) {
       String collection = prefs!.getString('collection').toString();
       _blog = DataCollection.fromJson(jsonDecode(collection));

          for (var i = 0; i < _blog!.categories!.length; i++) {
            categories.add(_blog!.categories![i].name ?? '');
          for (var j = 0; j <  _blog!.categories![i].data!.blogs.length; j++) {
            if (!allNewsBlogs.contains(_blog!.categories![i].data!.blogs[j]) && _blog!.categories![i].data!.blogs[j].type != 'ads') {
               allNewsBlogs.add( _blog!.categories![i].data!.blogs[j]);
            }
           
            if ( _blog!.categories![i].isFeed==true && !feedBlogs.contains(_blog!.categories![i].data!.blogs[j])  && _blog!.categories![i].data!.blogs[j].type != 'ads') {
               selectedFeed.add(_blog!.categories![i].id!.toInt());
               feedBlogs.add( _blog!.categories![i].data!.blogs[j]);  
            }

            if (_blog!.categories![i].data!.blogs[j].isFeatured == 1 && !featureBlogs.contains(_blog!.categories![i].data!.blogs[j]) ) {
               featureBlogs.add(_blog!.categories![i].data!.blogs[j]);
            }
           }
         }
         featureBlogs.sort((a, b) { 
            return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
          });
           allNewsBlogs.sort((a, b) { 
           return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
         });
         feedBlogs.sort((a, b) { 
           return b.scheduleDate!.compareTo(a.scheduleDate as DateTime);
        });
         
          // allNewsBlogs = await arrangeAds(allNewsBlogs);
          // feedBlogs = await arrangeAds(feedBlogs);
         
     loadQuotes(false);
     
     feed = DataModel(
          currentPage:  _blog!.categories![0].data!.currentPage,
          firstPageUrl:  _blog!.categories![0].data!.firstPageUrl,
          lastPageUrl: _blog!.categories![0].data!.lastPageUrl,
          nextPageUrl: _blog!.categories![0].data!.nextPageUrl,
          to:  _blog!.categories![0].data!.to,
          lastPage: _blog!.categories![0].data!.lastPage,
          from: _blog!.categories![0].data!.from,
          blogs: feedBlogs
        );
        allNews = DataModel(
          currentPage:  _blog!.categories![0].data!.currentPage,
          firstPageUrl:  _blog!.categories![0].data!.firstPageUrl,
          lastPageUrl: _blog!.categories![0].data!.lastPageUrl,
          nextPageUrl: _blog!.categories![0].data!.nextPageUrl,
          to:  _blog!.categories![0].data!.to,
          lastPage: _blog!.categories![0].data!.lastPage,
          from: _blog!.categories![0].data!.from,
          blogs: allNewsBlogs
        );
      
       allNews!.blogs = allNewsBlogs;
       feed!.blogs = feedBlogs;

      blogListHolder.clearList();
      blogListHolder.setList(feed!);
      notifyListeners();
     }
   }


   void addShareData(ShareType? type,int id){
    shareIds.add(id);
      analytics[3] = {
        'type': type == ShareType.twitter ?
        "share_twitter" : type == ShareType.telegram ? "share_telegram" :
        type == ShareType.whatsapp ? "share_whatsapp" : type == ShareType.mail ? 
        "share_mail" : 'share',
        'blog_ids': shareIds
      };
     notifyListeners();
   }

   void addAppTimeSpent({DateTime? startTime,DateTime? endTime}){
      var data = {
         'type': 'app_time_spent',
         'start_time': startTime,
         'end_time': endTime!.toIso8601String()
      } ;
      analytics.add(data);
      notifyListeners();
   }

     void addBookmarkData(int id){
    bookmarkIds.add(id);
      analytics[1] = {
        'type': 'bookmark',
        'blog_ids': bookmarkIds
    };
    notifyListeners();
   }
   
   void addTtsData(int id,String startTime,String endTime){
    ttsTimeline.add({
      "id" : id,
      "start_time" : startTime,
      "end_time" : endTime
    });
      analytics[7] = {
        'type': 'tts',
        'blog_ids': ttsTimeline
    };
    notifyListeners();
   }

  void removeBookmarkData(int id){
    // if (bookmarkIds.contains(id)) {
    //   bookmarkIds.remove(id);
    // }
    removeBookmarkIds.add(id);
      analytics[6] = {
      'type': 'remove_bookmark',
      'blog_ids': removeBookmarkIds
    };
    // debugPrint(bookmarkIds.toString());
    notifyListeners();
   }
   
    void addPollShare(int id){
    pollIds.add(id);
      analytics[2] = {
        'type': 'poll_share',
        'blog_ids': pollIds
    };
    notifyListeners();
   }
   

    void addviewData(int id){
    viewIds.add(id);
      analytics[4] = {
        'type': 'view',
        'blog_ids': viewIds
    };
    notifyListeners();
   }

   void addLikeData(int id){
    likesIds.add(id);
      analytics[8] = {
        'type': 'like',
        'blog_ids': likesIds
    };
    notifyListeners();
   }

    void addBlogTimeSpent(BlogTime blogtime){
      var data = {
        "type": "blog_time_spent",
        "blogs" : blogTimeSpent
      };
      var data2=  {
        "id": blogtime.id,
        "start_time": blogtime.startTime!.toIso8601String(),
        "end_time": blogtime.endTime!.toIso8601String()
      };
      analytics[0] = data;
      blogTimeSpent.add(data2);
      notifyListeners();
   }


  Future getAnalyticData()async{

    final msg = jsonEncode(analytics);

    final String url = '${Urls.baseUrl}add-analytics';
    final response = await http.post(Uri.parse(url),
      headers: currentUser.value.id != null ? {
        HttpHeaders.contentTypeHeader: 'application/json',
        "api-token" : currentUser.value.apiToken.toString()
      }: {
        HttpHeaders.contentTypeHeader: 'application/json',
        'player_id' : OneSignal.User.pushSubscription.id ?? ""
      },
      body: msg,
    // ignore: data_might_complete_normally_catch_error
    ).catchError((e) {
      // debugPrint("register error $e");
    });
    
    var res = json.decode(response.body);
    
    if (res['success'] == true) {
       setAnalyticData();
       clearAnalytics();
        // debugPrint(res.toString());
      //  debugPrint(analytics.toString());
    }
   }

   void clearAnalytics(){
       viewIds = [];
       likesIds = [];
       shareIds = [];
       ttsIds=[];
       removeBookmarkIds=[];
       blogTimeSpent = [];
       ttsTimeline=[];
       pollIds = [];
       notifyListeners();
   }


   void setAnalyticData(){
    analytics = [{
           "type" : "blog_time_spent",
           "blogs" : []
       },{
          "type" :"bookmark",
          "blog_ids": []
       },{
          "type" :"poll_share",
          "blog_ids": []
       },{
          "type" : "share",
          "blog_ids": []
       },{
          "type" :"view",
          "blog_ids":[]
       },{
          "type" : "sign_in",
          "start_time":"",
       },{
          "type" : "remove_bookmark",
          "blog_ids" : [] 
       },{
          "type" : "tts",
          "blog_ids" : [] 
       },{
         "type": "like",
         "blog_ids": []
       }];
   }

   void addUserSession({bool isSignup=false,isSocialSignup = false,bool isSignin=false}){
      var data = {
        'type' : isSignup ? 'sign_up' :
         isSocialSignup ?  'social_media_signup' : 
         isSignup==false && isSocialSignup==false && isSignin==false ? 
        'social_media_signin' : 'sign_in',
        'start_time':DateTime.now().toIso8601String(),
      };
      analytics[5] = data;
      notifyListeners();
   }

   void clearLists(){
     selectedFeed = [];
     feedBlogs = [];
     bookmarks=[];
    notifyListeners();  
   }


  Future loadMoreBlogs(String url,{BlogType? blogType}) async {
    await getCategory(externalUrl: url,type:blogType);
  }

Future<List<Blog>> arrangeAds(List<Blog> feeds) async{
 List<Blog> blogsWithAds = [];
  int adCount=0;
  int frequencyCount = blogAds.value[adCount].frequency!.toInt();
  for (int i = 0; i < feeds.length; i++) {
    blogsWithAds.add(feeds[i]);

 //  for (int j = 0; j < blogAds.value.length; j++) {
   // if(blogAds.value[adCount].frequency!.toInt()-1 >= i ) {
      if ((i+1) % frequencyCount == 0) {
        blogsWithAds.add(blogAds.value[adCount]);
         if (adCount == blogAds.value.length-1) {
           adCount=0;
        } else {
          adCount += 1;
        }
        frequencyCount += blogAds.value[adCount].frequency!.toInt();
       } 
   //  }
    //}
  }
  return blogsWithAds;
}
}