import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blogit/presentation/screens/Main/Article_list/article_list.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/presentation/widgets/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:blogit/controller/blog_controller.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/model/blog.dart';
import '../../../../../controller/app_provider.dart';
import '../search_data.dart';

class SearchOptionWrapper extends StatefulWidget {
  const SearchOptionWrapper({
    super.key,
  });

  @override
  State<SearchOptionWrapper> createState() => _SearchOptionWrapperState();
}

class _SearchOptionWrapperState extends State<SearchOptionWrapper> {
  int _selectedIndex = 0;
  onTap(int index) {
    _selectedIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context,listen:false);
      SearchTileModel model = SearchTileData.searchItems[0];
    return SizedBox(
        height: 100.h,
        child: TheMultiChildAnimationWrapper(
          length: provider.blog!.categories!.length,
          children: [
               Padding(
                  key: const ValueKey(12110),
                  padding: EdgeInsets.only(
                    left: 24.w,
                    right: 00.w,
                  ),
                  child: SearchOptions(
                    
                      onTap: () {
                        onTap(0);
                        if (_selectedIndex == 0) {
                          blogListHolder2.clearList();
                          blogListHolder2.setList(provider.allNews as DataModel);
                          blogListHolder2.setBlogType(BlogType.allnews);
                           setState(() { });
                           NavigationUtil.to(context, ArticleList(blogs: provider.allNewsBlogs,
                           isAllNews: true,
                           title: allMessages.value.allNews ?? 'All News',));
                        }
                      },
                      isSelected: true,
                      icon: model.icon,
                      name: model.name),
                ),
            if(provider.blog != null && provider.blog!.categories != null)
            ...List.generate(
              provider.blog!.categories!.length,
              (int index) {
                  return Padding(
                  key: ValueKey(index),
                  padding: EdgeInsets.only(
                    left: index == 0 ? 24.w : 16,
                    right:
                        index == provider.blog!.categories!.length - 1 ? 24 : 0,
                  ),
                  child: SearchOptions(
                      onTap: () {
                        onTap(index);
                         blogListHolder2.clearList();
                          blogListHolder2.setList(provider.blog!.categories![index].data as DataModel);
                          blogListHolder2.setBlogType(BlogType.category);
                          setState(() { });
                          NavigationUtil.to(context, ArticleList(category: provider.blog!.categories![index],isCategory: true));
                      
                      },
                      isSelected:false,
                      icon: provider.blog!.categories![index].image ?? '',
                      name: provider.blog!.categories![index].name ?? ''),
                );
            
              },
            )
          ],
        ));
  }
}

class SearchOptions extends StatefulWidget {
  const SearchOptions({
    super.key,
    required this.isSelected,
    required this.icon,
    required this.name,
    required this.onTap,
  });
  final bool isSelected;

  final String icon, name;
  final VoidCallback onTap;

  @override
  State<SearchOptions> createState() => _SearchOptionsState();
}

class _SearchOptionsState extends State<SearchOptions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: EdgeInsets.all(widget.icon.contains('http') ? 0 :18.h),
            height: 70.h,
            width: 70.h,
            decoration: BoxDecoration(
                border: Border.all(
                    width: 1.5,
                    color: widget.isSelected
                        ? Theme.of(context).primaryColor
                        : ColorUtil.themNeutral),
                borderRadius: BorderRadius.circular(100.r),
                color: widget.isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.transparent),
            child: widget.icon.contains('http') ? 
             ClipRRect(
               borderRadius: BorderRadius.circular(100.r),
               child: CachedNetworkImage(
                imageUrl: widget.icon,
                fit: BoxFit.cover,
               ),
             )
            :  SvgIcon(
              widget.icon,
              color: widget.isSelected ? Colors.white : ColorUtil.borderColor,
            ),
          ),
        ),
        SizedBox(
          height: 8.5.h,
        ),
        Text(
          widget.name,
          style: FontStyleUtilities.t4(context,
              fontWeight: FWT.extrabold,
              fontColor: widget.isSelected
                  ? Theme.of(context).primaryColor
                  : ColorUtil.themNeutral),
        )
      ],
    );
  }
}
