import 'package:blogit/presentation/widgets/nav_util.dart';
import 'package:flutter/cupertino.dart';

class NavigationUtil {
  static Future<void> to(BuildContext context, Widget child) async {
    Navigator.push(context, PagingTransform(widget: child));
  }

  static void dissolveTo(BuildContext context, Widget child) {
    Navigator.push(
        context,
        PagingTransform(widget: child));
  }
}

class MyDissolvingRoute extends PageRouteBuilder {
  final RoutePageBuilder myPageBuilder;

  MyDissolvingRoute(this.myPageBuilder)
      : super(
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: myPageBuilder,
          opaque: true,
        );
}
