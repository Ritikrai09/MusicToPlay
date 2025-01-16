import 'dart:io';

import 'package:blogit/presentation/widgets/maintenance_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Categories/categories.dart';
import 'package:blogit/presentation/screens/Main/Home/home.dart';
import 'package:blogit/presentation/screens/Main/feed/feed.dart';
import 'package:blogit/presentation/screens/Settings/Setting_main/settings.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/screens/shorts_video.dart';
import 'package:blogit/Utils/utils.dart';

import 'package:blogit/model/settings.dart';
import 'package:blogit/package/packages.dart';

import '../../../../controller/app_provider.dart';
import '../../../../controller/user_controller.dart';
import '../../../../main.dart';
import '../../../../model/blog.dart';

class HomeWrapper extends StatefulWidget {
  const HomeWrapper({super.key, this.isInitial = false});
  final bool isInitial;

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper>
    with TickerProviderStateMixin {
  late final TabController _tabController2;
  late final AnimationController _controller;
  // late List<Tab> tabs;
  late List<Tab> tabs2;
  UserProvider user = UserProvider();
  GlobalKey<RefreshIndicatorState> refresh = GlobalKey<RefreshIndicatorState>();

  int count = 0;
   static const platform = MethodChannel('com.signal/screen_wake_lock');
  Future<void> _disableScreenAwake() async {
    // setState(() {
    //   _isScreenAwake = false;
    // });
    try {
      await platform.invokeMethod('disableWakelock');
    } on PlatformException catch (e) {
      print("Failed to disable screen wake lock: '${e.message}'.");
    }
  }

  @override
  void initState() {
    super.initState();

    prefs!.remove('url');
     user.getLanguageFromServer(context);
    user.socialMediaList();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400), value: 1);

    _tabController2 = TabController(length: 5, vsync: this)
      ..addListener(() {
        if (_tabController2.indexIsChanging) {
          _controller.forward(from: .95);
        }
      });
    //tabs = ;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var provider = Provider.of<AppProvider>(context, listen: false);
      // if (prefs!.containsKey('blog')) {
      //   blogDetailDeepLink(context);
      // }
       
