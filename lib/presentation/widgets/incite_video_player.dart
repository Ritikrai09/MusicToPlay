import 'dart:async';
import 'dart:developer';

import 'package:blogit/Utils/urls.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/widgets/share.dart';
import 'package:blogit/presentation/widgets/the_logo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:webviewtube/webviewtube.dart';
import '../../model/blog.dart';
import 'svg_icon.dart';
import 'youtube_support_full_play.dart';

class PlayAnyVideoPlayer extends StatefulWidget {
  const PlayAnyVideoPlayer(
      {super.key,
      this.videoUrl,
      this.controller,
      this.aspectRatio,
      this.isCurrentlyOpened = false,
      this.orientation,
      this.onDurationChange,
      this.isShortVideo = false,
      this.onChangedOrientation,
      this.isLive = false,
      this.isAds = false,
      this.index,
      this.startAt=0,
      this.isPlayCenter = false,
      this.model,
      this.isNormalVideo = false});

  final String? videoUrl;
  final double? aspectRatio;
  final Blog? model;
  final bool isAds, isLive, isCurrentlyOpened;
  final int? startAt;
  final Orientation? orientation;
  final WebviewtubeController? controller;
  final ValueChanged? onChangedOrientation, onDurationChange;
  final bool isNormalVideo, isPlayCenter;
  final bool isShortVideo;
  final int? index;

  @override
  State<PlayAnyVideoPlayer> createState() => _PlayAnyVideoPlayerState();
}

