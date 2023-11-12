import 'package:nb_utils/nb_utils.dart';

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
