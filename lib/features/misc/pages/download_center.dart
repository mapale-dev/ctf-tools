import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadCenterScreen extends StatelessWidget {
  const DownloadCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ToolPageShell(
      title: '下载中心',
      description: '整理常见 CTF 工具的官方下载入口',
      badge: 'Links',
      child: ToolSectionCard(
        title: '常用工具列表',
        child: Column(
          children: downloadEntries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _DownloadEntryTile(entry: entry, scheme: scheme),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _DownloadEntryTile extends StatelessWidget {
  const _DownloadEntryTile({required this.entry, required this.scheme});

  final DownloadEntry entry;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: scheme.surfaceContainerHigh.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openLink(context, entry.url),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: scheme.primaryContainer,
                child: Icon(entry.icon, color: scheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.name,
                            style: TextStyle(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        FilledButton.tonalIcon(
                          onPressed: () => _openLink(context, entry.url),
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('打开'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.description,
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text(entry.category)),
                        Chip(label: Text(entry.url)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!success && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text('无法打开链接: $url')));
    }
  }
}

class DownloadEntry {
  const DownloadEntry({
    required this.name,
    required this.description,
    required this.category,
    required this.url,
    required this.icon,
  });

  final String name;
  final String description;
  final String category;
  final String url;
  final IconData icon;
}

const List<DownloadEntry> downloadEntries = [
  DownloadEntry(
    name: 'Burp Suite Community Edition',
    description: 'Web 安全测试代理，适合抓包、改包和基础漏洞验证。',
    category: 'Web Security',
    url: 'https://portswigger.net/burp/communitydownload',
    icon: Icons.bug_report_outlined,
  ),
  DownloadEntry(
    name: 'Wireshark',
    description: '经典抓包分析工具，用于协议解析和流量排查。',
    category: 'Network',
    url: 'https://www.wireshark.org/download.html',
    icon: Icons.wifi_tethering,
  ),
  DownloadEntry(
    name: 'Ghidra',
    description: 'NSA 开源逆向工具，适合静态分析与反编译。',
    category: 'Reverse Engineering',
    url: 'https://ghidra-sre.org/',
    icon: Icons.memory,
  ),
  DownloadEntry(
    name: 'IDA Free',
    description: 'Hex-Rays 提供的免费版 IDA，适合二进制浏览与分析。',
    category: 'Reverse Engineering',
    url: 'https://hex-rays.com/ida-free/',
    icon: Icons.developer_mode,
  ),
  DownloadEntry(
    name: 'ImHex',
    description: '现代十六进制编辑器，适合文件结构分析与模板解析。',
    category: 'Binary',
    url: 'https://imhex.werwolv.net/',
    icon: Icons.hexagon_outlined,
  ),
  DownloadEntry(
    name: 'CyberChef',
    description: '浏览器里的编码解码与数据处理工作台。',
    category: 'Encoding',
    url: 'https://gchq.github.io/CyberChef/',
    icon: Icons.restaurant_menu,
  ),
  DownloadEntry(
    name: 'Hashcat',
    description: '常用密码哈希破解工具，支持 GPU 加速。',
    category: 'Crypto',
    url: 'https://hashcat.net/hashcat/',
    icon: Icons.password,
  ),
  DownloadEntry(
    name: 'John the Ripper',
    description: '老牌密码审计工具，适合多类哈希测试。',
    category: 'Crypto',
    url: 'https://www.openwall.com/john/',
    icon: Icons.key,
  ),
  DownloadEntry(
    name: 'Stegsolve',
    description: '常见图像隐写辅助工具，适合图层与通道检查。',
    category: 'Stego',
    url: 'https://github.com/zardus/ctf-tools/blob/master/stegsolve/install',
    icon: Icons.image_search,
  ),
  DownloadEntry(
    name: 'binwalk',
    description: '固件分析和嵌入文件提取工具，常用于隐写与二进制题。',
    category: 'Forensics',
    url: 'https://github.com/ReFirmLabs/binwalk',
    icon: Icons.travel_explore,
  ),
];
