import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../utils/constants.dart';
import '../../../documents/components/program_card_widget.dart';
import 'report_controller.dart';

class ReportCenterPage extends GetView<ReportsController> {
  const ReportCenterPage({super.key});
  static const String routeName = '/report-center-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Report Center',
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
      body: GridView.builder(
        itemCount: controller.reportsType.length,
        padding: kPadding,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (context, index) {
          final title = controller.reportsType[index];
          return ProgramGrid(
            icon: index == 0 ? Icons.person : Icons.post_add,
            title: title,
            onTap: () => controller.navigate(index),
          );
        },
      ),
    );
  }
}
