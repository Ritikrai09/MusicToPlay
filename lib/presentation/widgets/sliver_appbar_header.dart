import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyStickyHeader extends StatelessWidget {
  const MyStickyHeader(
      {super.key,
      required this.height,
      required this.child,
      this.padding,
      this.pinned,
      this.scrollElevation=0,
      this.floating,
      this.elevation,
      this.forceElevated,
      this.expandedHeight});
  final double height;
  final double? expandedHeight;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool? pinned, floating, forceElevated;
  final double? elevation,scrollElevation;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
        removeTop: true,
        removeLeft: true,
        removeRight: true,
        removeBottom: true,
        context: context,
        child: SliverAppBar(
            expandedHeight: expandedHeight ?? height,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: elevation,
            toolbarHeight: 0.h,
            scrolledUnderElevation : scrollElevation,
            shadowColor: Colors.grey.shade200,
            pinned: pinned ?? false,
            floating: floating ?? false,
            bottom: PreferredSize(
                preferredSize: Size.fromHeight(height+3),
                child: Container(
                  height:height+3 ,
                  width:MediaQuery.of(context).size.width,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: child))));
  }
}
