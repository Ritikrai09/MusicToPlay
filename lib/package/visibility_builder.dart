import 'package:flutter/material.dart';

typedef VisibilityBuilder = Widget Function(BuildContext, Widget);

///THIS PACKAGE WORKS ON THE BASIS OF THE VIEWPORT BASICALLY IT WORKS LIKE
///DEVICE ORIENTATION CHANGE AND IT NOTIFY THE LISTENERS.AND IN THIS CASE THE
///SYSTEM KEY BOARD ALSO WORKS LIKE CONTRACTING THE DEVICE SIZE AND SO IT'S
///NOTIFIED...
class KeyboardVisibilityBuilder extends StatefulWidget {
  final Widget? child;
  final Widget Function(
    BuildContext context,
    Widget? child,
    bool isKeyboardVisible,
  ) builder;

  const KeyboardVisibilityBuilder({
    super.key,
    this.child,
    required this.builder,
  });

  @override
  _KeyboardVisibilityBuilderState createState() =>
      _KeyboardVisibilityBuilderState();
}

class _KeyboardVisibilityBuilderState extends State<KeyboardVisibilityBuilder>
    with WidgetsBindingObserver {
  bool _isKeyboardVisible =
      WidgetsBinding.instance.window.viewInsets.bottom > 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  ///THIS METHOD ALSO WORKS LIKE THE OTHER COMMON AND BASE METHOD LIKE INIT_STATE
  ///AND DID_CHANGE_DEPENDENCY WORKS IN CERTAIN CONDITION ...
  ///THIS METHOD IS CALLED WHEN THE VIEW_INSETS OF THE VIEW_PORT CHANGES...
  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    bool newValue = bottomInset > 0.0;
    if (newValue != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.builder(
        context,
        widget.child,
        _isKeyboardVisible,
      );
}
