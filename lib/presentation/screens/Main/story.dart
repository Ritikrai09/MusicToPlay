import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:blogit/Utils/font_style.dart';
import 'package:blogit/controller/user_controller.dart';
import 'package:blogit/presentation/screens/bookmarks.dart';
import 'package:blogit/presentation/widgets/anim_icon.dart';
import 'package:blogit/presentation/widgets/loader.dart';
import 'package:blogit/presentation/widgets/svg_icon.dart';

import '../../../controller/app_provider.dart';
import '../../../model/blog.dart';
import '../../widgets/share.dart';
import '../../widgets/tap_widget.dart';
import '../../widgets/the_logo.dart';

class StoryPage extends StatefulWidget {
  const StoryPage({super.key,this.index=0,this.isShare=false,this.blog});
  final int index;
  final Blog? blog;
  final bool isShare;

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {

late int currIndex;

  var isShow = true;

@override
void initState(){
  currIndex = widget.index;
  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async{
    var provider = Provider.of<AppProvider>(context,listen: false);
    provider.addviewData(provider.quotes[currIndex].id ?? 0);
    provider.quotes[currIndex].isUserViewed = 1;
    setState(() { });

   if(widget.isShare == true){
     setState(() {
      load = true;
    });
    Future.delayed(const Duration(milliseconds: 10));
    final  data = await captureScreenshot(previewContainer);
    Future.delayed(const Duration(milliseconds: 10));
    final  data2 = await convertToXFile(data!);
    Future.delayed(const Duration(milliseconds: 10));
    provider.addShareData(null,provider.quotes[currIndex].id!.toInt());
    shareImage(data2,provider.quotes[currIndex].id.toString());
    setState(() {
      load = false;
    });
   }
  });
  super.initState();
}

GlobalKey previewContainer = GlobalKey();
  bool load = false;

  @override
  Widget build(BuildContext context) {
    var  provider = Provider.of<AppProvider>(context,listen:false);
     var countLikes = provider.permanentlikesIds.contains( provider.quotes[currIndex].id) ?  
     provider.quotes[currIndex].likes!.toInt()+1
  : provider.quotes[currIndex].likes != null ?  provider.quotes[currIndex].likes!.toInt() : 0;
    return  CustomLoader(
      isLoading: load,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            RepaintBoundary(
              key: previewContainer,
              child: GestureLeftRightTap(
                onLongPress: (){
                  isShow = false;
                  setState(() {  });
                },
                onLongPressCancel: (){
                  isShow = true;
                  setState(() {  });
                },
                onLeftTap: widget.blog != null  ? (){} : () {
                   if (currIndex != 0) {
                    currIndex--;
                    if(provider.quotes[currIndex].isUserViewed == 0){
                      provider.addviewData(provider.quotes[currIndex].id ?? 0);
                      provider.quotes[currIndex].isUserViewed = 1;
                    }
                    setState(() { });
                  }
              },
              onRightTap: widget.blog != null  ? (){} :() {
                 if (currIndex < provider.quotes.length-1) {
                    currIndex++;
                    if(provider.quotes[currIndex].isUserViewed == 0){
                      provider.addviewData(provider.quotes[currIndex].id ?? 0);
                      provider.quotes[currIndex].isUserViewed = 1;
                    }
                    setState(() { });
                  }
              },
                child: Container(
                  foregroundDecoration:const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops:  [0.1,0.25,1],
                      colors: [
                      Colors.black,
                      Colors.transparent,
                      Colors.black,
                    ])
                  ),
                  child: AspectRatio(
                    aspectRatio: 9/17,
                    child: CachedNetworkImage(imageUrl:widget.blog != null  ? widget.blog!.backgroundImage.toString() 
                       :provider.quotes[currIndex].backgroundImage.toString(),
                     fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
              ),
            ),
            widget.blog == null  ? const SizedBox()
             : const Positioned(
                left: 16,
                top: kToolbarHeight,
               child: BackbUT()
             ),
            widget.blog != null  ? const SizedBox() :Positioned(
              top: 16,
              left: 10,
              right: 10,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [

                    if(isShow == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal:8.0),
                      child: LineIndicator(
                        key: ValueKey(currIndex),
                        currIndex: currIndex,
                        onChanged : (val){
                          if (currIndex < provider.quotes.length-1) {
                             currIndex = val;
                            setState(() {  });
                          } else {
                            Navigator.pop(context);
                          }
                          setState(() { });
                        },
                        length: provider.quotes.length
                      ),
                    ),
                    const SizedBox(height:16),
                      IconButton(
                        padding: const EdgeInsets.all(8),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close_rounded,color:Colors.white, size : 28))
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(context).size.height*0.050,
              width: MediaQuery.of(context).size.width,
              child: SafeArea(
                child: SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20 ,right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.quotes[currIndex].title ?? "",
                                 style: FontStyleUtilities.t1(context).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 24),
                              const Row(
                                children: [
                                  
                                  TheLogo()
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            BlurWidget(
                            child:AnimIcon(
                                 key: ValueKey(provider.permanentlikesIds.contains(provider.quotes[currIndex].id) || provider.quotes[currIndex].isUserLiked == 1),
                                  initialValue: provider.permanentlikesIds.contains(provider.quotes[currIndex].id) || provider.quotes[currIndex].isUserLiked == 1,
                                  // color: ColorUtil.themNeutral,
                                  height: 20.h,
                                  isChange: currentUser.value.id != null,
                                  width: 20.h,
                                  //deactivateColor: Colors.white,
                                  activeIcon: 'asset/Icons/heart.svg',
                                  deactivateIcon: 'asset/Icons/heart-icon.svg',
                                  onChanged: (value) {
                                    provider.setlike(blog: provider.quotes[currIndex]);
                                    setState(() { });
                                }),
                              ),
                              const SizedBox(height: 4),
                              Text(countLikes.toString(),
                              style: FontStyleUtilities.t1(context, fontColor: Colors.white)
                              ),
                              const SizedBox(height: 12),
                             InkResponse(
                              onTap: () async{
                                setState(() {
                                  load = true;
                                });
                                 Future.delayed(const Duration(milliseconds: 10));
                                final  data = await captureScreenshot(previewContainer);
                                Future.delayed(const Duration(milliseconds: 10));
                                final  data2 = await convertToXFile(data!);
                                Future.delayed(const Duration(milliseconds: 10));
                                provider.addShareData(null,provider.quotes[currIndex].id!.toInt());
                            
                                shareImage(data2,provider.quotes[currIndex].id.toString());
                                setState(() {
                                  load = false;
                                });
                              },
                              child: const BlurWidget(
                                child:SvgIcon('asset/Icons/share.svg',
                                color: Colors.white 
                              )),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
            )
          ],
        ),
      ),
    );
  }
}

