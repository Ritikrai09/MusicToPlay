import 'package:flutter/material.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedCheckBox extends StatefulWidget {
  const RoundedCheckBox({super.key, required this.onChanged, this.initialValue});
  final ValueChanged<bool> onChanged;
  final bool? initialValue;

  @override
  State<RoundedCheckBox> createState() => _RoundedCheckBoxState();
}

class _RoundedCheckBoxState extends State<RoundedCheckBox> {
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
      onTap: toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeIn,
        height: 33.2.h,
        width: 33.2.h,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? Theme.of(context).primaryColor : Colors.transparent,
            border: Border.all(
                width: 2,
                color: value
                    ? Theme.of(context).primaryColor
                    : ColorUtil.themNeutral)),
        child: Icon(
          Icons.done,
          color: value ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }
}
