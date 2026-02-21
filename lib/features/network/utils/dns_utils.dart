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

  @override
  String toString() {
    if (error != null) {
      return 'DnsResult(error: $error)';
    }
    if (!exists) {
      return 'DnsResult(domain does not exist)';
    }

    final buffer = StringBuffer('DnsResult(\n');
    if (aRecords.isNotEmpty) buffer.write('  A: $aRecords\n');
    if (aaaaRecords.isNotEmpty) buffer.write('  AAAA: $aaaaRecords\n');
    if (cnameRecords.isNotEmpty) buffer.write('  CNAME: $cnameRecords\n');
    if (mxRecords.isNotEmpty) buffer.write('  MX: $mxRecords\n');
    if (txtRecords.isNotEmpty) buffer.write('  TXT: $txtRecords\n');
    if (nsRecords.isNotEmpty) buffer.write('  NS: $nsRecords\n');
    if (soaRecord != null) buffer.write('  SOA: $soaRecord\n');
    buffer.write(')');
    return buffer.toString();
  }

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
  // 预定义 DNS 服务器列表
  static Map<String, DnsOverHttps> get dnsServers => {
    'Cloudflare': DnsOverHttps.cloudflare(timeout: Duration(seconds: 10)),
    'Google DNS': DnsOverHttps.google(timeout: Duration(seconds: 10)),
    'AdGuard': DnsOverHttps.adguard(timeout: Duration(seconds: 10)),
    'AdGuardFamily': DnsOverHttps.adguardFamily(timeout: Duration(seconds: 10)),
    'AdGuardNonFiltering': DnsOverHttps.adguardNonFiltering(timeout: Duration(seconds: 10),),
    'DnsSb': DnsOverHttps.dnsSb(timeout: Duration(seconds: 10)),
    'NextDns': DnsOverHttps.nextdns(timeout: Duration(seconds: 10)),
    'NextDnsAnycast': DnsOverHttps.nextdnsAnycast(timeout: Duration(seconds: 10),),
    '阿里DNS': DnsOverHttps("https://dns.alidns.com/dns-query", timeout: Duration(seconds: 10),),
    '腾讯DNSPod': DnsOverHttps("https://doh.pub/dns-query", timeout: Duration(seconds: 10),),
    '华为Cloud': DnsOverHttps("https://dns.huaweicloud.com/dns-query", timeout: Duration(seconds: 10),),
    '360 DoH': DnsOverHttps("https://doh.360.cn/dns-query", timeout: Duration(seconds: 10),),
    '114 DoH': DnsOverHttps("https://doh.114dns.com/dns-query", timeout: Duration(seconds: 10),),
  };

  /// 使用指定的 DnsOverHttps 查询所有记录
  static Future<DnsResult> queryAllWith(DnsOverHttps dns, String domain) async {
    final cleanDomain = _sanitizeDomain(domain);
    try {
      // 先查 A 记录判断是否存在
      final aResponse = await dns.lookupHttpsByRRType(cleanDomain, RRType.A);

      if (aResponse.isNxDomain) {
        return DnsResult(exists: false);
      }
      if (aResponse.isServerFailure) {
        return DnsResult(error: 'DNS server failure (SERVFAIL)');
      }

      // 并发查询各类记录
      final recordFutures = [
        _safeLookup(dns, RRType.A, cleanDomain),
        _safeLookup(dns, RRType.AAAA, cleanDomain),
        _safeLookup(dns, RRType.CNAME, cleanDomain),
        _safeLookup(dns, RRType.MX, cleanDomain),
        _safeLookup(dns, RRType.TXT, cleanDomain),
        _safeLookup(dns, RRType.NS, cleanDomain),
      ];
      final records = await Future.wait(recordFutures);

      final soa = await _safeLookupSoa(dns, cleanDomain);

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

  /// 安全查询通用记录
  static Future<List<String>> _safeLookup(
    DnsOverHttps dns,
    RRType type,
    String domain,
  ) async {
    try {
      return await dns.lookupDataByRRType(domain, type);
    } catch (e) {
      return [];
    }
  }

  /// 安全查询 SOA 记录
  static Future<String?> _safeLookupSoa(DnsOverHttps dns, String domain) async {
    try {
      final records = await dns.lookupDataByRRType(domain, RRType.SOA);
      return records.isNotEmpty ? records.first : null;
    } catch (e) {
      return null;
    }
  }

  /// 清理输入域名
  static String _sanitizeDomain(String input) {
    var domain = input.trim();
    if (domain.startsWith('http://')) domain = domain.substring(7);
    if (domain.startsWith('https://')) domain = domain.substring(8);
    final slashIndex = domain.indexOf('/');
    if (slashIndex != -1) domain = domain.substring(0, slashIndex);
    final colonIndex = domain.indexOf(':');
    if (colonIndex != -1 && !domain.contains('.')) {
      domain = domain.substring(0, colonIndex);
    }
    if (domain.endsWith('.')) domain = domain.substring(0, domain.length - 1);
    return domain.toLowerCase();
  }
}
