import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Main/Home_wrapper/home_wrapper.dart';
import 'package:blogit/presentation/screens/Pre_auth/Build_feed/build_field_data.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildMyField extends StatefulWidget {
  const BuildMyField({super.key});

  @override
  _BuildMyFieldState createState() => _BuildMyFieldState();
}

class _BuildMyFieldState extends State<BuildMyField> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: CustomScrollView(slivers: [
            MyStickyHeader(
                elevation: 0,
                floating: true,
                pinned: false,
                height: 65.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                )),
            SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                sliver: SliverList(
                    delegate: SliverChildListDelegate([
                  SizedBox(
                    height: 22.h,
                  ),
                  Text(
                    'Which news do you \nwant to see?',
                    style: FontStyleUtilities.h3(context,
                        fontWeight: FWT.extrabold),
                  ),
                  SizedBox(
                    height: 14.h,
                  ),
                ]))),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
              ),
              sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                      (context, int index) => BuildFieldTile(
                          onChanged: (value) {},
                          tittle: BuildFieldData.data[index].tittle,
                          sub: BuildFieldData.data[index].sub),
                      childCount: BuildFieldData.data.length)),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 24.h),
              sliver: SliverList(
                  delegate: SliverChildListDelegate([
                SizedBox(
                  height: 42.h,
                ),
                SignalOutlinedButton(
                    tittle: 'Save & Continue',
                    onTap: () {
                      NavigationUtil.to(context, const HomeWrapper());
                    }),
                SizedBox(
                  height: 12.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        NavigationUtil.to(context, const HomeWrapper());
                      },
                      child: Text(
                        'Skip',
                        style: FontStyleUtilities.t3(context,
                            fontWeight: FWT.extrabold,
                            fontColor: Theme.of(context).primaryColor),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 28.h,
                )
              ])),
            )
          ]),
        ),
      ),
    );
  }
}

class BuildFieldTile extends StatelessWidget {
  const BuildFieldTile(
      {super.key,
      required this.onChanged,
      required this.tittle,
      required this.sub});
  final ValueChanged<bool> onChanged;
  final String tittle, sub;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 13.5.h),
      child: Row(
        children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tittle,
                style:
                    FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
              ),
              SpaceUtils.ks4.height(),
              Text(
                sub,
                style: FontStyleUtilities.t4(context,
                    fontWeight: FWT.bold, fontColor: ColorUtil.themNeutral),
              ),
            ],
          )),
          RoundedCheckBox(onChanged: onChanged)
        ],
      ),
    );
  }
}
