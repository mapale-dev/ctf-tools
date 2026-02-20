import '../utils/dns_utils.dart';

void main() async {
  final result = await DnsUtils.queryAll('baidu.com');
  print(result);

  DnsUtils.dispose();
}