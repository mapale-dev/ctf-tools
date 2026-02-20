import 'package:ctf_tools/core/route/app_routes.dart';
import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  String? expandedMenu;
  String? _version;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionString = '${packageInfo.version}+${packageInfo.buildNumber}';
      if (mounted) {
        setState(() {
          _version = versionString;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = 'Unknown';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    // 自动展开当前路由的父菜单
    for (var item in navItems) {
      if (_isTopLevel(item.route) && location.startsWith(item.route)) {
        expandedMenu ??= item.route;
      }
    }

    return Container(
      width: 220,
      color: const Color(0xFF0D121C),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _topLogo(),
            const SizedBox(height: 4),
            // 一级菜单
            ...navItems
                .where((item) => _isTopLevel(item.route))
                .map((item) => _buildTopLevel(context, item, location)),
            const SizedBox(height: 12),
            // 底栏
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // 顶栏
  Widget _topLogo() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      alignment: Alignment.centerLeft,
      child: Row(
        children: const [
          Icon(Icons.terminal, color: Color(0xFF2B6CDE), size: 28),
          SizedBox(width: 12),
          Text(
            "CTF TOOLBOX",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2B6CDE),
            ),
          ),
        ],
      ),
    );
  }

  // 底栏
  Widget _buildFooter()  {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: const Color(0xFF0E1726),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text("Version ${_version ?? '...'}", style: const TextStyle(color: Color(0xFF505364))),
            ],
          ),
        ),
      ),
    );
  }

  // 是顶级菜单
  bool _isTopLevel(String route) {
    return route.split("/").length == 2;
  }

  // 一级菜单 + 展开逻辑
  Widget _buildTopLevel(BuildContext context, NavItem item, String location) {
    final bool isExpanded = expandedMenu == item.route;
    final bool isActive = item.route == "/"
        ? location == "/"
        : location.startsWith(item.route);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _menuCard(
          icon: item.icon,
          title: item.name,
          selected: isActive,
          expanded: isExpanded,
          isContainerOnly: item.isContainerOnly,
          onTap: () {
            setState(() {
              if (item.isContainerOnly) {
                // 折叠型菜单：只切换展开/收起，不跳转
                expandedMenu = isExpanded ? null : item.route;
              } else {
                // 非折叠型菜单：跳转 + 展开（不收起）
                expandedMenu = item.route;
                context.go(item.route);
              }
            });
          },
        ),

        // 二级菜单
        if (isExpanded)
          ...navItems
              .where((sub) => sub.route.startsWith("${item.route}/"))
              .map(
                (sub) => _subMenuCard(
                  icon: sub.icon,
                  title: sub.name,
                  selected: location == sub.route,
                  onTap: () => context.go(sub.route),
                ),
              ),
      ],
    );
  }

  // 一级卡片
  Widget _menuCard({
    required IconData icon,
    required String title,
    required bool selected,
    required bool expanded,
    required bool isContainerOnly,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: selected ? const Color(0xFF0F1B31) : const Color(0xFF0D121C),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF2B64CC)
                  : const Color(0xFF646C7A),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? const Color(0xFF285ABA)
                      : const Color(0xFF646C7A),
                ),
              ),
            ),
            if (isContainerOnly)
              AnimatedRotation(
                turns: expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: selected
                      ? const Color(0xFF285ABA)
                      : const Color(0xFF646C7A),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 二级卡片
  Widget _subMenuCard({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 20, top: 4, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: selected ? const Color(0xFF0F1B31) : const Color(0xFF0D121C),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? const Color(0xFF2453AC)
                  : const Color(0xFF7D8597),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: selected
                    ? const Color(0xFF2453AC)
                    : const Color(0xFF9AA4B2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
