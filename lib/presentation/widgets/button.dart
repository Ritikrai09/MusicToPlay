import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.tittle,
    required this.onTap,
    this.color,
    this.isBusy = false,
    this.isDisable = false,
    this.textColor,
    this.style,
    this.maxHeight,
    this.padding,
    this.edgePadding
  });

  final String tittle;
  final VoidCallback onTap;
  final Color? color, textColor;
  final bool? isBusy, isDisable;
  final TextStyle? style;
  final EdgeInsetsGeometry? edgePadding;
  final double? maxHeight, padding;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisable! ? .5 : 1,
      child: Container(
        height: maxHeight ?? 48.h,
        margin: edgePadding ?? const EdgeInsets.symmetric(horizontal: 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color ?? Theme.of(context).primaryColor),
        child: isBusy!
            ? const CupertinoActivityIndicator()
            : MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.symmetric(horizontal: padding ?? 0),
                onPressed: isDisable! ? null : onTap,
                child: Center(
                  child: Text(
                    tittle,
                    style: style ??
                        FontStyleUtilities.t2(context,
                            fontWeight: FWT.extrabold,
                            fontColor: textColor ??
                                Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
      ),
    );
  }
}
