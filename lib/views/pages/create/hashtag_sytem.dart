import 'dart:convert';

import 'package:nb_utils/nb_utils.dart';
import 'package:http/http.dart' as http;

import '../../../services/firebase_constants.dart';

List<String> hashTagSystem(String text) {
  List<String> hashtags = [];
  final hashtagRegx = RegExp(r'#\w+');

  final matches = hashtagRegx.allMatches(text);

  for (var matche in matches) {
    if (matche.group(0) != null) {
      hashtags.add(matche.group(0)!);
      log('${matche.group(0)} the Matches');
    }
  }
  return hashtags;
}

List<String> extractUrls(String text) {
  List<String> urls = [];
  RegExp urlRegExp = RegExp(r"(https?://\S+)", caseSensitive: false);

  Iterable<Match> matches = urlRegExp.allMatches(text);

  for (Match match in matches) {
    urls.add(match.group(0)!);
  }

  return urls;
}

Future<List<String>> filterSafeUrls(List<String> urls) async {
  String url =
      'https://safebrowsing.googleapis.com/v4/threatMatches:find?key=$googleApiKey';

  List<String> safeUrls = [];

  for (String u in urls) {
    final response = await http.post(Uri.parse(url),
        body: jsonEncode({
          'client': {
            'clientId': 'composite-cable-411108',
            'clientVersion': '1.5.2',
          },
          'threatInfo': {
            'threatTypes': [
              'MALWARE',
              'SOCIAL_ENGINEERING',
              'UNWANTED_SOFTWARE',
              'POTENTIALLY_HARMFUL_APPLICATION'
            ],
            'platformTypes': ['ANY_PLATFORM'],
            'threatEntryTypes': ['URL'],
            'threatEntries': [
              {'url': u}
            ],
          },
        }));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('matches') && data['matches'].isEmpty) {
        safeUrls.add(u);
      }
    }
  }
  return safeUrls;
}
