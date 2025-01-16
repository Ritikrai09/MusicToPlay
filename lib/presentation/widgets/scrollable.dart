import 'dart:math';

import 'package:blogit/main.dart';
import 'package:blogit/model/comment.dart';
import 'package:flutter/material.dart';
import 'package:blogit/controller/user_controller.dart';

import '../../Utils/color_util.dart';

// Future myBottomSheet(BuildContext context,
// List<SubCategory> subcategories,
//  {
// Key? key,
// String? title,
// int? subId,
// // ValueChanged<SubCategory>? onChanged,
// AppProvider? appProvider,
// VoidCallback? onTap
// })async {
//       BottomSheetWidget.bottom(
//         context,
//       ListScrollView(
//         subId:subId,
//         subcategories:subcategories,
//         onChanged :onChanged,
//         title: title,
//         onTap: onTap,
//         appProvider : appProvider,
//       ),
//         maxChild: 0.9,
//         initialSize: 0.9
//    ,isScrollable: true,onTap: onTap);
// }

class BottomSheetWidget {
  static Widget makeDismissible(
      {required Widget child, required BuildContext context}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: GestureDetector(
        onTap: () {},
        child: child,
      ),
    );
  }

  static Future<bool?> bottom(BuildContext context, Widget child,
      {double maxChild = 1,
      double initialSize = 0.75,
      String? title,
      VoidCallback? onSelect,
      int? blogid,
      bool isComment = false,
      ValueChanged<Comment>? onCommentAdd,
      VoidCallback? onTap,
      String? key,
      isScrollable = false}) async {
    return await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12), topRight: Radius.circular(12))),
        builder: (_) {
          // outFocus(context);

          var textcontroller = TextEditingController();
          return makeDismissible(
              child: DraggableScrollableSheet(
                  key: ValueKey(key),
                  initialChildSize: initialSize,
                  maxChildSize: maxChild,
                  minChildSize: 0.3,
                  builder: (context, controller) {
                    var size = MediaQuery.of(context).size;

                    var outlineInputBorder = OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            width: 1,
                            color: dark(context)
                                ? Colors.grey.shade700
                                : Colors.grey.shade300));
                    return ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16)),
                      child: isScrollable
                          ? Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Divider(
                                      endIndent: size.width / 2.2,
                                      indent: size.width / 2.2,
                                      thickness: 4,
                                    ),
                                  ),
                                  isComment
                                      ? const SizedBox(height: 8)
                                      : const SizedBox(),
                                  //  SizedBox(height: 24,),
                                  Expanded(
                                    child:
                                        // ListWheelScrollView(
                                        //   onSelectedItemChanged: (value) {

                                        //   },
                                        // //  dragStartBehavior: DragStartBehavior.down,
                                        // //  scrollDirection: Scroll,
                                        // useMagnifier: true,
                                        // itemExtent: 62,
                                        // physics: FixedExtentScrollPhysics(),
                                        //  controller: controller,
                                        title == null
                                            ? child
                                            : SingleChildScrollView(
                                          
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                      onTap: onTap ?? () {},
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 12),
                                                          child: Text(title,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: isComment
                                                                  ? const TextStyle(
                                                                      fontSize:
                                                                          18,
                                                                      fontFamily:
                                                                          'QuickSand',
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500)
                                                                  : null)),
                                                    ),
                                                    child
                                                  ],
                                                ),
                                              ),
                                  ),
                                  isComment
                                      ? Container(
                                          width: size.width,
                                          margin: EdgeInsets.only(
                                              bottom: MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom),
                                          height: 80,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16,top: 12),
                                                  child: SizedBox(
                                                    height: 50,
                                                    child: TextFormField(
                                                      controller:
                                                          textcontroller,
                                                      onTapOutside: ((event) {
                                                        FocusScope.of(context).unfocus();
                                                      }),
                                                      maxLines: 4,
                                                      // onFieldSubmitted:
                                                      //     (value) async {
                                                      //    await commentDone(textcontroller, blogid, onCommentAdd);
                                                      // },
                                                      decoration: InputDecoration(
                                                          filled: true,
                                                          contentPadding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
                                                          hintText: allMessages.value.writeYourComment ?? 'Write your comment ....',
                                                          enabledBorder: outlineInputBorder,
                                                          hintStyle: const TextStyle(
                                                                  fontFamily:'QuickSand',
                                                                  fontSize: 14
                                                                ),
                                                          focusedBorder:outlineInputBorder.copyWith(
                                                          borderSide: BorderSide(color: Theme.of(context).primaryColor))),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkResponse(
                                                onTap: () async {
                                                  await commentDone(textcontroller, blogid, onCommentAdd);
                                                },
                                                child: const Padding(
                                                  padding:
                                                      EdgeInsets.only(
                                                          top: 12.0),
                                                  child: SizedBox(
                                                      height: 50,
                                                      width: 45,
                                                      child: Center(
                                                          child: Icon(
                                                              Icons.send))),
                                                ),
                                              ),
                                              const SizedBox(width: 8)
                                            ],
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            )
                          : child,
                    );
                  }),
              context: context);
        });
  }

  static Future<void> commentDone(TextEditingController textcontroller, int? blogid, ValueChanged<Comment>? onCommentAdd) async {
    if (textcontroller.text.isNotEmpty) {
      // Navigator.pop(context);
     
      var comment = Comment(
        userId: int.parse(currentUser.value.id ?? '0'),
        blogId: blogid,
        id: Random().nextInt(99999),
        user: CommentUser(
          name: currentUser.value.name,
          photo: currentUser.value.photo,
          id:  int.parse(currentUser.value.id.toString()),
        ),
        comment: textcontroller.text,
        createdAt: DateTime.now()
      );
      onCommentAdd!(comment);
       Navigator.pop(navkey.currentState!.context);
        // await setComment(textcontroller.text,blogid ?? 0);
       textcontroller.clear();
    }
  }
}
