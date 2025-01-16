import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/widgets/widgets.dart';

import '../../../Utils/anim_util.dart';
import '../../../Utils/color_util.dart';
import '../../../controller/app_provider.dart';
import '../../../controller/user_controller.dart';
import '../../../main.dart';
import '../../../model/settings.dart';
import 'Home_wrapper/home_wrapper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserProvider user = UserProvider();

  void showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  void initState() {
    if (upgrader != null && upgrader!.isUpdateAvailable() == true ) {
      return;
    } else {
       startCall();
    }
   
    prefs!.remove('id');

    super.initState();
  }

  Future startCall() async {
    var of = Provider.of<AppProvider>(context, listen: false);
    //  user.adBlogs();
    if (!prefs!.containsKey('local_data')) {
      //  user.checkSettingUpdate();
      if (allSettings.value.enableMaintainanceMode != '1') {
        user.getLanguageFromServer(context).then((value) async {
          if (currentUser.value.id != null) {
            of.getCategory(allowUpdate: false).whenComplete(switchToPage);
          } else {
            switchToPage();
          }
        });
      }
    } else {
      // user.checkSettingUpdate();
      //  if (currentUser.value.id != null) {
      // if(allSettings.value.enableMaintainanceMode != '1'){
      of.getCategory(allowUpdate: false).then((value) {
        switchToPage();
      });
      // }
      // } else {
      //    Future.delayed(const Duration(milliseconds: 2500),() {
      //    switchToPage();
      //  });
      // }
    }
  }

  FutureOr<void> switchToPage() {
    //  ShortsApi().fetchShorts(context);
    //if (prefs!.containsKey('maintain') && prefs!.getBool('maintain') == false) {
    if (prefs!.getString('url') != '2') {
      if (currentUser.value.id != null) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeWrapper()),
            (route) => false);
      } else {
        // if (!prefs!.containsKey('local_data' )) {
        //      Navigator.pushNamedAndRemoveUntil(context, '/GetStarted',(route) => false);
        //   }else{
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const Login(isFromHome: false)),
            (route) => false);
        // }
      }
    }
    //}
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // onWillPop: () async{
      //   return false;
      // },
      child: ValueListenableBuilder<SettingModel>(
          valueListenable: allSettings,
          key: ValueKey(allSettings.value.enableMaintainanceMode),
          builder: (context, value, child) {
            return AnnotatedRegion(
              value: SystemUiOverlayStyle(
                  statusBarIconBrightness:
                      dark(context) ? Brightness.light : Brightness.dark,
                  statusBarColor: Colors.transparent),
              child: const Scaffold(
                body: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: AnimationFadeScale(
                          duration: 600,
                          child: AnimationFadeSlide(
                              duration: 700,
                              dy: 0.5,
                              child: TheLogo(
                                width: 120,
                                height: 120,
                                logo: false,
                              )
                          ))
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
