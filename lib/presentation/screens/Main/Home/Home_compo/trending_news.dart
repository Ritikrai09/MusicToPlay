import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/screens/Main/Article_details/article_details.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/presentation/widgets/anim_icon.dart';
import 'package:blogit/presentation/widgets/svg_icon.dart';
import 'package:blogit/Utils/custom_toast.dart';
import 'package:blogit/Utils/deep_link.dart';
import 'package:blogit/Utils/shimmer.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/model/blog.dart';
import '../../../../../controller/app_provider.dart';
import '../../../../../controller/user_controller.dart';


class TrendingNews extends StatefulWidget {
  const TrendingNews({
    super.key,
    required this.provider,
  });
  final AppProvider provider;

  @override
  State<TrendingNews> createState() => _TrendingNewsState();
}

class _TrendingNewsState extends State<TrendingNews> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SpaceUtils.ks20.height(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          child: Row(
            children: [
              Text(
                allMessages.value.popularNews ?? 'All News',
                style:
                    FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
              ),
              SizedBox(
                width: 9.w,
              ),
              // GestureDetector(
              //   onTap: () {
              //     blogListHolder2
              //         .setList(widget.provider.allNews ?? DataModel());
              //     setState(() {});
              //     NavigationUtil.to(
              //         context,
              //         ArticleList(
              //             blogs: widget.provider.allNewsBlogs,
              //             title: allMessages.value.popularNews ??
              //                 'All News'));
              //   },
              //   child: Container(
              //     height: 26,
              //     width: 69,
              //     decoration: BoxDecoration(
              //         color: Theme.of(context).primaryColor,
              //         borderRadius: BorderRadius.circular(16)),
              //     child: Center(
              //       child: Text(
              //         allMessages.value.seeAll ?? 'SEE ALL',
              //         style: FontStyleUtilities.t4(context,
              //             fontWeight: FWT.extrabold,
              //              fontColor: dark(context) && isBlack(Theme.of(context).primaryColor)
              //              ? Colors.white :  dark(context) && isWhiteRange(Theme.of(context).primaryColor) ?
              //              Colors.black : Colors.white),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        SpaceUtils.ks24.height(),
        if(widget.provider.allNewsBlogs.isNotEmpty)
        NewsHomeWidget(blog: widget.provider.allNewsBlogs[0], index: 0),
        // SizedBox(height: 10.h),
        if (widget.provider.allNewsBlogs.isNotEmpty)
          ...widget.provider.allNewsBlogs.asMap().entries.map((e) =>
              e.key == 0
                  ? const SizedBox()
                  : NewsHomeWidget(key: ValueKey(e.value.id), blog: e.value, index: e.key))
        else
          const ShimmerLoader(
            isScroll: false,
          ),
        //  NewsTile(key: const ValueKey(0), blog:provider.allNewsBlogs[1]),
        //  NewsTile(key: const ValueKey(1), blog:provider.allNewsBlogs[2]),
        //  NewsTile(key: const ValueKey(2), blog:provider.allNewsBlogs[3],
        //   toShowDivider: false,
        // ),
        SizedBox(height: 20.h),
      ],
    );
  }
}

class NewsHomeWidget extends StatefulWidget {
  const NewsHomeWidget({
    super.key,
    required this.blog,
    this.index=0,
  });

  final Blog blog;
  final int index;

  @override
  State<NewsHomeWidget> createState() => _NewsHomeWidgetState();
}

class _NewsHomeWidgetState extends State<NewsHomeWidget> {

  String likeCount = '0';
  
