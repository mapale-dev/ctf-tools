---
name: fix_base_encoding_decoding
overview: 修复 Base 编码解码模块中的三个错误：Base36 字符集中的制表符、解码方法的参数错误和逻辑错误。
todos:
  - id: fix-base36-charset
    content: 修复 base_encoding.dart 中 Base36Codec 的字符集制表符问题
    status: completed
  - id: fix-decode-logic
    content: 修复 base_encoding.dart 中 _baseDecoding() 方法的参数和逻辑错误
    status: completed
  - id: verify-encoding
    content: 验证 Base 编码解码功能正确性
    status: completed
    dependencies:
      - fix-base36-charset
      - fix-decode-logic
---

## 产品需求

修复 CTF Tools 应用中 Base 编码/解码功能的多个关键错误，确保编码和解码操作正确处理数据。

## 问题描述

当前 Base 编码/解码模块存在三个严重错误：

1. Base36 编码字符集包含隐藏的制表符，导致编码结果错误
2. Base 解码方法中的逻辑错误，使用了错误的变量获取输入数据
3. BaseCodecFactory.decode() 调用参数顺序完全错误，导致解码失败

## 核心功能

- 修复 Base36 编码字符集定义
- 修正 Base 解码方法的业务逻辑
- 确保正确调用 BaseCodecFactory 的 decode 方法
- 保证所有 Base 编码格式（Base2、Base8、Base16、Base32、Base36、Base58、Base62、Base64、Base66）的编码解码功能正确可用

## 技术栈

- 框架：Flutter (Dart)
- 编码库：base_x (用于 Base 编码)
- 字符集库：charset (用于字符编码转换)

## 实现方案

### 问题分析与解决策略

#### 问题 1：Base36Codec 字符集中的制表符

- **根因**：第 83 行的字符串字面量开头包含隐藏的制表符字符（`\t`），导致 Base36 编码的字符集不正确
- **影响范围**：所有使用 Base36 编码的操作都会失败
- **解决方案**：删除制表符，使用正确的字符串 `'0123456789abcdefghijklmnopqrstuvwxyz'`

#### 问题 2：_baseDecoding() 中的变量混淆

- **根因**：第 268 行获取 Base 编码类型名称时，错误地使用了 `baseInitialValue`（这是当前选中的 Base 编码类型，例如 "Base64"），而应该使用 `inputController.text`（用户输入的待解码数据）
- **影响范围**：解码流程从第一步就错误，导致后续所有操作失败
- **解决方案**：使用 `baseInitialValue` 作为编码类型名称传给 decode 方法，使用 `inputController.text` 作为待解码的数据

#### 问题 3：BaseCodecFactory.decode() 调用参数错误

- **根因**：第 270-272 行的调用完全颠倒了参数含义：
- 当前：`BaseCodecFactory.decode(baseText, selectedCharacterEncoding)` 
- 正确的工厂方法签名：`static List<int> decode(String name, String text)`
- 第一个参数应该是编码类型名称（如 "Base64"）
- 第二个参数应该是待解码的文本
- **影响范围**：解码操作完全失效
- **解决方案**：正确调用 `BaseCodecFactory.decode(baseInitialValue, inputController.text)`

### 架构设计

现有架构采用工厂模式管理不同的编码类型：

- `BaseCodecFactory`：管理所有编码类型实例的工厂类
- 各种 `*Codec` 类：实现具体的编码解码逻辑
- `BaseEncodingScreen`：UI 层，调用工厂类进行编码解码

修复后将保持现有架构不变，只修正实现层的逻辑错误。

### 实现细节

- **修复范围**：仅涉及两个文件的精确修正
- **性能影响**：无，修复只是纠正逻辑错误
- **向后兼容性**：修复不改变 API，只是修正错误的实现
- **测试点**：
- 每种 Base 编码类型的编码功能
- 每种 Base 编码类型的解码功能
- Base36 编码的特殊验证（最容易出错的类型）