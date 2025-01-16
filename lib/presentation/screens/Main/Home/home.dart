import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Shared_component/news_tile.dart';
import 'package:blogit/presentation/screens/news/live_news.dart';
import 'package:blogit/Utils/app_theme.dart';
import 'package:blogit/Utils/shimmer.dart';
///
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/blog.dart';

import '../../../../controller/app_provider.dart';
import 'Home_compo/carousel.dart';
import 'Home_compo/home_categories.dart';
import 'Home_compo/trending_news.dart';


class Home extends StatefulWidget {
  const Home({super.key,required this.onChanged, this.initial=false});
  final ValueChanged onChanged;
  final bool initial;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {

 // late List<Widget> tabs;

  late AppProvider provider;

  UserProvider user=UserProvider();
  
  int isLoad=0;
  late ScrollController scrollController;
  late TabController tabController;
  int currIndex=0;

  GlobalKey<RefreshIndicatorState> refresh = GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    scrollController = ScrollController();
    provider = Provider.of<AppProvider>(context,listen:false);
    
    user.getAllAvialbleLanguages(context);
    tabController = TabController(
      length:provider.blog != null ? provider.blog!.categories!.length+1 : 6,
      vsync: this,
    )..addListener(() {
      if (tabController.indexIsChanging) {
        currIndex = tabController.index;
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     if (widget.initial) {
        refresh.currentState!.show();
     }
    });
    //tabs =
    super.initState();
  }

  GlobalKey<ScaffoldState> scf = GlobalKey();

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        key: scf, 
        // drawer: const Drawer(
        //   child: SettingNew(),
        // ),
        onDrawerChanged: (isOpened) {
          widget.onChanged(!isOpened);
          setState(() {});
        },
        body: SafeArea(
          child: NotificationListener<ScrollNotification>(
              onNotification:
                  (ScrollNotification scrollInfo) {
               if ( blogListHolder.getList().nextPageUrl != null &&
                    scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent-80) {
                    
                  
                  if(currIndex!=0 && isLoad== 0){
                    isLoad= 1;  
                    setState(() { }); 
                      provider.allNewsList(url: blogListHolder.getList().nextPageUrl.toString(),
                      categoryId: provider.blog!.categories![currIndex-1].id,type: BlogType.category).whenComplete(() {
                        isLoad= 2;
                        isLoad = 0;
                        setState(() { });
                     });
                  } else {
                        if(isLoad== 0 && provider.allNews != null  && provider.allNews!.nextPageUrl != null){
                            isLoad= 1;
                            setState(() { }); 
                            provider.allNewsList(
                            type: BlogType.allnews,
                            url: provider.allNews!.nextPageUrl.toString()).whenComplete(() {
                            isLoad= 2;
                            isLoad = 0;
                            setState(() { });
                        });
                    }
                  }
              }
                return false;
              },
              child: RefreshIndicator(
                key: refresh,
                onRefresh: () async{
               await Future.delayed(const Duration(milliseconds:3000));
                  setState(() { 
                  provider.getVisibility();
                  user.checkSettingUpdate();
                 //  user.getLanguageFromServer(context);
                 provider.getAnalyticData().whenComplete(() {
                    provider.getCategory(allowUpdate: true);
                 });
              });
                
              },
              child: CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ScrollPhysics()
                ),
                slivers: [
                  const TheSearchArea(
                    elevation:0,
                  ),
                  // MyStickyHeader(
                  //     expandedHeight: 52.h,
                  //     elevation: 0,
                  //     pinned: true,
                  //     height: 52.h,
                  //     child: SizedBox(
                  //       child: Column(
                  //         children: [
                  //           Padding(
                  //             padding: EdgeInsets.only(left: 22.w,right:22.w,top: 0.h),
                  //             child: Row(
                  //               children: [
                  //                 // InkResponse(
                  //                 //     onTap: () {
                  //                 //       scf.currentState!.openDrawer();
                  //                 //     },
                  //                 //     child:
                  //                 const TheLogo(),
                  //                 SizedBox(
                  //                   width: 15.5.w,
                  //                 ),
                  //                 Expanded(
                  //                     child: GestureDetector(
                  //                   onTap: () {
                  //                    Navigator.push(context, PagingTransform(
                  //                     slideUp: true,
                  //                          widget: const SearchPage()));
                  //                   },
                  //                   child: SizedBox(
                  //                     child: AbsorbPointer(
                  //                       child: Hero(
                  //                           tag: 'SEARCH234',
                  //                           child: Material(
                  //                         elevation: 0,
                  //                         color: Colors.transparent,
                  //                         child: TextField(
                  //                            style: FontStyleUtilities.t2(context,
                  //                           fontWeight: FWT.medium,
                  //                           fontColor: Colors.black),
                  //                       decoration: InputDecoration(
                  //                         // filled: true,
                  //                         // enabledBorder: OutlineInputBorder(
                  //                         //   borderRadius: BorderRadius.circular(100),
                  //                         //   borderSide: BorderSide(width: 1,color: dark(context)? Colors.grey.shade700: Colors.white)
                  //                         // ),
                  //                         // fillColor: dark(context)? Colors.grey.shade900: Colors.white,
                  //                                 prefixIcon: Padding(
                  //                                   padding: EdgeInsets.symmetric(
                  //                                       vertical: 11.5.h),
                  //                                   child: const SvgIcon(
                  //                                       'asset/Icons/search-icon.svg'),
                  //                                 ),
                  //                                 hintText: allMessages.value.search ?? 'Search',
                  //                                 contentPadding:
                  //                                     EdgeInsets.symmetric(
                  //                                         vertical: 10.h,
                  //                                         horizontal: 7.w),
                  //                                 hintStyle: FontStyleUtilities.t2(
                  //                                     context,
                  //                                     fontColor: AppColor
                  //                                         .scaffoldBackGroundDark,
                  //                                     fontWeight: FWT.semiBold)),
                  //                           ),
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 )),
                  //                 SizedBox(
                  //                   width:12.5.w,
                  //                 ),
                  //                  ThemeButton(
                  //                   onChanged: (value) {
                                     
                  //                   },
                  //                 )
                  //               ],
                  //             ),
                  //           ),
                  //           // SizedBox(
                  //           //   height: 10.h,
                  //           // )
                  //         ],
                  //       ),
                  //     )),
                  // MyStickyHeader(
                  //     height: 57.h,
                  //     expandedHeight: 60.h,
                  //     elevation: 0,
                  //     child: Padding(
                  //       padding: EdgeInsets.symmetric(horizontal: 24.w),
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: [
                  //           SizedBox(
                  //             width: size.width,
                  //           ),
                            // SizedBox(
                            //   height: 12.h,
                            // ),
                            // Text(
                            //  allMessages.value.latestPost ?? 'Latest News',
                            //   style: FontStyleUtilities.h3(context,
                            //       fontWeight: FWT.extrabold),
                            // ),
                            // SizedBox(
                            //   height: 6.h,
                            // ),
                      //     ],
                      //   ),
                      // )),
                  MyStickyHeader(
                    pinned: true,
                    scrollElevation: 1,
                    expandedHeight: 49.h,
                    height: 49.h,
                    child: 
                     TabBar(
                     // key: ValueKey(23),
                          padding: EdgeInsets.only(left: 6.w,right: 12.w),
                          tabAlignment: TabAlignment.start,
                          indicator: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          
                          labelPadding: EdgeInsets.only(left: 12.w),
                          //indicatorSize: TabBarIndicatorSize.label,
                          // labelPadding: EdgeInsets.only(
                          //     right: 12.w, bottom: 7.h, left: 12.w),
                          onTap: (value) {
                            if (value == 0) {
                                //blogListHolder.clearList();
                                currIndex = 0;
                                tabController.index = 0;
                                setState(() { });
                            } else {
                                   currIndex = value;
                                  tabController.index = value;
                                  blogListHolder.setList(provider.blog!.categories![value-1].data as DataModel);
                                  blogListHolder.setBlogType(BlogType.category);
                                  scrollController.jumpTo(0);
                                  setState(() { });
                            }
                          },
                          isScrollable: true,
                          labelColor: dark(context) && isWhiteRange(Theme.of(context).primaryColor) ? 
                          Colors.black  : isBlack(Theme.of(context).primaryColor) ?
                          Colors.white : Colors.white,
                          tabs: provider.blog != null && provider.blog!.categories != null &&  provider.blog!.categories!.isNotEmpty? [
                             Container(
                                key: const ValueKey(0),
                             //  duration: const Duration(milliseconds: 300),
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(12),
                                 color: currIndex ==  0 ? Theme.of(context).primaryColor
                                 : Colors.transparent
                               ),
                               padding: EdgeInsets.symmetric(horizontal: 12.w),
                               child: Tab(
                               height: 35,
                                text: allMessages.value.allNews  ?? 'All',
                              )),
                             // if()
                          ...provider.blog!.categories!
                              .asMap().entries.map((e) => Container(
                                  key: ValueKey(e.key+1),
                               /// duration: const Duration(milliseconds: 300),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: currIndex ==  e.key+1 ?
                                   Theme.of(context).primaryColor
                                  : Colors.transparent 
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Tab(
                                        height: 35,
                                        text: e.value.name,
                                ),
                              ))
                        ] : [
                         ...List.generate(10, (index) =>
                          const Tab(
                            child:  ShimmerLoader(
                               key: ValueKey(0234),
                                width:80,
                                isHori: true,
                                height:15,
                                margin: EdgeInsets.all(5),
                                count: 6
                            ),
                          )
                         )
                        ],
                          dividerHeight: 0,
                          controller: tabController,
                        ) ,
                  ),
                     if (currIndex == 0)
                       SliverToBoxAdapter(
                        child:  SizedBox(
                            height: 12.h,
                        ),
                      ),
                      if(provider.quotes.isNotEmpty &&  currIndex == 0   && allSettings.value.isEnableStories == '1')
                      SliverToBoxAdapter(
                        child: HomeCategories(
                        provider: provider,
                      )),
                      currIndex != 0 ?
                      blogListHolder.getList().blogs.isNotEmpty ?
                      SliverList.builder(
                         key: ValueKey(currIndex),
                         itemCount: blogListHolder.getList().blogs.length,
                         itemBuilder: (context, i){
                          return 
                           blogListHolder.getList().blogs[i].type == 'ads'
                           ? const SizedBox() :
                            blogListHolder.getList().blogs[i].type == 'quote' 
                            ? const SizedBox() 
                            : NewsTile(
                               blog: blogListHolder.getList().blogs[i],
                               toShowDivider: blogListHolder.getList().blogs.last != blogListHolder.getList().blogs[i]
                              );
                         },
                 ) : const SliverToBoxAdapter()
                :
                 provider.featureBlogs.isNotEmpty ? SliverToBoxAdapter(
                    child: SizedBox(
                      width: size(context).width,
                      height: 280.h, 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left:18.0),
                          child: Text(
                            allMessages.value.featuredStories  ?? 'Featured News',
                           style: FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
                          ),
                        ),
                        const SizedBox(height: 12),
                       
                        const CarouselWrapper(),
                      ],
                    )),
                  ) : const SliverToBoxAdapter(),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 6.h,
                    ),
                  ),
                  // currIndex != 0 ?
                  // const SliverToBoxAdapter(): SliverToBoxAdapter(
                  //   child: Divider(
                  //     height: 1,
                  //     color: dark(context) ? Colors.grey.shade700 : Colors.grey.shade300,
                  //   ),
                  // ),
                currIndex != 0 ?
                  const SliverToBoxAdapter():  SliverToBoxAdapter(
                    child: TrendingNews(
                     provider: provider,
                    ),
                  ),
                 
                   SliverToBoxAdapter(
                    child: (isLoad == 1 && blogListHolder.getList().nextPageUrl != null && currIndex != 0) || (
                      isLoad == 1 && provider.allNews != null  && provider.allNews!.nextPageUrl != null && currIndex == 0
                    )?
                     const Padding(
                      padding:  EdgeInsets.all(16.0),
                      child:  Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox()
                  ),
                  if(currIndex == 0)
                  SliverToBoxAdapter(
                    child: Container(
                    width: size(context).width,
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 100.h,top: 24.h),
                    // height: Platform.isIOS ? 60.h : 83.h,
                     child: Text(allMessages.value.stayBlessedAndConnected ?? "Stay Blessed & Connected with Signal 💙",
                     style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontSize: 12,
                      color: dark(context) ? Colors.grey.shade500: Colors.grey.shade800
                     ),
                     ),
                   ),
                  )else SliverToBoxAdapter(
                      child: SizedBox(
                      height: 83.h
                    ))
                ],
              ),
             ),
           ),
        ),
      );
    });
  }
}
