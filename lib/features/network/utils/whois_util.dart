import 'package:whois/whois.dart';

class WhoisUtil {
  final String domainName;
  final String? registryDomainId;
  final String? registrarWhoisServer;
  final String? registrarUrl;
  final DateTime? updatedDate;
  final DateTime? creationDate;
  final DateTime? registryExpiryDate;
  final String? registrar;
  final String? registrarIanaId;
  final String? registrarAbuseContactEmail;
  final String? registrarAbuseContactPhone;
  final List<String> domainStatuses;
  final List<String> nameServers;
  final String? dnssec;
  final String? lastUpdateOfWhoisDatabase;

  WhoisUtil({
    required this.domainName,
    this.registryDomainId,
    this.registrarWhoisServer,
    this.registrarUrl,
    this.updatedDate,
    this.creationDate,
    this.registryExpiryDate,
    this.registrar,
    this.registrarIanaId,
    this.registrarAbuseContactEmail,
    this.registrarAbuseContactPhone,
    this.domainStatuses = const [],
    this.nameServers = const [],
    this.dnssec,
    this.lastUpdateOfWhoisDatabase,
  });

  /// 从 WHOIS 原始 Map 构建 WhoisUtil 实例
  factory WhoisUtil.fromMap(Map<String, dynamic> raw) {
    // 域名
    final domainName = (raw['Domain Name'] as String?)?.trim() ?? '';

    // 状态
    List<String> extractList(dynamic value) {
      if (value == null) return [];
      if (value is String) return [value.trim()];
      if (value is List) return value.map((e) => e.toString().trim()).toList();
      return [];
    }

    final statuses = extractList(raw['Domain Status']);
    final nameServers = extractList(raw['Name Server']);

    // 日期解析
    DateTime? parseIsoDate(String? input) {
      if (input == null || input.isEmpty) return null;
      try {
        return DateTime.parse(input);
      } catch (_) {
        return null;
      }
    }

    // 尝试从多个位置提取 "Last update of whois database"
    String? extractLastUpdate(String? rawText) {
      if (rawText == null) return null;
      final lines = rawText.split('\n');
      for (final line in lines) {
        if (line.contains('Last update of whois database')) {
          // 移除 >>> <<< : 等符号
          return line.replaceAll(RegExp(r'[<>\s:]+'), ' ').trim().replaceAll(RegExp(r'\s+'), ' ');
        }
      }
      return null;
    }

    return WhoisUtil(
      domainName: domainName.toUpperCase(),
      registryDomainId: raw['Registry Domain ID'],
      registrarWhoisServer: raw['Registrar WHOIS Server'],
      registrarUrl: raw['Registrar URL'],
      updatedDate: parseIsoDate(raw['Updated Date']),
      creationDate: parseIsoDate(raw['Creation Date']),
      registryExpiryDate: parseIsoDate(raw['Registry Expiry Date']),
      registrar: raw['Registrar'],
      registrarIanaId: raw['Registrar IANA ID'],
      registrarAbuseContactEmail: raw['Registrar Abuse Contact Email'],
      registrarAbuseContactPhone: raw['Registrar Abuse Contact Phone'],
      domainStatuses: statuses,
      nameServers: nameServers,
      dnssec: raw['DNSSEC'],
      lastUpdateOfWhoisDatabase: raw['>>> Last update of whois database:'] ??
          extractLastUpdate(raw['_raw'] as String?),
    );
  }

  /// 查询域名并返回格式化中文信息
  static Future<String> lookupAndFormatChinese(String domain) async {
    try {
      final rawResponse = await Whois.lookup(domain);
      final parsedMap = Whois.formatLookup(rawResponse); // 返回 Map<String, dynamic>
      final whois = WhoisUtil.fromMap(parsedMap);

      final buffer = StringBuffer();

      buffer.writeln('🔍 域名信息查询结果');
      buffer.writeln('=' * 20);
      buffer.writeln('域名：${whois.domainName}');

      if (whois.creationDate != null) {
        buffer.writeln('注册日期：${_formatDate(whois.creationDate!)}');
      }
      if (whois.registryExpiryDate != null) {
        buffer.writeln('过期日期：${_formatDate(whois.registryExpiryDate!)}');
      }
      if (whois.updatedDate != null) {
        buffer.writeln('最后更新：${_formatDate(whois.updatedDate!)}');
      }

      buffer.writeln('注册商：${whois.registrar ?? '未知'}');
      if (whois.registrarIanaId != null) {
        buffer.writeln('注册商 IANA ID：${whois.registrarIanaId}');
      }
      if (whois.registrarUrl != null) {
        buffer.writeln('注册商官网：${whois.registrarUrl}');
      }
      if (whois.registrarAbuseContactEmail != null) {
        buffer.writeln('滥用投诉邮箱：${whois.registrarAbuseContactEmail}');
      }
      if (whois.registrarAbuseContactPhone != null) {
        buffer.writeln('滥用投诉电话：${whois.registrarAbuseContactPhone}');
      }

      if (whois.nameServers.isNotEmpty) {
        buffer.writeln('DNS 服务器：');
        for (final ns in whois.nameServers) {
          buffer.writeln('  - $ns');
        }
      }

      if (whois.domainStatuses.isNotEmpty) {
        buffer.writeln('域名状态：');
        for (final status in whois.domainStatuses) {
          final desc = _translateStatus(status);
          buffer.writeln('  - $desc');
        }
      }

      final dnssecStatus = whois.dnssec?.toLowerCase() == 'unsigned' ? '未启用' : (whois.dnssec ?? '未知');
      buffer.writeln('DNSSEC：$dnssecStatus');

      if (whois.lastUpdateOfWhoisDatabase != null) {
        buffer.writeln('WHOIS 数据库最后更新：${whois.lastUpdateOfWhoisDatabase}');
      }

      return buffer.toString();
    } catch (e) {
      return '❌ WHOIS 查询失败：$e';
    }
  }

  /// 格式化日期为 YYYY-MM-DD
  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// 将 EPP 状态码翻译为中文描述
  static String _translateStatus(String fullStatus) {
    // 提取 # 后的状态码，如 clientTransferProhibited
    final parts = fullStatus.split('#');
    final code = parts.length > 1 ? parts[1].toLowerCase() : fullStatus.toLowerCase();

    switch (code) {
      case 'ok':
      case 'active':
        return '正常（无限制）';
      case 'clienttransferprohibited':
        return '禁止转移（由注册商设置）';
      case 'servertransferprohibited':
        return '禁止转移（由注册局设置）';
      case 'clientupdateprohibited':
        return '禁止修改（由注册商设置）';
      case 'serverupdateprohibited':
        return '禁止修改（由注册局设置）';
      case 'clientdeleteprohibited':
        return '禁止删除（由注册商设置）';
      case 'serverdeleteprohibited':
        return '禁止删除（由注册局设置）';
      case 'clienthold':
        return '客户端暂停（域名不解析）';
      case 'serverhold':
        return '服务端暂停（域名不解析）';
      case 'redemptionperiod':
        return '赎回期（已过期，可付费恢复）';
      case 'pendingdelete':
        return '即将删除（赎回期结束后）';
      case 'pendingtransfer':
        return '转移处理中';
      case 'pendingcreate':
        return '注册处理中';
      case 'pendingrenew':
        return '续费处理中';
      case 'pendingrestore':
        return '恢复处理中';
      default:
        return '$fullStatus（未识别状态）';
    }
  }
}