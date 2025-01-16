
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/main.dart';
import 'package:blogit/model/blog.dart';

class Loader extends StatefulWidget {
  const Loader({super.key,required this.blog,this.action});
  final String? action;
  final Blog blog;

  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> {

late Blog blog;
  
@override
 void initState(){
  blog = widget.blog;
   WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
    var provider = Provider.of<AppProvider>(context,listen:false);
     await blogDetail(blog.id.toString()).then((value) async{
      if (prefs!.containsKey('id')) {
        
        if (currentUser.value.id==null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeWrapper()));
        }
        provider.setAnalyticData();
        await provider.getCacheBlog();
        await inactiveState(value);
      } else {
        activeState(value);
      } 
    });
   });
   super.initState();
 }

Future activeState(Blog value) async{
   if (value.type == 'quote') {
   Navigator.pushReplacementNamed(context, '/Story',arguments: [
    value,widget.action == 'Share' ?  BlogAction.share: false
  ]);
   } else {
  Navigator.pushReplacementNamed(context,"/Article",
   arguments: [ 
   value,value.likes,
   widget.action == 'Share' ?  
    BlogAction.share
    : widget.action == 'Bookmark' ? 
     BlogAction.bookmark
    : null
   ]);
   }
}

Future inactiveState(Blog value) async{
   if (value.type == 'quote') {
    
   Navigator.pushNamed(context, '/Story',arguments: [
    value,widget.action == 'Share' ?  BlogAction.share: false
  ]);
   } else {
  Navigator.pushNamed(context,"/Article",
   arguments: [ 
   value,value.likes,
   widget.action == 'Share' ?  BlogAction.share
    : widget.action == 'Bookmark' ?  BlogAction.bookmark: null
   ]);
   }
}

  @override
  Widget build(BuildContext context) {
    return  const CustomLoader(
        isLoading: true, 
        opacity: 0.6,
        child: Opacity(
          opacity: 0.3,
          child: Material(
            color: Colors.transparent,
          ),
        )
    );
  }
}