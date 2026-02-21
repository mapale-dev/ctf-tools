import 'package:dns_client/dns_client.dart';

import '../utils/dns_utils.dart';

void main() async {
  final result = await DnsUtils.queryAllWith(DnsOverHttps.dnsSb(),'baidu.com');
  print(result);
}