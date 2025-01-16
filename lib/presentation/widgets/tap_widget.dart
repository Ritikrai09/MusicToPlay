import 'package:flutter/material.dart';

class GestureLeftRightTap extends StatelessWidget {
  const GestureLeftRightTap({
  super.key,
  required this.onLeftTap,
  required this.onRightTap,
  required this.child,
  required this.onLongPress,
  required this.onLongPressCancel,
});

  final VoidCallback onLeftTap,onLongPress,onLongPressCancel,onRightTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
    fit: StackFit.expand,
      children: [
        child,
        Positioned.fill(
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLeftTap,
                  onLongPress: onLongPress,
                  onLongPressCancel: onLongPressCancel,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    // Your left widget content
                    color:  Colors.transparent,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap:onRightTap,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    // Your right widget content
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}