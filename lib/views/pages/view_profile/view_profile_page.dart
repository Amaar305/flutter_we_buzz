import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/we_buzz_user_model.dart';
import '../../utils/constants.dart';
import '../../utils/method_utils.dart';
import '../../widgets/profile/buzz_section_widget.dart';
import '../../widgets/profile/profile_option_setting.dart';
import '../../widgets/profile/profile_tab_widget.dart';
import '../../widgets/profile/profile_tabs.dart';
import '../chat/add_users_page/add_users_controller.dart';
import '../dashboard/my_app_controller.dart';
import '../home/home_controller.dart';
import 'view_profile_controller.dart';

// View profile page ----> To view profile of a user
class ViewProfilePage extends GetView<ViewProfileController> {
  const ViewProfilePage({super.key, required this.weBuzzUser});

  final WeBuzzUser weBuzzUser;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton:
          weBuzzUser.userId != controller.currentUserID && !weBuzzUser.bot
              ? CustomFloatingActionButtonsForProfilePage(
                  weBuzzUser: weBuzzUser,
                  viewProfileController: controller,
                )
              : null,
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              // AppBar
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
                                  FullScreenWidget(
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
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weBuzzUser.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (weBuzzUser.isVerified) ...[
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.verified,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          size: 15,
                                        )
                                      ]
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Text(
                                      weBuzzUser.bio,
                                      textAlign: TextAlign.start,
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

              // Tab Titles
              ProfileTabs(userId: weBuzzUser.userId, isProfilePage: false),
            ];
          },
          body: TabBarView(
            children: [
              BuzzSectionWidget(userId: weBuzzUser.userId),
              Container(
                margin: const EdgeInsets.only(left: 16, top: 20, right: 16),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TitleSetting(title: 'Basic Information'),
                      const SizedBox(height: 15),

                      // User program
                      if (weBuzzUser.program != null)
                        BasicInfoWidget(
                          iconData: Icons.school,
                          subtitle: weBuzzUser.program!,
                          title: 'Program',
                        ),

                      // User lavel
                      if (weBuzzUser.level != null)
                        BasicInfoWidget(
                          iconData: FontAwesomeIcons.stairs,
                          subtitle: weBuzzUser.level!,
                          title: 'Level',
                        ),
                      const TitleSetting(title: 'Contact Information'),
                      const SizedBox(height: 15),

                      // User email
                      Builder(
                        builder: (context) {
                          final email = weBuzzUser.email.length >= 20
                              ? "${weBuzzUser.email.substring(0, 20)}..."
                              : weBuzzUser.email;
                          return GestureDetector(
                            onTap: () async {
                              await Clipboard.setData(
                                      ClipboardData(text: weBuzzUser.email))
                                  .then(
                                (value) {
                                  Get.back();
                                  toast('Email Copied');
                                },
                              );
                            },
                            child: BasicInfoWidget(
                              iconData: Icons.email,
                              subtitle: email,
                              title: 'Email',
                            ),
                          );
                        },
                      ),

                      // User phone
                      if (weBuzzUser.phone != null)
                        GestureDetector(
                          onTap: () {
                            MethodUtils.makePhoneCall(weBuzzUser.phone ?? '');
                          },
                          child: BasicInfoWidget(
                            iconData: Icons.phone,
                            subtitle: weBuzzUser.phone ?? 'not set',
                            title: 'Phone No.',
                          ),
                        ),

                      // Date of register
                      BasicInfoWidget(
                        iconData:
                            FluentSystemIcons.ic_fluent_calendar_date_filled,
                        subtitle: MethodUtils.getLastMessageTime(
                          time: weBuzzUser.createdAt.millisecondsSinceEpoch
                              .toString(),
                          showYear: true,
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

class CustomFloatingActionButtonsForProfilePage extends StatelessWidget {
  const CustomFloatingActionButtonsForProfilePage({
    super.key,
    required this.weBuzzUser,
    required this.viewProfileController,
  });

  final WeBuzzUser weBuzzUser;
  final ViewProfileController viewProfileController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                AddUsersController.instance.showDiaologForBlockingUser(
                  weBuzzUser,
                );
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              child: GetBuilder<AppController>(
                builder: (control) {
                  return Text(
                    control.currentUser == null
                        ? 'Block Warning!'
                        : control.currentUser!.blockedUsers
                                .contains(weBuzzUser.userId)
                            ? 'Unblock'
                            : 'Block',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.black),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
              label: Text(
                HomeController.instance.currenttUsersFollowers
                            .contains(weBuzzUser.userId) &&
                        HomeController.instance.currenttUsersFollowing
                            .contains(weBuzzUser.userId)
                    ? 'Friends'
                    : HomeController.instance.currenttUsersFollowing
                            .contains(weBuzzUser.userId)
                        ? 'UnFollow'
                        : 'Follow'
                            '',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: Colors.black),
              ),
              icon: Icon(
                HomeController.instance.currenttUsersFollowers
                            .contains(weBuzzUser.userId) &&
                        HomeController.instance.currenttUsersFollowing
                            .contains(weBuzzUser.userId)
                    ? Icons.person
                    : HomeController.instance.currenttUsersFollowing
                            .contains(weBuzzUser.userId)
                        ? Icons.person_off_outlined
                        : Icons.person_add_alt_1_outlined,
                size: 30,
                color: Colors.black,
              ),
              onPressed: () {
                if (HomeController.instance.currenttUsersFollowing
                    .contains(weBuzzUser.userId)) {
                  viewProfileController.unfollowUser(weBuzzUser.userId);
                } else {
                  viewProfileController.followUser(weBuzzUser);
                }
                // viewProfileController.followUser(weBuzzUser);
              },
            ),
          ],
        );
      },
    );
  }
}
