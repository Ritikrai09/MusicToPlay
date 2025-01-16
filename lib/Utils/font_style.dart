///FRAME WORK IMPORT..
library;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

///WE HAVE CONFIGURED THIS CLASS WITH COLOR INHERITANCE OF THE APP NOW IT NOT
///DEPENDS UPON LOCALLY DEFINED COLORS...

/// THIS ENUM IS USED TO MANAGE FONT_WEIGHT...
enum FWT { light, regular, medium, semiBold, bold, extrabold }

/// THIS CLASS IS USED TO MANAGE FONT_STYLES USED IN THE APPLICATION...
class FontStyleUtilities {
  /// THIS FUNCTION RETURNS FONT_WEIGHT ACCORDING TO USER REQUIREMENT(FROM ENUM)...
  static FontWeight getFontWeight({FWT? fontWeight = FWT.regular}) {
    switch (fontWeight) {
      case FWT.extrabold:
        return FontWeight.w800;
      case FWT.bold:
        return FontWeight.w700;
      case FWT.semiBold:
        return FontWeight.w600;
      case FWT.medium:
        return FontWeight.w500;
      case FWT.regular:
        return FontWeight.w400;
      case FWT.light:
        return FontWeight.w300;
      default:
        return FontWeight.w400;
    }
  }

  /// FONT_STYLE FOR FONT SIZE 34
  static TextStyle h1(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 34.sp,
    );
  }

  /// FONT_STYLE FOR FONT SIZE 30
  static TextStyle h2(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 30.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 24
  static TextStyle h3(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 24.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 20
  static TextStyle h4(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 20.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 17
  static TextStyle h5(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 17.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 16
  static TextStyle h6(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 16.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 15
  static TextStyle t1(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 15.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 14
  static TextStyle t2(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 14.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 13
  static TextStyle t3(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 13.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 12
  static TextStyle t4(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 12.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 11
  static TextStyle t5(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 11.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 14
  static TextStyle l1(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 14.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 14
  static TextStyle p1(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 14.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 13
  static TextStyle p2(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 13.sp,
    );
  }

  /// FONTSTYLE FOR FONT SIZE 12
  static TextStyle p3(
    BuildContext context, {
    Color? fontColor,
    FWT? fontWeight = FWT.regular,
  }) {
    return TextStyle(
      fontFamily: 'QuickSand',
      color: fontColor ?? Theme.of(context).textTheme.bodyMedium!.color,
      fontWeight: getFontWeight(fontWeight: fontWeight),
      fontSize: 12.sp,
    );
  }
}
