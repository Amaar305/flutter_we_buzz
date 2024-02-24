import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

import 'api_keys.dart';


class BotService {
  final url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$botApi';

  Future<String?> getData(String text) async {
    try {
      final header = {'Content-Type': 'application/json'};

      var data = {
        "contents": [
          {
            "parts": [
              {"text": text}
            ]
          }
        ]
      };
      String answer = '';

      final response = await http.post(
        Uri.parse(url),
        headers: header,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // log(result);
        answer = result['candidates'][0]['content']['parts'][0]['text'];
      } else {
        log('Error');
      }

      return answer;
    } catch (e) {
      if (kDebugMode) {
        print('erroe occured');
      }
      return null;
    }
  }
}
