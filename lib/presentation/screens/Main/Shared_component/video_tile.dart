import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Article_details/article_details.dart';
import 'package:blogit/Utils/app_util.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../controller/app_provider.dart';
import '../../../../model/blog.dart';

class VideosCard extends StatelessWidget {
  const VideosCard({super.key,required this.blog});
  final Blog blog;
 
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context, listen: false);
    return GestureDetector(
      onTap: () {
        NavigationUtil.to(context, ArticleDetails(
          blog: blog,
          likes: likeVisible(blog, provider) ?? "0"
          ));
      },
      child: Container(
          height: 263.h,
          margin: EdgeInsets.only(right: 20.w),
          width: 155.w,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 155.h,
                  width: 155.w,
                  decoration: BoxDecoration(
                      color: const Color(0xffDED6F6),
                      borderRadius: BorderRadius.circular(12.r),
                    image : blog.images != null && blog.images!.isNotEmpty ?
                     DecorationImage(image: CachedNetworkImageProvider(blog.images![0]),
                    fit: BoxFit.cover) : null)
                ),
              blog.videoUrl =='' ? const SizedBox() : Positioned.fill(
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24.r,
                      child: const SvgIcon('asset/Icons/play_button.svg'),
                    ),
                  ),
                ),
              ],
            ),
            SpaceUtils.ks12.height(),
            //  Container(
            //       padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 10),
            //       decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(12),
            //         color: hexToRgb(blog.categoryColor)
            //       ),
            //         child: Text(blog.categoryName.toString(),
            //         style: const TextStyle(fontSize: 12,color:Colors.white,fontWeight: FontWeight.w500))
            //       ),
             // SpaceUtils.ks8.height(),
            Text(
              blog.title ?? 'A man stand alone watch the full Moon Night',
              style: FontStyleUtilities.t2(context, fontWeight: FWT.extrabold,fontColor: dark(context) ? Colors.white :Colors.black),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            // SizedBox(
            //   height: 12.h,
            // ),
            Spacer(),
            Expanded(
              child: Column(
                children: [
                
                  Text(
                    customDate(blog.scheduleDate as DateTime),
                    style: FontStyleUtilities.t4(context,
                        fontWeight: FWT.bold, fontColor: ColorUtil.themNeutral),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
