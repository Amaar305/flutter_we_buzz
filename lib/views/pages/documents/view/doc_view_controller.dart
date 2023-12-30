import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class DocumentViewController extends GetxController {
  String? pdfFlePath;

  Future<String> downloadAndSavePdf(String url, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    if (await file.exists()) {
      return file.path;
    }
    final response = await http.get(Uri.parse(url));
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }

  void loadPdf(String url, String fileName) async {
    pdfFlePath = await downloadAndSavePdf(url, fileName);
    update();
  }
}
