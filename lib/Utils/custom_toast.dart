 // ignore_for_file: library_private_types_in_public_api

 import 'dart:io';

import 'package:blogit/main.dart';
import 'package:flutter/material.dart';
import 'package:blogit/Utils/color_util.dart';

import 'anim_util.dart';

void showCustomToast(BuildContext context, String message,{String? title,bool isTop=true,Color? backColor,bool isPending=false,String? text,isBig=false,VoidCallback? onTap,bool isSuccess = true,islogo = true}) {
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: isTop==false ? null : kToolbarHeight,
        bottom: isTop==false ? kToolbarHeight : null,
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: CustomToast(
          message: message,
          isBig:isBig,
          buttonText: text,
          backColor:backColor,
          onPressed: onTap,
          isPending: isPending,
          isLogo: islogo,
          title:title,
          isSuccess :isSuccess,
          onDismiss: () {
            overlayEntry!.remove();
          },
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }



class CustomToast extends StatefulWidget {
  final String message;
  final String? buttonText,title;
  final VoidCallback onDismiss;
  final Color? backColor;
  final bool isSuccess,isPending;
  final VoidCallback? onPressed;
  final bool isLogo,isBig;

  const CustomToast({super.key,
  required this.message,
  this.buttonText,
  this.backColor,
  this.onPressed,
  this.isLogo=true,
  this.isBig=false,
  this.isPending=false,
  required this.onDismiss,  
  this.title,
  this.isSuccess=false
  });

  @override
  State<CustomToast> createState() => _CustomToastState();
}

class _CustomToastState extends State<CustomToast> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      lowerBound: 0.8,
      upperBound: 1.0
    );
    _animation = CurvedAnimation(parent: _animationController, curve: const Cubic(0.2, 0.6, 0.1, 1));
    _animationController.forward();
    _animationController.addStatusListener((status) {
      statusListen(status);
    });
  }

  void statusListen(AnimationStatus status) {
    if (mounted) {
      if (status == AnimationStatus.completed) {
      Future.delayed( Duration(seconds: widget.isBig ? 2 : 2)).whenComplete(() {
          if (mounted) {
            _animationController.reverse().whenComplete(() {
          widget.onDismiss.call();
         });
          }
      });
    }
    }
  }

  @override
  void dispose() {
    _animationController.removeStatusListener(statusListen);
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  AnimationFadeSlide(
        dy: -0.6,
        dx: 0,
        duration: 200,
        child: AnimationFadeScale(
        duration: 300,
        child:AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
         opacity:  _animation.value,
         curve: const Cubic(0.2, 0.6, 0.1, 1),
          //  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
          //  decoration: BoxDecoration(
          //   borderRadius: BorderRadius.circular(0)
          //  ),
          child: Container(
            width: widget.title!=null ? MediaQuery.of(context).size.width :null,
            alignment: Alignment.topCenter,
            padding:  EdgeInsets.symmetric(horizontal: widget.title == null? 0 : 16),
            child: GestureDetector(
              onTap: () {
                _animationController.reverse().then((value) {
                  widget.onDismiss.call();
                });
              },
              child: Material(
                borderRadius:  BorderRadius.circular(widget.isBig ? 8 :100),
                elevation: 16.0,
                color: widget.isBig == true ? widget.backColor ?? Colors.yellow.shade800 : Theme.of(context).cardColor,
                shadowColor: !dark(context) ? Colors.grey.withOpacity(0.5) : Colors.black.withOpacity(0.7),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment:  widget.title != null ?  MainAxisAlignment.start : MainAxisAlignment.center,
                    mainAxisSize: widget.title == null ?  MainAxisSize.min : MainAxisSize.max,
                    children: [
                       const SizedBox(width: 12),
                       if (widget.isLogo == true) Image.file(File(prefs!.getString('app_logo').toString()),width: 20,height: 20)
                        else AnimationFadeScale(
                        // color: widget.isSuccess ? Colors.green : Colors.red,
                        child: widget.isPending ? const Icon(
                          Icons.info_outline_rounded,
                          color: Colors.white) :
                           Container(
                           padding: const EdgeInsets.all(2.5),
                           decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 1.25,color: Colors.white)
                           ),
                           child: widget.isSuccess ?
                           const Icon(Icons.done, 
                              size: 14.0,
                              color: Colors.white,)
                          : const Icon(
                          Icons.close_rounded,
                          size: 20.0,
                          color: Colors.white,
                        ),
                        )
                      ),
                     const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        widget.title==null  ? const SizedBox() : Text(
                            widget.title ?? 'Comment under Processing',
                            style:  TextStyle(fontSize: 15.0,
                            fontFamily: 'QuickSand',
                            color: widget.isBig ? Colors.white : dark(context) ? ColorUtil.white : Colors.black,
                            fontWeight: FontWeight.w700),
                          ),
                         widget.message==''  ? const SizedBox() :   Text(
                            widget.message,
                            style:  TextStyle(fontSize: 11.0,
                            fontFamily: 'QuickSand',
                            color:widget.isBig ?  Colors.white :  dark(context) ? ColorUtil.white : Colors.black,
                            fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      widget.buttonText == null ?  const SizedBox() :  const Spacer(),
                    widget.buttonText == null ?  const SizedBox() :
                     Expanded(
                       child: InkWell(onTap: () {
                         widget.onPressed!.call();
                         widget.onDismiss.call();
                       } , child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                          child: Text(widget.buttonText ?? '',
                          style: const TextStyle(
                            fontSize: 13.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'QuickSand'),),
                        )),
                     ),   const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}