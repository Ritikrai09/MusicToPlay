import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/model/lang.dart';
import 'package:blogit/model/messages.dart';

import '../controller/user_controller.dart';
import '../main.dart';
import '../model/cms.dart';
import '../model/settings.dart';
import 'app_util.dart';


ValueNotifier<AppModel> appThemeModel = ValueNotifier(AppModel());


Color hexToRgb(String? hexColor) {
  if (hexColor != null && hexColor.isNotEmpty) {
    hexColor = hexColor.replaceAll('#', '');
  int hexValue = int.parse(hexColor, radix: 16);
  int alpha = 255;
  int red = (hexValue >> 16) & 0xFF;
  int green = (hexValue >> 8) & 0xFF;
  int blue = hexValue & 0xFF;
   return isBlack(Color.fromARGB(alpha, red, green, blue)) ?
     appThemeModel.value.isDarkModeEnabled.value ?
     Colors.grey.shade400  : Color.fromARGB(alpha, red, green, blue)
     : Color.fromARGB(alpha, red, green, blue) ;
  }
   return const Color.fromRGBO(255, 134, 44,1);
}

toggleDarkMode(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': value,
    'isUserLoggedIn': model.isUserLoggedIn.value,
    'is_notification_enabled': model.isNotificationEnabled.value,
    'primary_color' : model.primaryColor.value
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

bool isBlack(Color color){
  return color.red <=  80 &&  color.blue <= 80 && color.green <= 80;
}

togglePrimaryColor(Color value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled':  model.isDarkModeEnabled.value,
    'primary_color' : value,
    'isUserLoggedIn': model.isUserLoggedIn.value,
    'is_notification_enabled': model.isNotificationEnabled.value,
  });
  
  // debugPrint(appThemeModel.value.toMap().toString());
  saveDataToSharedPrefs(appThemeModel.value);
}

toggleSignInOut(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': model.isDarkModeEnabled.value,
    'isUserLoggedIn': value,
    'primary_color' : model.primaryColor.value,
    'is_notification_enabled': model.isNotificationEnabled.value,
  });
  saveDataToSharedPrefs(appThemeModel.value);
}

toggleNotify(bool value) {
  AppModel model = appThemeModel.value;
  appThemeModel.value = AppModel.fromMap({
    'isDarkModeEnabled': model.isDarkModeEnabled.value,
    'isUserLoggedIn': model.isUserLoggedIn.value,
    'is_notification_enabled':value,
    'primary_color' : model.primaryColor.value
  });
  saveDataToSharedPrefs(appThemeModel.value);
}


saveDataToSharedPrefs(AppModel model) async {
  SharedPreferences? preferences =
     await SharedPreferences.getInstance();
  try {
    preferences.setString('app_data', json.encode(model.toMap()));
    // print(model.toMap());
  // ignore: empty_catches
  } on Exception catch (e) {
    throw Exception(e);
    // print(e);
  }
}

getDataFromSharedPrefs() async {
  try {
  if (prefs!.containsKey('app_data')) {
    AppModel model = AppModel.fromMap(
        json.decode(prefs!.getString('app_data').toString()));
    appThemeModel.value = model;
    //  debugPrint(model.toMap().toString());
  } else {
    // initializing app_data in sharedPreferences with default values
    saveDataToSharedPrefs(AppModel());
  }
} on Exception catch (e) {
  throw Exception(e);
  // debugPrint(e.toString());
}
}

getMessageAndSetting(){
  if (prefs!.containsKey('local_data')) {
    allMessages.value = Messages.fromJson(json.decode(prefs!.getString('local_data').toString()));
  }
  if (prefs!.containsKey('setting')) {
    allSettings.value = SettingModel.fromJson(json.decode(prefs!.getString('setting').toString()));
  }
  if (prefs!.containsKey('languages')) {
    allLanguages= [];
   json.decode(prefs!.getString("languages").toString()).forEach((lang){
        allLanguages.add(Language.fromJson(lang));
      });
  }
  if (prefs!.containsKey('defalut_language')) {
     String lng = prefs!.getString("defalut_language").toString();
    languageCode.value = Language.fromJson(json.decode(lng));
  }
   if (prefs!.containsKey('OffAds')) {
    allCMS=[];
      final ads = prefs!.getString('OffAds').toString();
      json.decode(ads)['data'].forEach((language) {
        allCMS.add(CmsModel.fromJson(language));
      });
   }
}

bool isWhiteRange(Color color) {
  const int threshold = 200;
  return color.red >= threshold && color.green >= threshold && color.blue >= threshold;
}

