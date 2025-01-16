import 'package:blogit/Utils/urls.dart';
import '../model/blog.dart';

Future<String> createDynamicLink(Blog blog) async {

    
  
    String? url= "${Urls.mainUrl}share-blog?blog_id=${blog.id}";

    return url.toString();
  }


//   Future initializeLink()async{
//  final initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

//    if (initialLink != null) {
//      final uriLink = initialLink.link;
//       print('my link generated ${uriLink.data}');
//    } 
  
//   }


