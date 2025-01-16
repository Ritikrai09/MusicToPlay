

import 'package:flutter/services.dart';

class ScreenTimeout{

   static const platform = MethodChannel('com.signal/screen_wake_lock');

     Future<void> disableScreenAwake() async {
    // setState(() {
    //   _isScreenAwake = false;
    // });
    try {
      await platform.invokeMethod('disableWakelock');
    } on PlatformException catch (e) {
      print("Failed to disable screen wake lock: '${e.message}'.");
    }
  }

   Future<void> enableScreenAwake() async {
    // setState(() {
    //   _isScreenAwake = true;
    // });
    try {
      await platform.invokeMethod('enableWakelock');
    } on PlatformException catch (e) {
      print("Failed to enable screen wake lock: '${e.message}'.");
    }
  }


}