import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = AppTheme.lightTheme;

  ThemeData get themeData => _themeData;

  // 나중에 다크 모드 등을 추가할 수 있음
  void setLightTheme() {
    _themeData = AppTheme.lightTheme;
    notifyListeners();
  }
} 