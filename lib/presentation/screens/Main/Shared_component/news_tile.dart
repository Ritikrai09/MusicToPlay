import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/presentation/screens/Main/Article_details/article_details.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/Utils/deep_link.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../../../Utils/custom_toast.dart';
import '../../../../controller/app_provider.dart';
import '../../../../model/blog.dart';
import '../../../widgets/svg_icon.dart';

class NewsTile extends StatefulWidget {
  const NewsTile({
    super.key,
    required this.blog,
    this.bookmarkPage=false,
    this.onChanged,
    this.border,
    this.height,
    this.padding,
    this.toShowDivider = true,
  });
  final bool? toShowDivider;
  final bool bookmarkPage;
  final BoxBorder? border;
  final Blog blog;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final ValueChanged? onChanged;

  @override
  State<NewsTile> createState() => _NewsTileState();
}

class _NewsTileState extends State<NewsTile> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen:false);
    return InkWell(
      onTap: () {
       if (widget.blog.type == 'quote') {
          NavigationUtil.to(context, StoryPage(blog: widget.blog, ));
       } else {
          NavigationUtil.to(context, ArticleDetails(
             likes:likeVisible(widget.blog, provider) ?? '0',
            blog: widget.blog));
       }
      },
      child: Container(
        padding: widget.padding ??  EdgeInsets.symmetric(horizontal: 28.w),
        height: widget.height ?? 100.h,
        child: Stack(
          children: [
            Hero(
              tag: widget.blog.images != null && widget.blog.images!.isNotEmpty 
               ? 'Blog${widget.blog.id}${widget.blog.images![0]}'
               : 'Blog${widget.blog.id}Image',
              child: Container(
                  padding: widget.padding ?? EdgeInsets.symmetric(vertical: 12.h),
                decoration:BoxDecoration(
                  borderRadius: widget.border != null ? BorderRadius.circular(12) : null,
                  border: widget.toShowDivider == true ? Border(
                    bottom: BorderSide(width: 1,color: Theme.of(context).dividerColor))  :
                    widget.border
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 80.h,
                          width: 80.h,
                          decoration: BoxDecoration(
                            image:  widget.blog.images != null &&  widget.blog.images!.isNotEmpty ? DecorationImage(image:
                             CachedNetworkImageProvider( 
                            widget.blog.type == 'quote' ? 
                            widget.blog.backgroundImage.toString() :
                             widget.blog.images!.isEmpty ? '' : 
                            widget.blog.images![0]) ,fit: BoxFit.cover) :
                            const DecorationImage(image: AssetImage("asset/Images/Logo/Signal.png")),
                              borderRadius: BorderRadius.circular(12),
                              ),
                        ),
                       widget.blog.videoUrl == '' ? const SizedBox() :  Positioned.fill(
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
                    SizedBox(
                      width: 16.w,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //  widget.blog.categoryName ?? 'LIFESTYLE',
                        //   style: FontStyleUtilities.t2(context,
                        //       fontWeight: FWT.medium, fontColor: ColorUtil.themNeutral),
                        // ),
                        // SpaceUtils.ks4.height(),
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.blog.title ?? 'Fabulous the shadow of\nthe little Prince Story',
                            style: FontStyleUtilities.t2(context, fontWeight: FWT.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                     //   SizedBox(height: 12.h),
                       const Spacer(),
                        Expanded(
                          child: Row(
                            children: [
                             Text(
                              "${widget.blog.scheduleDate!.day} ${getMonth(widget.blog.scheduleDate!.month)} ${widget.blog.scheduleDate!.year}",
                              style: FontStyleUtilities.t4(context,
                                  fontColor: dark(context) ? Colors.white70: ColorUtil.themNeutral,
                                  fontWeight: FWT.semiBold),
                            ),
                            const Spacer(),
                              Row(
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
                                  child: SvgIcon('asset/Icons/share.svg',
                                  color:dark(context) ? Colors.white 
                                    :Colors.black
                                  )),
                                   SizedBox(width: 24.w),
                                   InkResponse(
                                onTap : currentUser.value.id == null ? () {
                                  NavigationUtil.to(context, const Login());
                                } : () {
                                 if (provider.permanentIds.contains(widget.blog.id)) {
                                    showCustomToast(context,allMessages.value.bookmarkRemove ?? 'Bookmark removed');
                                    
                                    provider.removeBookmarkData(widget.blog.id!.toInt());
                                   if (widget.bookmarkPage==true) {
                                      widget.onChanged!(false);
                                   }
                                   
                                 } else {
                                    showCustomToast(context,allMessages.value.bookmarkSave ??'Bookmark saved');
                                    provider.addBookmarkData(widget.blog.id!.toInt());
                                 }
                                 provider.setBookmark(blog: widget.blog);
                                 setState((){});
                                },
                                child: !provider.permanentIds.contains(widget.blog.id)
                                ?  SvgIcon('asset/Icons/book_mark.svg',
                                 key: ValueKey('book${widget.blog.id}'),
                                width: 24,height: 24,color:Theme.of(context).colorScheme.primary)
                                 : SvgIcon('asset/Icons/bookmark-fill.svg',
                                   key:  ValueKey('bookfill${widget.blog.id}'),
                                   color: Theme.of(context).primaryColor, 
                                  ),
                                )
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        //  SpaceUtils.ks20.height(),
                        
                      ],
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
