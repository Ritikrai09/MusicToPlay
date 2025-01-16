import 'package:flutter/material.dart';

class TheMultiChildAnimationWrapper extends StatefulWidget {
  const TheMultiChildAnimationWrapper({
    super.key,
    required this.children,
    this.mainAxisAlignment,
    this.length=0,
  });
  final MainAxisAlignment? mainAxisAlignment;
  final List<Widget> children;
  final int length;
  @override
  _TheMultiChildAnimationWrapperState createState() =>
      _TheMultiChildAnimationWrapperState();
}

class _TheMultiChildAnimationWrapperState
    extends State<TheMultiChildAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _animationList;

  @override
  void initState() {
    _animationList = [];
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    List.generate(
        widget.length+1,
        (int index) => _animationList.add(Tween<double>(begin: 1, end: 0)
            .animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                    0.0 * ((index * (1 / (widget.length+1))) + 1),
                    .2 * ((index * (1 / (widget.length+1))) + 1),
                    curve: Curves.decelerate)))));

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment:
            widget.mainAxisAlignment ?? MainAxisAlignment.spaceBetween,
        children: [
          ...List.generate(widget.length+1, (i) {
            return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                      offset: Offset(size.width * _animationList[i].value, 0),
                      child: widget.children[i]);
                });
          })
        ],
      ),
    );
  }
}