class AppTheme {
  static OutlineInputBorder get border => OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(width: 1, color: Color(0xffE7EBF6)));
       static OutlineInputBorder get borderDark => OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(width: 1, color: Color.fromARGB(255, 90, 89, 89)));
    
  static ThemeData? darkThemeData (Color color)=> ThemeData(
        dividerColor: const Color(0xff4B4B4B),
        primaryColorDark: color,
        primaryColorLight: color,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white)
        ),
        appBarTheme: const AppBarTheme(color: Color.fromRGBO(40, 40, 40, 1)),
        scaffoldBackgroundColor: const Color.fromRGBO(30, 30, 30, 1),
         dividerTheme: const DividerThemeData(color: Color(0xff4B4B4B)),
        tabBarTheme: TabBarTheme(
            labelStyle: TextStyle(
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,  
            ),
            unselectedLabelStyle: TextStyle(
                fontFamily: 'QuickSand',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp),
            unselectedLabelColor: Colors.white.withOpacity(.75),
            labelColor: appThemeModel.value.primaryColor.value,
            indicator:
                CircleTabIndicator(color: color, radius: 4)),
        colorScheme: ColorScheme(
               primary: color,
            surface: Colors.black,
            error: Colors.red,
            onPrimary: Colors.white,

            ///WE DON'T HAVE ENOUGH OPTIONS TO CONFIGURE CUSTOM COLOR
            ///SO WE ARE CONVERTING THIS TO THE LOGO COLORS...
            secondary: AppColor.secondaryDark,
            onSecondary: AppColor.onSecondaryDark,
            ////

            onSurface: Colors.white,
            onError: Colors.red,
            brightness: Brightness.dark),
        fontFamily: 'QuickSand',
        inputDecorationTheme: InputDecorationTheme(
            constraints: const BoxConstraints(maxHeight: 40),
            filled: true,
            fillColor: Colors.grey.shade800,
            border: AppTheme.borderDark,
            focusedBorder: AppTheme.borderDark,
             enabledBorder:  AppTheme.borderDark,
            disabledBorder: AppTheme.borderDark),
        primaryColor: color,
         popupMenuTheme: const PopupMenuThemeData(
          color: Color.fromRGBO(25, 25, 25, 1)
        ),
        brightness: Brightness.dark,
        cardColor: const Color.fromRGBO(10, 10, 10, 1),
      //  scaffoldBackgroundColor: ,
      );
 static ThemeData?  lightTheme (Color color)=> ThemeData(
        dividerColor: const Color(0xffF3F3F3),
        primaryColorDark: color,
        primaryColorLight: color,
        
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.black)
        ),
        dividerTheme: const DividerThemeData(color:  Color(0xffF3F3F3)),
        tabBarTheme: TabBarTheme(
            labelStyle: TextStyle(
              fontFamily: 'QuickSand',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
            unselectedLabelStyle: TextStyle(
                fontFamily: 'QuickSand',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp),
            unselectedLabelColor:
                AppColor.scaffoldBackGroundDark.withOpacity(.75),
            labelColor: AppColor.scaffoldBackGroundDark,
            indicator:
                CircleTabIndicator(color: appThemeModel.value.primaryColor.value, radius: 4)),
        colorScheme: ColorScheme(
            primary: color,
            surface: Colors.white,
            error: Colors.red,
            onPrimary: Colors.white,

            ////
            secondary: AppColor.secondaryLight,
            onSecondary: AppColor.onSecondaryLight,
            ////

            onSurface: Colors.black,
            onError: Colors.red.withOpacity(.70),
            brightness: Brightness.light),
        fontFamily: 'QuickSand',
        inputDecorationTheme: InputDecorationTheme(
            constraints: const BoxConstraints(maxHeight: 40),
            filled: true,
            fillColor: color.withOpacity(0.2),
            border: AppTheme.border,
            enabledBorder: AppTheme.border,
            focusedBorder: AppTheme.border,
            disabledBorder: border),
        primaryColor:color,
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white
        ),
        brightness: Brightness.light,
        cardColor: const Color.fromRGBO(235, 235, 235, 1.0),
        scaffoldBackgroundColor:  Colors.white,
      );
}

class CircleTabIndicator extends Decoration {
  final BoxPainter _painter;

  CircleTabIndicator({required Color color, required double radius})
      : _painter = _CirclePainter(color, radius);

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) => _painter;
}

class _CirclePainter extends BoxPainter {
  final Paint _paint;
  final double radius;

  _CirclePainter(Color color, this.radius)
      : _paint = Paint()
          ..color = color
          ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final Offset circleOffset =
        offset + Offset(cfg.size!.width / 2, cfg.size!.height - radius);
    canvas.drawCircle(circleOffset, radius, _paint);
  }
}
