import 'package:ctf_tools/core/route/nav_item.dart';
import 'package:ctf_tools/main_layout.dart';
import 'package:ctf_tools/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ctf_tools/pages/settings_screen.dart';

final List<NavItem> navItems = [
  // 首页
  NavItem(name: "首页", route: "/", icon: Icons.dashboard, builder: (context,state) => HomeScreen()),

  // 编码/解码
  NavItem(name: "编码解码", route: "/encoding", icon: Icons.data_array, builder: (context,state) => HomeScreen(), isContainerOnly: true),
  // 1. Base 系列编码 Base64, Base32, Base58, Base85)
  NavItem(name: "Base系列", route: "/encoding/base", icon: Icons.numbers, builder: (context,state) => HomeScreen()),
  // 2. 文本内容编码 URL 编码, HTML 实体编码, Quoted-Printable, Morse Code
  NavItem(name: "文本编码", route: "/encoding/text", icon: Icons.text_format, builder: (context,state) => HomeScreen()),
  // 3. 字符集与文本表示转换	Unicode 转义, Hex ↔ ASCII, UTF-8 转换, Binary ↔ ASCII)
  NavItem(name: "字符集", route: "/encoding/char", icon: Icons.abc, builder: (context,state) => HomeScreen()),
  // 4. 压缩与解压缩	Zlib, Gzip)
  NavItem(name: "压缩/解压", route: "/encoding/compress", icon: Icons.compress, builder: (context,state) => HomeScreen()),
  // 5. 数值与进制转换	BCD 转换, Binary ↔ Hex, 进制互转
  NavItem(name: "数值/进制", route: "/encoding/number", icon: Icons.calculate, builder: (context,state) => HomeScreen()),
  // 6. 简单替换密码	ROT13, ROT47, 自定义 ROT
  NavItem(name: "替换密码", route: "/encoding/replace", icon: Icons.swap_horiz, builder: (context,state) => HomeScreen()),

  // 密码学工
  NavItem(name: "密码学", route: "/crypto", icon: Icons.lock, builder: (context,state) => HomeScreen(), isContainerOnly: true),
  // 1. 经典密码	Caesar, Vigenère, Atbash, Affine, Rail Fence, Baconia
  NavItem(name: "经典密码", route: "/crypto/classical", icon: Icons.history_edu, builder: (context,state) => HomeScreen()),
  // 2. 现代密码	AES/DES/3DES/Blowfish, RSA（含私钥修复）, EC
  NavItem(name: "现代密码", route: "/crypto/modern", icon: Icons.shield, builder: (context,state) => HomeScreen()),
  // 3. 哈希计算,识别与爆破	哈希类型识别、爆破
  NavItem(name: "哈希计算", route: "/crypto/hash", icon: Icons.fingerprint, builder: (context,state) => HomeScreen()),
  // 4. 密码分析与辅助工具	XOR 爆破、字频分析、多表替换分析、JWT 操作、PEM/DER 转换
  NavItem(name: "密码分析", route: "/crypto/analysis", icon: Icons.analytics, builder: (context,state) => HomeScreen()),

  // 隐写工
  NavItem(name: "隐写工具", route: "/stego", icon: Icons.hide_image, builder: (context,state) => HomeScreen(), isContainerOnly: true),
  // 1. 图像隐写	LSB 提取、zsteg、EXIF 查看、binwalk 扫
  NavItem(name: "图像", route: "/stego/image", icon: Icons.image_search, builder: (context,state) => HomeScreen()),
  // 2. 音视频隐写	频谱图分析、基于文件头的隐藏文件提取
  NavItem(name: "音视频", route: "/stego/audio_video", icon: Icons.music_note, builder: (context,state) => HomeScreen()),
  // 3. 文本隐写	空格/Tab 隐写（Snow）、零宽字符检测与提取
  NavItem(name: "文本", route: "/stego/text", icon: Icons.format_size, builder: (context,state) => HomeScreen()),

  // 网络协
  NavItem(name: "网络协议", route: "/network", icon: Icons.router, builder: (context,state) => HomeScreen(), isContainerOnly: true),
  // 1. 网络协议交互与模拟	SMTP/FTP/POP3 模拟、HTTP 请求构造器、WebSocket 重
  NavItem(name: "协议交互", route: "/network/interaction", icon: Icons.sync_alt, builder: (context,state) => HomeScreen()),
  // 2. 网络探测与信息收集	WHOIS、子域名枚举、DNS 查询（含 TXT
  NavItem(name: "信息收集", route: "/network/recon", icon: Icons.explore, builder: (context,state) => HomeScreen()),
  // 3. 流量分析与重组	TCP/UDP 流重组（pcap 解析）
  NavItem(name: "流量分析", route: "/network/traffic", icon: Icons.timeline, builder: (context,state) => HomeScreen()),
  // 4. 网络地址与扫描工具	IPv4/IPv6 格式转换、端口扫描
  NavItem(name: "地址扫描", route: "/network/scanning", icon: Icons.map, builder: (context,state) => HomeScreen()),

  // 二进制分析
  NavItem(name: "二进制分析", route: "/binary", icon: Icons.developer_mode, builder: (context,state) => HomeScreen(), isContainerOnly: true),
  // 1. 二进制文件基础解析	ELF/PE/Mach-O 解析、Canary/PIE/NX 检
  NavItem(name: "文件解析", route: "/binary/info", icon: Icons.file_open, builder: (context,state) => HomeScreen()),
  // 2. 静态内容提取	字符串提取（strings）
  NavItem(name: "字符串提取", route: "/binary/strings", icon: Icons.text_snippet, builder: (context,state) => HomeScreen()),
  // 3. 反汇编与代码分析	反汇编（Capstone/objdump）、ROP gadget 查找
  NavItem(name: "反汇编", route: "/binary/disasm", icon: Icons.code_off, builder: (context,state) => HomeScreen()),
  // 4. 漏洞利用辅助	格式化字符串偏移计算、Shellcode 生成
  NavItem(name: "漏洞利用", route: "/binary/exploit", icon: Icons.bug_report, builder: (context,state) => SettingsScreen()),

  // 下载其他工具
  NavItem(name: "下载", route: "/download", icon: Icons.download, builder: (context,state) => SettingsScreen()),
  // 设置
  NavItem(name: "设置", route: "/settings", icon: Icons.settings, builder: (context,state) => SettingsScreen()),
];

GoRouter get getRoute => GoRouter(
  initialLocation: "/",
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        ...navItems.map(
              (item) => GoRoute(
            name: item.name,
            path: item.route,
            builder: item.builder,
            pageBuilder: (context, state) {
              return NoTransitionPage(
                 child: item.builder(context, state),
              );
            },
          ),
        )
      ],
    ),
  ],
);