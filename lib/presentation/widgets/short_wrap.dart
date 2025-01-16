import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_preload_videos/provider/preload_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/presentation/screens/Main/Home/Home_compo/trending_story.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/widgets/svg_icon.dart';
import 'package:blogit/Utils/deep_link.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/blog.dart';

class ShortsWrap extends StatefulWidget {
  const ShortsWrap({ super.key,required this.child,required this.onMute ,required this.blog,
  required this.onShare,required this.onLike, this.index=0});
  final Widget child;
  final Blog blog;
  final int index;
  final VoidCallback? onLike,onShare, onMute;

  @override
  State<ShortsWrap> createState() => _ShortsWrapState();
}

class _ShortsWrapState extends State<ShortsWrap> {
  bool isExpand=false;


  @override
  Widget build(BuildContext context) {
   var provider = Provider.of<AppProvider>(context,listen: false);
  //  var preload = Provider.of<PreloadProvider>(context,listen: false);
  //  var i = widget.blog.likeCount!.toInt()+1;
  //  var data = provider.permanentLikeIds.contains(widget.blog.id) ?
  //    formatNumber(i) : formatNumber(widget.blog.likeCount!.toInt());
    return Consumer<PreloadProvider>(
      builder: (context, preload, child) {
        log(preload.urls.toString());
        return Stack(
          fit: StackFit.expand,
                     children: [
                     widget.child,
                        Positioned(
                            bottom: 30,
                            right: 0,
                            left: 0,
                            child: Container(
                            width: size(context).width,
                              decoration: const BoxDecoration(
                              gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                                colors: [
                                Colors.transparent,
                                Colors.black54
                              ])
                            ),
                            padding: const EdgeInsets.only(left: 15,right: 0,bottom:65),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    isExpand = !isExpand;
                                    setState(() {   });
                                  },
                                  child: SizedBox(
                                    width: size(context).width/1.33,
                                    child: RichText(
                                      maxLines: isExpand  == true ? 12 : 3,
                                      overflow: TextOverflow.ellipsis,
                                      text: TextSpan(
                                        children: [
                                        TextSpan(text: isExpand  == false && widget.blog.title!.length > 99
                                         ? widget.blog.title.toString().substring(0,100) : widget.blog.title.toString(), 
                                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                           fontSize: 17,
                                           color: Colors.white,
                                        ),
                                        ),
                                        if(widget.blog.title!.length > 89)
                                       TextSpan( text:isExpand  == true ? "...see less" :'...see more',
                                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                          fontSize: 17,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600
                                       )
                                       )
                                      ],
                                      )
                                    )),
                                ),
                                if(preload.controllers[widget.index] != null)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                       InkResponse(
                                        key: ValueKey(preload.controllers[widget.index]!.value.isPlaying),
                                        onTap: () {
                                          if (preload.controllers[widget.index]!.value.isPlaying == true) {
                                            preload.pauseVideoAtIndex(widget.index);
                                          } else {
                                             preload.playVideoAtIndex(widget.index);
                                          }
                                          setState(() { });
                                        },
                                         child: BlurWidget(
                                          width:  42,
                                          height: 42,
                                          padding:  EdgeInsets.all(preload.controllers[widget.index]!.value.isPlaying == true ? 10 : 13),
                                          child: SvgIcon(preload.controllers[widget.index]!.value.isPlaying == false
                                            ? 'asset/Icons/play_button.svg'
                                            : 'asset/Icons/pause.svg',
                                            color: Colors.white,
                                            width: 20,
                                           ),
                                         ),
                                       ),
                                        const SizedBox(height: 16),
                                       InkResponse(
                                        onTap: () {
                                          preload.setMute = widget.index;
                                          //  setState(() { });
                                        },
                                         child: BlurWidget(
                                          width: 42,
                                          height: 42,
                                          padding: const EdgeInsets.all(10),
                                          child:Icon(preload.isMute == true
                                            ? Icons.volume_off_rounded
                                            : Icons.volume_up_rounded,
                                            color: Colors.white,
                                            size: 20,
                                           ),
                                         ),
                                       ),
                                        const SizedBox(height: 16),
                                        InkResponse(
                                      onTap: () async{
                                        createDynamicLink(widget.blog).then((value) async {
                                          Share.share("${allMessages.value.shareMessage}\n$value");
                                          provider.addShareData(null,widget.blog.id as int);
                                        });
                                      },
                                      radius: 28,
                                      child: const BlurWidget(
                                          width: 42,
                                          height: 42,
                                          padding: EdgeInsets.all(10),
                                          child:SvgIcon('asset/Icons/share.svg',
                                            color: Colors.white
                                          ),
                                       )),
                                       const SizedBox(height: 16),
                                        BlurWidget(
                                          width: 42,
                                          height: 42,
                                          padding: const EdgeInsets.all(10),
                                          child: LikeIcon(
                                            initialValue : provider.permanentlikesIds.contains(widget.blog.id) ,
                                            isCountVisible: false,
                                            size: 20,
                                            inActiveColor: Colors.white,
                                            onChanged: (value) {
                                          // provider.addLikeData(blog.id!.toInt());
                                            provider.setlike(blog: widget.blog);
                                            provider.getAnalyticData();
                                             setState(() {     });
                                          }),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(likeVisible(widget.blog, provider) ?? "0",
                                         key: const ValueKey(1),
                                         style: Theme.of(context).textTheme.labelMedium!.copyWith(
                                           color: Colors.white,
                                         )),
                                   
                                    
                                  ]),
                                ),
                              ],
                            ),
                          )
                        )
                      ],
                    );
      }
    );
  }
}