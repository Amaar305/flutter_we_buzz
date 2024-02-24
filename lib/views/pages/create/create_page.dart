import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/utils/constants.dart';

import '../../widgets/create/my_iconbutton.dart';
import 'components/app_bar.dart';
import 'components/text_form_field.dart';
import 'create_controller.dart';

class CreateBuzzPage extends GetView<CreateBuzzController> {
  const CreateBuzzPage({this.isStaff, super.key});
  final bool? isStaff;

  static const routeName = '/create-buzz';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: kPadding,
          child: Column(
            children: [
              const CreateBuzzAppBar(title: 'New Buzz'),
              Expanded(
                child: ListView(
                  children: [
                    CreateBuzzTextFormField(
                      controller: controller.textEditingController,
                    ),
                    const SizedBox(height: 12),
                    GetBuilder<CreateBuzzController>(
                      builder: (_) {
                        if (controller.pickedImagePath != null) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: controller.isImagePicked
                                ? size.height * 0.32
                                : 0,
                            curve: Curves.fastEaseInToSlowEaseOut,
                            child: Stack(
                              alignment: Alignment.topRight,
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
                                  top: 5,
                                  right: 5,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: kDefaultGrey.withOpacity(0.5),
                                      // borderRadius: BorderRadius.circular(10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: InkWell(
                                      onTap: () => controller.cancleImage(),
                                      child: const Icon(Icons.close),
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
                    _buitBuzzActionButton(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buitBuzzActionButton(BuildContext context) {
    return Row(
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
              onPressed: () {
                controller.pickedGIF();
              },
              icon: Icons.gif,
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            controller.createTweet(isStaff: isStaff);
          },
          style: TextButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
          child: const Text(
            'Buzz Now',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ],
    );
  }
}
