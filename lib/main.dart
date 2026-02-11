import 'package:ctf_tools/pages/home_screen.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      builder: (context, child) {
        // final themeProvider = context.watch<ThemeProvider>();
        return MaterialApp(
          title: 'CTF 工具箱',
          // theme: themeProvider.currentTheme,
          home: HomeScreen(),
        );
      },
    ),
  );
}