import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/firebase_service.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../widgets/home/cards/reusable_card.dart';
import '../../../widgets/home/cards/sponsor_card_widget.dart';
import 'reply_controller.dart';

class RepliesPage extends GetView<ReplyController> {
  const RepliesPage({super.key});
  static const routeName = '/replies-page';

  @override
  Widget build(BuildContext context) {
    final webuzz = ModalRoute.of(context)!.settings.arguments as WeBuzz;
    // Device's sizes
    final deviceHeight = MediaQuery.sizeOf(context).height;
    final deviceWidth = MediaQuery.sizeOf(context).width;
    return _buildUI(webuzz, deviceWidth, deviceHeight);
  }

  Widget _buildUI(WeBuzz webuzz, deviceWidth, deviceHeight) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buzz'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.03),
        // height: deviceHeight * 0.90,
        // width: deviceWidth * 0.97,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _repliesList(webuzz),
            _replyForm(webuzz),
          ],
        ),
      ),
    );
  }

  Widget _repliesList(WeBuzz webuzz) {
    return Expanded(
      child: StreamBuilder(
        stream: FirebaseService.getReplies(webuzz),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const Center(child: CircularProgressIndicator());

            // if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              final buzzes = snapshot.data;

              if (buzzes != null) {
                buzzes.insert(0, webuzz);
                if (buzzes.isNotEmpty) {
                  return ListView.builder(
                    itemCount: buzzes.length,
                    itemBuilder: (context, index) {
                      final buzz = buzzes[index];

                      if (index == 0) {
                        if (buzz.validSponsor()) {
                          return SponsorCard(
                            normalWebuzz: buzz,
                            originalId: buzz.docId,
                          );
                        }

                        if (!buzz.isSponsor) {
                          return ReusableCard(
                            normalWebuzz: buzz,
                            originalId: buzz.docId,
                          );
                        }
                      } else {
                        if (buzz.validSponsor()) {
                          return SponsorCard(
                            normalWebuzz: buzz,
                            snapShotWebuzz: buzz,
                            originalId: buzzes[0].docId,
                          );
                        }

                        if (!buzz.isSponsor) {
                          return ReusableCard(
                            normalWebuzz: buzz,
                            snapShotWebuzz: buzz,
                            originalId: buzzes[0].docId,
                          );
                        }
                      }
                      return null;

                      // if (index == 0) {
                      //   return ReusableCard(
                      //     normalWebuzz: buzzes[index],
                      //   );
                      // } else {
                      //   return ReusableCard(
                      //     normalWebuzz: buzzes[index],
                      //     snapShotWebuzz: buzzes[index],
                      //   );
                      // }
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'Be the first to reply',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }
              } else {
                return const Text(
                  'Couldn\'t load comments for this buzz',
                  style: TextStyle(fontSize: 18),
                ).center();
              }
          }
        },
      ),
    );
  }

  Widget _replyForm(WeBuzz weBuzz) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller.textEditingController,
              keyboardType: TextInputType.multiline,
              // maxLines: null,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'Reply here...',
                hintStyle: TextStyle(
                    color: Theme.of(Get.context!).colorScheme.primary),
                border: InputBorder.none,
              ),
            ),
          ),
          // Adding some space
          SizedBox(
            width: MediaQuery.of(Get.context!).size.width * .02,
          ),
          MaterialButton(
            onPressed: () async {
              await controller.reply(weBuzz);
            },
            shape: const CircleBorder(),
            color: Theme.of(Get.context!).colorScheme.primary,
            padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
            minWidth: 0,
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }
}
