import 'package:dns_client/dns_client.dart';

/// DNS 查询结果结构体
class DnsResult {
  final List<String> aRecords; // IPv4
  final List<String> aaaaRecords; // IPv6
  final List<String> cnameRecords;
  final List<String> mxRecords;
  final List<String> txtRecords;
  final List<String> nsRecords;
  final String? soaRecord;
  final bool exists; // 是否存在
  final String? error; // 错误信息

  DnsResult({
    this.aRecords = const [],
    this.aaaaRecords = const [],
    this.cnameRecords = const [],
    this.mxRecords = const [],
    this.txtRecords = const [],
    this.nsRecords = const [],
    this.soaRecord,
    this.exists = true,
    this.error,
  });
}

/// DNS 工具类
class DnsUtils {

  Map<String, DnsOverHttps> get dnsServers => {
    'Google DNS': DnsOverHttps.google(timeout: Duration(seconds: 10)),
    'Cloudflare': DnsOverHttps.cloudflare(timeout: Duration(seconds: 10)),
    'AdGuard': DnsOverHttps.adguard(timeout: Duration(seconds: 10)),
    'AdGuardFamily': DnsOverHttps.adguardFamily(timeout: Duration(seconds: 10)),
    'AdGuardNonFiltering': DnsOverHttps.adguardNonFiltering(timeout: Duration(seconds: 10)),
    'DnsSb': DnsOverHttps.dnsSb(timeout: Duration(seconds: 10)),
    'NextDns': DnsOverHttps.nextdns(timeout: Duration(seconds: 10)),
    'NextDnsAnycast': DnsOverHttps.nextdnsAnycast(timeout: Duration(seconds: 10)),
    '阿里DNS': DnsOverHttps("https://dns.alidns.com/dns-query",timeout: Duration(seconds: 10)),
    '腾讯DNSPod': DnsOverHttps("https://doh.pub/dns-query",timeout: Duration(seconds: 10)),
    '华为Cloud': DnsOverHttps("https://dns.huaweicloud.com/dns-query",timeout: Duration(seconds: 10)),
    '360 DoH': DnsOverHttps("https://doh.360.cn/dns-query",timeout: Duration(seconds: 10)),
    '114 DoH': DnsOverHttps("https://doh.114dns.com/dns-query",timeout: Duration(seconds: 10)),
  };

  // 使用 Cloudflare DoH
  static final DnsOverHttps _dns = DnsOverHttps.cloudflare(
    timeout: Duration(seconds: 10),
  );

  /// 查询域名所有常见 DNS 记录
  static Future<DnsResult> queryAll(String domain) async {
    // 标准化域名
    final cleanDomain = _sanitizeDomain(domain);
    try {
      // 先查 A 记录判断是否存在
      final aResponse = await _dns.lookupHttpsByRRType(cleanDomain, RRType.A);

      if (aResponse.isNxDomain) {
        return DnsResult(exists: false);
      }
      if (aResponse.isServerFailure) {
        return DnsResult(error: 'DNS server failure (SERVFAIL)');
      }

      // 并发查询 List<String> 类型的记录
      final recordFutures = [
        _safeLookup(RRType.A, cleanDomain),
        _safeLookup(RRType.AAAA, cleanDomain),
        _safeLookup(RRType.CNAME, cleanDomain),
        _safeLookup(RRType.MX, cleanDomain),
        _safeLookup(RRType.TXT, cleanDomain),
        _safeLookup(RRType.NS, cleanDomain),
      ];
      final records = await Future.wait(recordFutures);

      // 单独查 SOA
      final soa = await _safeLookupSoa(cleanDomain);

      return DnsResult(
        aRecords: records[0],
        aaaaRecords: records[1],
        cnameRecords: records[2],
        mxRecords: records[3],
        txtRecords: records[4],
        nsRecords: records[5],
        soaRecord: soa,
        exists: true,
      );
    } on DnsHttpException catch (e) {
      return DnsResult(
        error: 'Network error: ${e.message} (HTTP ${e.statusCode})',
      );
    } on Exception catch (e) {
      return DnsResult(error: 'Unexpected error: ${e.toString()}');
    }
  }

  /// 查询
  static Future<List<String>> _safeLookup(RRType type, String domain) async {
    try {
      return await _dns.lookupDataByRRType(domain, type);
    } catch (e) {
      return [];
    }
  }

  /// 查询 SOA
  static Future<String?> _safeLookupSoa(String domain) async {
    try {
      final records = await _dns.lookupDataByRRType(domain, RRType.SOA);
      return records.isNotEmpty ? records.first : null;
    } catch (e) {
      return null;
    }
  }

  /// 清理输入域名
  static String _sanitizeDomain(String input) {
    var domain = input.trim();
    // 移除协议
    if (domain.startsWith('http://')) domain = domain.substring(7);
    if (domain.startsWith('https://')) domain = domain.substring(8);
    // 移除路径和查询参数
    final slashIndex = domain.indexOf('/');
    if (slashIndex != -1) domain = domain.substring(0, slashIndex);
    // 移除端口
    final colonIndex = domain.indexOf(':');
    if (colonIndex != -1 && !domain.contains('.')) {
      domain = domain.substring(0, colonIndex);
    }
    // 移除末尾的点
    if (domain.endsWith('.')) domain = domain.substring(0, domain.length - 1);
    return domain.toLowerCase();
  }

  static void dispose() {
    _dns.close();
  }
}
