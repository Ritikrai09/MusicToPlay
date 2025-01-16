class CommentModel{

  CommentModel({
        this.data
    });
   List<Comment>? data;


  CommentModel.fromJson(Map<String, dynamic> json) {
     if (json['data'] != null) {
       data = <Comment>[];
       json['data'].forEach((e){
          data!.add(Comment.fromJson(e)); 
       });
       data!.sort((a,b)=> DateTime.parse(b.createdAt.toString()).compareTo(DateTime.parse(a.createdAt.toString())));
     } 
  }

   Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
     if (data != null) {
      json['data'] = data!.map((v) => v.toJson()).toList();
    }
   return json; 
  }
}

class Comment {
  int? id;
  int? userId;
  int? blogId;
  String? comment;
  DateTime? createdAt;
  String? updatedAt;
  CommentUser? user;

  Comment(
      {this.id,
      this.userId,
      this.blogId,
      this.comment,
      this.createdAt,
      this.updatedAt,
      this.user});

  Comment.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    blogId = json['blog_id'];
    comment = json['comment'];
    createdAt = DateTime.tryParse(json['created_at']);
    updatedAt = json['updated_at'];
    user = json['user'] != null ?  CommentUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['blog_id'] = blogId;
    data['comment'] = comment;
    data['created_at'] = createdAt!.toIso8601String();
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class CommentUser {
  int? id;
  String? name;
  String? photo;

  CommentUser({this.id, this.name, this.photo});

  CommentUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['photo'] = photo;
    return data;
  }
}