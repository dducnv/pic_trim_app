import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pic_trim_app/core/local_pref.dart';
import 'package:pic_trim_app/main.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  String _addressSaveImage = '';
  String get addressSaveImage => _addressSaveImage;

  bool _saveImageSuccess = false;
  bool get saveImageSuccess => _saveImageSuccess;

  AppProvider() : _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleMode() async {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await PrefHelper()
        .saveBool(PrefKeys.isDarkMode, _themeMode == ThemeMode.dark);
    notifyListeners();
  }

  Future<void> setAddressSaveImage(String value) async {
    _addressSaveImage = value;
    await PrefHelper().saveString(PrefKeys.addressSaveImage, value);
    notifyListeners();
  }

  Future<void> initAddressSaveImage() async {
    final value = await PrefHelper().readString(PrefKeys.addressSaveImage);
    if (value == null) {
      _addressSaveImage = '';
      if (Platform.isAndroid) {
        _addressSaveImage = "/storage/emulated/0/Download";
      }
      if (Platform.isIOS) {
        Directory? documents = await getDownloadsDirectory();
        if (documents != null) {
          _addressSaveImage = documents.path;
        }
      }
      await PrefHelper()
          .saveString(PrefKeys.addressSaveImage, _addressSaveImage);
    } else {
      _addressSaveImage = value;
    }
    notifyListeners();
  }


  Future<void> setSaveImageSuccess(bool value) async {
    _saveImageSuccess = value;
    Future.delayed(const Duration(seconds: 3), () {
      _saveImageSuccess = false;
      notifyListeners();
    });
    notifyListeners();
  }
}
