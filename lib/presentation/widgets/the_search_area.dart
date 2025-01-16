import 'package:blogit/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Main/Search_page/search_page.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Utils/app_theme.dart';
import 'nav_util.dart';

class TheSearchArea extends StatefulWidget {
  const TheSearchArea({super.key,this.elevation});
  final double? elevation;

  @override
  State<TheSearchArea> createState() => _TheSearchAreaState();
}

class _TheSearchAreaState extends State<TheSearchArea> {
  @override
  Widget build(BuildContext context) {
    return MyStickyHeader(
      expandedHeight: 55.h,
      elevation: widget.elevation ?? 8,
      pinned: true,
      height: 55.7.h,
      child: SizedBox(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 22.w,right: 22.w),
              child: Row(
                children: [
                    const TheLogo(logo: true),
                    SizedBox(
                      width: 15.5.w,
                    ),
                    Expanded(
                        child: Material(
                      elevation: 0,
                      color: Colors.transparent,
                      child: TextFormField(
                        
                        style: FontStyleUtilities.t2(context, fontColor: dark(context) ?Colors.white : Colors.black),
                           readOnly: true,
                          
                            onTap: () {
                               Navigator.push(context, PagingTransform(
                                      slideUp: true,
                                           widget: const SearchPage()));
                          },
                          
                           decoration: InputDecoration(
                            
                            filled: true,
                            fillColor: dark(context) ? Colors.grey.shade800 : Theme.of(context).primaryColor.withOpacity(0.1),
                            prefixIcon: Padding(
                              padding: EdgeInsets.symmetric(vertical: 11.5.h),
                              child:  SvgIcon(
                                  'asset/Icons/search-icon.svg',
                                  color: dark(context) ?Colors.grey.shade500 : Colors.grey,
                                  ),
                            ),
                            hintText: allMessages.value.searchStories ?? "Search",
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 7.w),
                            hintStyle: FontStyleUtilities.t2(context,
                            fontColor: dark(context) ?Colors.grey :Colors.grey ,
                                fontWeight: FWT.semiBold)),
                      ),
                    )),
                    SizedBox(
                      width: 12.5.w,
                    ),
                     ThemeButton(
                      onChanged: (value) {
                          toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
                          setState(() {    });
                      },
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10.h,
              )
            ],
          ),
        ));
  }
}
