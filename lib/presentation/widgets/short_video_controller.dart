import 'dart:async';
import 'dart:developer';

import 'package:blogit/Utils/urls.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/shorts_controller.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/widgets/blogit_video_player.dart';
import 'package:blogit/presentation/widgets/full_screen.dart';
import 'package:blogit/presentation/widgets/svg_icon.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/models/play_video_from.dart';
import 'package:flutter_preload_videos/video_extraction.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../model/blog.dart';

class VideoQalityUrls {
  int quality;
  String url;
  VideoQalityUrls({
    required this.quality,
    required this.url,
  });

  @override
  String toString() => 'VideoQalityUrls(quality: $quality, urls: $url)';
}

class ShortPlayAnyVideo extends StatefulWidget {
  const ShortPlayAnyVideo(
      {super.key,
      this.controller,
      this.aspectRatio,
      this.isYoutube = false,
      this.isShortVideo = false,
      this.onChangedOrientation,
      this.onVideoLoad,
      this.model,
      this.index,
      this.currIndex
    });

  final double? aspectRatio;
  final Blog? model;
  final VideoPlayerController? controller;
  final ValueChanged? onChangedOrientation,onVideoLoad;
  final bool isShortVideo, isYoutube;
  final int? index,currIndex;

  @override
  State<ShortPlayAnyVideo> createState() => _ShortPlayAnyVideoState();
}

class _ShortPlayAnyVideoState extends State<ShortPlayAnyVideo> {
  
  late AppProvider provider;
  bool fullScreen = false;
  VideoPlayerController? videocontroller;

  bool showOverlay = false;

  Timer? hoverOverlayTimer;

  void isShowOverlay(bool val, {Duration? delay}) {
    if (val == true) {
      showOverlay = true;
      setState(() {});
      hoverOverlayTimer = Timer(const Duration(seconds: 3), () {
        showOverlay = val;
        isShowOverlay(false);
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      showOverlay = false;
      hoverOverlayTimer?.cancel();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {

    //conytolle
    // _enableScreenAwake();
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //  log(widget.model!.videoUrl.toString());
     var videoExtract = widget.model!.videoUrl!.length < 100
        ? await extractYoutube(widget.index ?? 0) : null;

     var isVideoExtracted = widget.model != null ?  widget.model!.videoUrl!.length < 100 : false;


     var youtubeLoaded = isVideoExtracted
        ? VideoPlayerController.networkUrl(Uri.parse(videoExtract ?? ""))
        : VideoPlayerController.networkUrl(Uri.parse( widget.model != null ?  widget.model!.videoUrl ?? "" : ""));

    // var new2 =  widget.model!.videoUrl!.length < 100 && widget.isShortVideo == true
    //     ?   widget.controller ?? VideoPlayerController.networkUrl(Uri.parse(
    //         widget.model!.videoUrl ?? (widget.model != null ? widget.model!.videoUrl ?? "" : "")))
    //     : null;

  
    //  if(widget.onVideoLoad != null ){
        // widget.onVideoLoad!(false);
        // if(widget.currIndex == widget.index){
          try {
               
               videocontroller = youtubeLoaded;

                  // var preload = Provider.of<AppProvider>(context, listen: false);

               videocontroller!.initialize().then((_) {
                    videocontroller!.play();
                    videocontroller!.setLooping(true);
                   if (isVideoExtracted) {
                    if (widget.isShortVideo == false) {
                       blogListHolder.getList().blogs[widget.index ?? 0].videoUrl = videoExtract;
                    } else if (widget.isShortVideo == true ) {
                        shortLists.blogModel.blogs[widget.index ?? 0].videoUrl = videoExtract;  
                    }

                }
                 setState(() {});
              });

              

            } on Exception catch (e) {
              
               throw Exception(e);
            }
        // }
         setState(() {});
      });
    
    super.initState();
  }

   Future<String?> extractYoutube(int i) async {

    log(widget.model!.videoUrl.toString());
      var urlss = await  getVideoQualityUrlsFromYoutube(
       PlayVideoFrom.youtube( widget.model!.videoUrl ?? "").dataSource ?? "",
      false,
    );
    
    final youtubeurl =  urlss != null && urlss.isNotEmpty ?
      await getUrlFromVideoQualityUrls(
      qualityList: [ 720, 480, 360, 240],
      videoUrls: urlss,
      initQuality : 360,
    ) : null;
    
    log("youtubeurl??""");
    log(youtubeurl??"");

    return youtubeurl;
  }
  

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ObjectKey(widget.model!.videoUrl),
      onVisibilityChanged: (visibility) {
        var visiblePercentage = visibility.visibleFraction * 100;

        if (visiblePercentage >= 50.0 &&
            mounted &&
            videocontroller != null ) {

              videocontroller!.play();
        
        } else if (visiblePercentage < 50.0 &&
            videocontroller != null ) {
          
            videocontroller!.pause();
        }
      },
      child: RepaintBoundary(
           child:OrientationBuilder(builder: (context, orientation) {
          return Stack(
            children: [
             if(videocontroller != null && videocontroller!.value.isInitialized)
              SizedBox(
                width: size(context).width,
                height: orientation == Orientation.landscape
                     ?  size(context).height 
                     : widget.aspectRatio != null
                    ? null
                    : orientation == Orientation.landscape
                     ?  size(context).height 
                     : size(context).height * 0.3,
                child: AspectRatio(
                  aspectRatio: widget.aspectRatio ?? ( widget.isShortVideo == true &&( (widget.model != null &&  widget.model!.videoUrl!.contains('shorts'))) ? 9/16 : videocontroller!.value.aspectRatio),
                  child: VideoPlayer(videocontroller!),
                ),
              ),
              if (videocontroller != null)
                ShowOverlay(
                  controller: videocontroller!,
                  showLay: showOverlay,
                  isAds: widget.isShortVideo,
                  onTap: () {
                    if (videocontroller!.value.isPlaying == true) {
                      videocontroller!.pause();
                      showOverlay = true;
                      hoverOverlayTimer?.cancel();
                    } else {
                      videocontroller!.play();
                      isShowOverlay(true);
                    }
                    setState(() {});
                  },
                  isFullScreen: orientation == Orientation.landscape,
                  onOverlayTap: () {
                    if (showOverlay == false) {
                      isShowOverlay(true);
                    } else {
                      isShowOverlay(false);
                    }
                  },
                  // onFullScreen: widget.onChangedOrientation??,
                  onFullScreen: () {
                    if (widget.onChangedOrientation == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FullScreenVideo(controller: videocontroller!)));
                    } else {

                      var orientation = MediaQuery.of(context).orientation == Orientation.landscape;

                        if (orientation == false) {
                          widget.onChangedOrientation!(true);
                        } else {
                          widget.onChangedOrientation!(false);
                        }
                      // Navigator.pop(context);
                    }
                  },
                  isPlay: videocontroller!.value.isPlaying,
                ),
               if(videocontroller == null )
               Positioned.fill(
               child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                   foregroundDecoration: const BoxDecoration(
                     color: Colors.black54,
                   ),
                    child: CachedNetworkImage(
                  imageUrl:  widget.isShortVideo == true ? "${Urls.mainUrl}uploads/short_video/${ widget.model!.backgroundImage ?? ''}" : widget.model!.images![0],
                  errorWidget: (context, url, error) {
                    return Padding(
                      padding: const EdgeInsets.all(50.0),
                      child: Image.asset(
                        'assets/images/app_icon.png',
                      ),
                    );
                  },
                  fit: BoxFit.cover),
                  ),
                  const Align(
                    alignment: Alignment.center,
                      child: Center(child: CircularProgressIndicator()
                    )
                  ),
                ],
               ),
             ),
            ],
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    if(videocontroller != null){
      videocontroller!.pause();
      videocontroller = null;
    }
    super.dispose();
  }
}

