// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:blogit/presentation/Widgets/text.dart';
// import 'package:blogit/Utils/app_theme.dart';

// import 'package:blogit/Utils/utils.dart';
// import 'package:blogit/presentation/Widgets/widgets.dart';
// import 'package:blogit/Extensions/extension.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../model/blog.dart';
// import '../Shared_component/video_tile.dart';
// import '../shared_component/video_tile.dart';
// import '../shared_component/comment_tile.dart';

// class StoryNews extends StatefulWidget {
//   const StoryNews({Key? key,required this.blog}) : super(key: key);
//   final Blog blog;

//   @override
//   _StoryNewsState createState() => _StoryNewsState();
// }

// class _StoryNewsState extends State<StoryNews> {
//   late ScrollController _scrollController;
//   double _offset = 0;

//   @override
//   void initState() {
//     _scrollController = ScrollController()
//       ..addListener(() {
//         _offset = _scrollController.position.pixels;
//       });
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _scrollController;
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor:C,
//       body: NotificationListener<OverscrollIndicatorNotification>(
//         onNotification: (notification) {
//           notification.disallowIndicator();
//           return true;
//         },
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 SliverAppBar(
//                   automaticallyImplyLeading: false,
//                   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//                   pinned: true,
//                   // floating: true,
//                   flexibleSpace: FlexibleSpaceBar(
//                     background: Stack(
//                       fit: StackFit.expand,
//                       children: [
//                         Container(
//                           alignment: Alignment.bottomLeft,
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 24.h, vertical: 16.h),
//                        decoration: BoxDecoration(
//                           color: Colors.black,
//                            image: DecorationImage(image: CachedNetworkImageProvider(
//                             widget.blog.images![0]
//                            ),fit: BoxFit.cover)
//                        ),
//                         ),Positioned.fill(
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 12),
//                             child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 mainAxisSize: MainAxisSize.max,
//                                 children: [
//                                   Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Container(
//                                         alignment: Alignment.centerLeft,
//                                          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 6),
//                                         decoration: BoxDecoration(
//                                           color: hexToRgb(widget.blog.categoryColor),
//                                           borderRadius: BorderRadius.circular(8.r),
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                           widget.blog.categoryName ??  'TRAVEL',
//                                             style: FontStyleUtilities.t4(context,
//                                                 fontColor: Colors.white,
//                                                 fontWeight: FWT.semiBold),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(
//                                     height: 12.5.h,
//                                   ),
//                                   Text(
//                                    widget.blog.title ?? 'Short Story is a\nPiece of Prose\nFiction',
//                                     style: FontStyleUtilities.h3(context,
//                                         fontWeight: FWT.extrabold,
//                                         fontColor: Colors.white),
//                                   ),
//                                   SizedBox(
//                                     height: 25.h,
//                                   ),
//                                   Row(
//                                     children: [
//                                       SizedBox(
//                                         height: 40.h,
//                                         width: 40.h,
//                                         child:
//                                             Image.asset('asset/Images/Temp/author.png'),
//                                       ),
//                                       SpaceUtils.ks7.width(),
//                                       Expanded(
//                                           child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Olivia',
//                                             style: FontStyleUtilities.t2(context,
//                                             fontColor: Colors.white,
//                                             fontWeight: FWT.extrabold),
//                                           ),
//                                           Text(
//                                             '7 min watch',
//                                             style: FontStyleUtilities.t4(context,
//                                                 fontWeight: FWT.extrabold,
//                                                 fontColor: ColorUtil.themNeutral),
//                                           ),
//                                         ],
//                                       )),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                           ),
//                         ),
                        
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: GestureDetector(
//                         onTap: () {
//                           Navigator.pop(context);
//                         },
//                         child: CircleAvatar(
//                           radius: 18.r,
//                           backgroundColor:
//                               Theme.of(context).colorScheme.onBackground,
//                           child: Icon(
//                             Icons.close,
//                             size: 26,
//                             color: Theme.of(context).cardColor,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 24.h,
//                     )
//                   ],
//                   expandedHeight: 550.h,
//                 ),
//                 const SliverToBoxAdapter(
//                   child: Divider(
//                     height: 1,
//                   ),
//                 ),
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.h),
//                   sliver: SliverList(
//                       delegate: SliverChildListDelegate([
//                     SpaceUtils.ks20.height(),
//                     Description(
//                      model: widget.blog,
//                     ),
//                     SizedBox(
//                       height: 43.h,
//                     ),
//                     Container(
//                       padding: EdgeInsets.only(bottom: 27 / 18 * (19 / 3).h),
//                       decoration: BoxDecoration(
//                           border: Border(
//                         left: BorderSide(
//                             width: 7.w, color: const Color(0xff8AB9A2)),
//                       )),
//                       child: Row(
//                         children: [
//                           SizedBox(
//                             width: 22.w,
//                           ),
//                           Expanded(
//                               child: Text(
//                             'Lorem ipsum dolor sit amet,Lorem ipsum dolor sit ametLorem ipsum dolor sit amet consectetur adipiscing elit. Nunc vitae felis sit amet ligula semper convallis. Vestibulum lectus neque, ultricies et lacus ut, pulvinar blandit sem.',
//                             style: FontStyleUtilities.h5(context,
//                                     fontWeight: FWT.semiBold)
//                                 .copyWith(fontSize: 19, height: 27 / 18),
//                           ))
//                         ],
//                       ),
//                     ),
//                     SizedBox(
//                       height: 43.h,
//                     ),
//                     Text(
//                       'Proin sed est porta, imperdiet velit quis, faucibus sem. Nam malesuada aliquam placerat. Nam hendrerit nibh non lacinia aliquet. Vivamus id sapien gravida, aliquet lorem ac, tristique odio. Cras eleifend urna hendrerit ullamcorper efficitur. Morbi mattis eros et neque congue eleifend. Curabitur at erat arcu.',
//                       style: FontStyleUtilities.t2(context,
//                               fontWeight: FWT.semiBold,
//                               fontColor: ColorUtil.themNeutral)
//                           .copyWith(height: 1.5),
//                     ),
//                     SizedBox(
//                       height: 31.h,
//                     ),
//                   ])),
//                 ),
//                 SliverToBoxAdapter(
//                   child: SizedBox(
//                     height: 320.h,
//                     width: 375.w,
//                     child: const DecoratedBox(
//                         decoration: BoxDecoration(color: Color(0xffDED6F6))),
//                   ),
//                 ),
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(horizontal: 24.w),
//                   sliver: SliverList(
//                       delegate: SliverChildListDelegate([
//                     SizedBox(
//                       height: 28.h,
//                     ),
//                     Stack(
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.only(top: 4.h),
//                           child: SizedBox(
//                             height: 54.84.h,
//                             width: 69.84.w,
//                             child: Image.asset('asset/Icons/quote.png'),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(left: 42.w),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'RELATED QUOTE',
//                                 style: FontStyleUtilities.t2(context,
//                                     fontWeight: FWT.semiBold,
//                                     fontColor: ColorUtil.themNeutral),
//                               ),
//                               SizedBox(
//                                 height: 7.h,
//                               ),
//                               Text(
//                                 'Trust yourself, you\nknow more than you\nthink you do.',
//                                 style: FontStyleUtilities.h3(context,
//                                         fontWeight: FWT.extrabold)
//                                     .copyWith(height: 1.3),
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 42.h,
//                     ),
//                     Text(
//                       'Proin sed est porta, imperdiet velit quis, faucibus sem. Nam malesuada aliquam placerat. Nam hendrerit nibh non lacinia aliquet. Vivamus id sapien gravida, aliquet lorem ac, tristique odio. Cras eleifend urna hendrerit ullamcorper efficitur. Morbi mattis eros et neque congue eleifend. Curabitur at erat arcu.',
//                       style: FontStyleUtilities.t2(context,
//                               fontWeight: FWT.semiBold,
//                               fontColor: ColorUtil.themNeutral)
//                           .copyWith(height: 1.50),
//                     ),
//                     SizedBox(
//                       height: 46.h,
//                     ),
//                     SignalOutlinedButton(
//                         tittle: 'Show This Article', onTap: () {}),
//                     SizedBox(height: 28.h),
//                   ])),
//                 ),
//                 const SliverToBoxAdapter(
//                   child: Divider(
//                     height: 1,
//                   ),
//                 ),
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 24.w,
//                   ),
//                   sliver: SliverList(
//                       delegate: SliverChildListDelegate([
//                     SizedBox(height: 28.h),
//                     Text(
//                       'You might also like',
//                       style: FontStyleUtilities.h6(context,
//                           fontWeight: FWT.extrabold),
//                     ),
//                     SizedBox(height: 28.h),
//                     Row(
//                       children: [
//                          Expanded(child: VideosCard(blog: ,)),
//                         SpaceUtils.ks16.width(),
//                          Expanded(child: VideosCard(blog : )),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 48.h,
//                     ),
//                   ])),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Comments',
//                           style: FontStyleUtilities.h6(context,
//                               fontWeight: FWT.extrabold),
//                         ),
//                         SpaceUtils.ks16.height(),
//                         // const CommentsTile(),
//                         // const CommentsTile(comments: null,),
//                         // const CommentsTile(
//                         //   showDivider: false,
//                         // ),
//                         SizedBox(
//                           height: 44.h,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 24.w),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Post New Comment',
//                           style: FontStyleUtilities.h6(context,
//                               fontWeight: FWT.extrabold),
//                         ),
//                         SizedBox(
//                           height: 32.h,
//                         ),
//                         const MyTextField(hint: 'Name'),
//                         SpaceUtils.ks8.height(),
//                         const MyTextField(hint: 'E-mail'),
//                         SpaceUtils.ks8.height(),
//                         MyTextField(
//                           hint: 'Comment',
//                           maxHeight: 210.h,
//                           maxLines: 8,
//                         ),
//                         SizedBox(
//                           height: 42.h,
//                         ),
//                         Button(tittle: 'Post Comment', onTap: () {}),
//                         SizedBox(
//                           height: 60.h,
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               ],
//             ),
//             AnimatedBuilder(
//                 animation: _scrollController,
//                 builder: (context, constraints) {
//                   return AnimatedPositioned(
//                       bottom: _offset > 100.h ? -186.h : 0,
//                       curve: Curves.decelerate,
//                       duration: const Duration(milliseconds: 300),
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Column(
//                             children: [
//                               Container(
//                                 height: 93.h,
//                                 width: 375.w,
//                                 decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                         colors: [
//                                       Colors.black.withOpacity(.10),
//                                       Colors.black
//                                     ],
//                                         begin: Alignment.topCenter,
//                                         end: Alignment.bottomCenter)),
//                               ),
//                               Container(
//                                 height: 93.h,
//                                 width: 375.w,
//                                 decoration:
//                                     const BoxDecoration(color: Colors.black),
//                               ),
//                             ],
//                           ),
//                           ScrollButton(onTap: () {
//                             _scrollController.animateTo(
//                                 590.h -
//                                     (MediaQuery.of(context).padding.top +
//                                         kToolbarHeight +
//                                         -5),
//                                 duration: const Duration(milliseconds: 400),
//                                 curve: Curves.decelerate);
//                           })
//                         ],
//                       ));
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }

// class ScrollButton extends StatefulWidget {
//   const ScrollButton({
//     Key? key,
//     required this.onTap,
//   }) : super(key: key);

//   final VoidCallback onTap;

//   @override
//   State<ScrollButton> createState() => _ScrollButtonState();
// }

// class _ScrollButtonState extends State<ScrollButton> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         padding: EdgeInsets.all(18.h),
//         height: 70.h,
//         width: 70.h,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1.5, color: ColorUtil.themNeutral),
//             borderRadius: BorderRadius.circular(35.r),
//             color: Colors.transparent),
//         child: RotatedBox(
//           quarterTurns: -1,
//           child: SvgIcon(
//             'asset/Icons/arrow-back.svg',
//             color: Theme.of(context).primaryColor,
//           ),
//         ),
//       ),
//     );
//   }
// }
