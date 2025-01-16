import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:blogit/Utils/color_util.dart';
import 'package:blogit/controller/repository.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/presentation/screens/Prelog/select_interest.dart';
import 'package:blogit/presentation/widgets/blog_ad.dart';
import '../../../../Utils/navigation_util.dart';
import '../../../../controller/app_provider.dart';
import '../../../widgets/outlined_button.dart';
import '../../../widgets/the_search_area.dart';
import '../../Auth/Login/login.dart';
import '../Home/Home_compo/trending_story.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {

ScrollController scrollController =ScrollController();

  bool load=false;
  // void _scrollListener() {
  //   print(scrollController.position.extentAfter);
  //   if (scrollController.position.extentAfter < 500) {
      
  //   }
  // }
 

  @override
  Widget build(BuildContext context) {
//    var  provider = Provider.of<AppProvider>(context,listen:false);
    return Scaffold(
      body:Consumer<AppProvider>(
          builder: (context,provider,child) {
            return RefreshIndicator(
        onRefresh: () async {
          Future.delayed(const Duration(milliseconds: 2000));
          setState(() {
             adView();
             provider.getCategory();
          });
        },
        child: SafeArea(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                   const TheSearchArea(),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 10.h,
                          )
                        ),
                            SliverList(
                              key: ValueKey(provider.feedBlogs.length),
                              delegate: SliverChildListDelegate([
                                ...List.generate(provider.feedBlogs.length, (index) { 
                                  if(provider.feedBlogs[index].type =='ads'){
                                  return Padding(
                                    key:ValueKey(index),
                                     padding: const EdgeInsets.only(bottom: 24),
                                     child: BlogAd(
                                      key: ValueKey(index),
                                      onTap: () {
                                        
                                      },
                                      model:  provider.feedBlogs[index],
                                      
                                     ),
                                   );
                                 } else { 
                                    return TrendingStory(
                                      key: ValueKey(index),
                                      blog: provider.feedBlogs[index],
                                      index : index
                                    );
                                  }
                                })
                              ]),
                          ),
                        provider.feed!.blogs.isEmpty ?
                           SliverToBoxAdapter(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height - kToolbarHeight*4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                       Icon(Icons.info_outline_rounded,size: 50,color:dark(context) ? Colors.grey.shade300 : Colors.grey.shade500),
                                       Text( allMessages.value.nofeed ?? 'No Feed ?',
                                       style: TextStyle(fontSize: 18,
                                       fontWeight: FontWeight.w700,
                                       color: Theme.of(context).primaryColor)),
                                      
                                       Padding(
                                         padding: const EdgeInsets.only(top:4,bottom: 12,left: 40,right: 40),
                                         child: Text(currentUser.value.id == null 
                                         ? allMessages.value.seemsLikeUnauthenticated ?? 'Seems like you are not authenticated. Please click below to proceed'
                                         : allMessages.value.seemsLikeNoInterests ?? 'Seems like you didn\'t select any of your interests. Please click below to proceed',
                                         textAlign: TextAlign.center,
                                         ),
                                       ),
                                      TextButt(
                                       text: currentUser.value.id != null ? allMessages.value.myFeed ?? 'My Feed' :
                                       allMessages.value.signIn ?? 'Login',
                                        onTap: () {
                                        NavigationUtil.to(context, currentUser.value.id != null ?
                                         const SelectInterest(isDrawer: true) : const Login());
                                      })
                                ],
                              ),
                            ),
                          ) :  provider.feed!.nextPageUrl != null && load==false ?
                            SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              child: SignalOutlinedButton(
                                    tittle: allMessages.value.loadMore ?? 'Load more', 
                                    onTap: provider.feed!.nextPageUrl == null ?
                                    (){
                                                      
                                    } : () async{
                                      
                                      load=true;
                                      setState(() {  });
                                       provider.loadMoreBlogs(provider.feed!.nextPageUrl.toString()).then((value) {
                                        load=false;
                                        setState(() {  });
                                      });
                                    }),
                            )) :provider.feed!.nextPageUrl != null && load ?  
                                  const  SliverToBoxAdapter(
                              child: SizedBox(
                                child:  Center(
                                  child: CircularProgressIndicator(),
                                ),
                            )) :  
                         SliverToBoxAdapter(
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
                         SliverToBoxAdapter(
                            child:SizedBox(
                                height: 110.h,
                          ))
                ],
              ),
            )
      );
      }
     ));
  }
}
