import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../model/we_buzz_model.dart';
import '../../../widgets/home/reusable_card.dart';
import '../home_controller.dart';
import 'reply_controller.dart';

late double _deviceHeight;
late double _deviceWidth;

class RepliesPage extends GetView<ReplyController> {
  const RepliesPage({super.key});
  static const routeName = '/replies-page';

  @override
  Widget build(BuildContext context) {
    final webuzz = ModalRoute.of(context)!.settings.arguments as WeBuzz;
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return _buildUI(webuzz);
  }

  Widget _buildUI(WeBuzz webuzz) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reply'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.03,
          vertical: _deviceHeight * 0.02,
        ),
        width: _deviceWidth * 0.97,
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
      child: FutureBuilder(
        future: HomeController.instance.getReplies(webuzz),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            // if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
              return const SizedBox();

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
                      if (index == 0) {
                        return ReusableCard(
                          normalWebuzz: buzzes[index],
                        );
                      } else {
                        return ReusableCard(
                          normalWebuzz: buzzes[index],
                          snapShotWebuzz: buzzes[index],
                        );
                      }
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
                return const SizedBox();
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
              maxLines: null,
              decoration: InputDecoration(
                  hintText: 'Reply here...',
                  hintStyle: TextStyle(
                      color: Theme.of(Get.context!).colorScheme.primary),
                  border: InputBorder.none),
            ),
          ),
          // Adding some space
          SizedBox(
            width: MediaQuery.of(Get.context!).size.width * .02,
          ),
          MaterialButton(
            onPressed: () async {
              controller.reply(weBuzz);
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
