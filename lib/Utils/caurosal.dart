import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../model/blog.dart';
import '../presentation/screens/fullscreen.dart';
import '../presentation/screens/news/live_news.dart';
import 'navigation_util.dart';
class CaurosalSlider extends StatefulWidget {


  const CaurosalSlider({super.key,required this.model});
  final Blog model;

  @override
  State<CaurosalSlider> createState() => _CaurosalSliderState();
}

class _CaurosalSliderState extends State<CaurosalSlider> {
  Timer? timer;
  late PageController pageController;
  int currentIndex=0;

   @override
    void initState() {
      pageController = PageController();
       slider();
      
      super.initState();
    }
  
  slider() {
  if (widget.model.images!.length > 1) {
     timer =  Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentIndex < widget.model.images!.length-1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      if (pageController.hasClients) {
        pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }
  }
    @override
    void dispose() {
      timer!.cancel();
      super.dispose();
    }
    
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
       borderRadius: BorderRadius.circular(16),
      child: Container(
            width: size(context).width,
             height: 220.h,
             decoration: BoxDecoration(
           color:const Color.fromRGBO(30, 30, 30, 0.4),
             borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
      children: [
      Positioned.fill(
        top: -20,
        left: -20,
        right: -20,
        bottom: -20,
        child: ClipRRect(
             borderRadius: BorderRadius.circular(16),
            child: SizedBox(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 25,
                sigmaY: 25,
                // tileMode: TileMode.decal,
              ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                    image:CachedNetworkImageProvider("${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}"),
                    fit: BoxFit.cover
                 ),
                 ),
              )),
            ),
          ),
        ),
            Positioned.fill(
              child: SizedBox(
                  width: size(context).width,
                  height:340.h,
                  child: PageView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: pageController,
                    itemCount: widget.model.images!.length,
                    onPageChanged: (value) {
                      currentIndex = value;
                      setState(() { });
                    },
                    itemBuilder: (context, index) {
                      return  GestureDetector(
                    onTap: () {
                      NavigationUtil.to(
                       context,FullScreen(
                        image: widget.model.images![index].toString(), 
                        index: index,
                        images: widget.model.images ,
                        title: widget.model.title.toString(),
                      ),
                    );
                  },
                  child: Hero(
                      tag: widget.model.images![index],
                      child: Container(
                        decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(16)
                      ),
                      width: size(context).width,
                      child: CachedNetworkImage(imageUrl: widget.model.images![index],
              
                       fit: BoxFit.cover,
                       errorWidget: (context, url, error) {
                         return const CircularProgressIndicator();
                       },
                      ),
                        )  ));
                    },
                  ),
          
                ),
             
            ),
          Positioned(
            bottom: 16,
           right: 16,
            child:   AnimatedSmoothIndicator(
          activeIndex: currentIndex,
          count: widget.model.images!.length,
          effect: ScrollingDotsEffect(
              activeDotColor: Theme.of(context).primaryColor,
              dotColor: const Color(0xff707070),
              dotHeight: 8,
              dotWidth: 8,
              radius: 4),
        )
          
            )
          ],
        ),
      ),
    );
  }
}