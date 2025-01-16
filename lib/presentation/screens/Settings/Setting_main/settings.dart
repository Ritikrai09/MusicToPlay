
import 'dart:io';

import 'package:flutter/cupertino.dart' show CupertinoSwitch;
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/presentation/screens/Prelog/select_interest.dart';
import 'package:blogit/presentation/screens/Profile/Edit_profile/edit_profile.dart';
import 'package:blogit/presentation/screens/Settings/Contact/contact.dart';
import 'package:blogit/presentation/screens/Settings/Language/language.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/cms.dart';
import 'package:blogit/Utils/app_theme.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';

import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;

import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/model/user.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../controller/user_controller.dart';
import '../../Auth/Login/login.dart';

final List<Color> _colors = [
  PrimaryColors.primaryColor1,
  PrimaryColors.primaryColor2,
  PrimaryColors.primaryColor3,
  PrimaryColors.primaryColor4,
  PrimaryColors.primaryColor5
];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  late TextDirection? direction;
  UserProvider user = UserProvider();
 

  @override
  void didChangeDependencies() {
    direction = Directionality.of(context);
    super.didChangeDependencies();
  }

        

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: SafeArea(
            child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: CustomScrollView(
            slivers: [
              const TheSearchArea(
                elevation:0,
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 8.h,
                ),
              ),
              MyStickyHeader(
                pinned: false,
                height: 86.h,
                elevation:0,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfileEdit(photo: currentUser.value.photo,isEdit: false,radius: 44.r),
                          SizedBox(
                            width: 16.w,
                          ),
                          Expanded(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                               currentUser.value.id == null ?  allMessages.value.guest.toString() :  currentUser.value.name ?? 'Charlotte',
                                style: FontStyleUtilities.h4(context,
                                    fontWeight: FWT.extrabold),
                              ),
                              currentUser.value.id == null ? const SizedBox() : SpaceUtils.ks12.height(),
                                currentUser.value.id == null ? const SizedBox() : Row(
                                children: [
                                  Button(
                                    padding: 16.5.w,
                                    maxHeight: 40.h,
                                    tittle: allMessages.value.edit ?? 'Edit Profile',
                                    onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfile())).then((value) {
                                      setState(() {});
                                    });
                                    },
                                    style: FontStyleUtilities.h6(context,
                                        fontWeight: FWT.extrabold,
                                        fontColor: Colors.white),
                                  )
                                ],
                              )
                            ],
                          ))
                        ],
                      ),
                    ),
                    // SizedBox(
                    //   height: 15.h,
                    // )
                  ],
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 0.w),
                sliver: SliverList(
                  
                    delegate: SliverChildListDelegate([
                  // SizedBox(
                  //   height: 28.h,
                  // ),
                  // Text(
                  //   allMessages.value.colorScheme ?? 'Color Scheme',
                  //   style: FontStyleUtilities.h4(context,
                  //       fontWeight: FWT.extrabold),
                  // ),
                  // SizedBox(
                  //   height: 28.h,
                  // ),
                  //   SchemeWrapper(onChanged: (int index) {
                  //     ///TO CHANGE PRIMARY COLOR OF THEME...
                  //     togglePrimaryColor(_colors[index]);
                  //     setState(() {   });
                  //   }),
                  
                  SizedBox(
                    height: 12.h,
                  ),
                  TheSettingTile(
                      onTap: () {
                        NavigationUtil.to(context, const LanguageSetting());
                      },
                      tittle: allMessages.value.selectLanguage ?? 'Language',
                      sub: languageCode.value.name),
                  // ToggleTile(
                  //   sub: _rtl ? 'LTR' : 'RTL',
                  //   tittle: 'Content Style',
                  //   onTap: () {},
                  //   onChanged: (bool value) async {
                  //     _rtl = value;
                  //     await Future.delayed(
                  //         const Duration(milliseconds: 150));
                  //     setState(() {});
                  //   },
                  // ),
                    currentUser.value.id == null ? const SizedBox() :  TheSettingTile(
                      onTap:  () {
                        NavigationUtil.to(context, const BookmarkPage());
                      },
                      tittle: allMessages.value.mySavedStories ?? 'Saved Stories'),
                     currentUser.value.id == null ? const SizedBox() :  TheSettingTile(
                      onTap: () {
                        NavigationUtil.to(context, const SelectInterest(isDrawer: true));
                      },
                      tittle:  allMessages.value.myFeed ??'My Feed'),
                    // allSettings.value.ePaperStatus != '1' ? const SizedBox() : TheSettingTile(
                    //   onTap: () {
                    //     NavigationUtil.to(context, const EnewsPage());
                    //   },
                    //   tittle: allMessages.value.eNews ?? 'E-news'),
                    //  allSettings.value.liveNewsStatus != '1' ? const SizedBox() : TheSettingTile(
                    //   onTap: () {
                    //     NavigationUtil.to(context, const LiveNewsPage());
                    //   },
                    //   tittle: allMessages.value.liveNews ?? 'Live-news'),
                        TheSettingTile(tittle: allMessages.value.shareYourApp ?? 'Share Your App', onTap: () {
                           Share.share(allMessages.value.shareMessage.toString());
                        }),
                        ToggleTile(
                          tittle: allMessages.value.enableDisablePushNotification ?? 'Notification',
                          initialValue: appThemeModel.value.isNotificationEnabled.value,
                          onTap: () {
                               
                          },
                          onChanged: (bool value) {
                            // if(currentUser.value.id == null ){
                            //   currentUser.value.deviceToken = getOnesignalUserId();
                            // }
                             
                               toggleNotify(value);
                              // updateToken(currentUser.value, OneSignal.User.pushSubscription.id ?? "", value:value);
                               if (appThemeModel.value.isNotificationEnabled.value == false){
                                    OneSignal.User.pushSubscription.optOut();
                                } else {
                                    OneSignal.User.pushSubscription.optIn();
                                }
                                setState(() { });
                          },
                        ),
                             TheSettingTile(
                          onTap: () async {
                            if(Platform.isAndroid){
                               await redirectPlayStore(allSettings.value.androidRateUs ?? '');
                            }else{
                              await redirectPlayStore(allSettings.value.iosRateUs ?? '');
                              }
                           },
                           tittle: allMessages.value.rateUs ?? 'Contact'),
                         TheSettingTile(
                          onTap: () {
                                NavigationUtil.to(context, const ContactPage());
                           },
                           tittle: allMessages.value.contactUs ?? 'Contact'),
                          // ...List.generate(allCMS.length, (index) => TheSettingTile(
                          //   key: ValueKey(allCMS[index].id),
                          //   onTap: () {
                          //     NavigationUtil.to(context, CmsPage(
                          //         cms: allCMS[index]
                          //      ));
                          //  },
                          //  tittle:allCMS[index].pageName ?? '' )),
                        ...List.generate(allCMS.length,(index){
                        return  TheSettingTile(
                          onTap: () {
                            NavigationUtil.to(context,  CmsPage(cms: allCMS[index]));
                          },
                          tittle: allCMS[index].title.toString());
                      }),
                  TheSettingTile(tittle: currentUser.value.id == null ? allMessages.value.signIn  ?? 'Login' 
                  : allMessages.value.signOut ?? 'Logout',
                   logout: currentUser.value.id == null ? false :  true,
                    onTap:  currentUser.value.id == null ? () {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Login()));
                      });
                    }:() {
                    user.logout(context);
                    setState(() {     });
                   }),
                   if(socialMedia.value.isNotEmpty)
                   Divider(height: 16.h),
                    if(socialMedia.value.isNotEmpty)
                    SizedBox(height: 16.h),
                    ValueListenableBuilder<List<SocialMedia>>(
                valueListenable: socialMedia,
                 builder: (context,value,child) {
                   return Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 20),
                     child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                                       ///  mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                       ...List.generate(value.length, (index) => InkResponse(
                        onTap: () {
                          openWhatsApp(value[index].url!.split('=').last);
                        },
                         child: SizedBox(
                          width: 30,
                          height: 30,
                          child: Icon(getTabIcons(value[index].name.toString()),size: 28),
                          ),
                       ))
                      ],
                     ),
                   );
                 }
               ),
                  SizedBox(
                    height: 100.h,
                  )
                ])),
              )
            ],
          ),
        )),
      );
    
  }

  Future<void> redirectPlayStore(String name) async {
   final url = name;
  try {
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
  } catch(e){
  
  }}
}


  IconData? getTabIcons(String icon){

  IconData? iconData;

   switch (icon.toLowerCase()) {
      case "facebook":
        iconData = TablerIcons.brand_facebook;
        return iconData;
      case "fb":
        iconData = TablerIcons.brand_facebook;
        return iconData;
      case "instagram":
        iconData = TablerIcons.brand_instagram;
        return iconData;
      case "youtube":
        iconData = TablerIcons.brand_youtube;
        return iconData;
      case "pintrest":
        iconData = TablerIcons.brand_pinterest;
        return iconData;
      case "pinterest":
        iconData = TablerIcons.brand_pinterest;
        return iconData;
      case "linkedin":
        iconData = TablerIcons.brand_linkedin;
        return iconData;
      case "snapchat":
        iconData = TablerIcons.brand_snapchat;
        return iconData;
      case "twitter":
        iconData = TablerIcons.brand_twitter;
        return iconData;
      case "skype":
        iconData = TablerIcons.brand_skype;
        return iconData;
      case "whatsapp":
        iconData = TablerIcons.brand_whatsapp;
        return iconData;
      case "telegram":
        iconData = TablerIcons.brand_telegram;
        return iconData;
      case "reddit":
        iconData = TablerIcons.brand_reddit;
        return iconData;
      case "tiktok":
        iconData = TablerIcons.brand_tiktok;
        return iconData;
      case "github":
        iconData = TablerIcons.brand_github;
        return iconData;
      case "discord":
        iconData = TablerIcons.brand_discord;
        return iconData;
      // case "thread":
      //    iconData = TablerIcons.brand_;
      //   return iconData;
      default:
        // Handle unknown cases or provide a default icon
        break;
    }
   return null;

  }

