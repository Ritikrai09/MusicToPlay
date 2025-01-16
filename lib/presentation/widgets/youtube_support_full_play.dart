import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:webviewtube/webviewtube.dart';

import 'package:blogit/model/blog.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';

import 'incite_video_player.dart';
import 'short_video_controller.dart';

class YoutubeSupportPlayScreen extends StatefulWidget {
  const YoutubeSupportPlayScreen({super.key,this.index,this.startAt, this.isWebViewPlayer=false,this.webviewtubeController, this.controller,this.isShortVideo=false, this.blog});
  final VideoPlayerController? controller;
  final WebviewtubeController? webviewtubeController;
  final Blog? blog;
  final int? index,startAt;
  final bool? isWebViewPlayer;
  final bool isShortVideo;

  @override
  State<YoutubeSupportPlayScreen> createState() => _YoutubeSupportPlayScreenState();
}

class _YoutubeSupportPlayScreenState extends State<YoutubeSupportPlayScreen> {
  @override
  Widget build(BuildContext context) {
     var orientation = MediaQuery.of(context).orientation == Orientation.landscape;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (val, c){
        if(val){
          return;
        }
         
          var orientation2 = MediaQuery.of(context).orientation == Orientation.landscape;
          
         if (widget.isWebViewPlayer == true) {

           if (orientation2 == true) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
             Navigator.pop(context);
           }
           
         } else {
          
          if (orientation2 == true) {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
           } else {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
              DeviceOrientation.portraitDown,
            ]);
             Navigator.pop(context);
           }
         }

      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar:  orientation == true ? null :AppBar(
          leading: const BackbUT(),
          leadingWidth: 60,
          backgroundColor: Colors.transparent,
          toolbarHeight: 50,
        ),
        body: Padding(
          padding:  EdgeInsets.only(bottom:orientation == true ? 0 : 100),
          child: Center(
            child: widget.isWebViewPlayer == true 
            ? 
              PlayAnyVideoPlayer(
                key: ValueKey(widget.blog!.id),
                model: widget.blog,
                startAt: widget.startAt,
                isCurrentlyOpened: true,
                // startAt: widget.webviewtubeController!.value.position.inSeconds,
                 onChangedOrientation: (value) {
                 if (value == true) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                  ]);
                } else {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                }
                setState(() {   });
              },
              )
             : ShortPlayAnyVideo(
              // controller: widget.controller,
              model: widget.blog,
              index: widget.index,
              isShortVideo: widget.isShortVideo,
              aspectRatio: widget.isShortVideo ? 9/16 : 16/9,
              onChangedOrientation: (value) {
                 if (value == true) {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.landscapeRight,
                    DeviceOrientation.landscapeLeft,
                  ]);
                } else {
                  SystemChrome.setPreferredOrientations([
                    DeviceOrientation.portraitUp,
                    DeviceOrientation.portraitDown,
                  ]);
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}