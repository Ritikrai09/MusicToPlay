import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:blogit/presentation/screens/Main/Categories/categories.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/app_provider.dart';
import '../../../../../model/blog.dart';

class HomeCategories extends StatefulWidget {
  const HomeCategories({
    super.key,
    required this.provider,
  });

  final AppProvider provider;

  @override
  State<HomeCategories> createState() => _HomeCategoriesState();
}

class _HomeCategoriesState extends State<HomeCategories> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 24),
        //   child: Row(
        //     children: [
            
        //       SizedBox(
        //         width: 9.w,
        //       ),
        //      if(provider.quotes.length > 6)
        //       GestureDetector(
        //         onTap: () {
        //           NavigationUtil.to(context,  Categories(title: allMessages.value.quotes ?? 'Quotes',isQuote: true,));
        //         },
        //         child: Container(
        //           height: 26,
        //           width: 69,
        //           decoration: BoxDecoration(
        //               color: Theme.of(context).primaryColor,
        //               borderRadius: BorderRadius.circular(16)),
        //           child: Center(
        //             child: Text(
        //              allMessages.value.seeAll?? 'SEE ALL',
        //               style: FontStyleUtilities.t4(context,
        //                   fontWeight: FWT.extrabold, fontColor: Colors.white),
        //             ),
        //           ),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
       // SpaceUtils.ks24.height(),
        SizedBox(
          width: size(context).width,
          height: 70.h,
          child: Row(
            children: [
              Expanded(
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (notification) {
                    notification.disallowIndicator();
                    return true;
                  },
                  child: AnimationLimiter(
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.provider.quotes.length,
                        itemBuilder: (context, index) {
                          Blog category =
                              widget.provider.quotes[index];
                          int itemCount = widget.provider.quotes.length;
                          return AnimationConfiguration.staggeredList(
                            duration: const Duration(milliseconds: 700),
                            delay: const Duration(milliseconds: 233),
                            position: index,
                            child: Container(
                              decoration: BoxDecoration(
                                border : category.isUserViewed == 1 ||  widget.provider.analytics[4]['blog_ids'].contains(category.id) 
                                ? Border.all(color: Colors.grey,width :1.5)
                                :Border.all(color:Theme.of(context).primaryColor,width :1.5),
                                borderRadius : BorderRadius.circular(100),
                              ),
                              padding: const EdgeInsets.all(2.0),
                              width: 70.w,
                                 margin: EdgeInsets.only(
                                  left: index == 0 ? 24.w : 8.w,
                                  right: index == itemCount - 1 ? 24 : 0),
                              child: CategoryTab(
                                isNews: true,
                                image: category.backgroundImage,
                                name: category.title,
                                onTap: () async {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (ctx) => StoryPage(index: index))).then((val){
                                    widget.provider.quotes.sort((a, b) => a.isUserViewed == 1 ? 1 : 0);
                                    setState(() { });
                                  });
                                },
                              padding: EdgeInsets.zero))
                          );
                        }),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 25.h)
      ],
    );
  }
}

class MyVerticalText extends StatelessWidget {
  final String text;

  const MyVerticalText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 12,
      spacing: 0,
      direction: Axis.vertical,
      alignment: WrapAlignment.center,
      children: text.split("").map((string) => Text(string, 
      style: FontStyleUtilities.t1(context, fontWeight: FWT.extrabold)
      .copyWith(fontSize: 10,letterSpacing: -0.53))).toList(),
    );
  }
}