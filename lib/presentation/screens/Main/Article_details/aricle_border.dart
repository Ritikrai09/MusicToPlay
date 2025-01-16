import 'package:flutter/material.dart';

class CustomBorder extends BorderSide {
  final Color? newColor;
  final double? strokeWidth;
  final BorderStyle? paintingStyle;

  const CustomBorder({this.newColor, this.strokeWidth, this.paintingStyle});
  @override
  Color get color => newColor ?? Colors.blueAccent;

  @override
  BorderSide scale(double t) {
    return const BorderSide();
  }

  @override
  BorderStyle get style => BorderStyle.solid;

  @override
  Paint toPaint() {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth ?? 1
      ..color = newColor ?? Colors.black
      ..strokeCap = StrokeCap.round;
    return paint;
  }

  @override
  double get width => strokeWidth ?? 1;

}
