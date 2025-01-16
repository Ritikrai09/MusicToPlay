import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:blogit/presentation/widgets/loader.dart';

import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/model/locale.dart';

import '../../../../Utils/custom_toast.dart';
import '../../../../controller/app_provider.dart';
import '../../../../controller/repository.dart';
import '../../../../controller/user_controller.dart';
import '../../../../main.dart';
import '../../../../utils/app_theme.dart';
import '../../bookmarks.dart';

class LanguageSetting extends StatefulWidget {
  const LanguageSetting({super.key});

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  
  bool isLoad=false;
  void _setIndex(int index) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen:false);
    return  CustomLoader(
      isLoading: isLoad,
      child: Scaffold(
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  MyStickyHeader(
                      floating: true,
                      elevation: 0,
                      height: 65.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                               const BackbUT(),
                                Text(
                                 allMessages.value.selectLanguage ?? 'Select language',
                                  style: FontStyleUtilities.h5(context,
                                          fontWeight: FWT.extrabold)
                                      .copyWith(fontSize: 20),
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
                          SizedBox(height: 16.h)
                        ],
                      )),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 14.h,
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          
                      ...List.generate(allLanguages.length, (index) => LanguageTile(
                        code: allLanguages[index].language,
                        language: allLanguages[index].name.toString(),
                        onTap: () async{
                          if (languageCode.value.language != allLanguages[index].language) {
                            _setIndex(index);
                           languageCode.value = allLanguages[index];
                            prefs!.setString('defalut_language',json.encode(languageCode.value.toJson()));
                              isLoad = true;
                              setState(() {});
                            
                            try {
                              await getLocalText(context).then((value) async{
                              await provider.getCategory().whenComplete(()async {
                                  prefs!.remove('isBookmark');
                                  // if (value != null) {
                                
                                showCustomToast(context,'',isBig: true,
                                title:'Language Translated to ${languageCode.value.name}',islogo: false,isSuccess: true,backColor: Colors.green);
                                Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(context) => 
                                 HomeWrapper(key:Key(languageCode.value.language.toString()))),(route) => false);
                              // }
                              });
                              });
                            } on Exception {
                              isLoad = false;
                              setState(() {});
                            }
                          }
                        },
                        isSelected: languageCode.value.language == allLanguages[index].language,
                      ))
                      // LanguageTile(
                      //   image: 'asset/Images/Social/united_states.svg',
                      //   language: 'English',
                      //   onTap: () {
                      //     _setIndex(1);
                      //   },
                      //   isSelected: _selectedIndex == 1,
                      // ),
                    ])),
                  )
                ],
              ),
            ),
          ),
        ),
    );
    
  }
}

class LanguageTile extends StatelessWidget {
  const LanguageTile(
      {super.key,
      this.code,
      required this.language,
      required this.onTap,
      required this.isSelected});
  final String? language,code;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(locale.firstWhere((element) => element['code']==code)['nativeName'].toString().substring(0,3), 
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Quick-Sand',
                  fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              language?? '',
              style: FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
            ),
            const Spacer(),
            RoundedRadio(onTap: onTap, value: isSelected)
          ],
        ),
      ),
    );
  }
}


class RoundedRadio extends StatelessWidget {
  const RoundedRadio({super.key, required this.onTap, required this.value});
  final VoidCallback onTap;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
    );
  }
}
