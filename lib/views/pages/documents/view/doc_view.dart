import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/documents/view/doc_view_controller.dart';
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class DocumentView extends GetView<DocumentViewController> {
  const DocumentView({super.key, required this.url, required this.title});
  final String url;
  final String title;

  @override
  Widget build(BuildContext context) {
    controller.loadPdf(url, title);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          children: [
            GetBuilder<DocumentViewController>(
              builder: (controller) {
                if (controller.pdfFlePath != null) {
                  return Expanded(
                    child: SizedBox(
                      child: PdfView(path: controller.pdfFlePath!),
                    ),
                  );
                } else {
                  return ElevatedButton(
                    onPressed: () {
                      controller.loadPdf(url, title);
                    },
                    child: const Text('Load File'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
