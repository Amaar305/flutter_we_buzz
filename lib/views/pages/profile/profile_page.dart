import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/views/pages/dashboard/dashboard_controller.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/reusable_card.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../utils/method_utils.dart';
import '../../widgets/profile/profile_option_setting.dart';
import '../../widgets/profile/profile_tab_widget.dart';
import '../home/home_controller.dart';
import '../settings/setting_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final buzzController = HomeController.homeController;
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                expandedHeight: size.height * 0.44,
                floating: false,
                pinned: true,
                titleSpacing: 0,
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed(SettingPage.routeName),
                    icon: const Icon(
                      FluentSystemIcons.ic_fluent_settings_regular,
                      size: 32,
                    ),
                  ),
                ],
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Profile',
                    style: Theme.of(context).appBarTheme.titleTextStyle,
                  ),
                ),
                centerTitle: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    color: context.scaffoldBackgroundColor,
                    child: Stack(
                      children: [
                        Container(
                          height: size.height * 0.22,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                              bottomLeft: Radius.circular(20.0),
                            ),
                            child: Image.asset(
                              'assets/images/ymsu.jpg',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: size.height * 0.22,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(
                                top: size.height * 0.12,
                              ),
                              child: Column(
                                children: [
                                  GetBuilder<AppController>(
                                    builder: (controller) {
                                      return FullScreenWidget(
                                        disposeLevel: DisposeLevel.High,
                                        backgroundIsTransparent: true,
                                        child: CircleAvatar(
                                          radius: size.height * 0.08,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                            controller.currentUser != null
                                                ? controller.currentUser!
                                                        .imageUrl ??
                                                    defaultProfileImage
                                                : defaultProfileImage,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GetBuilder<AppController>(
                                          builder: (controller) {
                                        return Text(
                                          controller.currentUser == null
                                              ? 'loading..'
                                              : controller.currentUser!.name,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.verified,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 15,
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: GetBuilder<AppController>(
                                      builder: (controller) {
                                        if (controller.currentUser != null) {
                                        } else {}
                                        return Text(
                                          controller.currentUser != null
                                              ? controller.currentUser!.bio
                                              : 'loading',
                                          textAlign: TextAlign.justify,
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic
                                              // color: kDefaultGrey,
                                              ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                delegate: SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(
                        text: 'Tweet',
                        icon: Icon(
                          FluentSystemIcons.ic_fluent_drafts_regular,
                        ),
                      ),
                      Tab(
                        text: 'About',
                        icon: Icon(
                          FluentSystemIcons.ic_fluent_person_accounts_regular,
                        ),
                      ),
                    ],
                  ),
                ),
                pinned: true,
              ),
            ];
          },
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Obx(() {
                  final myPost = buzzController.tweetBuzz
                      .where((buzz) =>
                          buzz.authorId ==
                          FirebaseAuth.instance.currentUser!.uid)
                      .toList();
                  return myPost.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: myPost.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return ReusableCard(tweet: myPost[index]);
                          },
                        )
                      : const Center(
                          child: Text(
                            'No Buzz Yet!',
                            style: TextStyle(fontSize: 20),
                          ),
                        );
                }),
              ),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 20, right: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitleSetting(title: 'Basic Information'),
                      const SizedBox(height: 15),
                      const BasicInfoWidget(
                        iconData: Icons.school,
                        subtitle: 'Computer Science',
                        title: 'Department',
                      ),
                      GetBuilder<AppController>(builder: (controll) {
                        return BasicInfoWidget(
                          iconData: FontAwesomeIcons.stairs,
                          subtitle: controll.currentUser != null
                              ? controll.currentUser!.level ?? ''
                              : 'loading',
                          title: 'Level',
                        );
                      }),
                      const TitleSetting(title: 'Contact Information'),
                      const SizedBox(height: 15),
                      GetBuilder<AppController>(builder: (controller) {
                        return BasicInfoWidget(
                          iconData: Icons.email,
                          subtitle: controller.currentUser != null
                              ? controller.currentUser!.email
                              : 'loading...',
                          title: 'Email',
                        );
                      }),
                      GetBuilder<AppController>(builder: (controller) {
                        return BasicInfoWidget(
                          iconData: Icons.phone,
                          subtitle: controller.currentUser != null
                              ? controller.currentUser!.phone ?? 'not set'
                              : 'loading',
                          title: 'Phone No.',
                        );
                      }),
                      GetBuilder<AppController>(builder: (controller) {
                        return BasicInfoWidget(
                          iconData:
                              FluentSystemIcons.ic_fluent_calendar_date_filled,
                          subtitle: controller.currentUser != null
                              ? MethodUtils.formatDateWithMonthAndDay(
                                  controller.currentUser!.createdAt)
                              : 'loading..',
                          title: 'Joined On',
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
