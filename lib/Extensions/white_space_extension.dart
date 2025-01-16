// ignore_for_file: unnecessary_this

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension SmartHeight on double {
  SizedBox height() {
    return SizedBox(
      height: this.h,
    );
  }

  SizedBox width() {
    return SizedBox(
      width: this.w,
    );
  }
}