class LineIndicator extends StatefulWidget {
  const LineIndicator({ 
    super.key,
    required this.currIndex,
    this.length=0,
    required this.onChanged,
  });

  final int currIndex,length;
  final ValueChanged onChanged;

  @override
  State<LineIndicator> createState() => _LineIndicatorState();
}

class _LineIndicatorState extends State<LineIndicator> with SingleTickerProviderStateMixin {

  late AnimationController controller;
  Timer? timer;

  @override
  void initState() {

    controller = AnimationController(vsync: this,
     duration: const Duration(seconds: 10),
     lowerBound: 0.0, 
     upperBound: 1.0
    );
    timer= Timer(const Duration(seconds: 10), (){
      
    });
    controller.forward();
    controller.addListener((){
        if (controller.isCompleted) {
          widget.onChanged(widget.currIndex+1);
        }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, snapshot) {
          return Row(
            children: [
               ...List.generate(widget.length, (index) =>
                 index >= widget.currIndex 
                ? Expanded(
                key: ValueKey(index),
                child: Padding(
                  padding:  EdgeInsets.only(right: index != widget.length-1 ? 2.0 : 0),
                  child: LinearProgressIndicator(
                    value: controller.value,
                    color: Colors.black26,
                    backgroundColor: Colors.white38,
                    valueColor: AlwaysStoppedAnimation( index == widget.currIndex  ? Colors.white :  Colors.transparent),
                    borderRadius: BorderRadius.circular(100)
                   ),
                )):Expanded(
                key: ValueKey(index),
                child: Padding(
                  padding:  EdgeInsets.only(right: index != widget.length-1 ? 2.0 : 0),
                  child: LinearProgressIndicator(
                    value: 1.0,
                    color:  Colors.black26,
                    backgroundColor: Colors.white38,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    borderRadius: BorderRadius.circular(100)
                   ),
                )))
            ],
          );
        }
      ),
    );
  }
}



class BlurWidget extends StatelessWidget {
  const BlurWidget({super.key,this.blur,required this.child,this.padding, this.radius,this.width, this.height});
  final double? radius, width, height;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? blur;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ??  40,
      height: height ?? 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 100),
        color: Colors.black.withOpacity(0.2),
        border: Border.all(width: 0.5,color: Colors.white.withOpacity(0.2)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: -2,
            color: Color.fromRGBO(0, 0, 0, 0.08)
          )
        ]
      ),
      child:  ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 100),
        child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10,sigmaY:10),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(10.0),
          child: child,
        )
      )));
  }
}