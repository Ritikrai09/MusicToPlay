import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/Utils/utils.dart';

class AnimIcon extends StatefulWidget {
  const AnimIcon(
      {super.key,
      required this.activeIcon,
      required this.deactivateIcon,
      this.initialValue,
      this.isChange=true,
      this.height,
      required this.onChanged,
      this.width,
      this.activeColor,
      this.deactivateColor});
  final ValueChanged<bool> onChanged;
  final String activeIcon, deactivateIcon;
  final bool? initialValue,isChange;
  final double? height, width;
  final Color? activeColor;
  final Color? deactivateColor;

  @override
  State<AnimIcon> createState() => _AnimIconState();
}

class _AnimIconState extends State<AnimIcon> {
  @override
  void initState() {
    value = widget.initialValue ?? false;
    super.initState();
  }

  void toggle() {
   if (widget.isChange==false) {
     NavigationUtil.to(context, const Login());
   }else{
     widget.onChanged(value);
      value = !value;
      setState(() {});
   }
  
  }

  bool value = false;
  @override
  Widget build(BuildContext context) {
    return Ink(
      height: widget.height ?? 24.41.w,
      width: widget.width ?? 25.49.w,
      child: InkWell(
        highlightColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashColor: Colors.transparent,
        onTap:  () {
          toggle();
        },
        child: AnimatedSwitcher(
          switchInCurve: Curves.easeIn,
          switchOutCurve: Curves.easeIn,
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
          child: value == true
              ? SvgIcon(
                  widget.activeIcon,
                  height: double.infinity,
                  width: double.infinity,
                  key: ValueKey(widget.activeIcon+value.toString()),
                  color: widget.activeColor,
                )
              : SvgIcon(
                  widget.deactivateIcon,
                  height: double.infinity,
                  width: double.infinity,
                  color: widget.deactivateColor,
                  key: ValueKey(widget.deactivateIcon+value.toString()),
                ),
        ),
      ),
    );
  }
}
