import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Article_list/article_list.dart';
import 'package:blogit/presentation/screens/Main/Shared_component/news_tile.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/loader.dart';

import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/app_provider.dart';
import 'package:http/http.dart' as http;
import '../../../../Utils/app_theme.dart';
import '../../../../Utils/custom_toast.dart';
import '../../../../Utils/urls.dart';
import '../../../../controller/blog_controller.dart';
import '../../../../controller/user_controller.dart';
import '../../../../model/blog.dart';
import 'package:get_storage/get_storage.dart';
import 'search_page_compo/search_option.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  bool isRecentSearch = true;
  
  bool searchListShor=true;
  late TextEditingController searchController;
  
  List mainDataList=[];
  GetStorage localList = GetStorage();
  bool isLoading=false;
  
  int isFound = -1;
  
  List<Blog> blogList = [];
  
 late AppProvider provider;
  FocusNode focusNode = FocusNode();


  @override
  void initState() {
    List local = localList.read('searchList') ?? [];
    for (int i = 0; i < local.length; i++) {
      mainDataList.add(local[i]);
    }
    
    provider = Provider.of<AppProvider>(context,listen:false);
    currentUser.value.isPageHome = false;
    searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     provider.getAllBookmarks();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomLoader(
      isLoading: isLoading,
      child: Scaffold(
          body: SafeArea(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  MyStickyHeader(
                      expandedHeight: 52.h,
                      elevation: 0,
                      pinned: true,
                      height: 52.h,
                      child: SizedBox(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(right: 22.w,left:12.w,top: 0.h),
                              child: Row(
                                children: [
                                // Material(
                                //   color: Colors.transparent,
                                //   child: 
                                //   IconButton(
                                //     onPressed: () {
                                //       Navigator.pop(context);
                                //     },
                                //     icon:  SvgIcon(
                                //      'asset/Icons/arrow-back.svg',
                                //      color:dark(context) ? Colors.white : Colors.black)),
                                // ),
                                const BackbUT(),
                                   SizedBox(
                                    width: 12.5.w,
                                  ),
                                  Expanded(
                                      child:  Hero(
                                      tag: 'SEARCH234',
                                      child:Material(
                                    elevation: 0,
                                    color: Colors.transparent,
                                    child:  TextFormField(
                                        controller: searchController,
                                        autofocus: true,
                                          onChanged: (text) {
                                          // if (text.length >= 3) {
                                          //   recentSearch = false;
                                          // } else
                                          if (text.isEmpty) {
                                            isRecentSearch = true;
                                            searchListShor = true;
                                            isFound=-1;
                                          }
                                          setState(() { });
                                                   
                                        },
                                          onFieldSubmitted: (value) {
                                            searchBlog(context);
                                          },
                                        
                                        style: FontStyleUtilities.t2(context,
                                            fontWeight: FWT.medium,
                                            fontColor: dark(context)?Colors.white : Colors.black),
                                            
                                        decoration: InputDecoration(
                                          suffixIcon: searchController.text.isNotEmpty && isFound == 0
                                           ?  InkResponse(
                                            onTap:() {
                                              //  if (searchController.text == '') {
                                              //     showCustomToast(context, allMessages.value.searchFieldEmpty ?? 'Search Field is empty',);
                                              //     } else {
                                                        // isNoResult = false;
                                                        blogList.clear();
                                                        searchListShor = true;
                                                        isRecentSearch = true;
                                                        searchController.text = '';
                                                        isFound = -1;
                                                        setState(() {});
                                                  //    }
                                            },
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 6.h),
                                                child:  Icon(Icons.close_rounded,
                                                color: dark(context)?Colors.white : Colors.black)
                                              ),
                                          ) : InkResponse(
                                            onTap: (){
                                              searchBlog(context);
                                            },
                                            child: Icon(Icons.search_rounded),
                                          ),
                                            // prefixIcon: Padding(
                                            //   padding: EdgeInsets.symmetric(
                                            //       vertical: 11.5.h),
                                            //   child:  SvgIcon(
                                            //       'asset/Icons/search-icon.svg',color: dark(context) ?Colors.grey.shade800 : null),
                                            // ),
                                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                              borderRadius: BorderRadius.circular(100)),
                                            hintText:allMessages.value.searchStories ?? 'Search',
                                            contentPadding: EdgeInsets.symmetric(
                                                vertical: 10.h, horizontal: 16.w),
                                            hintStyle: FontStyleUtilities.t2(
                                                context,
                                                fontColor: dark(context) ? Colors.grey.shade800:AppColor.scaffoldBackGroundDark,
                                                fontWeight: FWT.semiBold)),
                                      ),
                                    ),
                                  )),
                                   SizedBox(
                                    width: 12.5.w,
                                  ),
                                  if(blogList.isEmpty)
                                   ThemeButton(
                                    onChanged: (value) {
                                        toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
                                      setState(() {    });
                                    },
                                  )
                                ],
                              ),
                            ),
                            // SizedBox(
                            //   height: 10.h,
                            // )
                          ],
                        ),
                      )),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 20.h,
                    ),
                  ),
                   isFound==-1
                         ? const SliverToBoxAdapter(child:  SearchOptionWrapper())
                         : const SliverToBoxAdapter(),
                   blogList.isEmpty && isFound == -1 ? SliverToBoxAdapter(
                          child:   Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              const SizedBox(height: 30),
                              if(mainDataList.isNotEmpty)
                              Text(
                                allMessages.value.recentSearch ?? 'Recent Search',
                                style: FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
                              ),
                             const SizedBox(height: 12),
                            ...mainDataList.map((e) => 
                            Recents(
                              onClear: () {
                                 localList.remove('searchList');
                                mainDataList
                                    .removeWhere(
                                        (item) =>item == e);
                                localList.write(
                                    'searchList',
                                    mainDataList);
                                setState(() {});
                              },
                             onTap: () async{ 
                            searchController.text = e;
                            searchController.value =
                            TextEditingValue(
                               text: e,
                               selection: TextSelection.collapsed(offset:searchController.text.length),
                               );
                               isRecentSearch=false;
                              await getSearchedBlog();
                               setState(() {});
                            },text: e))
                              ],
                            ),
                          ),
                         ):  isFound == 1
                         ? isLoading == true ?  const SliverToBoxAdapter() : 
                        SliverList(
                        delegate: SliverChildListDelegate([
                            ...blogList.asMap().entries.map((e) => NewsTile(
                              toShowDivider:blogList.last != e.value,
                              blog: e.value))
                        ])
                    )
                    :   SliverToBoxAdapter(
                      child: NotFoundWidget(
                        text: allMessages.value.noResultsFoundMatchingWithYourKeyword ?? "")
                    ),
                 const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  )
                ],
              ),
            ),
          ),
        )
    );
  }

  void searchBlog(BuildContext context) {
    searchController.text = searchController.text.trim();
    setState(() {  });
    if (searchController.text == '') {
    showCustomToast(context,allMessages.value.searchFieldEmpty ?? 'Search Field is empty');
    } else {
      if (searchListShor) {
        isRecentSearch=false;
        getSearchedBlog();
        if (!mainDataList.contains(searchController.text)) {
          if (mainDataList.length >= 4) {
            localList.remove('searchList');
            mainDataList.removeAt(mainDataList.length - 1);
            mainDataList.add(searchController.text);
            localList.write('searchList', mainDataList);
          } else {
            localList.remove('searchList');
            mainDataList.add(searchController.text);
            localList.write('searchList', mainDataList);
          }
        } else {
          localList.remove('searchList');
          mainDataList.removeWhere(
              (item) => item == searchController.text);
          mainDataList.add(searchController.text);
          localList.write('searchList', mainDataList);
        }
        searchListShor = false;
      } else {
        searchListShor = true;
        searchController.text = '';
      }
      setState(() {
        searchListShor = false;
      });
    }
  }
  Future getSearchedBlog() async {
    isLoading = true;
    setState(() { });
    if (searchController.text != '' && searchListShor == true) {
      final msg = jsonEncode({"keyword": searchController.text,});
      final String url = '${Urls.baseUrl}blog-search';
      final client = http.Client();
      final response = await client.post(
        Uri.parse(url),
        headers:   {
          HttpHeaders.contentTypeHeader: 'application/json',
          "language-code" : languageCode.value.language ?? 'en',
        },
        body: msg,
      );
      Map<String, dynamic> data = json.decode(response.body);
     
      setState(() {
        if (data['data'] is List && data['data'].isNotEmpty){
          isFound = 1;
        } else {
          isFound = 0;
        }

        final list = DataModel.fromJson(data,isSearch: true);
        isRecentSearch = false;
        blogList = list.blogs;
        blogListHolder2.clearList();
        blogListHolder2.setList(list);
        blogListHolder2.setBlogType(BlogType.search);
        isLoading = false;
      });
    } else {
      isRecentSearch = true;
      isLoading = false;
      setState(() {});
    }

  }
  
}



class Recents extends StatelessWidget {
  const Recents({
    super.key,
   required this.onClear,
    required this.onTap,
    this.text,
  });
 
  final String? text;
  final VoidCallback onTap,onClear;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
             Row(
               children: [
                const Icon(Icons.refresh_rounded,size: 16),
                const SizedBox(width: 6),
                 Text(text ?? '',style: const TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15,
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500
                 )),
               ],
             ),
              IconButton(onPressed:onClear,
               icon:const Icon(Icons.close_rounded,size: 16))
          ]
        ),
      ),
    );
  }
}