import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/widgets.dart';

import '../Utils/color_util.dart';
import '../Utils/font_style.dart';
import '../model/cms.dart';
import 'Screens/web_view.dart';

class CmsPage extends StatefulWidget {
  const CmsPage({super.key,this.cms});
  final CmsModel? cms;

  @override
  State<CmsPage> createState() => _CmsPageState();
}

class _CmsPageState extends State<CmsPage> {
  @override
  Widget build(BuildContext context) {
    // var text = parse(widget.cms!.description).body!.text;
    return  Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
           MyStickyHeader(
                        floating: true,
                        elevation: 0,
                        height: 65.h,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                               const BackbUT(),
                                  Text(
                                  widget.cms!.title ?? 'Page',
                                    style: FontStyleUtilities.h5(context,
                                            fontWeight: FWT.extrabold)
                                        .copyWith(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    width: 24,
                                  )
                                  //  ThemeButton(
                                  //   onChanged: (value) {
                                  //       toggleDarkMode(!appThemeModel.value.isDarkModeEnabled.value);
                                  //         setState(() {    });
                                  //   },
                                  // )
                                ],
                              ),
                            ),
                            SizedBox(height: 16.h)
                          ],
                        )),
            const SliverToBoxAdapter(
              child: SizedBox(height: 10),
            ),
             SliverPadding(
               padding: const EdgeInsets.symmetric(horizontal: 24),
               sliver: SliverToBoxAdapter(
                child: widget.cms!.image!.contains('https') ? 
                CachedNetworkImage(imageUrl:widget.cms!.image.toString(),height: 200 ) 
                : Image.asset('asset/Images/Logo/splash_logo.png',height: 200,),
               ),
             ),
            SliverPadding(
               padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 16),
               sliver: SliverToBoxAdapter(
                child: Html(
                  data: widget.cms!.description ?? 'Lorem ipsum data can wiit the ckiodf iskf flkfgsdcadsad dbcd bhsdMN DVMMAM',
                  style: {
                    "body": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'QuickSand',
                      padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                    "p": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'QuickSand',
                        padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                    "b": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'QuickSand',
                      fontWeight: FontWeight.w600,
                        padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                     "i": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'QuickSand',
                      fontStyle: FontStyle.italic,
                        padding: HtmlPaddings(left: HtmlPadding(0),right: HtmlPadding(0),)
                    ),
                     "a": Style(
                      fontSize:  FontSize(16),
                      fontFamily: 'QuickSand',
                      color: ColorUtil.primaryColor,
                    ),
                  },
                  onLinkTap: (url, context1, element) {
                   Navigator.push(context, MaterialPageRoute(builder:(coontext)=> CustomWebView(url: url.toString())));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}