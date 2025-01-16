
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:blogit/Utils/color_util.dart';

import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;
import 'package:blogit/Utils/custom_toast.dart';
import 'package:blogit/controller/user_controller.dart';


class CustomWebView extends StatefulWidget {
  final String url;
  const CustomWebView({super.key, required this.url});
  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  String? host;
  List<PopupMenuItem>? popupList;

  @override
  void initState() {
    super.initState();
    final uri = Uri.parse(widget.url);
    host = uri.host;
    popupList = [
      // PopupMenuItem(
      //   child: Row(
      //     children: [
      //       GestureDetector(
      //         onTap: () {
      //           if (_webViewController != null) {
      //             _webViewController!.goBack();
      //           }
      //         },
      //         child: const Icon(
      //           Icons.arrow_back_ios,
      //           color: Colors.black,
      //           size: 20,
      //         ),
      //       ),
      //       const SizedBox(
      //         width: 20,
      //       ),
      //       GestureDetector(
      //         onTap: () {
      //           if (_webViewController != null) {
      //             _webViewController!.goForward();
      //           }
      //         },
      //         child: const Icon(
      //           Icons.arrow_forward_ios,
      //           color: Colors.black,
      //           size: 20,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      PopupMenuItem(
        child: GestureDetector(
          onTap: () {
          
            Clipboard.setData(
              ClipboardData(
                text: widget.url,
              ),
            );

           showCustomToast(context, allMessages.value.copiedToClipboard ?? 'Copied to Clipboard',isTop:false);
            Navigator.pop(context);
          },
          child:  Text(
        allMessages.value.copyLink  ?? 'Copy Link',
            style: const TextStyle(
             ///   color: Colors.black,
                fontSize: 16),
          ),
        ),
      ),
      PopupMenuItem(
        child: GestureDetector(
          onTap: () {
           custom.launchUrl(Uri.parse(widget.url));
          },
          child:  Text(
             allMessages.value.openBrowser  ??'Open in browser',
            style: const TextStyle(
               /// color: Colors.black,
                fontSize: 16),
          ),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value:  SystemUiOverlayStyle(
        statusBarIconBrightness: dark(context) ?
         Brightness.light : Brightness.dark,
        statusBarColor: Theme.of(context).primaryColor),
      // child: Dismissible(
        // key: UniqueKey(),
        // direction: DismissDirection.startToEnd,
        // onDismissed: (direction) {
        //   if (direction == DismissDirection.startToEnd) {
        //     // Handle left swipe
        //     Navigator.pop(context);
        //   }
        // },
        // behavior: HitTestBehavior.deferToChild,
        // // background: Container(
        // //   color: Colors.white,
        // // ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: AppBar(
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ),
          body:Column(
            children: [
              SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        host!,
                        style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600,
                        color: Colors.white),
                      ),
                      const Spacer(),
                      PopupMenuButton(
                        child: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        itemBuilder: (context) {
                          return popupList!.map((e) => e).toList();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: InAppWebView(
                  gestureRecognizers: {}..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer(  ))),
                  initialUrlRequest: URLRequest(
                    url: WebUri(widget.url),
                  ),
                  onReceivedServerTrustAuthRequest: (_, challenge) async {
                      return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                    },
                  initialSettings: InAppWebViewSettings(
                    verticalScrollBarEnabled: true,
                     
            // Enable overscroll for Android
                      scrollBarStyle:ScrollBarStyle.SCROLLBARS_OUTSIDE_OVERLAY ,
                      overScrollMode: OverScrollMode.NEVER,
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {
                  },
                ),
              ),
              /* Expanded(
                child: WebView(
                  initialUrl: widget.url,
                ),
              ),*/
            ],
          ),
        ),
      // ),
    );
  }
}
