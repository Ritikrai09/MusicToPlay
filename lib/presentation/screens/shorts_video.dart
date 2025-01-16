import 'dart:async';
import 'dart:developer';

import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/presentation/widgets/incite_video_player.dart';
import 'package:flutter/material.dart';
import 'package:blogit/controller/shorts_controller.dart';
import 'package:blogit/model/blog.dart';
import 'package:blogit/presentation/widgets/last_widget.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PreloadVideoPage extends StatefulWidget {
  
  const PreloadVideoPage({super.key, required this.onHomeTap, this.focusedIndex});
  final VoidCallback onHomeTap;
  final int? focusedIndex;

  @override
  State<PreloadVideoPage> createState() => _PreloadVideoPageState();
}

class _PreloadVideoPageState extends State<PreloadVideoPage> {

  bool isShare = false;

  int currIndex = 0;

  late PreloadPageController pageController;

  @override
  void initState() {
      // ScreenTimeout().enableScreenAwake();
    pageController = PreloadPageController(initialPage: widget.focusedIndex ?? 0);
    WidgetsBinding.instance.addPostFrameCallback((e) {
     
      currIndex = widget.focusedIndex ?? 0;
      setState(() {  });
    });

    super.initState();
  }


  // @override
  // void deactivate() {
  //    ScreenTimeout().disableScreenAwake();
  //   super.deactivate();
  // }

  @override
  void dispose() {
    pageController.dispose();
    //  ScreenTimeout().disableScreenAwake();
    super.dispose();
  }



  bool isLoad = false;

  Future<List<String>?> expensiveWork(BuildContext context) async {
    // var preload = Provider.of<PreloadProvider>(context, listen: false);

    List<String>? data = await ShortsApi().fetchShorts(nextPageUrl: shortLists.blogModel.nextPageUrl) ??
        [];

    // preload.updateUrls = data;
    // lots of calculations
    return data;
  }

  GlobalKey<RefreshIndicatorState>  refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen:false);
    return SafeArea(
      child: Scaffold(
        body: RefreshIndicator(
              key: refreshKey,
              onRefresh: () async {
                isShare = true;
                setState(() {});
                await Future.delayed(const Duration(milliseconds: 2000));
                ShortsApi().fetchShorts(isInitialLoad: true).then((value) {
                  
                    isShare = false;
                    setState(() { });
                }).onError((e,r){
                    isShare = false;
                    setState(() { });
                });
              },
              child: PreloadPageView.builder(
                itemCount: shortLists.blogModel.blogs.length,
                scrollDirection: Axis.vertical,
                controller: pageController,
                preloadPagesCount: 3,
                onPageChanged: (index) async {
                  
                  // provider.onVideoIndexChanged(index);
                  // provider.focusedIndex = ;
                  currIndex = index;
                  provider.setShortVideo = index;
                    setState(() {});

                  if (index % 8 == 0 &&
                      shortLists.blogModel.nextPageUrl != null &&
                      isLoad == false) {

                    isLoad = true;
                    setState(() {});

                    log('--------------- Current Index  -------------');
                    expensiveWork(context).whenComplete(() {
                      isLoad = false;
                      setState(() {});
                    });

                  }
                   
                },
                itemBuilder: (context, index) {
                  return shortLists.blogModel.blogs[index].id == 000000
                  ? LastNewsWidget(onBack: widget.onHomeTap,
                   onTap: (){
                      // provider.onVideoIndexChanged(0);
                      // ScreenTimeout().enableScreenAwake();
                      pageController.jumpToPage(0);
                      refreshKey.currentState!.show();
                      setState(() { });
                  })
                   : currIndex == index 
                  ? VideoWidget(
                        key: ValueKey("$index"),
                        isLoading: false,
                        index: index,
                        currIndex: currIndex,
                        blog: shortLists.blogModel.blogs[index],
                      ) : VideoWidget(
                        key: ValueKey("$index"),
                        isLoading: false,
                        index: index,
                        currIndex: currIndex,
                        blog: shortLists.blogModel.blogs[index],
                      );
                },
              ),
            )
      ),
    );
  }
}

/// Custom Feed Widget consisting video
class VideoWidget extends StatefulWidget {
  const VideoWidget(
      {super.key,
      required this.isLoading,
       this.controller,
      this.onTap,
      this.index = 0,
      this.currIndex=0,
      required this.blog});

  final bool isLoading;
  final VoidCallback? onTap;
  final int index,currIndex;
  final Blog blog;
  final VideoPlayerController? controller;

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {

  VideoPlayerController? loadController;
  
  bool isLoading = false;

  @override
  void initState() {
   loadController = widget.controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlayAnyVideoPlayer(
              model: widget.blog,
              // currIndex: widget.currIndex,
              // controller: loadController,
              aspectRatio: 9/16,
              index: widget.index,
              isShortVideo: true,
              isCurrentlyOpened: widget.index == widget.currIndex,
             );
  }
}

class ShowOverlay extends StatefulWidget {
  const ShowOverlay({
    super.key,
  });

  @override
  State<ShowOverlay> createState() => _ShowOverlayState();
}

class _ShowOverlayState extends State<ShowOverlay> {
  Timer? hoverOverlayTimer;

  @override
  void initState() {
    hoverOverlayTimer = Timer(
      const Duration(seconds: 3),
      () => isShowOverlay(false),
    );
    super.initState();
  }

  void isShowOverlay(bool val, {Duration? delay}) {
    if (val == true) {
      hoverOverlayTimer = Timer(const Duration(seconds: 2), () {});
    } else {
      hoverOverlayTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black38,
        child: const Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: Colors.black45,
            child: Icon(Icons.volume_off_rounded),
          ),
        ),
      ),
    );
  }
}
