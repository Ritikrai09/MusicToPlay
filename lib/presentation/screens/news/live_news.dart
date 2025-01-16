

import 'package:blogit/Utils/screen_timeout_display.dart';
import 'package:blogit/model/blog.dart';
import 'package:blogit/presentation/widgets/incite_video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/loader.dart';

import 'package:video_player/video_player.dart';

import '../../../Utils/app_theme.dart';
import '../../../Utils/color_util.dart';
import '../../../Utils/font_style.dart';
import '../../../controller/news_repo.dart';
import '../../../controller/user_controller.dart';
import '../../../model/news.dart';
import '../../widgets/sliver_appbar_header.dart';
import '../../widgets/svg_icon.dart';
import '../../widgets/theme_button.dart';

class LiveNewsPage extends StatefulWidget {
  const LiveNewsPage({super.key});

  @override
  State<LiveNewsPage> createState() => _LiveNewsPageState();
}

class _LiveNewsPageState extends State<LiveNewsPage>  {
  // ... your code ...

 late bool load;
  LiveNews? live;
  bool isFullScreen = false;


  
 VideoPlayerController? controller;

  @override
  void initState() {
    load = liveNews.isEmpty ? true: false;
     live = liveNews.isNotEmpty ? liveNews[0] : null; 
    ScreenTimeout().enableScreenAwake();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
     await getliveNews(context).whenComplete(() async {
     
          live = liveNews[0]; 
          load = false;
          // controller = await CacheVideoController().playYoutubeVideo( url:live != null ?  live!.url ?? "" : liveNews[0].url ?? "" , isLive: true, cacheDuration: const Duration(days: 0));
          setState(() {   });
      });
    });
    super.initState();
  }

    @override
  void deactivate() {
     ScreenTimeout().disableScreenAwake();
    super.deactivate();
  }

  @override
  void dispose() {
     ScreenTimeout().disableScreenAwake();
     if(controller !=null){
      controller!.pause();
     }
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var landscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return  CustomLoader(
      isLoading: load,
      child: OrientationBuilder(
        builder: (context,orientation) {
          var s = '${allSettings.value.baseImageUrl}/${allSettings.value.liveNewsLogo.toString()}';

          if(orientation == Orientation.landscape) {
            return  youtubeplayer(landscape, context, s);
          } else {
            return  Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: ()async {
                  load = true;
                  setState(() { });
                   await getliveNews(context).whenComplete(() async {
                      live = liveNews[0]; 
                      load = false;
                      // controller = await CacheVideoController().playYoutubeVideo( url:live != null ?  live!.url ?? "" : liveNews[0].url ?? "" , isLive: true, cacheDuration: const Duration(days: 0));
                      setState(() {   });
                  });
                },
                child: CustomScrollView(
                  slivers: [
                   landscape ? const SliverToBoxAdapter() : MyStickyHeader(
                  floating: true,
                  elevation: 0,
                  height: 65.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             const BackbUT(),
                            Text(
                            allMessages.value.liveNews ?? 'Live-News',
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
                    landscape ? const SliverToBoxAdapter() :const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal:landscape ? 0 : 24),
                      sliver: SliverToBoxAdapter(
                        child: youtubeplayer(landscape, context, s),
                      ),
                    ),
                     SliverToBoxAdapter(
                      child: Column(
                        children : landscape ? []
                         : liveNews.isEmpty ? [
                        ]:[
                          ...liveNews.map((e) =>  LiveWidget(
                            title: e.companyName,
                            onTap:()async {
                              if(live!.url != e.url){
                                live = e ;
                              
                                // controller = await CacheVideoController().playYoutubeVideo( url:live!.url ?? "", isLive: true);
                                setState((){});
                              }
                            },
                            image: e.image,
                          ))
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
          }
        }
      ),
    );
  }

  Stack youtubeplayer(bool landscape, BuildContext context, String s) {
    return Stack(
                        children: [
                            Positioned.fill(child: CachedNetworkImage(
                               key:live != null ? ValueKey("${live!.id}${live!.image}") : null,
                              height: landscape ? size(context).height  : 218.h,
                              imageUrl:liveNews.isEmpty ? 
                              s : live != null ? live!.image ?? s : s,
                              fit: BoxFit.cover)),
                             if(liveNews.isEmpty && live == null && controller == null  && load == true )
                              Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black38
                                ),
                                child: const Center(child: CircularProgressIndicator()))
                            )else
                            SizedBox(
                             key:live != null ? ValueKey("${live!.id}${live!.image}") : null,
                            height: landscape ? size(context).height  : 218.h,
                            width: size(context).width,
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(20),
                            //   image:liveNews.isEmpty  ? null :  DecorationImage(image: CachedNetworkImageProvider('${allSettings.value.baseImageUrl}/${allSettings.value.liveNewsLogo.toString()}'),fit: BoxFit.cover)
                            // ),
                            child:  PopScope(
                              canPop: !landscape,
                              onPopInvoked: (didPop) async{
                                if(didPop){
                                  controller!.pause();
                                  return;
                                }
                                if (landscape) {
                                  SystemChrome.setPreferredOrientations(DeviceOrientation.values);
                                  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                                   overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
                                   isFullScreen = false;
                                   setState(() {   });
                                }
                               
                              },
                              child: PlayAnyVideoPlayer(
                                key: ValueKey(live!.id),
                                isLive: true,
                                isCurrentlyOpened: true,
                                model: Blog(
                                  id: live!.id,
                                  videoUrl: live!.url,
                                  images: [live!.image]
                                ),
                                // videoUrl: live != null ? live!.url ?? liveNews[0].url : '',
                              )
                            ) ,
                          ),
                          // Positioned(
                          //   top: 15,
                          //   left: 15,
                          //   right: 15,
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //        Row(
                          //         children: [
                          //         liveNews.isEmpty ? const ShimmerLoader(
                          //           width: 30,
                          //           height: 30,
                          //           borderRadius: 100,
                          //          ) : CircleAvatar(radius: 15,
                          //           backgroundImage: CachedNetworkImageProvider(live!.image.toString())),
                          //           const SizedBox(width: 12),
                          //            liveNews.isEmpty   ?  ShimmerLoader(
                          //           width: size(context).width/2,
                          //           height: 30,
                          //          ) : Text(live!.companyName.toString(),
                          //            style: const TextStyle(
                          //             fontFamily: 'Roboto',
                          //             fontSize: 14,
                          //             color: Colors.white
                          //           )),
                          //         ],
                          //       ),
                                // TapInk(
                                //   onTap: (){} ,
                                //   child: const Icon(Icons.more_vert,size: 16,color: Colors.white))
                            //   ],/
                            // ))
                        ],
                      );
  }
}

Size size(BuildContext context) {
  return MediaQuery.of(context).size;
}

// class ListShimmer extends StatelessWidget {
//   const ListShimmer({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin : const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         mainAxisAlignment :MainAxisAlignment.center,
//         children: [
//            const ShimmerLoader(
//          height: 70,
//          width: 70,
//          borderRadius: 100,
//          ),
//          const SizedBox(width:12),
//          Column(
//           children: [
//             ShimmerLoader(width: size(context).width/2,height: 20),
//             SizedBox(height: height10(context)),
//              ShimmerLoader(width: size(context).width/2,height: 20)
//           ],
//          )
//         ],
//       ),
//     );
//   }
// }

class LiveWidget extends StatelessWidget {
  const LiveWidget({
    super.key,
    this.title,
    this.isLive=false,
    this.onTap,
    this.image,
    this.radius,
  });

final String? title,image;
final double? radius;
final bool isLive;
final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: ColorUtil.themNeutral,
      onTap: onTap ?? (){},
      child: Padding(
        padding: const EdgeInsets.only(left: 24,top: 20,bottom: 30,right: 24),
        child: Row(children: [
           Stack(
             children: [
               CircleAvatar(
                radius:radius ?? 35,
                backgroundImage: CachedNetworkImageProvider(image!),
               ),
               if(isLive ==true)
               Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius:BorderRadius.circular(100) ,
                   color: Colors.black.withOpacity(0.3),
                ),
             child: Center(
               child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                radius: 16.r,
                child: const SvgIcon('asset/Icons/play_button.svg',color: Colors.white,),
                         ),
             ),
          ),
                )
             ],
           ),
           const SizedBox(width: 15),
           Text( title ?? 'Tv',style: TextStyle(
            fontSize: 20,
            color: dark(context)? Colors.white : Colors.black,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w600
           ))
        ]),
      ),
    );
  }
}