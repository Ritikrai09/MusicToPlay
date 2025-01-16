/// flutter:
///   fonts:
///    - family:  SignalIcons
///      fonts:
///       - asset: fonts/MyFlutterApp.ttf
///
///
///
library;
import 'package:flutter/widgets.dart';

class SignalIcons {
  SignalIcons._();

  static const _kFontFam = 'Signal_Icons';
  static const String? _kFontPkg = null;
  static const IconData feed =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData video =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData home = IconData(0xe802, fontFamily: _kFontFam,fontPackage: _kFontPkg);
  static const IconData author =
      IconData(0xe802, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData categories =
      IconData(0xe803, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData settings =
      IconData(0xe804, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
