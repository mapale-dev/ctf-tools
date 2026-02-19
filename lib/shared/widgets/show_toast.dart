import 'package:flutter/material.dart';

/// 显示提示弹窗（Toast）
void showToast(String message, BuildContext context) {

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: const Color(0xFF2B5EC9),
      duration: const Duration(seconds: 2),
    ),
  );
}