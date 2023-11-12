import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../utils/constants.dart';
import '../hashtag_sytem.dart';
import 'edit_post_controller.dart';

class EditPostPage extends GetView<EditPostController> {
  EditPostPage(this.weBuzz, {super.key}) {
    controller.textEditingController.text = weBuzz.content;
  }
  final WeBuzz weBuzz;

  static const routeName = '/update-buzz';

  @override
  Widget build(BuildContext context) {
    return _buildUI();
  }

  Widget _buildUI() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kDefaultAppPadding,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                  ),
                  const Text(
                    'Update Buzz',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  children: [
                    TextFormField(
                      controller: controller.textEditingController,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Start a buzz...',
                      ),
                      maxLength: 250,
                      maxLines: 2,
                    ),
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
                      controller.updateBuzz(updatedBuzz);
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
                      'Post Now',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
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
