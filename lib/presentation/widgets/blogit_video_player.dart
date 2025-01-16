
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/widgets/full_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../controller/app_provider.dart';
import '../../model/blog.dart';

import 'svg_icon.dart';

class PlayAnyVideoPlayer2 extends StatefulWidget {
  const PlayAnyVideoPlayer2({super.key,this.videoUrl, this.controller,this.aspectRatio,this.isYoutube=false,
  this.isShortVideo=false,this.onChangedOrientation,this.isLive=false ,this.isAds = false,this.isPlayCenter=false ,this.model,this.isNormalVideo=false});

  final String? videoUrl;
  final double? aspectRatio;
  final Blog? model;
  final bool isAds,isLive;
  final VideoPlayerController? controller; 
  final ValueChanged? onChangedOrientation;
  final bool isNormalVideo, isPlayCenter;
  final bool isShortVideo,isYoutube;

  @override
  State<PlayAnyVideoPlayer2> createState() => _PlayAnyVideoPlayer2State();
}

class _PlayAnyVideoPlayer2State extends State<PlayAnyVideoPlayer2> {
  
final videoTextFieldCtr = TextEditingController();
late AppProvider provider;
bool fullScreen = false;
late VideoPlayerController videocontroller;

  bool showOverlay = false;
  
  Timer? hoverOverlayTimer;

  void isShowOverlay(bool val, {Duration? delay}) {
    if (val == true) {
      showOverlay = true;
       setState(() {   });
      hoverOverlayTimer = Timer(const Duration(seconds: 3), () {
         showOverlay = val;
         isShowOverlay(false);
         setState(() {   });
     });
    } else {
       showOverlay = false;
      hoverOverlayTimer?.cancel();
      setState(() { });
    }
  }

  
  
  @override
  void initState()  {
    //conytolle
    // _enableScreenAwake();
    if(widget.onChangedOrientation != null){
      widget.onChangedOrientation!(true);
    } 
    videocontroller =  widget.controller ??  VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl ?? ""))..initialize()..play();
    // controller = PodPlayerController(
    //   playVideoFrom : widget.isNormalVideo == true ? 
    //   PlayVideoFrom.network(widget.videoUrl  != null 
    //   ? widget.videoUrl  ?? "" 
    //   : widget.model!.media ?? "") :
    //   PlayVideoFrom.youtube(widget.videoUrl  != null 
    //   ? widget.videoUrl  ?? "" 
    //   : widget.model!.videoUrl ?? ""),
    //   podPlayerConfig: const PodPlayerConfig(
    //     videoQualityPriority: [720, 480, 360],
    //     autoPlay: false,
    //   ),
    // )..initialise()..hideOverlay();
    
    if( widget.model != null){
     WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
       var provider = Provider.of<AppProvider>(context,listen: false);
       provider.addviewData(widget.model!.id!.toInt());
       setState(() { });
     });
    }

    super.initState();
  }

  @override
  void dispose() {
   if(widget.onChangedOrientation == null && widget.isLive == false){
     videocontroller.dispose();
   }
    // _disableScreenAwake();
    super.dispose();
  }



  // @override
  // void deactivate() {
  //   _disableScreenAwake();
  //   super.deactivate();
  // }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
          key:ObjectKey( widget.videoUrl.toString()),
          onVisibilityChanged: (visibility) {
            var visiblePercentage = visibility.visibleFraction * 100;
            if (visiblePercentage >= 50.0 && mounted) {
                videocontroller.play();
            } else if (visiblePercentage < 50.0 && mounted) {
                videocontroller.pause();
            }
          },
          child: RepaintBoundary(
           child: OrientationBuilder(
             builder: (context, orientation) {
               return Stack(
                 children: [
                 SizedBox(
                          width: size(context).width,
                          height :  widget.aspectRatio != null ? 
                            null: widget.onChangedOrientation != null 
                          ? size(context).height : size(context).height * 0.27,
                          child :  AspectRatio(
                          aspectRatio: widget.aspectRatio ?? 4/3,
                          child:  VideoPlayer(
                          videocontroller
                        ),
                      ),
                   ),
                  
                     ShowOverlay(
                      key: ValueKey("$showOverlay${videocontroller.value.isPlaying}"),
                      controlller: videocontroller,
                      showLay: showOverlay,
                      isAds : widget.isAds,
                      onTap: () {
                        if (videocontroller.value.isPlaying == true) {
                          videocontroller.pause();
                           showOverlay = true;
                           hoverOverlayTimer?.cancel();
                        } else {
                            videocontroller.play();
                            isShowOverlay(true);
                            setState(() {   });
                        }
                        setState(() { });
                      },
                      isFullScreen: widget.onChangedOrientation != null,
                      onOverlayTap: (){
                       if (showOverlay == false) {
                          isShowOverlay(true);
                       } else {
                          isShowOverlay(false);
                       }
                      },
                      onFullScreen: (){
                        if (widget.onChangedOrientation == null) {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> FullScreenVideo(controller: videocontroller)));
                        } else {
                           SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                            DeviceOrientation.portraitDown,
                          ]);
                          Navigator.pop(context);
                        }
                      },
                      isPlay: videocontroller.value.isPlaying,
                      ),
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
                   
                 ],
               );
             }
           ),
      ),
    );
  }

}



class ShowOverlay extends StatefulWidget {
  const ShowOverlay({
    super.key,
    this.isPlay=false,
    this.onTap,
    required this.controlller,
    this.onOverlayTap,
    this.onFullScreen,
    this.isFullScreen=false,
    this.showLay=false,
    this.isAds=false,
  });

  final bool isPlay,showLay,isFullScreen,isAds;
  final VideoPlayerController controlller;
  final VoidCallback? onTap,onOverlayTap,onFullScreen;

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
    if(widget.showLay == true) {
      return  Positioned.fill(
    child:  GestureDetector(
      onTap: widget.onOverlayTap,
      child: Container(
        color: Colors.black.withOpacity(0.53),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Spacer(flex: widget.isAds ? 1 :2),
            Center(
              child: InkResponse(
              key: ValueKey(widget.isPlay),
              onTap: widget.onTap,
                child: BlurWidget(
                width:  60,
                height: 60,
                padding:  EdgeInsets.all(widget.isPlay == true ? 18 : 20),
                child: SvgIcon(widget.isPlay == false
                  ? 'asset/Icons/play_button.svg'
                  : 'asset/Icons/pause.svg',
                  color: Colors.white,
                  width: 16,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 DurationWidget( controller: widget.controlller),
                if(widget.isAds == false)
                IconButton(
                  onPressed:widget.onFullScreen,
                  icon: widget.isFullScreen == false
                  ? const Icon(Icons.fullscreen,color: Colors.white)
                  :const Icon(Icons.fullscreen_exit,color: Colors.white)
                )
              ],
            ),
            VideoProgressIndicator(widget.controlller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 8),)
          ],
        ),
      ),
    ),
  );
    } else {
      return Positioned.fill(child: GestureDetector(
        onTap: widget.onOverlayTap,
        child: Container(
          color: Colors.transparent,
        )));
    }
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

  return hours > 1 ? '$formattedHours:$formattedMinutes:$formattedSeconds' : '$formattedMinutes:$formattedSeconds';
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: Text("${formatDuration(video.value.position.inSeconds)} / ${formatDuration(video.value.duration.inSeconds)}",
      key: ValueKey(video.value.position.inSeconds),
        textAlign: TextAlign.left,
       style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
