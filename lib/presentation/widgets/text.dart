import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_iframe/flutter_html_iframe.dart';

import '../../Utils/color_util.dart';
import '../../controller/user_controller.dart';
import '../../model/blog.dart';
import '../screens/web_view.dart';


class Description extends StatelessWidget {
  const Description({
    super.key,
    required this.model,
    this.maxlines,
    this.color,
    this.bodyMaxLines,
    this.optionLength=0,
    this.isPoll=false,
    this.isVideoIncluded=false
  });

  final Blog? model;
  final Color? color;
  final int? optionLength,maxlines,bodyMaxLines;
  final bool isPoll;
  final bool isVideoIncluded;

//   String convertHtmlToPlainText(String htmlText) {
//   final tempElement = html.Element.html(htmlText);
//   return tempElement.innerText;
// }

  @override
  Widget build(BuildContext context) {

    var htmlPaddings = HtmlPaddings.zero;
    var des = model!.description!.length > 300 ? model!.description.toString().substring(0,300) : model!.description!;
    return    Html(
                data: des,
                anchorKey: GlobalKey(),
                style: {
                  "body": Style(
                    margin: Margins(left: Margin(0),right: Margin(0),
                    blockStart:Margin(0) ,
                     blockEnd:Margin(0) ,
                    top: Margin(0),bottom: Margin(0)),
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                     maxLines: bodyMaxLines,
                     color: dark(context) ? color ?? ColorUtil.white : color ?? Colors.grey,
                    lineHeight: const LineHeight(1.4),
                    fontWeight: FontWeight.w500,
                    textOverflow: bodyMaxLines == 4 ? TextOverflow.ellipsis : TextOverflow.visible,
                    padding: htmlPaddings
                  ),
                  "p": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                     margin: Margins(left: Margin(0),right: Margin(0),
                        blockStart:Margin(0) ,
                     blockEnd:Margin(0) ,
                    top: Margin(0),bottom: Margin(0)),
                    fontFamily: 'QuickSand',
                     color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.themNeutral,
                       padding: htmlPaddings,
                      lineHeight: const LineHeight(1.4),
                      fontWeight: FontWeight.w500, 
                      maxLines : bodyMaxLines ==4 && model!.description.toString().length > 300 ? 4 : null ,
                    ),
                  "strong":Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                    margin: Margins.zero,
                    fontWeight: FontWeight.w700,
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.themNeutral,
                      lineHeight: const LineHeight(1.4),
                       padding: htmlPaddings
                  ),
                  "b": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                    margin: Margins.zero,
                    fontWeight: FontWeight.w700,
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.themNeutral,
                      lineHeight: const LineHeight(1.4),
                       padding: htmlPaddings
                  ),
                   "i": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                    margin: Margins.zero,
                    fontStyle: FontStyle.italic,
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.themNeutral,
                       lineHeight: const LineHeight(1.4),
                       fontWeight: FontWeight.w600,
                       padding: htmlPaddings
                  ),
                   "a": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                    margin: Margins.zero,
                   lineHeight: const LineHeight(1.4),
                   fontWeight: FontWeight.w600,
                   textDecoration: TextDecoration.underline,
                    color: ColorUtil.primaryColor,
                  ),
                  "li": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.themNeutral,
                    lineHeight: const LineHeight(1.4),
                     maxLines: maxlines,
                     margin: Margins.zero,
                    fontWeight: FontWeight.w600,
                    padding: HtmlPaddings(
                      left: HtmlPadding(bodyMaxLines == 5 ? 8 :12),
                      right: HtmlPadding(bodyMaxLines == 5 ? 8 :12),
                    )
                  ),
                  "ul": Style(
                    fontSize:  FontSize(defaultFontSize.value),
                    fontFamily: 'QuickSand',
                    color: dark(context) ? color ?? ColorUtil.white : color ?? ColorUtil.themNeutral,
                    lineHeight: const LineHeight(1.4),
                   maxLines:  maxlines,
                    fontWeight: FontWeight.w600,
                    padding: HtmlPaddings(
                      left: HtmlPadding(12),
                      right: HtmlPadding(12),
                    ),
                    margin: Margins.zero,
                  ),
                },
                extensions:isVideoIncluded == false ? [

                ]: [
                 const IframeHtmlExtension(),
                ],
                onLinkTap: (url, context1, element) {
                 Navigator.push(context, CupertinoPageRoute(builder:
                  (context) => CustomWebView(url: url.toString())));
                },
              ); 
}
}
