import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hi_tweet/views/pages/sponsor/sponsor_controller.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/my_buttons.dart';
import 'package:hi_tweet/views/widgets/home/my_drop_button.dart';
import 'package:hi_tweet/views/widgets/home/my_textfield.dart';

import '../../../model/we_buzz_model.dart';

class SponsorPage extends GetView<SponsorController> {
  SponsorPage({this.sponsor, super.key}) {
    if (sponsor == null) return;
    controller.textEditingController.text = sponsor!.content;
    controller.phoneEditingController.text = sponsor!.whatsapp ?? '';
    controller.webUrlEditingController.text = sponsor!.websiteUrl ?? '';
  }

  static const String routeName = '/sponsor-page';
  final WeBuzz? sponsor;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          sponsor == null
              ? 'Create sponsor'
              : sponsor!.expired || !sponsor!.hasPaid
                  ? 'Update sponsor'
                  : 'Update sponsor',
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      floatingActionButton: GetBuilder<SponsorController>(
        builder: (_) {
          return MaterialButton(
            onPressed: null,
            child: Text(
              '₦${controller.amount}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimary,
              ),
            ),
          );
        },
      ),
      body: Padding(
        padding: kPadding,
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: controller.textEditingController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Start a buzz...',
                  ),
                  maxLength: 250,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Content cannot be null';
                    }
                    return null;
                  },
                ),
                MyInputField(
                  controller: controller.phoneEditingController,
                  hintext: 'Whatsapp',
                  iconData: FontAwesomeIcons.whatsapp,
                  label: 'Your Whatsapp',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Whatsapp number must be provided';
                    }

                    if (!value.isPhoneNumber) {
                      return 'Not a phone number!';
                    }
                    if (value.length < 11 || value.length > 11) {
                      return 'Invalid phone number!';
                    }
                    return null;
                  },
                ),
                MyInputField(
                  controller: controller.webUrlEditingController,
                  hintext: 'Website Url',
                  iconData: FontAwesomeIcons.link,
                  label: 'Your Official Website',
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value!.isNotEmpty) {
                      if (!value.isURL) {
                        return 'Invalid Url';
                      }
                    }
                    return null;
                  },
                ),
                MyDropDownButtonForm(
                  items: controller.weeks.map((e) => e.title).toList(),
                  label:
                      sponsor == null ? 'Select Duration' : 'Update Duration',
                  hintext: 'Duration',
                  onChanged: (value) {
                    final week = controller.weeks
                        .firstWhere((week) => week.title == value!);

                    controller.setAmount(week.duration);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Select a duration';
                    }

                    return null;
                  },
                ),
                if (sponsor == null)
                  GetBuilder<SponsorController>(
                    builder: (_) {
                      return MaterialButton(
                        onPressed: () {
                          controller.seletImages();
                        },
                        child: Text(
                          controller.imagePicked
                              ? 'Images Picked'
                              : 'Select three images',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kPrimary,
                          ),
                        ),
                      );
                    },
                  )
                else
                  const SizedBox(height: 20),
                MyRegistrationButton(
                  primaryColor: const Color(0xFF1c1c1c),
                  secondaryColor: Colors.white,
                  title: sponsor == null ? 'Submit' : 'Update',
                  onPressed: () {
                    final isValid = controller.formKey.currentState!.validate();
                    FocusScope.of(context).unfocus();
                    if (isValid) {
                      controller.formKey.currentState!.save();
                      if (sponsor != null) {
                        controller.updateSponsor(context, sponsor!);
                      } else {
                        controller.submit(context);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