class _PlayAnyVideoPlayerState extends State<PlayAnyVideoPlayer>
    with WidgetsBindingObserver {
      
  bool fullScreen = false;
  bool playVideoOnDifferentPage = false;
  bool isLiveError  = false;
  // VideoPlayerController? videocontroller;

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

  late WebviewtubeController controller;
   late WebviewtubeOptions options ;
  
  late int startAt;

  @override
  void initState() {
    //conytolle
    // _enableScreenAwake();
    WidgetsBinding.instance.addObserver(this);
    startAt = widget.startAt ?? 0;
    // var extractYouTubeVideoId2 = extractYouTubeVideoId((widget.model != null? widget.model!.videoUrl ?? "" : widget.videoUrl ?? ""));

    controller = widget.controller ?? WebviewtubeController(
      onPlayerReady: () {

          
        if (widget.onChangedOrientation == null) {
          
           if (widget.isLive == true ) {
             controller.play();
           }else if(widget.isCurrentlyOpened == true && widget.isShortVideo == true){
            controller.play();
           }else if(widget.isCurrentlyOpened == true && widget.isShortVideo == false){

             controller.play();
             playVideoOnDifferentPage = false;

           }
           
        } else if (widget.onChangedOrientation != null || widget.isShortVideo == true || widget.isLive == true) {
           
           controller.play();
           
            playVideoOnDifferentPage = false;
        }
        setState(() {});
      },
      onPlayerError: (error) {
        if (error.errorCode == 150) {
          
          if (widget.isLive == false) {
            playVideoOnDifferentPage = true;
            controller.reload();
          }
           if (widget.isLive == true) {
              isLiveError = true;
              setState(() {});
           }
        }
      },
      onPlayerWebResourceError: (error) {
      //  / log(error.errorCode.toString());
         playVideoOnDifferentPage = true;
        
          if (widget.isLive == true) {
              isLiveError = true;
           }

            setState(() {});
         
      },
    );
     
     // load video
    //  controller.load(extractYouTubeVideoId2 ?? "", startAt: widget.startAt ?? 0);
    

     options  = WebviewtubeOptions(
      currentTimeUpdateInterval: 170,
      showControls: !widget.isShortVideo, forceHd: false, loop: true, interfaceLanguage: 'en');
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (widget.onChangedOrientation != null) {
        widget.onChangedOrientation!(true);
      }

      // var newVariable = widget.videoUrl != null && widget.isYoutube == true
      //     ? await CacheVideoController()
      //         .playYoutubeVideo(url: widget.videoUrl ?? "", isLive: widget.isLive)
      //     : null;

      // var new2 = widget.isLive == false && widget.videoUrl !=  null && widget.videoUrl!.length < 100
      //     ?  VideoPlayerController.networkUrl(Uri.parse(
      //         widget.videoUrl ?? (widget.model != null ? widget.model!.videoUrl ?? "" : "")))
      //     : null;

      // if (widget.isLive == false) {

      //   videocontroller = (widget.controller ??
      //     (widget.videoUrl != null ? newVariable : new2)
      //         as VideoPlayerController)..pause();

      // } else {

      //   videocontroller = (widget.controller ??
      //     (widget.videoUrl != null ? newVariable : new2)
      //         as VideoPlayerController)..play();
      // }
      
      if (widget.model != null) {
        var provider = Provider.of<AppProvider>(context, listen: false);
       
        provider.addviewData(widget.model!.id!.toInt());
        setState(() {});
      }
    });

    super.initState();
  }


  @override
  void dispose() {
    // If a controller is passed to the player, remember to dispose it when
    // it's not in need.
    controller.pause();
    playVideoOnDifferentPage = false;
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlayAnyVideoPlayer oldWidget) {
    if (widget.isCurrentlyOpened != oldWidget.isCurrentlyOpened) {
      controller.pause();
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
     var provider = Provider.of<AppProvider>(context, listen: false);
    return VisibilityDetector(
      key: ObjectKey(widget.videoUrl.toString()),
      onVisibilityChanged: (visibility) {
        var visiblePercentage = visibility.visibleFraction * 100;

        if (visiblePercentage >= 50.0 &&
            mounted && widget.isCurrentlyOpened == true ) {

            controller.play();
            if(widget.startAt != null){
               controller.seekTo(Duration(seconds: widget.startAt ?? 0),allowSeekAhead: true);
            }

        } else if (visiblePercentage < 50.0) {

          controller.pause();
        }
      },
      child: RepaintBoundary(
        child: OrientationBuilder(builder: (context, orientation) {
          var height2 = widget.isShortVideo == true
                      ? size(context).height : widget.aspectRatio != null
                      ? null
                      : widget.onChangedOrientation != null
                          ? size(context).height
                          : size(context).height * 0.3;
          return Stack(
            children: [
              if (playVideoOnDifferentPage == false)
                SizedBox(
                  width: size(context).width,
                  height: height2,
                  child: WebviewtubePlayer(
                    videoId: extractYouTubeVideoId(widget.model != null
                            ? widget.model!.videoUrl ?? ""
                            : widget.videoUrl ?? "") ??
                        "",
                    options: options,
                    controller: controller,
                  ),
                )
              else
                SizedBox(
                  width: size(context).width,
                  height: height2,
                  child: Stack(
                    children: [
                      Container(
                          foregroundDecoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                          ),
                          child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              height: height2,
                              imageUrl: widget.isShortVideo == true ?
                                "${Urls.mainUrl}uploads/short_video/${widget.model!.backgroundImage}"
                               : widget.model != null
                                  ? widget.model!.images![0]
                                  : '')),
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                            child: InkResponse(
                            onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder:
                                (context)=>  YoutubeSupportPlayScreen(
                                  blog: widget.model,
                                  isShortVideo : widget.isShortVideo,
                                  index: widget.index,
                                )));
                              },
                                child: const BlurWidget(
                                  width: 60,
                                  height: 60,
                                  padding: EdgeInsets.all( 20),
                                  child: SvgIcon('asset/Icons/play_button.svg',
                                    color: Colors.white,
                                    width: 16,
                                  ),
                                ),
                              ),
                            ),
                           
                          ],
                        ),
                      ),
                    ],
                  ),
                ), 
               if (isLiveError == false && playVideoOnDifferentPage == false && widget.isShortVideo == false )
                Positioned(
                  right: 8,
                  left: 0,
                  bottom: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Spacer(),
                      InkWell(
                        onTap: (){
                           if (widget.onChangedOrientation == null) {
                                 controller.pause();
                                 setState(() { });

                                  Navigator.push(context,
                                  MaterialPageRoute(builder: (context)=> YoutubeSupportPlayScreen(
                                    isWebViewPlayer: true,
                                    blog: widget.model,
                                    startAt : controller.value.position.inSeconds,
                                    index: widget.index,
                                    // webviewtubeController: controller
                                  ))).then((value){
                                    widget.onDurationChange!(value);
                                  });

                            } else {

                              var orientation = MediaQuery.of(context).orientation == Orientation.landscape;

                                if (orientation == false) {
                                  widget.onChangedOrientation!(true);
                                } else {
                                  widget.onChangedOrientation!(false);
                                   Navigator.pop(context,controller.value.position.inSeconds);
                                }
                            }       
                        },
                        child: Container(
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)
                          ),
                          width: 80,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const TheLogo(
                                width: 40,
                                rectangle: true,
                              ),
                              const SizedBox(width: 5),
                              Icon(
                                widget.onChangedOrientation != null
                                ? Icons.fullscreen_exit_rounded 
                                : Icons.fullscreen,
                                color: Colors.black,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
               )else if(widget.isShortVideo == true && widget.isAds==false )
              Positioned(
              bottom: 60,
              right: 0,
              left: 0,
              child: Container(
                width: size(context).width,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87])),
                padding: const EdgeInsets.only(left: 15, right: 0, bottom: 30),
                child:  shortsActions(provider)))
              // Positioned(
              //   left: 0,
              //   right: 0,
              //   bottom: 0,
              //   child: LinearVideoProgress(
              //     controller: controller),)
              // if (videocontroller != null)
              //   ShowOverlay(
              //     controller: controller,
              //     showLay: showOverlay,
              //     isAds: widget.isAds || widget.isShortVideo,
              //     onTap: () {
              //       if (videocontroller!.value.isPlaying == true) {
              //         videocontroller!.pause();
              //         showOverlay = true;
              //         hoverOverlayTimer?.cancel();
              //       } else {
              //         videocontroller!.play();
              //         isShowOverlay(true);
              //       }
              //       setState(() {});
              //     },
              //     isFullScreen: widget.onChangedOrientation != null,
              //     onOverlayTap: () {
              //       if (showOverlay == false) {
              //         isShowOverlay(true);
              //       } else {
              //         isShowOverlay(false);
              //       }
              //     },
              //     onFullScreen: () {
              //       if (widget.onChangedOrientation == null) {
              //         Navigator.push(
              //             context,
              //             MaterialPageRoute(
              //                 builder: (context) =>
              //                     FullScreenVideo(controller: videocontroller!)));
              //       } else {
              //         SystemChrome.setPreferredOrientations([
              //           DeviceOrientation.portraitUp,
              //           DeviceOrientation.portraitDown,
              //         ]);
              //         Navigator.pop(context);
              //       }
              //     },
              //     isPlay: videocontroller!.value.isPlaying,
              //   ),
              //  Positioned(
              //   right: 0,
              //   child: InkWell(
              //     onTap: (){

              //     },
              //     child: Container(
              //       width: 60,
              //       // height: 25,
              //       margin: EdgeInsets.all(16),
              //       decoration: BoxDecoration(
              //         color: Colors.black.withOpacity(0.4),
              //         borderRadius: BorderRadius.circular(100),
              //         border: Border.all(width: 1,color: Colors.grey)
              //       ),
              //       padding: EdgeInsets.symmetric(horizontal:12,vertical: 6),
              //       child: Text('Visit Us'),
              //     ),
              //   )
              // ),
              // const SizedBox(height: 40),
              // _loadVideoFromUrl()
              //     if(showOverlay == true)
              //      Positioned(
              //        right: 8,
              //        top: 16,
              //        child: IconButton(
              //        onPressed: () async {
              //        await showModalBottomSheet(
              //          context: context,
              //           showDragHandle: true,
              //           enableDrag : true,
              //          builder: (context) {
              //            return VideoQualitySelectorMob(
              //              initSelectedQuality : preloadProvider.getVideoQuality,
              //              onChanged: (val) async {

              //                Navigator.pop(context);
              //                var currentPosition  = videocontroller!.value.position;
              //                log(currentPosition.toString());
              //                 if(widget.model!.videoUrl  != null ){

              //                    preloadProvider.setVideoQuality = val;

              //                    videocontroller = (await CacheVideoController().playYoutubeVideo(
              //                      url:  widget.model!.videoUrl ?? "",
              //                      setDuration: currentPosition,
              //                      initQuality: val
              //                    ));

              //                    setState(() { });
              //                 }
              //                // videocontroller =  VideoPlayerController.networkUrl(
              //                //   Uri.parse(widget.videoUrl ?? ""))..initialize();
              //              },
              //              quality: const [1080, 720, 480, 360, 240],
              //            );
              //          });
              //    },
              //    icon:  Image.asset("assets/images/video_quality.png",width: 30, height: 30),
              //  ))
              ,
              
             
            ],
          );
        }),
      ),
    );
    
  }


  @override
  void deactivate() {
    super.deactivate();
     controller.pause();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // controller.reload();
      controller.pause();
      setState(() {});
    }else if (state == AppLifecycleState.resumed) {
      // controller.reload();
     if(widget.isCurrentlyOpened == true && widget.isShortVideo == true){
       controller.play();
        setState(() {});
     }
    }
  }


  Widget shortsActions(AppProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
         Expanded(
          flex: 4,
          child:  ExpandableDescription(blog: widget.model ?? Blog())),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // InkResponse(
                //   key: ValueKey(preload.controllers[widget.index]!
                //       .value.isPlaying),
                //   onTap: () {
                //     if (preload.controllers[widget.index]!.value
                //             .isPlaying ==
                //         true) {
                //       preload.pauseVideoAtIndex(widget.index);
                //     } else {
                //       preload.playVideoAtIndex(widget.index);
                //     }
                //     setState(() {});
                //   },
                //   child: BlurWidget(
                //     width:  42,
                //     height: 42,
                //     padding: const EdgeInsets.all(13),
                //     child: SvgIcon(
                //       preload.controllers[widget.index]!.value
                //                   .isPlaying ==
                //               false
                //           ? 'asset/Icons/play_button.svg'
                //           : 'asset/Icons/pause.svg',
                //       color: Colors.white,
                //       width:  20,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),
                // InkResponse(
                //   onTap: () {
                //     if (controller.value.isMuted == true) {
                //       controller.unMute();
                //     } else {
                //       controller.mute();
                //     }
                //     provider.setMute = !provider.isMute;
                //     setState(() {});
                //   },
                //   child: BlurWidget(
                //     width: 42,
                //     height: 42,
                //     padding: const EdgeInsets.all(10),
                //     child: Icon(
                //       provider.isMute == true
                //           ? Icons.volume_off_rounded
                //           : Icons.volume_up_rounded,
                //       color: Colors.white,
                //       size: 20,
                //     ),
                //   ),
                // ),
                const SizedBox(height: 16),
                InkResponse(
                    onTap: () async {
                      shareText(widget.model ?? Blog());
                    },
                    radius: 28,
                    child: const BlurWidget(
                      width: 42,
                      radius: 100,
                      height: 42,
                      padding: EdgeInsets.all(10),
                      child: SvgIcon('asset/Icons/share.svg',
                          color: Colors.white),
                    )),
                const SizedBox(height: 4),
              ]),
        ),
      ],
    );
  }
}

