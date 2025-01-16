import 'dart:io';

import 'package:blogit/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TheLogo extends StatelessWidget {
  const TheLogo({super.key,this.rectangle = false,this.logo=true,this.height,this.width});
  final bool rectangle, logo;
  final double? width,height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:height?? 28.h,
      width:width??  30.w,
      child:  rectangle == true ? 
        prefs!.containsKey('rect_logo') ?
        Image.file(File(prefs!.getString('rect_logo') ?? ""),width: height, height: height)
       : Image.asset("asset/Images/Logo/Signal.png", width: height, height: height)
      : logo == false ? 
      prefs!.containsKey('splash_logo') ?
        Image.file(File(prefs!.getString('splash_logo') ?? ""),width: height, height: height)
       : Image.asset("asset/Images/Logo/Signal.png", width: height, height: height)
      : prefs!.containsKey('app_logo') ?
        Image.file(File(prefs!.getString('app_logo') ?? ""),width: height, height: height)
       : Image.asset("asset/Images/Logo/Signal.png", width: height, height: height)
         
    );
  }
}
