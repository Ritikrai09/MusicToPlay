import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/loader.dart';

import '../../../Utils/font_style.dart';
import '../../../controller/news_repo.dart';
import '../../../controller/user_controller.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/pdf.dart';
import '../../widgets/sliver_appbar_header.dart';
import '../../widgets/theme_button.dart';
import 'live_news.dart';

class EnewsPage extends StatefulWidget {
  const EnewsPage({super.key});

  @override
  State<EnewsPage> createState() => _EnewsPageState();
}

class _EnewsPageState extends State<EnewsPage> {

  late bool load;

  @override
  void initState() {
    load = eNews.isEmpty ? true : false;
      getENews(context).then((value) {
        load = false;
        setState(() { });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  CustomLoader(
      isLoading: load,
      child: Scaffold(
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
                      padding: EdgeInsets.symmetric(horizontal: 24.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        const BackbUT(),
                          Text(
                          allMessages.value.eNews ?? 'E-News',
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
                    SizedBox(height: 16.h)
                  ],
                )),
               const SliverToBoxAdapter(
                child: SizedBox(height: 10),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: eNews.isEmpty ? [
                     
                  ] : [
                    ...eNews.map((e) => LiveWidget(
                      title: e.name,
                      image: e.image,
                      onTap: (){
                        Navigator.push(context,MaterialPageRoute(builder: (context)=> PdfViewWidget(
                          model: e,
                        )));
                      },
                    )
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}