class LinearVideoProgress extends StatefulWidget {
  const LinearVideoProgress({
    super.key,
    required this.controller,
  });

  final WebviewtubeController controller;

  @override
  State<LinearVideoProgress> createState() => _LinearVideoProgressState();
}

class _LinearVideoProgressState extends State<LinearVideoProgress> {
  
  @override
  void initState() {
    setState(() {
      
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant LinearVideoProgress oldWidget) {
   if(widget.key != oldWidget.key){
     setState(() {
       
     });
   }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
     Widget progressIndicator;
    if (widget.controller.value.isReady) {
      final int duration = widget.controller.value.videoMetadata.duration.inMilliseconds;
      final int position = widget.controller.value.position.inMilliseconds;
     log((position / duration).toString());
     var string = (position / duration).toString();
     progressIndicator = Stack(
        fit: StackFit.passthrough,
        children: <Widget>[
          LinearProgressIndicator(
            value: double.parse(duration.toString()),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
            backgroundColor: Colors.black45,
          ),
          LinearProgressIndicator(
            value: string != 'NaN' ? double.parse(string) : 0.0,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            backgroundColor: Colors.transparent,
          ),
        ],
      );
    } else {
      progressIndicator = LinearProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
        backgroundColor: Colors.black45,
      );
    }
    return progressIndicator;
  }
}


