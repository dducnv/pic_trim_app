import 'package:flutter/material.dart';

class PicEditProvider extends ChangeNotifier {
  double _aspectRatio = 0;

  double get aspectRatio => _aspectRatio ;

  void setAspectRatio(double value) {
    _aspectRatio = value;
    notifyListeners();
  }
}
