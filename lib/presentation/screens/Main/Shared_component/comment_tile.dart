import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:blogit/presentation/screens/Auth/Login/login.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:blogit/Extensions/extension.dart';
import 'package:blogit/controller/repository.dart';
import 'package:blogit/controller/user_controller.dart';
import '../../../../Utils/app_theme.dart';
import '../../../../Utils/custom_toast.dart';
import '../../../../model/comment.dart';

// ignore: must_be_immutable
class CommentsTile extends StatefulWidget {
  
   CommentsTile({
    super.key,
    required this.comments,
    this.isPopup=false,
    this.showDivider = true,
    required this.onChanged,
  });


  final bool? showDivider,isPopup;
   Comment comments;
   final ValueChanged<Comment> onChanged;

  @override
  State<CommentsTile> createState() => _CommentsTileState();
}

class _CommentsTileState extends State<CommentsTile> {

late List<PopupMenuItem>? popupList;

  Timer? timer;
  late Comment data;
  
  
  @override
  void initState() {
     data = widget.comments;
    super.initState();
  }

    @override
    void dispose(){
   if (timer != null) {
      timer!.cancel();
   }
    super.dispose();
   }


  void exitDelete(BuildContext context,VoidCallback onTap) async {
    await showCustomDialog(context: context,
    title: "${allMessages.value.delete} ${allMessages.value.comment}",
    text: allMessages.value.deleteCommentConfirm ?? "Do you want to delete comment ?",
    onTap:onTap,
    isTwoButton: true
   );
  }

Row wraprow({String text='Delete',IconData icon=Icons.delete}) {
  var color2 = text=='Delete' ? Colors.red :appThemeModel.value.isDarkModeEnabled.value
                    ? Colors.white
                    : Colors.black;
  return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,color:  color2),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
               fontFamily: 'QuickSand',
               fontWeight: FontWeight.w500,
                color: color2,
                fontSize: 14),
          ),
        ],
      );
}

  @override
  Widget build(BuildContext context) {
   
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(widget.comments.user != null )
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).disabledColor,
            ),
            alignment: Alignment.center,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child : widget.comments.user!.photo != null ?
               CachedNetworkImage(imageUrl: widget.comments.user!.photo!.toString(),
              errorWidget: (context, url, error) { 
                var first2 = widget.comments.user!.name!.split(' ').first[0];
                var s =  widget.comments.user!.name!.split(' ').last.isNotEmpty ? first2+widget.comments.user!.name!.split(' ').last[0] 
                : first2;
                var text = widget.comments.user!.name!.contains(' ') ? s :  widget.comments.user!.name![0];
                return  Container(
                  color: ColorUtil.primaryColor,
                  child: Center(child:Text(text,style: const TextStyle(fontSize: 14,color: Colors.white)),
                   ),
                ); },
              ) : Text(
                 widget.comments.user!.name.toString().split(' ').length > 2 ? 
                 "${widget.comments.user!.name.toString().split(' ')[0][0]} ${widget.comments.user!.name.toString().split(' ')[1][0]}"
                 : widget.comments.user!.name.toString().split(' ')[0][0],
                textAlign: TextAlign.center,
                 style: const TextStyle(
                  fontFamily: 'QuickSand',
                  fontSize: 12,
                  fontWeight: FontWeight.w600
                 ),
               ),
            )
          ),
          SpaceUtils.ks16.width(),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                       widget.comments.user != null ? widget.comments.user!.name.toString() : "",
                        style:
                            FontStyleUtilities.h6(context, fontWeight: FWT.extrabold),
                      ),
                      SpaceUtils.ks2.height(),
                      Text(
                        "${widget.comments.createdAt!.day} ${getMonth(widget.comments.createdAt!.month)} ${widget.comments.createdAt!.year}",
                        style: FontStyleUtilities.t5(context,
                                fontWeight: FWT.semiBold,
                                fontColor: ColorUtil.themNeutral)
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  PopupMenuButton(
                    child:  Icon(
                      Icons.more_vert,
                      color: dark(context) ? Colors.white : Colors.black,
                    ),
                    itemBuilder: (context) {
                      return widget.comments.user!.id.toString() != currentUser.value.id.toString() ?
                        [
                          reportWidget(context)
                        ] :[
                          PopupMenuItem(
                              onTap: () async{
                                exitDelete(context, () async{
                                Navigator.pop(context);
                                if (currentUser.value.id != null) {
                                  
                                  // showCustomToast(context, '',
                                  //       title:  allMessages.value.undoComment ?? 'Undo your comment',
                                  //       isTop: false,
                                  //       isBig: true, isPending : true, islogo: false, 
                                  //       text: allMessages.value.undo ??'Undo',
                                  //       onTap: () {
                                  //           timer!.cancel(); 
                                  //           timer = null;
                                  //           widget.onChanged(data);
                                  //         if (mounted) {
                                  //           setState(() {});
                                  //         }
                                  //       }
                                  //     );
                                //  Future.delayed(const Duration(seconds: 500), () async{ 
                                  widget.onChanged(widget.comments);
                                    setState(() {});

                                  if(widget.isPopup == false){
                                    await deleteComment(widget.comments.id!.toInt()).then((value){
                                    if (value == false) {
                                        showCustomToast(context,
                                        allMessages.value.commentCannotDelete ?? 'Comment cannot be deleted. Please try again!!',
                                        title :  allMessages.value.somethingWentWrong ?? 'Something went wrong!!',
                                        isSuccess: false, islogo:false,isBig:true,backColor: Colors.red);
                                    } 
                                    
                                  }).whenComplete(() {  
                                      if(mounted) {
                                          timer!.cancel(); 
                                          timer = null;
                                          setState(() {});
                                      }
                                    });
                                  }
                                  // });
                                } else {
                                  NavigationUtil.to(context, const Login());
                                }
                              });
                              },
                            child: wraprow(),
                          ),
                          if(currentUser.value.id.toString() != widget.comments.user!.id!.toString())
                         reportWidget(context)
                        ];
                    },
                  ),
                ],
              ),
              
              SpaceUtils.ks10.height(),
              Text(
               widget.comments.comment.toString(),
                style: FontStyleUtilities.t2(context,
                        fontWeight: FWT.medium,
                        fontColor: ColorUtil.themNeutral)
                    .copyWith(height: 1.5),
              ),
              const SizedBox(
                height: 22,
              ),
              if (widget.showDivider!)
                const Divider(
                  height: 1,
                )
            ],
          ))
        ],
      ),
    );
  }

  PopupMenuItem<dynamic> reportWidget(BuildContext context) {
    return PopupMenuItem(
          onTap: () async{
            await commentReportWrap(context);
            },
          child: wraprow(text: allMessages.value.report ?? 'Report', icon:Icons.report)
        );
  }

  Future<void> commentReportWrap(BuildContext context) async {
      await reportComment(widget.comments.id!.toInt()).then((value) {
        if (value['success'] == false) {
          showCustomToast(context,
          allMessages.value.commentCannotReport ?? 'Comment cannot be reported. Please Try Again!!',
          title :allMessages.value.somethingWentWrong ?? 'Something went wrong!!',isSuccess: false, islogo:false,isBig:true,backColor: Colors.red);
      } else{
          showCustomToast(context, value['message'],
          title:  allMessages.value.commentReport ?? 'Comment Reported',
          isBig: true, isSuccess : true,islogo: false);
      }
    });
  }
}
