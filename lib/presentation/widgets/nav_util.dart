import 'package:flutter/cupertino.dart';

class PagingTransform extends PageRouteBuilder {
  final Widget widget;
  final double dx, dy;
  final int? duration;
  final bool slideUp,isReverseSlide;

  PagingTransform(
      {required this.widget,this.duration, this.slideUp = false,this.isReverseSlide =false,isScale =false, this.dy = 0, this.dx = 0})
      : super(
            transitionDuration:  Duration(milliseconds: duration ?? 300),
            reverseTransitionDuration:  Duration(milliseconds:  duration ?? 500),
            transitionsBuilder: (BuildContext context,
                Animation<double> animation,
                Animation<double> secAnimation,
                Widget child) {
              return AnimatedSwitcher(
                  key: ValueKey(animation),
                  switchInCurve: Curves.easeInSine,
                  switchOutCurve: Curves.easeOutSine,
                  duration:  Duration(milliseconds: duration ?? 300),
                  child:  ScaleTransition(
                          scale:animation,
                            child:  FadeTransition(opacity: animation,
                               child: child),
                        ));
            },
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secAnimation) {
              return widget;
            },opaque: false);
}
