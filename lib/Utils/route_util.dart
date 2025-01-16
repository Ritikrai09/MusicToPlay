
import 'package:flutter/cupertino.dart';
import 'package:blogit/presentation/screens/Auth/Forget_password/otp.dart';
import 'package:blogit/presentation/screens/Auth/Forget_password/reset_password.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/screens/Auth/Register/register.dart';
import 'package:blogit/presentation/screens/Main/Article_details/article_details.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:blogit/presentation/screens/Main/splash_screen.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/Profile/Edit_profile/edit_profile.dart';
import 'package:blogit/Utils/blank_util.dart';
import 'package:blogit/model/blog.dart';

import '../presentation/screens/web_view.dart';
import '../presentation/widgets/nav_util.dart';
// import 'package:http/http.dart' as http;

class RouteGenerator {

  static Route<dynamic>? generateRoute(RouteSettings settings)  {
    dynamic args = settings.arguments;
    switch (settings.name) {
     
  
      case '/SignUp':
        return PagingTransform(widget: const Register());
      // case '/LanguageSelection':
      //   return PagingTransform(widget:  Sel(isSetting: args ?? false),
      //   );
      case '/Home':
        return PagingTransform(widget: const HomeWrapper());
     
      case '/Article':
        return CupertinoPageRoute(builder:(context)=> ArticleDetails(blog: args[0],
        likes: args.length > 1 ? args[1].toString() : '0',action: args.length > 2 ? args[2] : false));
        // case '/BlogWrap':
        // return PagingTransform(widget: BlogWrapPage());
      case '/LoginPage':
        return PagingTransform(widget:const Login());
      case '/UserProfile':
        return PagingTransform(widget: const EditProfile());
      case '/weburl':
        return PagingTransform(widget: CustomWebView(url: args ));
       case '/OTP':
        return PagingTransform(widget: OtpScreen(mail: args));
      // case '/SearchPage':
      //   return PagingTransform(widget:const SearchPage());
      // case '/SettingPage':
      //   return PagingTransform(widget:const SettingPage());
      // case '/SavedPage':
      //   return PagingTransform(widget: const BookmarkPage());

      case "/Splash":
        return PagingTransform(widget:const SplashScreen());
    
      case '/ResetPage':
        return PagingTransform(widget: ResetPassword(isReset: args[0],mail: args[1]));
     
      case '/Story':
        return PagingTransform(widget:
        StoryPage(blog: args[0],isShare: args.length > 1 ? args[1] : false,
      ));

      default : {

        if(settings.name != null && (settings.name!.contains('/blog/') || settings.name!.contains('/quote/'))){
                   
          var split = settings.name!.split('/');
          var id  = int.parse(split.last);
          String? action = settings.name!.contains('/Share/') || settings.name!.contains('/Bookmark/') 
          ? split[split.length-2] : null;
          
         return PagingTransform(widget: Loader(blog: Blog(id: int.parse(id.toString())),action: action));
     
       } else {

         return PagingTransform(widget:const SplashScreen());
       
       }
      }
     }
    }
}