class ShowOverlay extends StatefulWidget {
  const ShowOverlay({
    super.key,
    this.isPlay = false,
    this.onTap,
    required this.controller,
    this.onOverlayTap,
    this.onFullScreen,
    this.isFullScreen = false,
    this.showLay = false,
    this.isAds = false,
  });

  final bool isPlay, showLay, isFullScreen, isAds;
  final VideoPlayerController controller;
  final VoidCallback? onTap, onOverlayTap, onFullScreen;

  @override
  State<ShowOverlay> createState() => _ShowOverlayState();
}

class _ShowOverlayState extends State<ShowOverlay> {
  // @override
  // void initState() {
  //     hoverOverlayTimer = Timer(
  //       const Duration(seconds: 3),
  //       () {
  //          isShowOverlay(false);
  //       });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.showLay == true) {
      return Positioned.fill(
        child: GestureDetector(
          onTap: widget.onOverlayTap,
          child: Container(
            color: Colors.black.withOpacity(0.53),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 1 ),
                Center(
                  child: InkResponse(
                    key: ValueKey(widget.isPlay),
                    onTap: widget.onTap,
                    child: BlurWidget(
                      width: 60,
                      height: 60,
                      padding: EdgeInsets.all(widget.isPlay == true ? 18 : 20),
                      child: SvgIcon(
                        widget.isPlay == false
                            ? 'asset/Icons/play_button.svg'
                            : 'asset/Icons/pause.svg',
                        color: Colors.white,
                        width: 16,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                   if (widget.isAds == false)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DurationWidget(
                            key: ValueKey(
                                widget.controller.value.position.inSeconds),
                            controller: widget.controller),
                        const Spacer(),
                        IconButton(
                          onPressed: widget.onFullScreen,
                          icon: widget.isFullScreen == false
                              ? const Icon(Icons.fullscreen,
                                  color: Colors.white)
                              : const Icon(Icons.fullscreen_exit,
                                  color: Colors.white),
                        )
                      ],
                    ),
                  ),
                VideoProgressIndicator(
                    padding: const EdgeInsets.only(top: 5),
                    widget.controller,
                    allowScrubbing: true)
              ],
            ),
          ),
        ),
      );
    } else {
      return Positioned.fill(
          child: GestureDetector(
              onTap: widget.onOverlayTap,
              child: Container(
                color: Colors.transparent,
              )));
    }
  }
}

