import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';

import '../../widgets/create/my_iconbutton.dart';
import 'create_controller.dart';

class CreateTweetPage extends GetView<CreateTweetController> {
  const CreateTweetPage({super.key});

  static const routeName = '/create-tweet';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                    'New Buzz',
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
                    const SizedBox(height: 12),
                    GetBuilder<CreateTweetController>(
                      builder: (_) {
                        if (controller.pickedImagePath != null) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: controller.isImagePicked
                                ? size.height * 0.32
                                : 0,
                            curve: Curves.fastEaseInToSlowEaseOut,
                            child: Stack(
                              clipBehavior: Clip.antiAlias,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.file(
                                    controller.pickedImagePath!,
                                    fit: BoxFit.cover,
                                    width: double.maxFinite,
                                  ),
                                ),
                                Positioned(
                                  left: 300,
                                  right: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: GestureDetector(
                                      onTap: () =>
                                          controller.cancleImage(false),
                                      child: const CircleAvatar(
                                        radius: 15,
                                        backgroundColor: Colors.white54,
                                        child: Icon(Icons.close),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Row(
                          children: [
                            MyIconButton(
                              color: Theme.of(context).colorScheme.primary,
                              backgroundColor: Colors.black,
                              onPressed: () {
                                controller.selectImage();
                              },
                              icon: Icons.image_outlined,
                            ),
                            MyIconButton(
                              color: Colors.black,
                              backgroundColor: Colors.grey.shade200,
                              onPressed: () {},
                              icon: Icons.gif,
                            ),
                            MyIconButton(
                              color: Colors.black,
                              backgroundColor: Colors.grey.shade200,
                              onPressed: () {},
                              icon: Icons.location_on_outlined,
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            controller.createTweet();
                          },
                          style: TextButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
