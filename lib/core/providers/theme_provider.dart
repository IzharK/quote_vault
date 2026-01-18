import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _colorKey = 'theme_color';
  static const String _modeKey = 'theme_mode';
  static const String _scaleKey = 'text_scale';
  late SharedPreferences _prefs;

  // Default values
  Color _primaryColor = const Color(0xFF2B4BEE);
  ThemeMode _themeMode = ThemeMode.system;
  double _textScaleFactor = 1.0;

  Color get primaryColor => _primaryColor;
  ThemeMode get themeMode => _themeMode;
  double get textScaleFactor => _textScaleFactor;

  ThemeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    // Load Color
    final colorValue = _prefs.getInt(_colorKey);
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
    }

    // Load Mode
    final modeString = _prefs.getString(_modeKey);
    if (modeString != null) {
      if (modeString == 'light') {
        _themeMode = ThemeMode.light;
      } else if (modeString == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    }

    // Load Text Scale
    final scale = _prefs.getDouble(_scaleKey);
    if (scale != null) {
      _textScaleFactor = scale;
    }

    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    notifyListeners();
    await _prefs.setInt(_colorKey, color.value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    String modeStr = 'system';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.dark) modeStr = 'dark';
    await _prefs.setString(_modeKey, modeStr);
  }

  Future<void> setTextScale(double scale) async {
    _textScaleFactor = scale;
    notifyListeners();
    await _prefs.setDouble(_scaleKey, scale);
  }
}