  @override
  void initState() {
   
    WidgetsBinding.instance.addPostFrameCallback((e)async {
     
      var provider = Provider.of<AppProvider>(context, listen: false);
      likeCount = likeVisible(widget.blog, provider) ?? '0';
      setState(() {   });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context, listen: false);
    var numberOfLines =  _calculateNumberOfLines(widget.blog.title ?? "");
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,MaterialPageRoute(builder: (ctx)=>
            ArticleDetails(
                index: widget.index,
                type: BlogType.allnews,
                likes: likeVisible(widget.blog, provider) ?? '0',
                blog: widget.blog))).then((v)async{
                 likeCount = likeVisible(widget.blog, provider) ?? "0";
                 setState(() {    });
             });
      },
      child: Container(
        padding: EdgeInsets.only(
            left: provider.allNewsBlogs.isEmpty ? 0 : 18.w,
            right: provider.allNewsBlogs.isEmpty ? 0 : 18.w,
            //bottom: 8.h,
            top: 8.h
        ),
        margin:  EdgeInsets.only(bottom : 12.h),
        // decoration: BoxDecoration(
        //   border: Border(bottom: BorderSide(width: 1,color:Theme.of(context).dividerColor))
        // ),
        height:numberOfLines == 2 ? 300.h : 265.h,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            provider.allNewsBlogs.isNotEmpty
                ? Expanded(
                  flex:numberOfLines == 2 ? 4 :7,
                  child: Stack(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width,
                          foregroundDecoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.8),
                                  ]),
                              borderRadius: BorderRadius.circular(16)),
                          decoration: provider.allNewsBlogs.isEmpty
                              ? null
                              : BoxDecoration(
                                  image: widget.blog.images != null &&
                                          widget.blog.images!.isNotEmpty
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              widget.blog.images![0]),
                                          fit: BoxFit.cover)
                                      : null,
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(16)),
                        ),
                   Positioned(
                  right: 12,
                  top: 12,
                  child: BlurWidget(
                    radius: 12,
                    height: 25,
                    width: 55,
                    padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                    child: Container(
                      // height: 33.h,
                      // width: 68.w,
                    //  padding:const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.5.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimIcon(
                              initialValue: true,
                              // color: ColorUtil.themNeutral,
                              height: 12.h,
                              isChange: currentUser.value.id != null,
                              width: 12.h,
                              activeColor: Colors.white,
                              deactivateColor:Colors.white,
                              activeIcon: 'asset/Icons/heart-icon.svg',
                              deactivateIcon: 'asset/Icons/heart-icon.svg',
                              onChanged: (value) {

                              }),
                          const Spacer(),
                          Text(
                            key: ValueKey(likeVisible(widget.blog, provider)),
                            likeVisible(widget.blog, provider) ?? "0",
                            style: FontStyleUtilities.t2(context,
                                fontColor: Colors.white),
                          )
                        ],
                      ),
                    ),
                  )),
                  if(widget.blog.videoUrl.toString().contains('http') || widget.blog.videoFile.toString().contains('http'))
                   Align(
                    alignment: Alignment.center,
                  child: BlurWidget(
                    radius: 100,
                    height: 56,
                    width: 56,
                    blur: 5,
                    padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 10),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: SvgIcon( 'asset/Icons/play_button.svg',color: Colors.grey.shade400),
                      )
                    ),
                  )),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkResponse(
                          onTap: () async{
                            createDynamicLink(widget.blog).then((value) async {
                              Share.share("${allMessages.value.shareMessage}\n$value");
                              provider.addShareData(null,widget.blog.id as int);
                            });
                          },
                          radius: 18,
                          child: const BlurWidget(
                              width: 32,
                              height: 32,
                              padding: EdgeInsets.all(8),
                              child:SvgIcon('asset/Icons/share.svg',
                                color: Colors.white
                                ),
                          ),),
                          SizedBox(width: 12.w),
                          InkResponse(
                            onTap: currentUser.value.id == null
                                ? () {
                                    NavigationUtil.to(
                                        context, const Login());
                                  }
                                : () {
                                    if (provider.permanentIds
                                        .contains(widget.blog.id)) {
                                      showCustomToast(
                                          context,
                                          allMessages
                                                  .value.bookmarkRemove ??
                                              'Bookmark removed');
                                                        
                                      provider.removeBookmarkData(
                                          widget.blog.id!.toInt());
                                    } else {
                                      showCustomToast(
                                          context,
                                          allMessages
                                                  .value.bookmarkSave ??
                                              'Bookmark saved');
                                      provider.addBookmarkData(
                                          widget.blog.id!.toInt());
                                    }
                                    provider.setBookmark(
                                        blog: widget.blog);
                                    setState(() {});
                                  },
                            child: BlurWidget(
                              width: 32,
                              height: 32,
                              padding: const EdgeInsets.all(8),
                              child: !provider.permanentIds
                                      .contains(widget.blog.id)
                                  ? SvgIcon('asset/Icons/book_mark.svg',
                                      key:ValueKey('book${widget.blog.id}'),
                                      color: Colors.white)
                                  : SvgIcon(
                                      'asset/Icons/bookmark-fill.svg',
                                      key: ValueKey('bookfill${widget.blog.id}'),
                                      color: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      ))
                    ],
                  ),
                )
                : ShimmerLoader(
                    width: size(context).width,
                    height: 200,
                    count: 1,
                  ),
            provider.allNewsBlogs.isEmpty
                ? ShimmerLoader(
                    width: size(context).width,
                    height: 200,
                    count: 1,
                    isScroll: false,
                  )
                : Expanded(
                  child: Padding(
                  padding: const EdgeInsets.only(left:4.0, right:4.0, top:12.0),
                  child:  Text(
                      widget.blog.title ?? "",
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      style: FontStyleUtilities.h4(context,
                          fontWeight: FWT.extrabold,
                        ).copyWith(fontSize: 15.sp),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  int _calculateNumberOfLines(String str) {

    String text = str;

    final TextSpan textSpan = TextSpan(
      text: text,
      style: TextStyle(fontSize: 15.sp),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: MediaQuery.of(context).size.width-36.w,
    );

    return textPainter.computeLineMetrics().length;
    
  }
  
}
