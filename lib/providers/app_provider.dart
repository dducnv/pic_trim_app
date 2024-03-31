import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:pic_trim_app/core/local_pref.dart';
import 'package:pic_trim_app/main.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  bool _isShowOptionRoundedCorner = false;
  bool get isShowOptionRoundedCorner => _isShowOptionRoundedCorner;


  int _tabEditIndex = 0;
  int get tabEditIndex => _tabEditIndex;

  String _addressSaveImage = '';
  String get addressSaveImage => _addressSaveImage;

  bool _saveImageSuccess = false;
  bool get saveImageSuccess => _saveImageSuccess;

  bool _loadSaveImage = false;
  bool get loadSaveImage => _loadSaveImage;

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
    Directory path = Directory("/storage/emulated/0/Pictures/PicTrim");
    if (!path.existsSync()) {
      path.createSync();
    }
    final value = await PrefHelper().readString(PrefKeys.addressSaveImage);
    if (value == null) {
      _addressSaveImage = '';

      if (Platform.isAndroid) {
        _addressSaveImage = path.path;
      }
      if (Platform.isIOS) {
    
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
    _loadSaveImage = false;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 2500), () {
      _saveImageSuccess = false;
      notifyListeners();
    });
  }

  void setTabEditIndex(int value) {
    _tabEditIndex = value;
    notifyListeners();
  }

  void changePage(int index) {
    _tabEditIndex = index;
    notifyListeners();
  }

  void setShowOptionRoundedCorner(bool value) {
    _isShowOptionRoundedCorner = value;
    notifyListeners();
  }

  void setLoadSaveImage(bool value) {
    _loadSaveImage = value;
    notifyListeners();
  }


}
