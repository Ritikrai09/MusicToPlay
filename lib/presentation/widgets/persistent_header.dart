import 'package:flutter/material.dart';
import 'dart:math' as math;

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.child,
    required this.collapsedHeight,
    required this.expandedHeight,
  });

  final double expandedHeight;
  final double collapsedHeight;
  final Widget child;

  @override
  double get minExtent => collapsedHeight;
  @override
  double get maxExtent => math.max(expandedHeight, minExtent);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return expandedHeight != oldDelegate.expandedHeight ||
        collapsedHeight != oldDelegate.collapsedHeight;
  }
}

class MyHeader extends StatelessWidget {
  const MyHeader(
      {super.key,
      required this.child,
      required this.collapsedHeight,
      required this.expandedHeight,
      this.pinned,
      this.floating});
  final Widget child;
  final double collapsedHeight, expandedHeight;
  final bool? pinned, floating;

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(builder: (context, constraints) {
      return SliverPersistentHeader(
        pinned: pinned ?? false,
        floating: floating ?? false,
        delegate: _SliverAppBarDelegate(
            child: child,
            collapsedHeight: collapsedHeight,
            expandedHeight: expandedHeight),
      );
    });
  }
}
