import 'package:flutter/material.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HahsTagsWrapper extends StatefulWidget {
  const HahsTagsWrapper(
      {super.key, required this.preSetHashTags, required this.userDefineHashTag});
  final List<String> preSetHashTags;
  final ValueChanged<List<String>> userDefineHashTag;
  @override
  _HahsTagsWrapperState createState() => _HahsTagsWrapperState();
}

class _HahsTagsWrapperState extends State<HahsTagsWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<String> _interests;
  late List<Animation<double>> _animationList;

  @override
  void initState() {
    _interests = ['Cricket'];
    _animationList = [];
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 4000));
    List.generate(
        widget.preSetHashTags.length,
        (int index) => _animationList.add(Tween<double>(begin: 1, end: 0)
            .animate(CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                    0.0 * ((index * (1 / widget.preSetHashTags.length)) + 1),
                    .2 * ((index * (1 / widget.preSetHashTags.length)) + 1),
                    curve: Curves.decelerate)))));

    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _animationList.clear();
    _interests.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Wrap(
      runSpacing: 12.5.h,
      spacing: 8.2.w,
      children: [
        ...List.generate(widget.preSetHashTags.length, (index) {
          String interest = widget.preSetHashTags[index];
          return AnimatedBuilder(
              animation: _animationController,
              builder: (context, snapshot) {
                return Transform.translate(
                  offset: Offset(size.width * _animationList[index].value, 0),
                  child: SuggestedHashTagButton(
                    title: interest,
                    isSelected: _interests.contains(interest),
                    onTap: () {
                      if (_interests.contains(interest)) {
                        _interests.remove(interest);
                      } else {
                        _interests.add(interest);
                      }
                      widget.userDefineHashTag(_interests);
                      setState(() {});
                    },
                  ),
                );
              });
        })
      ],
    );
  }
}

class SuggestedHashTagButton extends StatefulWidget {
  const SuggestedHashTagButton(
      {super.key,
      required this.title,
      required this.isSelected,
      required this.onTap});
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  @override
  _SuggestedHashTagButtonState createState() => _SuggestedHashTagButtonState();
}

class _SuggestedHashTagButtonState extends State<SuggestedHashTagButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 35.h,
        decoration: BoxDecoration(
            color: widget.isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            border: Border.all(
                color: widget.isSelected
                    ? Theme.of(context).primaryColor
                    : ColorUtil.borderColor,
                width: 1),
            borderRadius: BorderRadius.circular(18.r)),
        padding: EdgeInsets.symmetric(horizontal: 23.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: FontStyleUtilities.t3(context,
                  fontWeight: FWT.extrabold,
                  fontColor:
                      widget.isSelected ? Colors.white : ColorUtil.themNeutral),
            ),
          ],
        ),
      ),
    );
  }
}
