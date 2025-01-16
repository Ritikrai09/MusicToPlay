
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/widgets/widgets.dart';

import 'package:blogit/Utils/app_theme.dart';

class ThemeButton extends StatefulWidget {
  const ThemeButton({
    super.key,
    required this.onChanged,
  });

  final ValueChanged onChanged;

  @override
  State<ThemeButton> createState() => _ThemeButtonState();
}

class _ThemeButtonState extends State<ThemeButton> {

  @override
  Widget build(BuildContext context) {
    return  ClipRRect(
       borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: IconButton(
        onPressed: () {
          toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
            setState(() {    });
        },
        icon: SizedBox(
          height: 23.h,
          width: 23.w,
          child:appThemeModel.value.isDarkModeEnabled.value==true ?
          const Icon(Icons.sunny)
          :const SvgIcon('asset/Icons/moon.svg'),
        ),
      )),
    );
  }
}
