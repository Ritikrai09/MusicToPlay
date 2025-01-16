import 'package:flutter/material.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FollowUnFollowButton extends StatefulWidget {
  const FollowUnFollowButton(
      {super.key, this.initialValue, required this.onChanged});
  final bool? initialValue;
  final ValueChanged<bool> onChanged;
  @override
  _FollowUnFollowButtonState createState() => _FollowUnFollowButtonState();
}

class _FollowUnFollowButtonState extends State<FollowUnFollowButton> {
  bool value = false;
  void toggle() {
    value = !value;
    widget.onChanged(value);
    setState(() {});
  }

  @override
  void initState() {
    value = widget.initialValue ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        toggle();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 13.w),
        height: 32.h,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 1.7)),
        child: Center(
          child: Text(
            value ? 'UNFOLLOW' : 'FOLLOW',
            style: FontStyleUtilities.t4(context,
                fontWeight: FWT.bold,
                fontColor: Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }
}