  String? extractYouTubeVideoId(String url) {
  final RegExp regExp = RegExp(
    r'(?<=watch\?v=|youtu\.be/|shorts/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
  );

  final match = regExp.firstMatch(url);
  return match?.group(0);
}
  // @override
  // void dispose() {
  //   if(widget.isLive == false || widget.isShortVideo == false){
  //      videocontroller = null;
  //   }
  //   super.dispose();
  // }


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
  final WebviewtubeVideoPlayer controller;
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
                Spacer(flex: widget.isAds || widget.isFullScreen ? 1 : 3),
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
                // if (widget.isAds == false)
                //   Padding(
                //     padding: const EdgeInsets.only(left: 16.0, right: 8),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         DurationWidget(
                //             key: ValueKey(
                //                 widget.controller.value.position.inSeconds),
                //             controller: widget.controller),
                //         const Spacer(),
                //         IconButton(
                //           onPressed: widget.onFullScreen,
                //           icon: widget.isFullScreen == false
                //               ? const Icon(Icons.fullscreen,
                //                   color: Colors.white)
                //               : const Icon(Icons.fullscreen_exit,
                //                   color: Colors.white),
                //         )
                //       ],
                //     ),
                //   ),
                const SizedBox(height: 8),
                // VideoProgressIndicator(
                //     padding: const EdgeInsets.only(top: 5),
                //     widget.controller,
                //     allowScrubbing: true)
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

class ExpandableDescription extends StatefulWidget {
  const ExpandableDescription({super.key,required this.blog});

