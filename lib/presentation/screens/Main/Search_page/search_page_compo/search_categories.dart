import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:blogit/presentation/screens/Main/Categories/categories.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../../../../controller/app_provider.dart';
import '../../../../../model/blog.dart';

class SearchCategories extends StatelessWidget {
  const SearchCategories({
    super.key,
    required this.provider
  });

  final AppProvider provider;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 30.5.h,
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            allMessages.value.recentSearch ?? 'Recent Search',
            style: FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
          ),
        ),
        SizedBox(
          height: 29.h,
        ),
        if(provider.blog!.categories != null)
        SizedBox(
          height: 160.h,
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: AnimationLimiter(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.blog!.categories!.length,
                  itemBuilder: (context, index) {
                    Category category =
                        provider.blog!.categories![index];
                    int itemCount = provider.blog!.categories!.length;
                    return AnimationConfiguration.staggeredList(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 300),
                      position: index,
                      child: FadeInAnimation(
                        curve: Curves.decelerate,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          curve: Curves.decelerate,
                          duration: const Duration(milliseconds: 500),
                          horizontalOffset: (size.width / 3) * (index + 1),
                          child: Container(
                            //width: 120.h,
                            // padding: const EdgeInsets.symmetric(
                            //     vertical: 10, horizontal: 14),
                            margin: EdgeInsets.only(
                                left: index == 0 ? 24.w : 8.w,
                                right: index == itemCount - 1 ? 24.w : 0),
                            child: CategoryTab(category: category,padding: EdgeInsets.zero),
                          ),
                        ),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ],
    );
  }
}
