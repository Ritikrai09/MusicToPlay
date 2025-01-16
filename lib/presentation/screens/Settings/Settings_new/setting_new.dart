import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/presentation/screens/Prelog/select_interest.dart';
import 'package:blogit/presentation/screens/Profile/Edit_profile/edit_profile.dart';
import 'package:blogit/presentation/screens/Settings/Contact/contact.dart';
import 'package:blogit/presentation/screens/Settings/Language/language.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/screens/news/e_news.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../../../Utils/app_theme.dart';
import '../../../../controller/repository.dart';
import '../../Auth/Login/login.dart';
import '../../news/live_news.dart';

class SettingNew extends StatefulWidget {
  const SettingNew({super.key});

  @override
  State<SettingNew> createState() => _SettingNewState();
}

class _SettingNewState extends State<SettingNew> {
  late Brightness _brightness;

  @override
  void didChangeDependencies() {
    _brightness = Theme.of(context).brightness;
    super.didChangeDependencies();
  }

   final bool _rtl = false;
  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Directionality(
        textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
        child: Scaffold(
          body: SafeArea(
              child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  actions: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        radius: 12.5.r,
                        backgroundColor:
                            Theme.of(context).colorScheme.onSurface,
                        child: Icon(
                          Icons.close,
                          size: 20,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 24.w,
                    )
                  ],
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  floating: true,
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 16.h,
                  ),
                ),
                MyStickyHeader(
                  pinned: true,
                  height: 126.h,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ProfileEdit(isEdit: false,radius: 44.r),
                            SizedBox(
                              width: 16.w,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                 Text(
                                 currentUser.value.id == null ?  allMessages.value.guest.toString() : currentUser.value.name ?? 'Charlotte',
                                  style: FontStyleUtilities.h4(context,
                                      fontWeight: FWT.extrabold),
                                ),
                                 currentUser.value.id == null ? const SizedBox() : SpaceUtils.ks12.height(),
                                currentUser.value.id == null ? const SizedBox() : Row(
                                  children: [
                                    Button(
                                      padding: 16.5.w,
                                      maxHeight: 40.h,
                                      tittle:allMessages.value.edit ?? 'Edit Profile',
                                      onTap: () {
                                        NavigationUtil.to(
                                            context, const EditProfile());
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
                      SizedBox(
                        height: 15.h,
                      )
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                  sliver: SliverList(
                      delegate: SliverChildListDelegate([
                    SizedBox(
                      height: 28.h,
                    ),
                    TheSettingTile(
                        brightness: _brightness,
                        icon: 'asset/Icons/language.svg',
                        onTap: () {
                          NavigationUtil.to(context, const LanguageSetting());
                        },
                        tittle: allMessages.value.selectLanguage ??'Language'),
                    // ExpandableToggleTile(
                    //   icon: 'asset/Icons/content_style.svg',
                    //   tittle: 'Content Style',
                    //   onTap: () {},
                    //   onChanged: (v) {},
                    //   brightness: _brightness,
                    //   onRTL: () {
                    //     _rtl = true;
                    //     setState(() {});
                    //   },
                    //   onLTR: () {
                    //     _rtl = false;
                    //     setState(() {});
                    //   },
                    // ),
                   currentUser.value.id == null ? const SizedBox() :   TheSettingTile(
                        brightness: _brightness,
                        icon: 'asset/Icons/book_mark.svg',
                        tittle: allMessages.value.mySavedStories ?? 'Booknarks',
                        onTap:() {
                            NavigationUtil.to(context, const BookmarkPage());
                        }),
                     allSettings.value.ePaperStatus != '1' ? const SizedBox() : TheSettingTile(
                        onTap: () {
                          NavigationUtil.to(context, const EnewsPage());
                        },
                        icon: "${allSettings.value.baseImageUrl}/${allSettings.value.ePaperLogo}",
                        tittle: allMessages.value.eNews ?? 'E-news', brightness: _brightness,),
                       allSettings.value.liveNewsStatus != '1' ? const SizedBox() : TheSettingTile(
                        icon: "${allSettings.value.baseImageUrl}/${allSettings.value.liveNewsLogo}",
                        onTap: () {
                          NavigationUtil.to(context, const LiveNewsPage());
                        },
                        tittle: allMessages.value.liveNews ?? 'Live-news',brightness: _brightness,),
                  
                        currentUser.value.id == null ? const SizedBox() : TheSettingTile(
                        brightness: _brightness,
                        icon: 'asset/Icons/compo.svg',
                        tittle: allMessages.value.myFeed ?? 'My Feed',
                        onTap: () {
                          NavigationUtil.to(context, const SelectInterest(isDrawer: true));
                        }),
                    ToggleTile(
                        brightness: _brightness,
                        tittle: allMessages.value.notifications ?? 'Notification',
                        icon: 'asset/Icons/notification.svg',
                      onTap: () {

                      },
                      onChanged: (bool value) {
                         if(currentUser.value.id == null ){
                           currentUser.value.deviceToken = getOnesignalUserId();
                         }
                          toggleNotify(value);
                          updateToken(currentUser.value,getOnesignalUserId().toString(),value:value);
                          setState(() { });
                      },
                     ),
                       TheSettingTile(
                        brightness: _brightness,
                        icon: 'asset/Icons/contact.svg',
                        onTap: () {
                          NavigationUtil.to(context, const ContactPage());
                        },
                        tittle: allMessages.value.contactUs ?? 'Contact'),
                       TheSettingTile(
                        brightness: _brightness,
                        icon: 'asset/Icons/share.svg',
                        tittle: 'Share',
                        onTap: () async{
                         await Share.share('${allMessages.value.shareMessage}');
                        }),
                       if(currentUser.value.id == null)
                        TheSettingTile(
                        brightness: _brightness,
                        icon: 'asset/Icons/login.svg',
                        tittle: allMessages.value.login ?? 'Login',
                        onTap: () {
                          NavigationUtil.to(context,const Login());
                        }),
                  ])),
                )
              ],
            ),
          )),
        ),
      );
    });
  }
}