  final Blog blog;
  

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {


   bool isExpand =false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          isExpand = !isExpand;
          setState(() {});
        },
        child: Container(
          padding: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            gradient: isExpand == true ? const LinearGradient(

              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
             Colors.black87,
              Colors.black
            ]) : null
          ),
            width: size(context).width / 1.33,
            child: RichText(
                maxLines: isExpand == true ? 12 : 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                text: TextSpan(
              
                  children: [
                    TextSpan(
                      text: isExpand == false &&
                              widget.blog.title!.length > 99
                          ? widget.blog.title
                              .toString()
                              .substring(0, 100)
                          : widget.blog.title.toString(),
                  
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(
                            fontSize: 17,
                            color: Colors.white,
                          ),
                    ),
                    if (widget.blog.title!.length > 89)
                      TextSpan(
                          text: isExpand == true
                              ? "...see less"
                              : '...see more',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600))
                  ],
                ))),
      );
  }
}

class DurationWidget extends StatefulWidget {
  const DurationWidget({
    super.key,
    required this.controller,
  });

  final VideoPlayerController controller;

  @override
  State<DurationWidget> createState() => _DurationWidgetState();
}

class _DurationWidgetState extends State<DurationWidget> {
  late VideoPlayerController video;

  late VoidCallback listener;

  _VideoProgressIndicatorState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    video = widget.controller;
    _VideoProgressIndicatorState();
    video.addListener(listener);
    super.initState();
  }

  String formatDuration(int seconds) {
    int hours = (seconds ~/ 3600);
    int minutes = (seconds % 3600) ~/ 60;
    int secondsRemaining = seconds % 60;

    // Format the hours, minutes, and seconds with leading zeros if needed
    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = secondsRemaining.toString().padLeft(2, '0');

    return hours > 1
        ? '$formattedHours:$formattedMinutes:$formattedSeconds'
        : '$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${formatDuration(video.value.position.inSeconds)} / ${formatDuration(video.value.duration.inSeconds)}",
      key: ValueKey(video.value.position.inSeconds),
      textAlign: TextAlign.left,
      style: const TextStyle(color: Colors.white),
    );
  }
}
