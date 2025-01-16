import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../controller/user_controller.dart';
import 'bookmarks.dart';
import 'news/live_news.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({super.key,required this.image,this.images,this.isProfile=false,required this.index,this.title,});
  final String? image,title;
  final int index;
  final List? images;
  final bool isProfile;

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {

late PageController pageController;

@override
void initState(){
 
    pageController = PageController(initialPage: widget.index);
  
  super.initState();
}


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      child:Stack(
          children: [ Container(
       width: size(context).width, 
       height: size(context).height,
       alignment: Alignment.center,
        child:
             Stack(
          children: [
           Positioned.fill(
            child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                width: size(context).width,
                height: size(context).height,
                color: Colors.transparent,
              ),
            )),
           widget.images != null
          ? Positioned(child: SizedBox(
            width: size(context).width,
         //   height: 250.h,
            child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: pageController,
                      itemCount: widget.images!.length,
                      onPageChanged: (value) {
                      },
                      itemBuilder: (context, index) {
                        return Hero(
                        tag: widget.images![index],
                        child: Container(
                          decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(16)
                        ),
                        width: size(context).width,
                        child:  PhotoView(
                      enableRotation :false,
                      minScale : 0.3,
                      backgroundDecoration: BoxDecoration(
                        color:Theme.of(context).scaffoldBackgroundColor
                      ),
                      imageProvider :
                       !widget.images![index].toString().contains('http') 
                       ? CachedNetworkImageProvider("${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}")
                      : CachedNetworkImageProvider(widget.images![index],
                        // fit: BoxFit.cover,
                        //  errorWidget: (context, url, error) {
                        //    return const CircularProgressIndicator();
                        //  },
                        ),
                       )));
                      },
                    ),
          ))
           : 
            Positioned(
              child: !widget.image.toString().contains("http") ? 
              Image.file(File(widget.image ?? ""))
              : Hero(
                tag: '${widget.index}${widget.image}',
                child: widget.isProfile ? PhotoView(
                    enableRotation :false,
                    minScale : 0.3,
                    backgroundDecoration: BoxDecoration(
                      color:Theme.of(context).scaffoldBackgroundColor
                    ),
                    imageProvider: CachedNetworkImageProvider(widget.image!,
                  // fit: BoxFit.fitWidth,
                  // width: size(context).width,
                  // height: size(context).height/1.5,
                  errorListener: (p0) {
                    
                  }
                ) ) : PhotoView(
                    enableRotation :false,
                    minScale : 0.3,
                    backgroundDecoration: BoxDecoration(
                      color:Theme.of(context).scaffoldBackgroundColor
                    ),
                    imageProvider: !widget.image.toString().contains('http') 
                       ? CachedNetworkImageProvider("${allSettings.value.baseImageUrl}/${allSettings.value.appLogo}")
                      : CachedNetworkImageProvider(
                     widget.image!,
                  //  fit: BoxFit.cover
                  ),
                )
              ),
            ),
          //  Padding(
          //    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
          //    child: TitleWidget(title: title,size: 16),
          //  )
          ],
        ),
      ),
          Positioned(
          left: widget.isProfile==true ? 6 : 8,
          top: widget.isProfile==true ? 4 : 8,
          child: const SafeArea(
            child: BackbUT())
        ),
      ])
    );
  }
}