
import 'dart:io';

import 'package:blogit/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/blog.dart';
import 'package:blogit/presentation/screens/Main/story.dart';
import 'package:blogit/presentation/screens/news/e_news.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_grid_view.dart';
import 'package:staggered_grid_view_flutter/widgets/staggered_tile.dart';

import '../../../../presentation/screens/Main/Article_list/article_list.dart';
import '../../../screens/news/live_news.dart';



class Categories extends StatefulWidget {
  const Categories({super.key,this.title='Categories',this.isQuote=false,});
  final String title;
  final bool isQuote;

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen:false);   
    var len= allSettings.value.ePaperStatus != '0' &&  allSettings.value.liveNewsLogo  != '0' 
                        ?  provider.blog!.categories!.length+2 : allSettings.value.ePaperStatus != '0' || allSettings.value.liveNewsLogo != '0' 
                        ?  provider.blog!.categories!.length +1 : provider.blog!.categories!.length;
  
    return Builder(builder: (context) {
      return Scaffold(
        body: SafeArea(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return false;
            },
            child: CustomScrollView(
              slivers: [
                const TheSearchArea(),
                SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w,vertical: 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                           widget.title,
                            style: FontStyleUtilities.h3(context,
                                fontWeight: FWT.extrabold),
                          ),
                        ],
                      ),
                    )),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  sliver: widget.isQuote ? SliverToBoxAdapter(
                    child: StaggeredGridView.countBuilder(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 16.h,
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        itemBuilder: (context, int index) {
                           Blog category = provider.quotes[index];
                          return CategoryTab(
                          isNews: true,
                          width: 120.w,
                          height: 160.h,
                          image: category.backgroundImage,
                          name: category.title,
                          onTap: () {
                            NavigationUtil.to(context, StoryPage(index: index));
                          },
                          padding: EdgeInsets.zero
                          );
                        },
                        itemCount: provider.quotes.length,
                        staggeredTileBuilder: (int index) =>
                            const StaggeredTile.fit(1)),
                  ) :   SliverToBoxAdapter(
                    child:GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        // crossAxisSpacing: 0.w,
                        // mainAxisSpacing: 24.h,
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 4/5.5
                          ),
                        //crossAxisCount: 3,
                        itemBuilder: (context, int index) {
                            return  allSettings.value.ePaperStatus != '0' && index == len-2  ?
                             Padding(
                               padding: const EdgeInsets.symmetric(horizontal:8.0),
                               child: CategoryCircleTab(
                                key: ValueKey(index),
                                isNews: true,
                                title: allMessages.value.eNews,
                                onTap: (){
                                    NavigationUtil.to(context, const EnewsPage());
                               },
                               image: "${allSettings.value.baseImageUrl}/${allSettings.value.ePaperLogo}",
                              ),
                             ) : allSettings.value.liveNewsStatus != '0' && index == len-1  ?  
                              Padding(
                               padding: const EdgeInsets.symmetric(horizontal:8.0),
                               child: CategoryCircleTab(
                              key: ValueKey(index),
                               isNews: true,
                                onTap: (){
                                  NavigationUtil.to(context, const LiveNewsPage());
                             },
                                title: allMessages.value.liveNews,
                                image:"${allSettings.value.baseImageUrl}/${allSettings.value.liveNewsLogo}",
                            
                            )) : allSettings.value.liveNewsStatus == '0' && index >= len-1 ? const SizedBox() 
                            : Padding(
                                 padding: const EdgeInsets.symmetric(horizontal:8.0),
                               child:  CategoryCircleTab(
                              key: ValueKey(index),
                              category: provider.blog!.categories![index],
                            ));
                        },
                        itemCount: len,
                        ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100.h,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}

class CategoryCircleTab extends StatefulWidget {
  const CategoryCircleTab({super.key,
   this.category,
   this.onTap,
   this.isNews=false,
   this.image,
   this.title,
   this.textColor,
  });
  final Category? category;
  final VoidCallback? onTap;
  final bool isNews;
  final String? title,image;
  final Color? textColor;

  @override
  State<CategoryCircleTab> createState() => _CategoryCircleTabState();
}

class _CategoryCircleTabState extends State<CategoryCircleTab> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkResponse(
    onTap: widget.onTap?? () {
      blogListHolder2.setList(widget.category!.data as DataModel);
       blogListHolder2.setBlogType(BlogType.category);
      setState(() {   });
      NavigationUtil.to(context, ArticleList(category: widget.category,isCategory: true));
    },
    child: CircleAvatar(
            radius: 36,
            backgroundImage: ((widget.category != null && widget.category!.image != null) || widget.isNews == true)
            ? CachedNetworkImageProvider(widget.isNews == true ?
              widget.image ?? "" :
              widget.category!.image ?? '' )
              : FileImage(File(prefs!.getString('app_logo') ?? "")
            ),
            ),
        ),
         const SizedBox(height: 6),
         InkWell(
      onTap: widget.onTap?? () {
        blogListHolder2.setList(widget.category!.data as DataModel);
        setState(() {   });
        NavigationUtil.to(context, ArticleList(category: widget.category,isCategory: true));
      },
      child:Text(widget.isNews == true ?   widget.title ?? ""
      : widget.category!.name ?? '',
           maxLines: 2,
           textAlign: TextAlign.center,
           style: FontStyleUtilities.t1(context,
            fontWeight: FWT.extrabold,
                   ).copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color : widget.textColor
                ),
           overflow: TextOverflow.ellipsis,
                   ),
         )
      ],
    );
  }
}


class CategoryTab extends StatefulWidget {
  const CategoryTab({super.key,
  this.onTap,
  this.height,
  this.width,
   this.isNews=false,
   this.isCategory=false,
   this.category,
   this.padding,
   this.subtitle,
   this.image,this.name});

  final Category? category;
  final bool isNews;
  final bool isCategory;
  final VoidCallback? onTap;
  final double? height,width;
  final String? subtitle,name,image; 
  final EdgeInsetsGeometry? padding;

  @override
  State<CategoryTab> createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
        onTap: widget.onTap ??() {
          blogListHolder2.setList(widget.category!.data as DataModel);
          setState(() {   });
          NavigationUtil.to(context, ArticleList(category: widget.category,isCategory: true));
        },
        child: Container(
            height: widget.height ?? 70.h,
            width: widget.width ??  70.h,
            // padding: padding?? EdgeInsets.symmetric(
            //     vertical: 10.h, horizontal: 14.w),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.isCategory ? 100 :100),
              border: Border.all(width: 0.5,
              color: dark(context) ? Colors.grey.shade700 : Colors.grey.shade200),
               
                color: Colors.transparent),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isCategory ? 100 :100),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      color: Colors.grey.shade200.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: -3
                    )
                  ]
                ),
                // foregroundDecoration: BoxDecoration(
                //   gradient: LinearGradient(
                //     begin: Alignment.topCenter,
                //     end: Alignment.bottomCenter,
                //     stops: const [
                //       0.5,
                //       1.0
                //     ],
                //     colors: [
                //     Colors.black.withOpacity(0.5),
                //     Colors.black.withOpacity(0.8)
                //   ])
                // ),
                child: CachedNetworkImage(imageUrl : widget.image ?? widget.category!.image.toString(),
                fit: BoxFit.cover))),
          ),
    );
  }
}