import 'dart:ui';
import 'package:flutter/material.dart';
import '../../Utils/color_util.dart';

class CustomLoader extends StatefulWidget {
  const CustomLoader({super.key,this.color,this.opacity,this.isLoading=false,required this.child});
  final Color? color;
  final Widget child;
  final double? opacity;
  final bool isLoading;

  @override
  // ignore: library_private_types_in_public_api
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>{


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
       widget.child,
       widget.isLoading==false ? const SizedBox() :  Stack(children: <Widget>[
                Opacity(
                  opacity: widget.opacity ?? 0.6,
                  child: ModalBarrier(
                    dismissible: false,
                    color: dark(context) ? widget.color ?? Colors.grey.shade800 : Colors.black87,
                  ),
                ),
               const Center(child: MotionLogo(),
            ),
          ],
        ),
      ],
    );
  }
}

class MotionLogo extends StatefulWidget {
  const MotionLogo({
    super.key,
    this.decochild,
  }) ;  
 final Widget? decochild;

  @override
  State<MotionLogo> createState() => _MotionLogoState();
}

class _MotionLogoState extends State<MotionLogo>  with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _animation2;
  @override
  void initState() {
    super.initState();

    // Configure the animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Configure the animation
    _animation = Tween<double>(begin:widget.decochild != null  ? 0.5 : 0.0, end: 1.0).animate(_animationController);
     _animation2 = Tween<double>(begin:widget.decochild != null  ? 0.94 : 0.85, end: 1.0).animate(_animationController);
  }

   @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
     animation: _animation,
     builder: (context, child) {
       return ScaleTransition(   
         scale: _animation2,
         child: Container(
           width: widget.decochild != null  ? 50: 80,
           height: widget.decochild != null  ? 50:80, 
           decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
             borderRadius: BorderRadius.circular(widget.decochild != null ? 100 :40.0),
             border: Border.all(
               color: Theme.of(context).cardColor,
               width: lerpDouble(2.0, 4.0, _animation.value)!,
             ),
           ),
           child: Center(
             child:Container(
           width:widget.decochild != null  ? 50: 60,
           height: widget.decochild != null  ? 50:60,
           decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.decochild != null  ? 0 :00.0),
            // border: Border.all(
             //  color: Theme.of(context).cardColor,
             //  width: lerpDouble(1.0, 2.0, _animation.value)!,
           //  ),
             image:const DecorationImage(image: AssetImage('asset/Images/Logo/splash_logo.png'))
           ),
           child: widget.decochild,
           )
           ),
         ),
       );
     },
    );
  }
}
