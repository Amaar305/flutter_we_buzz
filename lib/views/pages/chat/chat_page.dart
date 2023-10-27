import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants.dart';
import 'recent_chat_controller.dart';

class ChatPage extends GetView<RecentChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: MediaQuery.of(context).size.height * 0.4,
            title: const Text('Direct Message'),
            centerTitle: false,
            // backgroundColor:
            //     Theme.of(context).colorScheme.secondary.withGreen(210),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.flag_outlined),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      _builtSearchUserField(context),
                      const SizedBox(height: 20),
                      Text(
                        'Frequently contacted',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 10),
                      _builtFQUserSection()
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverList.separated(
            itemCount: controller.recentChats.length,
            itemBuilder: (context, index) => controller.recentChats[index],
            separatorBuilder: (context, index) =>
                const Divider(indent: 20, thickness: 0.2, endIndent: 20),
          ),
        ],
        shrinkWrap: true,
      ),
    );
  }

  SingleChildScrollView _builtFQUserSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.fqusers,
      ),
    );
  }

  TextField _builtSearchUserField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 20.0,
        ),
        prefixIcon: const Icon(
          Icons.search,
          size: 30,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kDefaultGrey),
          borderRadius: BorderRadius.circular(50),
        ),
        fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        filled: true,
        hintText: "Search direct message...",
      ),
    );
  }
}
