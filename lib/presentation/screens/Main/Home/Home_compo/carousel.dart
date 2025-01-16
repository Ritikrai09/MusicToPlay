import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/Presentation/widgets/widgets.dart';
import 'package:blogit/presentation/screens/Main/Article_details/article_details.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/Utils/shimmer.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/blog.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../../controller/app_provider.dart';

class CarouselWrapper extends StatefulWidget {
  const CarouselWrapper({super.key,});

  @override
  State<CarouselWrapper> createState() => _CarouselWrapperState();
}

class _CarouselWrapperState extends State<CarouselWrapper> {
  int _selectedIndex = 0;
  void onPageChanged(int index, carousel) {
    _selectedIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var  provider = Provider.of<AppProvider>(context,listen:false);
    return Column(
      children:  provider.featureBlogs.isEmpty ? [
          SizedBox(
          width:size(context).width,
          height:230.h,
           child: ShimmerLoader(
                key: const ValueKey(0234),
                width:size(context).width/1.2,
                isHori: true,
                margin: const EdgeInsets.all(5),
                count: 6
            ),
        )
      ] : [
         SizedBox(
          width:size(context).width,
          height:230.h,
           child: CarouselSlider.builder(
              itemCount: provider.featureBlogs.length,
              itemBuilder: (context, index1, index2) => GestureDetector(
                  // key: ValueKey(index1),
                  onTap: () {
                    NavigationUtil.to(context, ArticleDetails(blog: 
                    provider.featureBlogs[index1],
                    likes: likeVisible( provider.featureBlogs[index1],provider) ?? "0",
                    ));
                  },
                  // child: NewsTile(
                  //   height: 250.h,
                  //   // key: ValueKey(index2),
                  //   blog: provider.featureBlogs[index1],
                  //   toShowDivider: false,
                  //   padding:const EdgeInsets.all(12),
                  //   border: Border.all(width: 1,color:Theme.of(context).dividerColor),
                  // )
                child:  CarouselWidget(
                    provider: provider,
                    blog:provider.featureBlogs[index1] ,
                  )
              ),
              options: CarouselOptions(
                onPageChanged: onPageChanged,
                autoPlay: true,
                autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
                viewportFraction: 1,
                height: 230.h,
              )),
         ),
        SpaceUtils.ks6.height(),
        AnimatedSmoothIndicator(
          activeIndex: _selectedIndex,
          count: provider.featureBlogs.length,
          effect: ScrollingDotsEffect(
              activeDotColor: Theme.of(context).primaryColor,
              dotColor: const Color(0xff707070),
              dotHeight: 6,
              dotWidth: 6,
              radius: 3),
        )
      ],
    );
  }
}

class CarouselWidget extends StatefulWidget {
  const CarouselWidget({
    super.key,
    required this.provider,
    required this.blog,
  });

  final Blog blog;
  final AppProvider provider;

  @override
  State<CarouselWidget> createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {


  int countLikes(AppProvider provider){
    // var likeCount=0;
    // provider.permanentlikesIds.forEach((element) {
    //      if (widget.blog.id == element) {
    //        likeCount+=element;
    //      }
    // });
     
    return  widget.blog.likes!.toInt();
  }

  @override
  Widget build(BuildContext context) {
  var provider = Provider.of<AppProvider>(context,listen: false);
  // var blogLikesCount = countLikes(provider);
  int likes=  widget.blog.likes ?? 0;
  var count = provider.permanentlikesIds.contains(widget.blog.id) ? likes+1  : likes; 
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          transformAlignment: Alignment.center,
          alignment: Alignment.center,
          transform: Matrix4.rotationZ(-pi / 180 * 5),
          height: 200.65.h,
          width: 325.56.w,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            
          )
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
          height: 200.65.h,
          width: 325.56.w,
         
          decoration: BoxDecoration(
              image: widget.blog.images != null && widget.blog.images!.isNotEmpty ?
               DecorationImage(image: CachedNetworkImageProvider(widget.blog.images![0]),fit: BoxFit.cover) : null,
              color: Colors.black, borderRadius: BorderRadius.circular(16)),
               foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [
                0.5,
                1.0
              ],
              colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8)
            ])
          ),
        ),
           Positioned.fill(
             child: Padding(
               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
               child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        // height: 33.h,
                       // width: 68.w,
                       padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.5.r),
                            color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimIcon(
                              // key: ValueKey(widget.blog.isUserViewed == 1 && widget.provider.permanentlikesIds.contains(widget.blog.id)),
                                initialValue: true,
                                // color: ColorUtil.themNeutral,
                                height: 12.h,
                                isChange: currentUser.value.id != null,
                                width: 12.h,
                                activeIcon: 'asset/Icons/heart-icon.svg',
                                deactivateIcon: 'asset/Icons/heart-icon.svg',
                                onChanged: (value) {
                                  // if (widget.blog.isUserLiked == 1) {
                                  //    widget.blog.isUserLiked = 0;
                                  //     setState((){});
                                  // } else {
                                  //    widget.blog.isUserLiked = 1;
                                  //     setState((){});
                                //   // }
                                //  provider.setlike(blog: widget.blog);

                                // setState(() {});
                                //  Future.delayed(const Duration(milliseconds: 1000),() {
                                //    provider.getAnalyticData();
                                //  });
                                }),
                            SizedBox(
                              width: 4.3.w,
                            ),
                            Text(
                             count.toString(),
                              style: FontStyleUtilities.t2(context,
                                  fontColor: Colors.black),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.blog.title??'Short Story is a Piece of\nProse Fiction',
                    style: FontStyleUtilities.h5(context,
                            fontWeight: FWT.semiBold, fontColor: Colors.white)
                        .copyWith(fontSize: 15.sp),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SpaceUtils.ks14.height(),
                  // Row(
                  //   children: [
                  //     Container(
                  //     padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 12),
                  //     decoration: BoxDecoration(
                  //       borderRadius: BorderRadius.circular(12),
                  //       color: hexToRgb(widget.blog.categoryColor)
                  //     ),
                  //       child: Text(widget.blog.categoryName.toString(),
                  //       style: const TextStyle(color:Colors.white,fontWeight: FontWeight.w500))
                  //     ),
                  //     const Spacer(),
                  //     Text(
                  //       customDate(widget.blog.scheduleDate as DateTime),
                  //       style: FontStyleUtilities.t4(context,
                  //           fontColor: Colors.white,
                  //           fontWeight: FWT.medium),
                  //     ),
                  
                  //   ],
                  // )
                ],
                 ),
             ),
          
        )
      ],
    );
  }
}
