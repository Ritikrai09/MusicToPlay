import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/model/comment.dart';

import '../controller/user_controller.dart';
import 'home.dart';

class DataCollection {
 DataCollection({
      this.success,
      this.categories,
  });

bool? success;
List<Category>? categories;


  DataCollection.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
        categories = <Category>[];
      json['data'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }
  }
}



class Category{
    Category({
      this.id,
      this.name,
      this.image,
      
      this.color,
      this.data,
      this.isFeed,
      this.createdAt,
      this.title,
      this.isFeatured,
      this.updatedAt,
      this.parentId,
      this.blogSubCategory,
    });

  String? name,image,color,title;
  int? id,parentId;
  int? isFeatured;
  bool? isFeed;
  List<BlogSubCategory>? blogSubCategory;
  DataModel? data;
  DateTime? createdAt,updatedAt;

    factory Category.fromJson(Map<String, dynamic> map){
     var blogs = map['blogs'];
     if(map.containsKey('color')){
      
     blogs['category_color'] = map['color'];
     blogs['category_name'] = map['name'];
     }
    return Category(
      id:map['id'] ?? 0,
      name: map['name'],
      title : map['title'],
      parentId: map["parent_id"],
      isFeatured: map['is_featured'] ?? 0, 
      image: map['image'] ?? '',
      color: map['color'] ?? '#000000',
      isFeed : map['is_feed'],
      blogSubCategory: map.containsKey('blog_sub_category') && map['blog_sub_category'] != null && map['blog_sub_category'] != []?
      map['blog_sub_category'].map((e){
        return BlogSubCategory.fromJson(e);
      }).toList() : [],
      data: DataModel.fromJson(blogs),
    );
  }

}

class QuestionModel {
  int? id;
  String? question;
  List<PollOption>? options;

  QuestionModel({
      this.id,
      this.question,
      this.options
  });

  QuestionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    if (json['options'] != null) {
      options = <PollOption>[];
      json['options'].forEach((v) {
        options!.add( PollOption.fromJSON(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Blog {
  int? id;
  String? type;
  String? title;
  int? likes;
  String? videoFile;
  String? video;
  String? description;
  String? sourceName;
  String? sourceLink;
  String? voice;
  int? categoryIndex;
  String? accentCode;
  String? videoUrl;
  int? isVotingEnable;
  DateTime? scheduleDate;
  String? createdAt;
  String? updatedAt;
  String? backgroundImage;
  bool? isFeed;
  int? isVote;
  String? categoryColor;
  int? isBookmark;
  int? isUserViewed;
  List? visibilities;
  int? frequency;
  String? mediaType,media,imageUrl;
  QuestionModel? question;
  List? images;
  PostType? postType;
  List<int>? blogSubCategory;
   CommentModel? comments;
  String? categoryName;
  Size? dimensions;
  int? isUserLiked;
  int? isFeatured;
  Uint8List? audioData;
  

  Blog({
      this.id,
      this.frequency,
      this.type,
      this.title,
      this.description,
      this.isFeatured,
      this.sourceName,
      this.sourceLink,
      this.voice,
      this.videoFile,
      this.accentCode,
      this.comments,
      this.videoUrl,
      this.isVotingEnable,
      this.scheduleDate,
      this.createdAt,
      this.updatedAt,
      this.postType,
      this.backgroundImage,
      this.isFeed,
      this.categoryName,
      this.isVote,
      this.isBookmark,
      this.isUserViewed,
      this.visibilities,
      this.question,
      this.images,
      this.dimensions,
      this.categoryColor,
      this.mediaType,
      this.media,
      this.audioData,
      this.isUserLiked,
      this.categoryIndex,
      this.likes,
      this.blogSubCategory});


  Blog.fromJson(Map<String, dynamic> json,{isNotification = false,isCache = false,isAds = false}) {
    id = json['id'] ?? 0;
    type = isAds ? 'ads' :  json['type']?? 'post';
    title = json['title']??'';
    categoryIndex = json['index'];
    likes = json.containsKey('like_count') ? json['like_count'] : 0; 
    description =  isAds ? '' : json['description'] ?? '';
    sourceName =  json['source_name'];
    sourceLink = json['source_link']??'';
    isUserLiked = json['is_user_liked'] ?? 0;
    if (allSettings.value.isVoiceEnabled == true && allSettings.value.googleApikey != '') {
    audioData = json['audioData'];
    }
    voice = isAds ? '' : json['voice']??'';
    imageUrl = isAds ? json["image_url"] ?? '': null;
    mediaType = isAds ?json["media_type"] ?? '': null;
    media  = isAds ? json["media"] ?? '': null;
    accentCode = isAds ? '' :json['accent_code']??'en';
    frequency = isAds ? json['frequency'] : 0;
    // controller =  json['video_file'] != null || json['video_url'] != null || json['media'] != null ? 
    //   PodPlayerController(
    //   playVideoFrom :json['video_file'] != null  ? 
    //   PlayVideoFrom.network(json['video_file']  != null 
    //   ? json['video_file']  ?? "" 
    //   : json['media'] ?? "") :
    //   PlayVideoFrom.youtube( json['video_url'] ?? ""),
    //   podPlayerConfig:  PodPlayerConfig(
    //     videoQualityPriority: [720, 480, 360],
    //     autoPlay: false,
    //     isLooping: true,
    //     isShowDuration: json['type'] == 'post' || json.containsKey('dimensions'),
    //     isFullScreen: json['type'] == 'post',
    //     isPlayCenter: json['type'] == 'post' || json.containsKey('dimensions')
    //   )
    // ) : null; 
    comments = json.containsKey('comments') ? CommentModel.fromJson(json['comments']) : null; 
    videoUrl = json['video_url']?? '';
    categoryColor = isNotification ? json['blog_category'][0]['category']['color']  : json['category_color'] ?? "#000000" ;
    categoryName = isNotification ? json['blog_category'][0]['category']['name']  : json['category_name'] ?? "";
    isVotingEnable =isAds ? 0 :json['is_voting_enable'] ?? 0;
    postType = getPostType(json['type']);
    isFeatured = json.containsKey('is_featured') ? json['is_featured'] ?? 0 : 0;
    scheduleDate = isAds ? DateTime.now() : DateTime.parse(json['schedule_date']);
    createdAt = json['created_at']??'';
    updatedAt = json['updated_at']??'';
    backgroundImage = isAds ? '' : json['background_image'] ?? '';
    isFeed =  json['is_feed'] ?? false ;
    isVote = isAds ? 0 :json['is_vote'] ?? 0;
    isBookmark = isAds ? 0 : json['is_bookmark'] ?? 0;
    isUserViewed = isAds ? 0 :json['is_user_viewed'] ?? 0;
    visibilities = isAds ? [] : json['visibilities'] ?? [];
    dimensions  = isAds ? json['dimensions']!=null ? Size(
      double.parse(json['dimensions'].toString().split('x')[0]),
      double.parse(json['dimensions'].toString().split('x')[1])) : null : null;
    question = isAds ? null : json['question'] != null? QuestionModel.fromJson(json['question']) : null;
    videoFile =json['video_file'];
    images = isAds ? [] :json['images'];
    
     if (json['blog_sub_category_ids'] != []) {
    if (json.containsKey('blog_sub_category_ids')) {
      blogSubCategory = [];
      json['blog_sub_category_ids'].forEach((v) {
        if(v['blog_sub_category_ids'] != null) {
         blogSubCategory!.add(int.parse(v.toString()));
        }
     
      });
    }
   }

  }

  PostType getPostType(data){
    switch (data) {
      case 'ads':
        return PostType.ads;
      case 'post':
        return PostType.image;
      case 'video':
         return PostType.video;
      case 'quote':
         return PostType.quote;
      default:
        return PostType.image;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['title'] = title;
    data['description'] = description;
    data['source_name'] = sourceName;
    data['source_link'] = sourceLink;
    data['voice'] = voice;
    data['accent_code'] = accentCode;
    data['video_url'] = videoUrl;
    data.containsKey('like_count') ? data['like_count'] = likes : 0; 
    if (allSettings.value.isVoiceEnabled == true && allSettings.value.googleApikey != '') {
      data["audioData"] = audioData;
    }
    data['is_voting_enable'] = isVotingEnable;
    data['schedule_date'] = scheduleDate!.toIso8601String();
    data['created_at'] = createdAt;
    data["image_url"] = imageUrl;
    data["media_type"] = mediaType;
    data["media"] = media;
    data['category_color'] = categoryColor;
    data['category_name'] = categoryName;
    data['updated_at'] = updatedAt;
    data['background_image'] = backgroundImage;
    data['is_feed'] = isFeed;
    data['is_vote'] = isVote;
    data['is_bookmark'] = isBookmark;
    data['is_user_viewed'] = isUserViewed;
    data['visibilities'] = visibilities;
    data['question'] = question;
    data['is_featured'] = isFeatured;
    data['is_user_viewed'] = isUserViewed;
    data['index'] = categoryIndex;
    data['video_file'] = videoFile;
    if (comments != null) {
      data['comments'] = comments;
    }
    data['images'] = images;
    if (blogSubCategory != null) {
      data['blog_sub_category_ids'] =
          blogSubCategory!.map((v) => v).toList();
    }
    if (question != null) {
      data['question'] = question!.toJson();
    }
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Blog &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          description == other.description;
          
    @override
  int get hashCode => id.hashCode;
          
}

enum BlogAction{ bookmark, share }

class PollOption{
  PollOption({
     this.id,
     this.option,
     this.percentage
  });

  String? option;
  dynamic percentage;
  int? id;
  
  PollOption.fromJSON(Map<String,dynamic> map){
    id = map['id'];
    option= map['option'];
    percentage= map['percentage'];
  }

  Map toJson(){
   return {
       "id": id,
       "option": option,
       "percentage" : percentage
    };
  }

}

class DataModel {
   DataModel({
       this.currentPage,
       this.nextPageUrl,
       this.prevPageUrl,
       this.from,
       this.path,
       this.perPage,
       this.to,
       this.total,
       this.lastPage,
       this.blogs= const [],
       this.firstPageUrl,
       this.lastPageUrl
    });
     String? nextPageUrl,prevPageUrl,path,firstPageUrl,lastPageUrl;
     List<Blog> blogs=[];
     int? to,from,total,lastPage,perPage,currentPage;


  Map toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['current_page'] = currentPage;
   if( blogs.isNotEmpty ){
       data['data'] =  blogs.map((e) => e.toJson()).toList();
   }
    data['to'] = to;
    data['first_page_url'] = firstPageUrl;
    data['from'] = from;
    data['last_page'] = lastPage;
    data['last_page_url'] = lastPageUrl;
    data['next_page_url']= nextPageUrl ;
    data['path'] = path;
    data['per_page'] = perPage;
    data['prev_page_url']=prevPageUrl ;
    data['total']=total;

    return data;
  }

   DataModel.fromJson(Map<String, dynamic> json,{bool isSearch = false, bool isShorts = false}) {
    var cat;
    currentPage =json.containsKey('current_page') ? json['current_page'] ?? 0 :0;
 
    if (json['data'] != []) {
      blogs = <Blog>[];
      json['data'].forEach((v) {
         if (v.containsKey('blog_category')) {
            if (v['blog_category'] != null) {
           v['blog_category'].forEach((e){
               cat = e['category'];
           });
             v["category_color"] = cat['color']; 
              v["category_name"] = cat['name']; 
            }
         }else{
           if (json.containsKey('category_color')) {
              v["category_color"] = json['category_color']; 
              v["category_name"] = json['category_name']; 
          }
         }
          blogs.add(Blog.fromJson(v));
      });
      if (isShorts == true) {
        blogs.sort((a, b) => DateTime.parse(b.createdAt??"").compareTo(DateTime.parse(a.createdAt ?? "")));
      }
    }
    firstPageUrl = json['first_page_url'];
    from = json['from'];
    lastPage = json['last_page'];
    lastPageUrl = json['last_page_url'];
    nextPageUrl = json['next_page_url'];
    path = json['path'];
    perPage = json['per_page'];
    prevPageUrl = json['prev_page_url'];
    to = json['to'];
    total = json['total'];
  }

}

class BlogSubCategory {
  int? id;
  int? parentId;
  String? name;
  String? slug;
  String? image;
  String? color;
  int? order;
  int? status;
  int? isFeatured;
  String? createdAt;

  BlogSubCategory(
      {this.id,
      this.parentId,
      this.name,
      this.slug,
      this.image,
      this.color,
      this.isFeatured,
      this.createdAt,
    });

  BlogSubCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    parentId = json['parent_id'];
    name = json['name'];
    slug = json['slug'];
    image = json['image'];
    color = json['color'];
    isFeatured = json['is_featured'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['parent_id'] = parentId;
    data['name'] = name;
    data['slug'] = slug;
    data['image'] = image;
    data['color'] = color;
    data['order'] = order;
    data['status'] = status;
    data['is_featured'] = isFeatured;
    data['created_at'] = createdAt;
    return data;
  }
}

String? likeVisible(Blog model ,AppProvider provider3) {
    Blog  model2 = model;
    var i = model2.likes == 1 ? model2.likes!.toInt() :
     provider3.permanentlikesIds.contains(model2.id) ? 
     model2.likes!.toInt() : model2.likes!.toInt()-1;
    var data = provider3.permanentlikesIds.contains(model2.id) ?
     formatNumber(i) : model2.likes != null && model2.likes == 0 ?
      '0' : formatNumber(model2.likes!.toInt()-1);
    
    return data == '0' ?
           provider3.permanentlikesIds.contains(model2.id) 
            ? "${i+1}" 
            : '0' 
           : data;
        
  }


 String formatNumber(int number) {
    // Create a compact format
    NumberFormat compactFormat = NumberFormat.compact();
    // Format the number
    return compactFormat.format(number);
  }