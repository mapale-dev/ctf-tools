import 'package:ctf_tools/shared/widgets/sidebar.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget{
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Sidebar(),
          Expanded(child: child)
        ],
      ),
    );
  }
}