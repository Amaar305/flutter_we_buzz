import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:hi_tweet/model/user.dart';
import 'package:hi_tweet/views/pages/dashboard/dashboard_controller.dart';
import 'package:hi_tweet/views/utils/constants.dart';
import 'package:hi_tweet/views/widgets/home/reusable_card.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../utils/method_utils.dart';
import '../../widgets/profile/profile_option_setting.dart';
import '../../widgets/profile/profile_tab_widget.dart';
import '../home/home_controller.dart';
import 'view_profile_controller.dart';

// View profile page ----> To view profile of a user
class ViewProfilePage extends StatelessWidget {
  ViewProfilePage({super.key, required this.weBuzzUser});

  final WeBuzzUser weBuzzUser;

  final viewProfileController = ViewProfileController.viewProfileController;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final buzzController = HomeController.homeController;
    return Scaffold(
      floatingActionButton: Obx(() {
        return TextButton.icon(
          style: TextButton.styleFrom(
            backgroundColor: kPrimary.withOpacity(0.8),
          ),
          label: Text(
            viewProfileController.currentWeBuxxUser.value!.following
                    .contains(weBuzzUser.userId)
                ? 'UnFollow'
                : 'Follow',
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
            if (viewProfileController.currentWeBuxxUser.value!.following
                .contains(weBuzzUser.userId)) {
              viewProfileController.unfollowUser(weBuzzUser.userId);
            } else {
              viewProfileController.followUser(weBuzzUser);
            }
            // viewProfileController.followUser(weBuzzUser);
          },
        );
      }),
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
                                            weBuzzUser.imageUrl ??
                                                defaultProfileImage,
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
                                          weBuzzUser.name,
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
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      weBuzzUser.bio,
                                      textAlign: TextAlign.justify,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                      ),
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
                        text: 'Buzz',
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
                  // Filter and return the user's tweet
                  final myPost = buzzController.tweetBuzz
                      .where(
                        (buzz) => buzz.authorId == weBuzzUser.userId,
                      )
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
                      if (weBuzzUser.level != null)
                        BasicInfoWidget(
                          iconData: FontAwesomeIcons.stairs,
                          subtitle: weBuzzUser.level!,
                          title: 'Level',
                        ),
                      const TitleSetting(title: 'Contact Information'),
                      const SizedBox(height: 15),
                      BasicInfoWidget(
                        iconData: Icons.email,
                        subtitle: weBuzzUser.email,
                        title: 'Email',
                      ),
                      BasicInfoWidget(
                        iconData: Icons.phone,
                        subtitle: weBuzzUser.phone ?? 'not set',
                        title: 'Phone No.',
                      ),
                      BasicInfoWidget(
                        iconData:
                            FluentSystemIcons.ic_fluent_calendar_date_filled,
                        subtitle: MethodUtils.formatDateWithMonthAndDay(
                          // TODO get the month years and days
                          weBuzzUser.createdAt,
                        ),
                        title: 'Joined On',
                      ),
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
