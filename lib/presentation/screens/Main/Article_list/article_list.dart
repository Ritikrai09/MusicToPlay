
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';

import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../../../Utils/app_theme.dart';
import '../../../../model/blog.dart';
import '../Shared_component/news_tile.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key,this.isAllNews=false, this.category,this.isCategory=false,this.title,this.blogs});
  final Category? category;
  final bool isCategory,isAllNews;
  final String? title;
  final List<Blog>? blogs;

  @override
  // ignore: library_private_types_in_public_api
  _ArticleListState createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
 int isLoad = 0;
  
  var scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
   var provider = Provider.of<AppProvider>(context,listen: false);
    return  Scaffold(
        body: SafeArea(
          child:  NotificationListener<ScrollNotification>(
              onNotification:
                  (ScrollNotification scrollInfo) {
               if ( scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              if (blogListHolder2.getList().nextPageUrl != null && blogListHolder2.blogType == BlogType.category) {
                    if(isLoad== 0){
                        isLoad= 1;
                        setState(() { }); 
                        provider.allNewsList(url: blogListHolder2.getList().nextPageUrl.toString(),
                        categoryId: widget.category!.id,type: BlogType.category).whenComplete(() {
                          isLoad= 2;
                          isLoad = 0;
                          setState(() { });
                        }).onError((e, stack){
                          isLoad = 0;
                          setState(() { });
                        });
                        }
                      } else {
                        if (blogListHolder2.getList().nextPageUrl != null && blogListHolder2.blogType == BlogType.allnews) {
                          if(isLoad== 0){
                          isLoad= 1;
                          setState(() { }); 
                          provider.allNewsList(
                            type: BlogType.allnews,
                            url: blogListHolder2.getList().nextPageUrl.toString()).whenComplete(() {
                            isLoad= 2;
                            isLoad = 0;
                          setState(() { });
                          });
                          }
                        }
                      }
                  
              }
                return false;
              },
              child: CustomScrollView(
                controller:scrollController,
              slivers: [
                SliverAppBar(
                    automaticallyImplyLeading: false,
                    // elevation: 0,
                    pinned: true,
                    surfaceTintColor :Colors.white,
                    backgroundColor:
                        Theme.of(context).scaffoldBackgroundColor,
                    collapsedHeight: 66.h,
                    scrolledUnderElevation: 1,
                    expandedHeight: 66.h,
                    flexibleSpace: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            const BackbUT(),
                              Text(
                               widget.isCategory==false ? widget.title.toString() :  widget.category!.name ?? 'Travel',
                                style: FontStyleUtilities.h5(context,
                                        fontWeight: FWT.extrabold)
                                    .copyWith(fontSize: 20),
                              ),
                               ThemeButton(
                                onChanged: (value) {
                                    toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
                                    setState(() {    });
                                },
                              )
                            ],
                          ),
                        ),
                      ],
                    )),
                // MyStickyHeader(
                //     expandedHeight: 60.h,
                //     pinned: true,
                //     height: 56.h,
                //     child: ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 14.h,
                  ),
                ),
                if(blogListHolder2.getList().blogs.isNotEmpty)
                SliverList(
                  key: ValueKey(blogListHolder2.getList().blogs.length),
                    delegate: SliverChildBuilderDelegate(
                        (context, int index) {
                        if (blogListHolder2.getList().blogs[index].type == "quote") {
                          return const SizedBox();
                        } else {
                          return NewsTile(
                          key: ValueKey(index),
                          blog: blogListHolder2.getList().blogs[index] ,
                              toShowDivider: index == blogListHolder2.getList().blogs.length-1 ? false : true,
                          );
                        }
                    },
                  childCount:blogListHolder2.getList().blogs.length))
                else
                    SliverToBoxAdapter(
                      child: NotFoundWidget(
                        text:  allMessages.value.noMorePosts ?? "No Post Found",
                      ),
                    ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        // if(blogListHolder2.getList().nextPageUrl  != null && isLoading==false )
                        // SignalOutlinedButton(
                        //     tittle: allMessages.value.loadMore ?? 'Load more', 
                        //     onTap: blogListHolder2.getList().nextPageUrl == null ?
                        //     (){

                        //     } : () {
                           
                              
                        //     })
                        if(isLoad==1 && blogListHolder2.getList().nextPageUrl != null )
                        const Center(child: CircularProgressIndicator())
                        else 
                        const SizedBox(),
                        // SizedBox(
                        //   height: 30.h,
                        // ),
                       const Divider()
                      ],
                    ),
                  ),
                 ),
                  if(blogListHolder2.getList().nextPageUrl == null && blogListHolder2.getList().blogs.length > 6)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                 Text( allMessages.value.noMorePosts ?? 'No more posts to display'),
                                const SizedBox(width: 12),
                                TextButton(onPressed: () {
                                  scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                                }, child:  Row(
                                  children: [
                                    Text(allMessages.value.scrollToTop ??'Back to Top'),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.arrow_upward_rounded)
                                  ],
                                ))
                              ],
                            ),
                          ),
                         ),
              ],
            ),
          ),
        ),
      );
  }
}

class NotFoundWidget extends StatelessWidget {
  const NotFoundWidget({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size(context).height/1.36,
      padding:const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline_rounded,size: 40),
          const SizedBox(height:12),
          Text(text ?? "Not Found",
          textAlign: TextAlign.center,
          style:const TextStyle(
            fontSize: 16,
            fontFamily: 'QuickSand',
            fontWeight: FontWeight.w600,
            
          ))
      ]),
    );
  }
}
