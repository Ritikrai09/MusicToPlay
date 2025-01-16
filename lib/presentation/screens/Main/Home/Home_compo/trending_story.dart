import 'dart:io';

import 'package:blogit/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/presentation/screens/Main/Article_details/article_details.dart';
import 'package:blogit/presentation/widgets/text.dart';
import 'package:blogit/Utils/app_util.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../../../../Utils/deep_link.dart';
import '../../../../../controller/app_provider.dart';
import '../../../../../model/blog.dart';

class TrendingStory extends StatefulWidget {
  const TrendingStory({
    super.key,
   // required this.provider,
    required this.blog,
    this.index=0 
  });

 // final AppProvider provider;
  final Blog blog;
  final int? index;

  @override
  State<TrendingStory> createState() => _TrendingStoryState();
}

class _TrendingStoryState extends State<TrendingStory> {

  @override
  Widget build(BuildContext context) {
   
    return Consumer<AppProvider>(
      builder: (context,provider,child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: GestureDetector(
                      onTap:() {
                        NavigationUtil.to(context,
                         ArticleDetails(blog:widget.blog,
                         index: widget.index as int,
                         type: BlogType.feed,
                         likes:likeVisible(widget.blog,provider) ?? "0",
                         )).then((value) {
                          setState(() { });
                         });
                      },
                      child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'TRENDING STORY IN LIFESTYLE',
                //   style: FontStyleUtilities.t3(context,
                //       fontColor: ColorUtil.themNeutral, fontWeight: FWT.semiBold),
                // ),
                // SizedBox(height: 23.h),
                GestureDetector(
                  onTap: () {
                      NavigationUtil.to(context,  ArticleDetails(
                         blog : widget.blog,
                         index : widget.index ?? 0,
                         type : BlogType.feed,
                         likes :likeVisible(widget.blog,provider) ?? "0",
                        )).then((value) {
                          setState(() { });
                         });
                    // NavigationUtil.to(context, StoryNews(blog:provider.featureBlogs[0]));
                  },
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 95.h,
                            width: 95.w,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xff949AA9),
                                image: widget.blog.images!.isEmpty ?
                                DecorationImage(image: FileImage(File(prefs!.getString('app_logo') ?? "")),fit: BoxFit.cover ) : 
                                DecorationImage(image: CachedNetworkImageProvider(widget.blog.images![0]),fit: BoxFit.cover)
                                ),
                          ),
                         widget.blog.videoUrl == '' ? const SizedBox() :   Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.8),
                              radius: 20.r,
                              child: const SvgIcon('asset/Icons/play_button.svg',color: Colors.black,),
                            ),
                           ),
                      )
                        ],
                      ),
                      SpaceUtils.ks16.width(),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                           widget.blog.title ?? '6 Habits of Super\nLearners',
                            style: FontStyleUtilities.h6(context,
                             fontWeight: FWT.extrabold),
                            maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          ),
                          SpaceUtils.ks4.height(),
                          Text(
                            customDate(widget.blog.scheduleDate as DateTime),
                            style: FontStyleUtilities.p2(context,
                                fontColor: ColorUtil.themNeutral,
                                fontWeight: FWT.semiBold),
                          )
                        ],
                      )),
                     
                    ],
                  ),
                ),
                SpaceUtils.ks4.height(),
                // Text(
                //   'Go to bed early and \nget up early.',
                //   style: FontStyleUtilities.h4(context, fontWeight: FWT.semiBold),
                // ),
                // SizedBox(
                //   height: 19.h,
                // ),
                // Container(
                //   height: 8.h,
                //   width: 32.w,
                //   decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(4.r),
                //       color: const Color(0xff8AB9A2)),
                // ),
                // SizedBox(
                //   height: 15.h,
                // ),
                Padding(
                  padding: EdgeInsets.only(right: 28.w),
                  child: Description(
                   model: widget.blog,
                   maxlines: 3,
                   bodyMaxLines: 4,
                    // style: FontStyleUtilities.t2(context,
                    //         fontWeight: FWT.semiBold,
                    //         fontColor: ColorUtil.themNeutral)
                    //     .copyWith(height: 1.5.sp),
                  ),
                ),
                SizedBox(
                  height: 8.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LikeIcon(
                      inActiveColor: Theme.of(context).primaryColor,
                      isCountVisible: true,
                      count: likeVisible(widget.blog,provider) ?? "0",
                      initialValue : provider.permanentlikesIds.contains(widget.blog.id) ,
                      onChanged: (value) {
                     // provider.addLikeData(blog.id!.toInt());
                      provider.setlike(blog: widget.blog);
                      provider.getAnalyticData();
                      setState(() {     });
                    }),
                       const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        NavigationUtil.to(context, ArticleDetails(
                          blog: widget.blog,isCommentScroll: true,
                           likes: likeVisible(widget.blog, provider) ?? "0",
                          ));
                      },
                      child:  Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconAndAction(
                            icon: 'asset/Icons/chat-icon.svg', action:allMessages.value.comment  ?? 'Comment'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                         createDynamicLink(widget.blog).then((value) async {
                            Share.share(value);
                          });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: IconAndAction(
                    icon: 'asset/Icons/share-icon.svg', action: allMessages.value.share 
                    ?? 'Share'),
                      ))
                  ],
                ),
                // SizedBox(
                //   height: 20.h,
                // ),
                // Button(
                //     tittle: 'Read Full Story',
                //     onTap: () {
                //       NavigationUtil.to(context,  ArticleDetails(blog:blog));
                //     }),
                Divider(
                  height: 48.h,
                  color: Theme.of(context).dividerColor,
                )
              ],
            ),
          ),
        );
      }
    );
  }
}

class IconAndAction extends StatelessWidget {
  const IconAndAction({
    super.key,
    required this.icon,
    required this.action,
  });
  final String icon, action;

  @override
  Widget build(BuildContext context) {
    return SvgIcon(icon,color:  Theme.of(context).primaryColor);
  }
}

class LikeIcon extends StatefulWidget {
  const LikeIcon({
    super.key,
    required this.onChanged,
    this.initialValue=false,
    this.count='0',
    this.inActiveColor,
    this.size,
    this.isCountVisible=false,
  });

  final ValueChanged<bool> onChanged;
  final bool initialValue,isCountVisible;
  final double? size;
  final Color? inActiveColor;
  final String count;

  @override
  State<LikeIcon> createState() => _LikeIconState();
}

class _LikeIconState extends State<LikeIcon> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimIcon(
          key: ValueKey(widget.initialValue),
            width: widget.size ?? 24,
            height: widget.size ?? 24,
            isChange: currentUser.value.id != null,
            initialValue: widget.initialValue,
            activeIcon: 'asset/Icons/heart.svg',
            deactivateColor: widget.inActiveColor ?? ( dark(context) ? Colors.white : null),
            deactivateIcon: 'asset/Icons/heart-icon.svg',
            onChanged: widget.onChanged
        ),
        if(widget.isCountVisible == true)
        SpaceUtils.ks8.width(),
        if(widget.isCountVisible == true)
        Text(
          widget.count.toString(),
          style: FontStyleUtilities.t1(context,
              fontWeight: FWT.semiBold, fontColor: ColorUtil.themNeutral),
        )
      ],
    );
  }
}
