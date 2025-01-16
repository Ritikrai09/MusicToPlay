import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../model/blog.dart';
import '../../presentation/widgets/incite_video_player.dart';
import '../screens/news/live_news.dart';
import '../screens/web_view.dart';

class BlogAd extends StatefulWidget {
  const BlogAd({super.key,this.isBack=false,this.model,required this.onTap});
  final VoidCallback onTap;
  final Blog? model;
  final bool isBack;

  @override
  State<BlogAd> createState() => _BlogAdState();
}

class _BlogAdState extends State<BlogAd> {

  Size? imageSize = Size(375,300);


//   Future calculateImageDimension(String imageUrl) async{
//   Completer<Size> completer = Completer();
//   Image image =  Image(image: CachedNetworkImageProvider(imageUrl)); // I modified this line
//   image.image.resolve(const ImageConfiguration()).addListener(
//     ImageStreamListener(
//       (ImageInfo image, bool synchronousCall) {
//         var myImage = image.image;
//         imageSize = Size(myImage.width.toDouble(), myImage.height.toDouble());
//         completer.complete(imageSize);
//       },
//     ),
//   );
//   // print(imageSize!.width);
//   //  print(imageSize!.height);
//   setState(() { });
// }

  @override
  Widget build(BuildContext context) {
  
    return GestureDetector(
    onTap: widget.model!.sourceLink == null ?
     null : () {
        Navigator.push(context, CupertinoPageRoute(
         builder: (context) => CustomWebView(url: widget.model!.sourceLink.toString())));
     },
      child: AspectRatio(
          aspectRatio: 4/3  ,
        child: SizedBox(
          width: size(context).width,
      
          child:  Stack(
              fit: StackFit.expand,
              children: [
              if(widget.model!.media != null && widget.model!.mediaType == 'image')
               CachedNetworkImage(
               imageUrl: widget.model!.media ?? '',
              //                  width:widget.model!.dimensions != null ? widget.model!.dimensions!.width : null,
              //  height: widget.model!.dimensions != null ? widget.model!.dimensions!.height : null,
               errorWidget: (context, url, error) {
                 return Image.asset('asset/Images/Logo/Signal.png',
                 fit: BoxFit.cover);
               },
                fit: BoxFit.cover)
                else if(widget.model!.videoUrl!.isNotEmpty &&  widget.model!.mediaType == 'video_url')
                PlayAnyVideoPlayer(
                  key: ValueKey(widget.model!.id),
                  isShortVideo: true,
                   isAds:true,
                   isCurrentlyOpened: true,
                  model: widget.model)
                else if(widget.model!.media!.isNotEmpty && widget.model!.mediaType == 'video')
                 MyVideoPlayer(
                  url: widget.model!.media ?? "",
                 ),
                 if(widget.model!.sourceLink != '')
                 Positioned(
                  //left: size(context).width/2,
                  right: 12,
                  bottom: 12,
                ///  width: ,
                  child: SizedBox(
                  child: IconTextButton(
                  text: widget.model!.sourceName ?? 'Explore Now',  
                  splash: Colors.black,
                  //width: size(context).width/3,
                  trailIcon: SvgPicture.asset('asset/Icons/visit.svg',
                  width: 20,
                  height: 20,
                   color: Colors.white,
                  ),
                  color: Colors.white,
                  style: const TextStyle(
                    fontFamily: 'QuickSand',
                    fontSize:13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                  onTap:() {
                  Navigator.push(context, CupertinoPageRoute(
                   builder: (context) => CustomWebView(url: widget.model!.sourceLink.toString())));
                  },
                  ) )),
                //  Positioned(
                //   top: 16,
                //   left: 24,
                //   width: size(context).width/1.2,
                //   child: SafeArea(
                //     child: Row(
                //       mainAxisAlignment : MainAxisAlignment.spaceBetween,
                //       children: [
                //         BackbUT(
                //           onTap: widget.isBack ? (){
                //           Navigator.pop(context);
                //         } : widget.onTap)
                //     ]),
                //   )
                //   ),
                ])
        ),
      ),
    );
  }
}




class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({super.key, required this.url});
  final String url;

  @override
  State<MyVideoPlayer> createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    controller.initialize().then((_) {
      // precache the video
      controller.setLooping(true);
      controller.setVolume(0);
       controller.play();
      // controller.play();
      setState(() {});
      // controller.pause();
    });
  }


@override
  void didChangeDependencies() {
    controller.pause();
    super.didChangeDependencies();
  }


    @override
    void dispose() {
      controller.pause();
      controller.dispose();
      super.dispose();
    }

  bool _audioEnabled = false;
  void _toggleAudio() {
    setState(() {
      _audioEnabled = !_audioEnabled;
      controller.setVolume(0);
      controller.setVolume(_audioEnabled ? 100 : 0);
    });
  }

  // void _playPause() {
  //   if (_isPlay == true) {
  //     setState(() {
  //       controller.pause();
  //     });
  //   } else {
  //     setState(() {
  //       controller.play();
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [VisibilityDetector(
      key: Key(widget.key.toString()),
      onVisibilityChanged: (visibility) {
        var visiblePercentage = visibility.visibleFraction * 100;
        if (visiblePercentage < 1 && mounted) {
          controller.pause();
            setState(() { });
          //pausing  functionality
        } else if (mounted) {
          controller.play();
          setState(() { });
          //playing  functionality
        }
      },
      child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(
              controller,
            ),
          ),
        ),
        // Positioned(
        //     top: 0,
        //     left: 0,
        //     bottom: 0,
        //     right: 0,
        //     child: InkResponse(
        //       onTap: _playPause,
        //       child: CircleAvatar(
        //           backgroundColor: Colors.black26,
        //           child: controller.value.isPlaying
        //               ? const Icon(
        //                   Icons.pause,
        //                   color: Colors.white,
        //                 )
        //               : const Icon(
        //                   Icons.arrow_forward,
        //                   color: Colors.white,
        //                 )),
        //     )),
        
            Positioned(
            top: 16,
            right: 16,
            child: InkResponse(
              onTap: _toggleAudio,
              child: CircleAvatar(
              backgroundColor: Colors.black26,
              child: _audioEnabled
                  ? const Icon(
                      Icons.volume_up_outlined,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.volume_off_outlined,
                      color: Colors.white,
                    )),
            ))
      ],
    );
  }
}




class IconTextButton extends StatelessWidget {
  final VoidCallback onTap;
  final TextStyle? style;
  final double? width;
  final String text;
  final Color? color,splash;
  final Widget? leadIcon,trailIcon;
  final EdgeInsetsGeometry? padding;

  const IconTextButton({super.key,
  this.trailIcon,
  this.width,
  this.padding,
  this.splash,
  this.color,
  this.leadIcon,
  required this.onTap,
  this.text='Get Started',
  this.style});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        splashColor:splash ?? Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
        onTap:onTap,
        child: Ink(
          width: width,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 6,horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            border: Border.all(width: 1,color:Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              leadIcon ?? const SizedBox(),
              SizedBox(width: leadIcon != null ? 12 : 0),
              Text(text ,style: style ?? const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.w400
              )),
              SizedBox(width: trailIcon != null ? 12 : 0),
               trailIcon ?? const SizedBox(),
            ],
          )
        ),
      ),
    );
  }
}