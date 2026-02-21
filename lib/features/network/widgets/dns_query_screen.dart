import 'package:ctf_tools/features/network/utils/dns_utils.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter/material.dart';

class DnsQueryScreen extends StatefulWidget {
  const DnsQueryScreen({super.key});

  @override
  State<DnsQueryScreen> createState() => _DnsQueryScreen();
}

class _DnsQueryScreen extends State<DnsQueryScreen> {
  // 输入框文本控制器
  TextEditingController inputController = TextEditingController();
  // 输出框文本控制器
  TextEditingController outputController = TextEditingController();
  // 是否启用 自定义DNS服务器
  bool isEnableDns = false;
  // 是否文本模式
  bool isRawMode = false;
  // 自定义DNS服务器文本控制器
  TextEditingController dnsController = TextEditingController();
  // 当前选中的DNS Server Key, 默认使用CloudFlare好了
  String _selectedDnsKey = DnsUtils.dnsServers.keys.first;
  // 存放查询结果
  List<DataRow> _resultRows = [];
  // 用于管理自定义 DNS 实例生命周期
  DnsOverHttps? _customDns;

  @override
  void dispose() {
    _customDns?.close();
    inputController.dispose();
    outputController.dispose();
    dnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF101622),
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            // 输入框标题
            Row(
              children: [
                Text(
                  "域名 (DOMAIN)",
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
                    "INPUT",
                    style: TextStyle(color: Color(0xFF2B64D1)),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  "自定义DNS服务器",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                Switch(
                  value: isEnableDns,
                  activeThumbColor: Colors.blueAccent, // 开关开启时的滑块颜色
                  activeTrackColor: Colors.blueAccent[1], // 开关开启时的轨道颜色
                  inactiveThumbColor: Colors.grey, // 开关关闭时的滑块颜色
                  inactiveTrackColor: Colors.black, // 开关关闭时的轨道颜色
                  onChanged: (value) {
                    setState(() {
                      isEnableDns = value;
                    });
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  "文本模式",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                Switch(
                  value: isRawMode,
                  activeThumbColor: Colors.blueAccent, // 开关开启时的滑块颜色
                  activeTrackColor: Colors.blueAccent[1], // 开关开启时的轨道颜色
                  inactiveThumbColor: Colors.grey, // 开关关闭时的滑块颜色
                  inactiveTrackColor: Colors.black, // 开关关闭时的轨道颜色
                  onChanged: (value) {
                    setState(() {
                      isRawMode = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                if (!isEnableDns) ...[
                  MDropdownMenu(
                    initialValue: _selectedDnsKey,
                    items: DnsUtils.dnsServers
                        .map((key, value) => MapEntry(key, key))
                        .values
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDnsKey = value;
                      });
                    },
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: TextField(
                    controller: inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '输入想要查询的域名...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          inputController.clear();
                          setState(() {});
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                MElevatedButton(
                  icon: Icons.search,
                  text: "搜索",
                  onPressed: () {
                    _dnsSearch();
                    setState(() {});
                  },
                ),
                SizedBox(width: 20),
                // 清空按钮
                MElevatedButton(
                  icon: Icons.delete,
                  text: "清空",
                  onPressed: () => {_clear()},
                ),
              ],
            ),
            SizedBox(height: 20),
            // 自定义DNS服务
            if (isEnableDns) ...[
              Row(
                children: [
                  Text(
                    "自定义DNS服务器 (DNS Server)",
                    style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Flexible(
                child: TextField(
                  controller: dnsController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'DNS 服务器...',
                    prefixIcon: Icon(Icons.dns_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        dnsController.clear();
                        setState(() {});
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
            // 输出框标题
            Row(
              children: [
                Text(
                  "输出 (OUTPUT)",
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
              ],
            ),
            SizedBox(height: 20),

            //输出框
            Expanded(
              child: isRawMode
                  ? TextField(
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      textAlign: TextAlign.start,
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
                    )
                  : SingleChildScrollView(
                      // 横向滚动
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        // 纵向滚动
                        scrollDirection: Axis.vertical,
                        child: _buildTableOutput(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableOutput() {
    if (_resultRows.isEmpty) {
      return const Center(
        child: Text(
          '📭 无 DNS 记录',
          style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowColor: WidgetStateColor.resolveWith(
          (states) => const Color(0xFF151B2A),
        ),
        headingRowColor: WidgetStateColor.resolveWith(
          (states) => const Color(0xFF1E293B),
        ),
        headingTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        dataTextStyle: const TextStyle(color: Colors.white),
        columns: const [
          DataColumn(label: Text('记录类型')),
          DataColumn(label: Text('值')),
        ],
        rows: _resultRows,
      ),
    );
  }

  ///=== 私有方法 ===///
  // === 查询逻辑 ===
  Future<void> _dnsSearch() async {
    if (inputController.text.isEmpty) {
      showToast("不知道你要查询什么喵", context);
      return;
    }
    if (isEnableDns && dnsController.text.isEmpty) {
      showToast("请输入自定义DNS服务器喵", context);
      return;
    }

    DnsResult? result;
    DnsOverHttps? dnsToUse;

    try {
      if (!isEnableDns) {
        dnsToUse = DnsUtils.dnsServers[_selectedDnsKey];
        if (dnsToUse == null) {
          showToast("DNS服务器不存在喵", context);
          return;
        }
      } else {
        // 关闭旧的自定义 DNS
        _customDns?.close();
        _customDns = DnsOverHttps(dnsController.text.trim());
        dnsToUse = _customDns;
      }

      result = await DnsUtils.queryAllWith(dnsToUse!, inputController.text);
    } catch (e) {
      if (!mounted) return;
      showToast('查询失败: ${e.toString()}', context);
      return;
    }

    // ✅ 统一更新状态
    if (mounted) {
      setState(() {
        if (isRawMode) {
          outputController.text = result.toString();
        } else {
          _resultRows = _buildResultRows(result!);
        }
      });
    }
  }

  // === 构建表格行 ===
  List<DataRow> _buildResultRows(DnsResult result) {
    final rows = <DataRow>[];

    void addRows(String type, List<String> records) {
      for (final record in records) {
        rows.add(
          DataRow(cells: [DataCell(Text(type)), DataCell(Text(record))]),
        );
      }
    }

    if (result.error != null) {
      rows.add(
        DataRow(
          cells: [
            const DataCell(Text('错误')),
            DataCell(
              Text(result.error!, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      return rows;
    }

    if (!result.exists) {
      rows.add(
        const DataRow(
          cells: [
            DataCell(Text('状态')),
            DataCell(
              Text('域名不存在 (NXDOMAIN)', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      );
      return rows;
    }

    addRows('A', result.aRecords);
    addRows('AAAA', result.aaaaRecords);
    addRows('CNAME', result.cnameRecords);
    addRows('MX', result.mxRecords);
    addRows('TXT', result.txtRecords);
    addRows('NS', result.nsRecords);
    if (result.soaRecord != null) {
      rows.add(
        DataRow(
          cells: [
            const DataCell(Text('SOA')),
            DataCell(Text(result.soaRecord!)),
          ],
        ),
      );
    }

    return rows;
  }

  /// 清理输入输出框
  void _clear() {
    if (inputController.text.isEmpty) {
      showToast("无内容可清空喵", context);
      return;
    }
    inputController.clear();
    dnsController.clear();
    outputController.clear();
    showToast("已清空喵", context);
  }
}
