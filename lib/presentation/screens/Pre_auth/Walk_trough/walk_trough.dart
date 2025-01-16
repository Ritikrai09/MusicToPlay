import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../controller/user_controller.dart';

class WalkTrough extends StatefulWidget {
  const WalkTrough({super.key});

  @override
  State<WalkTrough> createState() => _WalkTroughState();
}

class _WalkTroughState extends State<WalkTrough> {
  late PageController _pageController;
  late Brightness _brightness;

UserProvider user = UserProvider();

@override
  void initState() {
     _pageController = PageController()..addListener(() {});
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
    user.checkSettingUpdate();
    user.getLanguageFromServer(context);
    user.getAllAvialbleLanguages(context);
  });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _brightness = Theme.of(context).brightness;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // int _selectedIndex = 0;
  void onPageChanged(int index) {
    // _selectedIndex = index;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: _brightness == Brightness.light
          ? Colors.white
          : Theme.of(context).primaryColor,
      body: Column(
        children: [
          SizedBox(width: size.width),
          SizedBox(
            height: 70.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  NavigationUtil.to(context, const Login());
                },
                child: Text(
                  'Skip',
                  style: FontStyleUtilities.t4(context,
                      fontColor: _brightness == Brightness.light
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FWT.extrabold),
                ),
              ),
              SizedBox(
                width: 23.3.w,
              ),
            ],
          ),
          SizedBox(
            height: 48.h,
          ),
          Expanded(
              child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: PageView(
              onPageChanged: onPageChanged,
              controller: _pageController,
              children: [
                WalkThroughTile(
                  brightness: _brightness,
                ),
                WalkThroughTile(
                  brightness: _brightness,
                ),
                WalkThroughTile(
                  brightness: _brightness,
                ),
              ],
            ),
          )),
          SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: ExpandingDotsEffect(
                dotHeight: 7.h,
                dotWidth: 7.h,
                dotColor: const Color(0xffECECEC),
                activeDotColor: _brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).primaryColor),
          ),
          SizedBox(
            height: 76.h,
          )
        ],
      ),
    );
  }
}

class WalkThroughTile extends StatelessWidget {
  const WalkThroughTile({
    super.key,
    required this.brightness,
  });
  final Brightness brightness;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size.width,
        ),
        Text(
          'Read articles & watch\nvideos offline',
          textDirection: TextDirection.ltr,
          style: FontStyleUtilities.h3(context, fontWeight: FWT.extrabold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 28.h,
        ),
        Text(
          'Access your content even when\nyou’re not connected to the internet',
          style: FontStyleUtilities.t2(context,
              fontWeight: FWT.semiBold,
              fontColor: brightness == Brightness.light
                  ? ColorUtil.themNeutral
                  : Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: 82.h,
        ),
        SizedBox(
          height: 260.h,
          child: Image.asset('asset/Images/Temp/image.png'),
        ),
        SizedBox(
          height: 105.h,
        )
      ],
    );
  }
}
