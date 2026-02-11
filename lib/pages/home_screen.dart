import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // 1.搜索框
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (text) {
                      if (kDebugMode) {
                        print("搜索内容：$text");
                      }
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      labelText: '搜索',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                // 2. 间距
                const SizedBox(width: 22),
                // 3. 通知按钮
                IconButton(
                  onPressed: () {
                    if (kDebugMode) print("点击了通知按钮");
                  },
                  icon: Badge(
                    // TODO: 后续留给更新日志用
                    // label: Text,
                    child: Icon(Icons.notifications),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}