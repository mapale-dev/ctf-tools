import 'package:ctf_tools/shared/providers/theme/theme_color.dart';
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier{
  bool _isDark = false;
  int _colorIndex = 0;

  // 是否为暗色模式
  bool get isDark => _isDark;

  // 当前颜色
  Color get color => _isDark ? AppTheme.colors[_colorIndex].dark : AppTheme.colors[_colorIndex].light;

  // 当前颜色索引
  int get selectedColorIndex => _colorIndex;

  // 当前主题
  ThemeData get currentTheme => _isDark ? AppTheme.darkTheme(color) : AppTheme.lightTheme(color);

  // 切换主题
  void toggleTheme() {
    _isDark = !_isDark;
    notifyListeners();
  }

  // 根据颜色索引设置颜色
  void setColorIndex(int index) {
    _colorIndex = index;
    notifyListeners();
  }
}