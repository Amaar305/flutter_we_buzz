import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../utils/constants.dart';
import '../../../../widgets/home/my_buttons.dart';
import 'report_bug_controller.dart';

class ReportBugPage extends GetView<ReportBugController> {
  const ReportBugPage({
    super.key,
  });
  static const String routeName = '/report-bugs-page';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        title: const Text('Report a Bug'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: kPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              16.height,
              const Text(
                'Go to the bug page and take a scerrenshot of it, or you could just describe it here.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              20.height,
              // 16.height,
              ElevatedButton(
                onPressed: controller.pickScreenshot,
                child: const Text('Pick Screenshot from Gallery'),
              ),
              16.height,

              GetBuilder<ReportBugController>(
                builder: (_) {
                  if (controller.screenshotFile != null) {
                    return SizedBox(
                      width: double.infinity,
                      height: MediaQuery.sizeOf(context).height * 0.25,
                      child: Image.file(
                        controller.screenshotFile!,
                        fit: BoxFit.fitHeight,
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),

              16.height,
              TextField(
                controller: controller.textEditingController,
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
                decoration: const InputDecoration(
                  // labelText: 'Describe the bug',
                  border: InputBorder.none,
                  hintText: 'type here...',
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              16.height,
              MyRegistrationButton(
                title: 'Submit',
                onPressed: () => controller.submitReportBug(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