class ToggleTile extends StatefulWidget {
  const ToggleTile({
    super.key,
    required this.tittle,
    required this.onTap,
    this.initialValue,
    required this.onChanged,
    this.sub,
  });
  final String tittle;
  final String? sub;
  final VoidCallback onTap;
  final bool? initialValue;
  final ValueChanged<bool> onChanged;

  @override
  State<ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<ToggleTile> {
 
 
  void toggle() {
    appThemeModel.value.isNotificationEnabled.value = !appThemeModel.value.isNotificationEnabled.value;
    widget.onChanged(appThemeModel.value.isNotificationEnabled.value);
    setState(() {});
  }

  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        toggle();
        widget.onTap();
      },
      highlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
      overlayColor: WidgetStateProperty.all(Theme.of(context).primaryColor.withOpacity(0.2)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
        child: Row(
          children: [
            Text(
              widget.tittle,
              style: FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
            ),
            const Spacer(),
            if (widget.sub != null)
              Text(
                widget.sub!,
                style: FontStyleUtilities.t2(context,
                    fontWeight: FWT.medium, fontColor: ColorUtil.themNeutral),
              ),
            SizedBox(width: 7.60.w),
            Transform.scale(
              scale: .75,
              child: SizedBox(
                width: 30,
                height: 20,
                child: CupertinoSwitch(
                    activeTrackColor: Theme.of(context).primaryColor,
                    value: appThemeModel.value.isNotificationEnabled.value,
                    onChanged: (v) {
                      appThemeModel.value.isNotificationEnabled.value = v;
                      widget.onChanged(appThemeModel.value.isNotificationEnabled.value);
                      setState(() {});
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  

}

class TheSettingTile extends StatelessWidget {
  const TheSettingTile({
    super.key,
    required this.tittle,
    this.sub,
    this.logout=false,
    required this.onTap,
  });
  final String tittle;
  final String? sub;
  final bool logout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
      overlayColor: WidgetStateProperty.all( Theme.of(context).primaryColor.withOpacity(0.2)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 24.w),
        child: Row(
          children: [
            Text(
              tittle,
              style: FontStyleUtilities.h6(context, 
              fontWeight: FWT.extrabold,
              fontColor: logout ? Colors.red: null),
            ),
            const Spacer(),
            if (sub != null)
              Text(
                sub!,
                style: FontStyleUtilities.t2(context,
                    fontWeight: FWT.extrabold,
                    fontColor: ColorUtil.themNeutral),
              ),
            SizedBox(
              width: 9.w,
            ),
         logout?  const Icon(Icons.logout,color: Colors.red) :  RotatedBox(
              quarterTurns:
                  Directionality.of(context) == TextDirection.ltr ? 0 : 2,
              child: const SvgIcon(
                'asset/Icons/arrow_right.svg',
                color: ColorUtil.themNeutral,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SchemeWrapper extends StatefulWidget {
  const SchemeWrapper({super.key, required this.onChanged});

  final ValueChanged<int> onChanged;
  @override
  _SchemeWrapperState createState() => _SchemeWrapperState();
}

class _SchemeWrapperState extends State<SchemeWrapper> {
  late int _selectedIndex;
  void _setIndex(int index) {
    _selectedIndex = index;
    widget.onChanged(_selectedIndex);
    setState(() {});
  }

@override
  void initState() {
  _selectedIndex= _colors.indexOf(appThemeModel.value.primaryColor.value);
    super.initState();
  }
  

  @override
  Widget build(BuildContext context) {
   
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      ...List.generate(
          5,
          (int index) => GestureDetector(
            key:ValueKey(index),
                onTap: () {
                  _setIndex(index);
                },
                child: TheSchemeMark(
                    color: _colors[index],
                    isSelected: appThemeModel.value.primaryColor.value.value == _colors[index].value
                    )
              ))
    ]);
  }
}


  void openWhatsApp(String text) async {
  final url = text;
  try {
   await custom.launchUrl(Uri.parse(text));
  } catch(e){
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  } else {
    throw 'Could not launch $url';
  }
  }
}

class TheSchemeMark extends StatelessWidget {
  const TheSchemeMark({super.key, required this.color, required this.isSelected});
  final Color color;
  final bool isSelected;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16.w),
      height: 48.h,
      width: 48.h,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(
        Icons.done,
        color: isSelected ? Colors.white : Colors.transparent,
      ),
    );
  }
}
