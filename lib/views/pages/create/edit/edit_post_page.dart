import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../utils/constants.dart';
import '../components/app_bar.dart';
import '../components/text_form_field.dart';
import '../hashtag_sytem.dart';
import 'edit_post_controller.dart';

class EditPostPage extends GetView<EditPostController> {
  EditPostPage(this.weBuzz, this.isReply, this.originalId, {super.key}) {
    controller.textEditingController.text = weBuzz.content;
  }
  final String originalId;
  final WeBuzz weBuzz;
  final bool isReply;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kPadding,
          child: Column(
            children: [
              const CreateBuzzAppBar(title: 'Update Buzz'),
              Expanded(
                child: ListView(
                  children: [
                    CreateBuzzTextFormField(
                      controller: controller.textEditingController,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      final hashtags =
                          hashTagSystem(controller.textEditingController.text);

                      WeBuzz updatedBuzz = weBuzz.copyWith(
                        content: controller.textEditingController.text,
                        hashtags: hashtags,
                      );
                      if (isReply) {
                        controller.updateReply(updatedBuzz, originalId);
                      } else {
                        controller.updateBuzz(updatedBuzz);
                      }
                    },
                    style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(Get.context!).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
