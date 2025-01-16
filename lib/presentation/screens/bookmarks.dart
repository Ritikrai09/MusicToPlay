import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Shared_component/news_tile.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/presentation/widgets/theme_button.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../Utils/app_theme.dart';
import '../../Utils/color_util.dart';
import '../../Utils/font_style.dart';
import '../../controller/app_provider.dart';
import '../../main.dart';
import '../widgets/sliver_appbar_header.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {

  bool load=false;
  late AppProvider provider;

    @override
    void initState(){
   provider = Provider.of<AppProvider>(context,listen:false);
   // load = !prefs!.containsKey('isBookmark') ? true :false;
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
     if (!prefs!.containsKey('isBookmark')) {
        provider.getAllBookmarks().then(( value) {
         load=false;
        setState(() { });
      });
     } else {
       provider.setAllBookmarks().then((value) {
      //  load=false;
        setState(() { });
       });
     }    
        
    });
    super.initState();
    }


  @override
  Widget build(BuildContext context) {
    return CustomLoader(
      isLoading: load,
      child: Scaffold(
          body: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (notification) {
              notification.disallowIndicator();
              return true;
            },
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  MyStickyHeader(
                      floating: true,
                      elevation: 0,
                      expandedHeight: 65.h,
                      height: 65.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                BackbUT(),
                                Text(
                                allMessages.value.mySavedStories ?? 'Bookmarks Page',
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
                          SizedBox(height: 14.h)
                        ],
                      )),
                  Builder(
                    key: ValueKey(provider.bookmarks.length),
                    builder: (context) {
                      return SliverList(
                        
                        delegate: SliverChildListDelegate(
                        provider.bookmarks.isEmpty && load == false? [
                              Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height/1.33,
                                child: Text(allMessages.value.noSavedPostFound.toString(),
                                style: FontStyleUtilities.h5(context,fontWeight: FWT.semiBold)),
                              )
                        ]:[
                        ...provider.bookmarks.asMap().entries.map((e) => NewsTile(
                          blog: e.value,
                          bookmarkPage:true,
                          toShowDivider : e.key != provider.bookmarks.length-1,
                          onChanged:(value){
                            setState((){});
                          }
                          ))
                      ]));
                    }
                  ),
                  SliverToBoxAdapter(
                    child:  SizedBox(height: 24.h),
                  )
          ],
        ),
      ))),
    );
  }
}

class BackbUT extends StatelessWidget {
  const BackbUT({
    super.key,
    this.onTap,
    this.color,
    this.padding,
  });

final VoidCallback? onTap;
final Color? color;
final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
       borderRadius: BorderRadius.circular(16),
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          padding: padding,
          onPressed: onTap ?? () {
            Navigator.pop(context);
          },
          icon:  Image.asset(
           'asset/Icons/arrow.png',
           width: 22,height: 22,
           color: dark(context) ? color ??Colors.white : color ??Colors.black)),
      ),
    );
  }
}