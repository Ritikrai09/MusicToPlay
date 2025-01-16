import '../model/blog.dart';

class BlogListHolder {
  DataModel _list = DataModel();
  BlogType blogType = BlogType.feed;
  int _index = 0;

  int getIndex() => _index;
  DataModel getList() => _list;

  void setIndex(int index) {
    _index = index;
  } 
  
   void updateList(DataModel list) {
    // _list.currentPage = list.currentPage;
    // _list.firstPageUrl = list.firstPageUrl;
    // _list.lastPageUrl = list.lastPageUrl;
    _list.nextPageUrl = list.nextPageUrl;
    // _list.to = list.to;
    // _list.prevPageUrl = list.prevPageUrl;
    // _list.lastPage = list.lastPage;
    // _list.from = list.from;
    var dataList = list.blogs;
     List<Blog>? copyList = List.from(_list.blogs);
    for (var element in dataList) { 
       copyList.add(element);
    }
    _list.blogs = copyList;
  }



  void setBlogType(BlogType list) {
    blogType = list;
  }

  void setList(DataModel list) {
    _list = list;
  }

  void clearList() {
    _list = DataModel();
  }
}

BlogListHolder blogListHolder = BlogListHolder();
BlogListHolder blogListHolder2 = BlogListHolder();

enum BlogType{
  feed,
  allnews,
  featured,
  category,
  bookmarks,
  search
}