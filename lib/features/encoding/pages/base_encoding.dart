import 'dart:convert';

import 'package:ctf_tools/features/encoding/utils/base_encoding/base_encoding.dart';
import 'package:ctf_tools/features/encoding/utils/base_encoding/base_list.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:flutter/material.dart';
import 'package:ctf_tools/features/encoding/utils/character_encoding.dart';
import 'package:flutter/services.dart';

class BaseEncodingScreen extends StatefulWidget {
  const BaseEncodingScreen({super.key});

  @override
  State<BaseEncodingScreen> createState() => _BaseEncodingScreen();
}

class _BaseEncodingScreen extends State<BaseEncodingScreen> {
  // 当前选中的字符编码
  String selectedCharacterEncoding =
      CharacterEncoding().characterEncodingList[0];
  // 当前选中的Base编码
  String baseInitialValue = getBaseEncodingList[7];

  // 输入框文本控制器
  TextEditingController inputController = TextEditingController();
  // 交换文本
  String swapTextTemp = "";
  // 输出框文本控制器
  TextEditingController outputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF101622),
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            // 顶栏
            Row(
              children: [
                // 标题
                Text(
                  "Base 编码/解码",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFE1D4),
                  ),
                ),
                const SizedBox(width: 26),

                // 字符集切换按钮
                Text(
                  "字符集",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 6),
                MDropdownMenu(
                  initialValue: selectedCharacterEncoding,
                  items: CharacterEncoding().characterEncodingList,
                  onChanged: (value) {
                    setState(() {
                      selectedCharacterEncoding = value;
                    });
                  },
                ),

                const SizedBox(width: 16),

                // Base编码切换按钮
                Text(
                  "Base编码",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 6),
                MDropdownMenu(
                  initialValue: baseInitialValue,
                  items: getBaseEncodingList,
                  onChanged: (value) {
                    setState(() {
                      baseInitialValue = value;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 20),

            // 输入框标题
            Row(
              children: [
                Text(
                  "输入框 (INPUT)",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF122244),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "RAW Text",
                    style: TextStyle(color: Color(0xFF2B64D1)),
                  ),
                ),
                Spacer(),

                // 复制按钮
                MElevatedButton(
                  icon: Icons.copy,
                  text: "复制",
                  onPressed: () => {_copyText(inputController.text)},
                ),
                const SizedBox(width: 12),
                // 导入文件按钮
                MElevatedButton(
                  icon: Icons.file_open,
                  text: "导入文件",
                  onPressed: () => {},
                ),
                const SizedBox(width: 12),
                // 清空按钮
                MElevatedButton(
                  icon: Icons.delete,
                  text: "清空",
                  onPressed: () => {_clear()},
                ),
              ],
            ),
            SizedBox(height: 20),

            // 输入框
            TextField(
              maxLines: 10,
              controller: inputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF0F17AA)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6), // 聚焦时高亮边框
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // 中间的编码解码按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MElevatedButton(
                  icon: Icons.lock,
                  iconColor: Colors.white,
                  text: "编码",
                  textColor: Colors.white,
                  onPressed: () => {_baseEncoding()},
                ),
                SizedBox(width: 20),
                MElevatedButton(
                  icon: Icons.lock_open,
                  iconColor: Colors.white,
                  text: "解码",
                  textColor: Colors.white,
                  onPressed: () => {_baseDecoding()},
                ),
                SizedBox(width: 20),
                MElevatedButton(
                  icon: Icons.sync_outlined,
                  iconColor: Colors.white,
                  text: "交换",
                  textColor: Colors.white,
                  onPressed: () => {
                    swapTextTemp = inputController.text,
                    inputController.text = outputController.text,
                    outputController.text = swapTextTemp,
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // 输出框标题
            Row(
              children: [
                Text(
                  "输出框 (OUTPUT)",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0C312D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "READY",
                    style: TextStyle(color: Color(0xFF0F9F6D)),
                  ),
                ),
                Spacer(),

                // 复制按钮
                MElevatedButton(
                  icon: Icons.copy,
                  text: "复制",
                  onPressed: () => {_copyText(outputController.text)},
                ),
                const SizedBox(width: 12),
                // 导出文件按钮
                MElevatedButton(
                  icon: Icons.file_copy,
                  text: "导出到文件",
                  onPressed: () => {},
                ),
                const SizedBox(width: 12),
                // 清空按钮
                MElevatedButton(
                  icon: Icons.delete,
                  text: "清空",
                  onPressed: () => {_clear()},
                ),
              ],
            ),
            SizedBox(height: 20),

            //输出框
            Expanded(
              child: TextField(
                maxLines: 15,
                controller: outputController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF0F17AA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B82F6), // 聚焦时高亮边框
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///=== 私有方法 ===///
  /// Base编码
  void _baseEncoding() {
    setState(() {
      // 先转 UTF-8 bytes
      final utf8Bytes = utf8.encode(inputController.text);

      // 再 Base 编码
      outputController.text = BaseCodecFactory.encode(
        baseInitialValue,
        utf8Bytes,
      );
    });
  }

  /// Base解码
  void _baseDecoding() {
    setState(() {
      // Base 解码成字节
      final decodedBytes = BaseCodecFactory.decode(
        baseInitialValue,
        inputController.text,
      );
      // 转成 UTF-8
      final utf8Bytes = CharacterEncoding.convertToUtf8(
        decodedBytes,
        selectedCharacterEncoding,
      );
      // 转成字符串显示
      outputController.text = utf8.decode(utf8Bytes);
    });
  }

  /// 清理输入输出框
  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      _showToast("无内容可清空喵");
      return;
    }
    inputController.clear();
    outputController.clear();
    _showToast("已清空喵");
  }

  /// 复制文本
  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      _showToast("无内容可复制喵");
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    _showToast("复制成功喵");
  }

  /// 显示提示弹窗（Toast）
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2B5EC9),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
