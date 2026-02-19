import 'package:whois/whois.dart';

Future<void> main() async {
  final whoisResponse = await Whois.lookup('xeost.com');
  final parsedResponse = Whois.formatLookup(whoisResponse);
  print(parsedResponse);
}