class TheSettingTile extends StatelessWidget {
  const TheSettingTile(
      {super.key,
      required this.tittle,
      this.sub,
      required this.onTap,
      required this.icon,
      required this.brightness});
  final String tittle, icon;
  final String? sub;
  final VoidCallback onTap;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
            child: Row(
              children: [
                SizedBox(
                    width: 19.5.w,
                    height: 20.5.h,
                    child: icon.contains('https')  ? CachedNetworkImage(imageUrl: icon) : SvgIcon(icon, width: 19.5.w, height: 20.5.h)),
                SizedBox(width: 13.5.w),
                Text(
                  tittle,
                  style:
                      FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
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
                RotatedBox(
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
          Divider(
            color: brightness == Brightness.light
                ? const Color(0xffF6F6F6)
                : const Color(0xff4B4B4B),
            height: .50,  
            thickness: .50,
          ),
        ],
      ),
    );
  }
}

class ExpandableToggleTile extends StatefulWidget {
  const ExpandableToggleTile(
      {super.key,
      required this.onChanged,
      required this.tittle,
      required this.icon,
      required this.onTap,
      required this.brightness,
      required this.onRTL,
      required this.onLTR});
  final ValueChanged<bool> onChanged;
  final String tittle, icon;
  final Brightness brightness;
  final VoidCallback onTap, onRTL, onLTR;
  @override
  State<ExpandableToggleTile> createState() => _ExpandableToggleTileState();
}

class _ExpandableToggleTileState extends State<ExpandableToggleTile> {
  bool value = true;
  void toggle() {
    value = !value;
    widget.onChanged(value);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: value ? 53.h : 144.h,
      child: InkWell(
        onTap: () {
          toggle();
        },
        highlightColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
              child: Row(
                children: [
                  SizedBox(
                      width: 17.5.w,
                      height: 20.5.h,
                      child:
                          SvgIcon(widget.icon, width: 19.5.w, height: 20.5.h)),
                  SizedBox(width: 13.5.w),
                  Text(
                    widget.tittle,
                    style: FontStyleUtilities.h6(context,
                        fontWeight: FWT.extrabold),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            if (!value)
              Row(
                children: [
                  SizedBox(
                    width: (17.5 + 26.5 + 13.5).w,
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10.4.h),
                      GestureDetector(
                        onTap: () {
                          toggle();
                          widget.onRTL();
                        },
                        child: Text(
                          'Right To Left',
                          style: FontStyleUtilities.t2(context,
                              fontColor: ColorUtil.themNeutral,
                              fontWeight: FWT.extrabold),
                        ),
                      ),
                      SizedBox(height: 11.h),
                      GestureDetector(
                        onTap: () {
                          toggle();
                          widget.onLTR();
                        },
                        child: Text(
                          'Left To Right',
                          style: FontStyleUtilities.t2(context,
                              fontColor: ColorUtil.themNeutral,
                              fontWeight: FWT.extrabold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const Spacer(),
            Divider(
              color: widget.brightness == Brightness.light
                  ? const Color(0xffF6F6F6)
                  : const Color(0xff4B4B4B),
              height: .50,
              thickness: .50,
            ),
          ],
        ),
      ),
    );
  }
}

class ToggleTile extends StatefulWidget {
  const ToggleTile(
      {super.key,
      required this.tittle,
      required this.onTap,
      required this.icon,
      this.initialValue,
      required this.onChanged,
      required this.brightness});
  final String tittle, icon;
  final VoidCallback onTap;
  final bool? initialValue;
  final ValueChanged<bool> onChanged;
  final Brightness brightness;

  @override
  State<ToggleTile> createState() => _ToggleTileState();
}

class _ToggleTileState extends State<ToggleTile> {
  bool value = false;
  void toggle() {
   appThemeModel.value.isNotificationEnabled.value = !appThemeModel.value.isNotificationEnabled.value;
    widget.onChanged(appThemeModel.value.isNotificationEnabled.value);
    setState(() {});
  }

  @override
  void initState() {
    value = widget.initialValue ?? false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        toggle();
        widget.onTap();
      },
      highlightColor: Colors.transparent,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
            child: Row(
              children: [
                SizedBox(
                    width: 17.5.w,
                    height: 20.5.h,
                    child: SvgIcon(widget.icon, width: 19.5.w, height: 20.5.h)),
                SizedBox(width: 13.5.w),
                Text(
                  widget.tittle,
                  style:
                      FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
                ),
                const Spacer(),
                Transform.scale(
                  scale: .8,
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
          Divider(
            color: widget.brightness == Brightness.light
                ? const Color(0xffF6F6F6)
                : const Color(0xff4B4B4B),
            height: .50,
            thickness: .50,
          ),
        ],
      ),
    );
  }
}