      user.getCMS(context);
      if (provider.visibility.isEmpty) {
        provider.getVisibility();
      }
      //  provider.loadQuotes();
      if (!prefs!.containsKey('isBookmark')) {
        provider.getAllBookmarks().then((DataModel? value) {});
      } else {
        provider.setAllBookmarks();
      }
    });

    // tabs2 = [
    //   ...List.generate(
    //       3,
    //       (index) => Tab(
    //             height: 20,
    //             text: tabNames[index],
    //           ))
    // ];
  }

 
  final List<String> _icons = [
    "asset/Icons/Dashboard.svg",
    "asset/Icons/play_button.svg",
    "asset/Icons/My feed.svg",
    "asset/Icons/Category.svg",
    "asset/Icons/Settings.svg",
  ];

  bool isVisible = true;

  @override
  void dispose() {
    _tabController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
     List<String> tabNames = <String>[
    allMessages.value.dashboard ?? 'Home',
    // 'Videos',
    allMessages.value.shortsNav ?? 'Shorts',
    allMessages.value.myFeed ?? 'My Feed',
    allMessages.value.categoryPost ?? 'Categories',
    // 'Authors',
    allMessages.value.settings ?? 'Settings',
  ];
    var mySystemTheme = SystemUiOverlayStyle(
        systemNavigationBarIconBrightness:
            dark(context) ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: dark(context)
            ? Theme.of(context).scaffoldBackgroundColor
            : Colors.white);
    SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
    var provider = Provider.of<AppProvider>(context,listen:false);
    return ValueListenableBuilder<SettingModel>(
        valueListenable: allSettings,
        builder: (context, value, child) {
          return AnimatedBuilder(
              animation: _tabController2,
              builder: (context, child) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                    body: value.enableMaintainanceMode == '1'
                        ? PopScope(
                            canPop: false,
                            onPopInvoked: (val) async {
                              showCustomDialog(
                                  context: context,
                                  title: allMessages.value.confirmExitTitle ??
                                      "Exit Application",
                                  text: allMessages.value.confirmExitApp ??
                                      'Do you want to exit from app ?',
                                  onTap: () {
                                    var provider = Provider.of<AppProvider>(
                                        context,
                                        listen: false);
                                    var end = DateTime.now();
                                    provider.addAppTimeSpent(
                                        startTime: provider.appStartTime,
                                        endTime: end);
                                    provider.getAnalyticData();
                                    Future.delayed(
                                        const Duration(milliseconds: 300));
                                    exit(0);
                                  },
                                  isTwoButton: true);
                            },
                            child: MaintainanceWidget(value: value),
                          )
                        : PopScope(
                            canPop: false,
                            onPopInvoked: (val) async {
                              showCustomDialog(
                                  context: context,
                                  title: allMessages.value.confirmExitTitle ??
                                      "Exit Application",
                                  text: allMessages.value.confirmExitApp ??
                                      'Do you want to exit from app ?',
                                  onTap: () {
                                    var provider = Provider.of<AppProvider>(
                                        context,
                                        listen: false);
                                    var end = DateTime.now();
                                    provider.addAppTimeSpent(
                                        startTime: provider.appStartTime,
                                        endTime: end);
                                    provider.getAnalyticData();
                                    Future.delayed(
                                        const Duration(milliseconds: 300));
                                    exit(0);
                                  },
                                  isTwoButton: true);
                            },
                            child: value.enableMaintainanceMode == '1'
                                ?  MaintainanceWidget(value: value)
                                : Stack(
                                    children: [
                                      LazyIndexedStack(
                                          index: _tabController2.index,
                                          children: [
                                            ScaleWrapper(
                                                key: const ValueKey(1),
                                                animation: _controller,
                                                child: Home(
                                                  initial: widget.isInitial,
                                                  onChanged: (value) {
                                                    isVisible = value;
                                                    setState(() {});
                                                  },
                                                )),
                                             ScaleWrapper(
                                                key: const ValueKey(2),
                                                animation: _controller,
                                                child: PreloadVideoPage(
                                                  focusedIndex: provider.getShortIndex,
                                                  onHomeTap : (){
                                                     _tabController2.index = 0;
                                                      count = 0;
                                                      
                                                       _disableScreenAwake();
                                                        
                                                       setState(() {});
                                                })),
                                            ScaleWrapper(
                                                key: const ValueKey(3),
                                                animation: _controller,
                                                child: const FeedPage()),
                                            ScaleWrapper(
                                                key: const ValueKey(4),
                                                animation: _controller,
                                                child: const Categories()),
                                            ScaleWrapper(
                                                key: const ValueKey(5),
                                                animation: _controller,
                                                child: const SettingsPage()),
                                          ]),
                                      AnimatedPositioned(
                                        curve: Curves.decelerate,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        bottom: isVisible == false
                                            ? Platform.isIOS
                                                ? -86.h
                                                : -70.h
                                            : 0,
                                        width: size.width,
                                        child: Container(
                                          height: Platform.isIOS ? 86.h : 70.h,
                                          decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: !dark(context)
                                                        ? Colors.black12
                                                        : Colors.white12,
                                                    blurRadius: 50,
                                                    spreadRadius: 4)
                                              ]),
                                          child: TabBar(
                                              labelColor: Theme.of(context)
                                                  .primaryColor,
                                              labelPadding: EdgeInsets.zero,
                                              indicatorPadding: EdgeInsets.zero,
                                              indicator: BoxDecoration(
                                                  border: Border(
                                                      top: BorderSide(
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          width: 2)),
                                                  borderRadius:
                                                      BorderRadius.circular(2)),
                                              indicatorSize:
                                                  TabBarIndicatorSize.tab,
                                              padding: EdgeInsets.zero,
                                              dividerColor: Colors.transparent,
                                              dividerHeight: 0,
                                              onTap: (value) {
                                             
                                                if (_tabController2.index ==
                                                    0) {
                                                  count += 1;
                                                  //  if (currIndex != 0 && count == 2) {
                                                  //    currIndex = 0;
                                                  //    count = 0;
                                                  //   // tabController!.index = 0;
                                                  //  }
                                                } else {
                                                  count = 0;
                                                }
                                                if(value != 1){
                                                  _disableScreenAwake();
                                                }
                                                _tabController2.index = value;
                                                setState(() {});
                                              },
                                              controller: _tabController2,
                                              tabs: <Tab>[
                                                ...List.generate(
                                                    5,
                                                    (index) => Tab(
                                                          height: 50.h,
                                                          icon: SvgPicture.asset(
                                                              _icons[index],
                                                              colorFilter: ColorFilter.mode(
                                                                  _tabController2.index == index
                                                                      ? Theme.of(context).primaryColor
                                                                      : dark(context)
                                                                          ? Colors.white38
                                                                          : Colors.black,
                                                                  BlendMode.srcIn),
                                                              width: 24.sp),
                                                          iconMargin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  bottom: 6),
                                                          text: tabNames[index],
                                                        )),
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ),
                          ));
              });
        });
  }
}

class ScaleWrapper extends StatelessWidget {
  const ScaleWrapper({super.key, required this.child, required this.animation});
  final Widget child;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
