# ctf_tools

🎯 ![ctf_tools](https://img.shields.io/badge/CTF--Tools-MapleLeaf-orange?style=for-the-badge&logo=github)
📜 ![License](https://img.shields.io/github/license/mapale-dev/ctf-tools?style=for-the-badge) ![Stars](https://img.shields.io/github/stars/mapale-dev/ctf-tools?style=social) ![Forks](https://img.shields.io/github/forks/mapale-dev/ctf-tools?style=social)

MapleLeaf 的跨平台 CTF 工具箱。项目基于 Flutter 构建，提供统一的 Material 3 工作台，用来快速处理编码解码、密码分析、流量排查、二进制辅助和隐写提取等常见 CTF 场景。

## 亮点

- 多模块工作台：`encoding`、`crypto`、`stego`、`network`、`binary`、`misc`
- 跨平台运行：支持 Android、Windows、Linux、macOS、iOS
- 统一交互：侧边栏导航、首页搜索、模块化页面结构
- 易于扩展：每类工具按 `features/*` 分目录维护，便于继续加页和复用组件

## 快速导航

- 入口：[`lib/main.dart`](lib/main.dart)
- 主布局：[`lib/main_layout.dart`](lib/main_layout.dart)
- 路由定义：[`lib/core/route/app_routes.dart`](lib/core/route/app_routes.dart)
- 功能模块：[`lib/features`](lib/features)
- 配置：[`pubspec.yaml`](pubspec.yaml)

## 工具箱内容

基于当前路由和页面实现，工具箱已包含这些模块与功能：

### 编码解码 `encoding`

- `Base` 系列编码解码
- 文本编码转换
- ProtoBuf 编解码
- 压缩与解压
- 数值/进制转换
- 替换密码工具

### 密码学 `crypto`

- 经典密码分析
- 现代密码工具
- 哈希计算
- XOR/密码分析辅助

### 隐写 `stego`

- 图像隐写检测与提取
- 音视频隐写辅助分析
- 文本隐写编码与检测

### 网络 `network`

- HTTP/协议交互构造
- 信息收集
- 流量分析
- 地址扫描与地址工具
- DNS / WHOIS 等网络查询能力

### 二进制 `binary`

- 文件解析
- 字符串提取
- 反汇编辅助
- 漏洞利用辅助

### 其它 `misc`

- 下载中心
- 设置页与主题配置

## 环境需求

- Flutter SDK（以 [`pubspec.yaml`](pubspec.yaml) 为准）
- 推荐 Dart SDK：`^3.10.8`
- 桌面构建依赖：
  - Windows: Visual Studio（Desktop development with C++）
  - macOS: Xcode
  - Linux: clang、cmake、ninja-build、pkg-config、GTK 3 开发库

## 本地运行

安装依赖：

```bash
flutter pub get
```

启动应用：

```bash
flutter run
```

指定平台运行（示例为 Windows）：

```bash
flutter run -d windows
```

构建发布包（示例为 Windows）：

```bash
flutter build windows --release
```

## 项目结构

```text
lib/
  core/route/        路由与导航定义
  pages/             首页与设置页
  features/          各功能模块
  shared/            通用布局、组件、主题与工具函数
```

## 贡献指南

1. Fork 仓库并创建新分支，如 `feature/...` 或 `fix/...`
2. 完成修改后本地运行并补充测试（如适用）
3. 提交 PR，说明变更内容、使用场景和必要截图

代码风格默认遵循 `flutter_lints`。

## 资源

- Flutter: https://flutter.dev
- Dart: https://dart.dev

## 许可证

本项目遵循 [LICENSE](LICENSE)。

## 联系

如有建议或问题，欢迎在 Issues 中提出。
