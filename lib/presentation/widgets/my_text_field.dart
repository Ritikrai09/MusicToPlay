
import 'package:flutter/material.dart';
import 'package:blogit/Utils/utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class MyTextField extends StatelessWidget {
  final String hint;

  final double? maxHeight;
  final int? maxLines;
  final Color? fillColor;
   final FocusNode? focus;
  final bool readOnly,isObscure,autoFocus;
  final void Function(String?)? onSaved;
  final String? Function(String?)?  onValidate;
  final  Function(String)? onFieldSubmit;
  final Function(String)? onChanged;
  final Widget? suffix,prefix;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final bool isCommentBox;
  final VoidCallback? onTap, onTapOutRead;
  final AutovalidateMode autovalidateMode;

  const MyTextField({
    super.key,
    this.onFieldSubmit,
    this.onTap,
    this.textInputAction,
    this.onChanged,
    this.isCommentBox=false,
    this.onTapOutRead,
    this.onValidate,
    this.prefix,
    this.suffix,
    this.autoFocus=false,
    this.focus,
    this.controller,
    this.autovalidateMode = AutovalidateMode.disabled,
    required this.hint,
    this.contentPadding,
    this.isObscure=false,
    this.maxHeight,
    this.onSaved,
    this.maxLines = 1,
    this.readOnly=false,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), borderSide: BorderSide(strokeAlign: 1,
        color: dark(context) ?  fillColor ??  Colors.grey.shade800 : fillColor ?? Theme.of(context).primaryColor.withOpacity(0.2),));
         OutlineInputBorder border2 = OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), borderSide: BorderSide(width: 1,color: Theme.of(context).primaryColor));
    return SizedBox(
       height : null,
      child: TextFormField(
        controller :controller,
          maxLines: maxLines,
          focusNode: focus,
          style: FontStyleUtilities.t1(context, fontColor: dark(context) ? Colors.white : Colors.black,fontWeight: FWT.medium),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmit,
           validator: onValidate,
           obscureText: isObscure,
           autofocus: autoFocus,
           readOnly:readOnly,
          //  autovalidateMode: autovalidateMode,
           onSaved: onSaved,
           onTapOutside: ((event) {
              FocusScope.of(context).unfocus();
               if(onTapOutRead != null){
                onTapOutRead!.call();
               }
            }),
            onTap: onTap,
            textInputAction: textInputAction,
            decoration: InputDecoration(
              fillColor: dark(context) ?  fillColor ??  Colors.grey.shade800 : fillColor ?? Theme.of(context).primaryColor.withOpacity(0.1),
              filled: true,
              suffixIcon:suffix,
              contentPadding : contentPadding ?? const EdgeInsets.only(right: 10, top: 15, left: 15),
              hintText: hint,
              prefixIcon: prefix,
              hintStyle: FontStyleUtilities.t1(context, fontColor: dark(context) ? Colors.grey.shade500 : Colors.grey.shade600),
               constraints:  isCommentBox == true ? null : BoxConstraints(maxHeight: maxHeight ?? 80.h),
              border: border,
              enabledBorder: border,
              focusedBorder: border2)),
    );
  }
}
