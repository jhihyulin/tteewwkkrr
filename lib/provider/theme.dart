import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  static const Color dThemeColor = Colors.blueGrey;
  static const int dThemeMode = 0; // 0: System 1: Light 2: Dark
  Color _themeColor = dThemeColor;
  int _themeMode = dThemeMode;

  ThemeProvider() {
    dealData();
  }

  void dealData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? cookieThemeColor = prefs.getInt('themeColor');
    int? cookieThemeMode = prefs.getInt('themeMode');
    _themeColor = Color(cookieThemeColor ?? dThemeColor.value);
    _themeMode = cookieThemeMode ?? dThemeMode;
    notifyListeners();
  }

  Color get themeColor => _themeColor;

  Color get defaultThemeColor => dThemeColor;

  setThemeColor(Color themeColor) async {
    _themeColor = themeColor;
    setData('themeColor', themeColor.value);
    notifyListeners();
  }

  int get themeMode => _themeMode;

  int get defaultThemeMode => dThemeMode;

  setThemeMode(int themeMode) async {
    _themeMode = themeMode;
    setData('themeMode', themeMode);
    notifyListeners();
  }

  void setData(String key, dynamic value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.reload();
    prefs.setInt(key, value);
    if (kDebugMode) {
      print('Saved with: key: $key, value: $value');
    }
  }
}
