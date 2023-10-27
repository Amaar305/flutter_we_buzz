import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/services/current_user.dart';
import 'package:hi_tweet/views/pages/dashboard/dashboard_controller.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/reusable_card.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../utils/method_utils.dart';
import '../../widgets/profile/profile_option_setting.dart';
import '../home/home_controller.dart';
import '../settings/setting_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: kPrimary.withOpacity(0.8),
        ),
        label: Text(
          'Follow',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Colors.black),
        ),
        icon: const Icon(
          Icons.add,
          size: 30,
          color: Colors.black,
        ),
        onPressed: () {
          // AppController.instance.followUser();
        },
      ),
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
                                                            .imageUrl !=
                                                        null
                                                    ? controller
                                                        .currentUser!.imageUrl!
                                                    : 'https://firebasestorage.googleapis.com/v0/b/my-hi-tweet.appspot.com/o/933-9332131_profile-picture-default-png.png?alt=media&token=7c98e0e7-c3bf-454e-8e7b-b0ec4b2ec900&_gl=1*1w37gdj*_ga*MTUxNDc4MTA2OC4xNjc1OTQwOTc4*_ga_CW55HF8NVT*MTY5ODMxOTk3Mi42MS4xLjE2OTgzMjAwMzEuMS4wLjA.'
                                                : 'https://firebasestorage.googleapis.com/v0/b/my-hi-tweet.appspot.com/o/933-9332131_profile-picture-default-png.png?alt=media&token=7c98e0e7-c3bf-454e-8e7b-b0ec4b2ec900&_gl=1*1w37gdj*_ga*MTUxNDc4MTA2OC4xNjc1OTQwOTc4*_ga_CW55HF8NVT*MTY5ODMxOTk3Mi42MS4xLjE2OTgzMjAwMzEuMS4wLjA.',
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
                                              ? controller.currentUser!.bio ??
                                                  'not set'
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
                delegate: _SliverAppBarDelegate(
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
                child: GetBuilder<HomeController>(builder: (controll) {
                  final myPost = controll.tweetBuzz
                      .where((buzz) =>
                          buzz.authorId ==
                          CurrentLoggeedInUser.currentUserId!.uid)
                      .toList();
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: myPost.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ReusableCard(tweet: myPost[index]);
                    },
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

class TitleSetting extends StatelessWidget {
  const TitleSetting({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.bodyLarge,
      textAlign: TextAlign.start,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverAppBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
