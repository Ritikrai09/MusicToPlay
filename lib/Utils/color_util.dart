import 'package:flutter/material.dart';
import 'package:blogit/Utils/app_theme_colors.dart';

class ColorUtil {
  static const Color themNeutral = Color.fromRGBO(148, 154, 169, 1);
  static const Color borderColor = Color(0xffD8D8D8);
  static const Color dividerColor = Color(0xffE2E2E2);
  static MaterialColor primaryColor =  PrimaryColors.primaryColor1;
  
  static const Color white = Color(0xffE2E2E2);
  static const Color black = Color(0xffE2E2E2);
}


bool dark(context){
return Theme.of(context).brightness == Brightness.dark;
}

String getMonth(int str){
   switch (str) {
      case 1: 
    return 'Jan';
      case 2:
    return 'Feb';
      case 3:
    return 'Mar';
      case 4:
    return 'Apr';
      case 5:
    return 'May';
      case 6:
    return 'Jun';
        case 7:
    return 'Jul';
      case 8:
    return 'Aug';
      case 9:
    return 'Sept';
      case 10:
    return 'Oct';
      case 11:
    return 'Nov';
      case 12:
    return 'Dec';
  default:
    return '';
   }
}