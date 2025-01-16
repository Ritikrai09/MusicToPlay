import 'package:flutter/material.dart';
import 'package:blogit/Utils/color_util.dart';

class AppModel {
  ValueNotifier<bool> isDarkModeEnabled = ValueNotifier(false);
  ValueNotifier<bool> isUserLoggedIn = ValueNotifier(false);
  ValueNotifier<bool> isNotificationEnabled = ValueNotifier(true);
  ValueNotifier<Color> primaryColor = ValueNotifier(ColorUtil.primaryColor);
  AppModel();

  AppModel.fromMap(Map data) {
    isDarkModeEnabled.value = data['isDarkModeEnabled'] as bool;
    isUserLoggedIn.value = data['isUserLoggedIn'] as bool;
    isNotificationEnabled.value = data['is_notification_enabled'] as bool;
    primaryColor.value =  isHexColor(data['primary_color'].toString()) ? hexToColor(data['primary_color']) : data['primary_color'];
  }

  bool isHexColor(String value) {
  RegExp colorRegex = RegExp(r'^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$');
  return colorRegex.hasMatch(value);
}

  Map toMap() {
   
    return {
      'isDarkModeEnabled': isDarkModeEnabled.value,
      'isUserLoggedIn': isUserLoggedIn.value,
      'is_notification_enabled' : isNotificationEnabled.value,
      'primary_color' : materialColorToHex(primaryColor.value)
    };
  }
}

Color hexToColor(String hexColor) {
  hexColor.replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF$hexColor";
  }
  return Color(int.parse(hexColor, radix: 16));
}

String materialColorToHex(Color color) {
return color.value.toRadixString(16).substring(2);
}

String customDate(DateTime date){
return  "${date.day} ${getMonth(date.month)} ${date.year}";
}