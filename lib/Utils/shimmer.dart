import 'package:flutter/material.dart';
import 'package:blogit/Utils/color_util.dart';

class ShimmerLoader extends StatefulWidget {
  final double? width,height;

  const ShimmerLoader({super.key, this.width,this.isScroll=true,this.count,this.height,this.isHori=false,this.margin,this.borderRadius});
  final EdgeInsetsGeometry? margin;
  final bool isHori;
  final bool isScroll;
  final int? count;
  final double? borderRadius;

  @override
   State<ShimmerLoader> createState() => _ShimmerLoaderState();
}
class _ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds:1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
         builder: (context, child) {
        const beginAlignment = Alignment.topRight;
        const endAlignment = Alignment.bottomLeft;
        final gradient = LinearGradient(
          begin: Alignment.lerp(beginAlignment, endAlignment, _animation.value)!,
          end: Alignment.lerp(beginAlignment, endAlignment, _animation.value - 0.5)!,
          colors: dark(context) ? [
            Colors.grey[900]!,
            Colors.grey[800]!,
            Colors.grey[900]!,
          ]:[
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: const [0.0, 0.5, 1.0],
        );
        return widget.count ==1  ?
        Container(
           width: widget.width ?? MediaQuery.of(context).size.width,
              height: widget.height ?? 152,
              margin: widget.margin ?? const EdgeInsets.only(left: 16,right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular( widget.borderRadius ??20),
                gradient:gradient,
           ),
        )
         : ListView.separated(
          itemCount: widget.count ?? 6,
          shrinkWrap: true,
          scrollDirection: widget.isHori ? Axis.horizontal :  Axis.vertical,
          // primary: false,
          physics: widget.isScroll ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) {
            return const SizedBox(height: 15);
          },
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemBuilder:(context, index) {
           return Container(
              width: widget.width ?? MediaQuery.of(context).size.width,
              height: widget.height ?? 152,
              margin: widget.margin ?? const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular( widget.borderRadius ??20),
                gradient:gradient,
              ),
           );
        });
      },
    );
  }
}
