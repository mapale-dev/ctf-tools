import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class NavItem {
  final String name;
  final String route;
  final IconData icon;
  final Widget Function(BuildContext, GoRouterState) builder;
  final bool isContainerOnly;

  NavItem({
    required this.name,
    required this.route,
    required this.icon,
    required this.builder,
    this.isContainerOnly = false
  });
}
