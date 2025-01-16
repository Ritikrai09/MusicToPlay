import 'package:flutter/material.dart';


 ///THIS IS WRAPPER AROUND THE INDEXED_STACK IN GENERAL THE 
 ///INDEXED_STACK BUILDS CHILDREN ALL AT ONCE WHILE THIS WORK AS LAZY 
 ///WHENEVER THEY ARE REQUESTED BUILDS ONCE AND THEN THE LOCAL PAGE 
 ///MAINTAINS STATE AT IT'S OWN LOCALLY...
 
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  _LazyIndexedStackState createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  late Map<int, bool> _innerWidgetMap;

  int index = 0;

  @override
  void initState() {
    super.initState();
    index = widget.index;
    _innerWidgetMap = Map<int, bool>.fromEntries(
      List<MapEntry<int, bool>>.generate(
        widget.children.length,
        (int i) => MapEntry<int, bool>(i, i == index),
      ),
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _changeIndex(widget.index);
    }
  }

  void _activeCurrentIndex(int index) {
    if (_innerWidgetMap[index] != true) {
      _innerWidgetMap[index] = true;
    }
  }

  void _changeIndex(int value) {
    if (value == index) {
      return;
    }
    setState(() {
      index = value;
    });
  }

  bool _hasInit(int index) {
    final bool? result = _innerWidgetMap[index];
    if (result == null) {
      return false;
    }
    return result == true;
  }

  List<Widget> _buildChildren(BuildContext context) {
    final List<Widget> list = <Widget>[];
    for (int i = 0; i < widget.children.length; i++) {
      if (_hasInit(i)) {
        list.add(widget.children[i]);
      } else {
        list.add(const SizedBox.shrink());
      }
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    _activeCurrentIndex(index);
    return IndexedStack(
      index: index,
      children: _buildChildren(context),
    );
  }
}
