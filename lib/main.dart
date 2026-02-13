import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/shared/providers/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: getRoute,
      theme: ThemeData(
        fontFamily: "MapleFont"
      ),
    );
  }
}
