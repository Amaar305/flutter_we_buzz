import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';

import 'package:nb_utils/nb_utils.dart';

import '../../utils/constants.dart';
import '../../utils/method_utils.dart';
import '../../widgets/home/reusable_card.dart';
import '../../widgets/profile/profile_option_setting.dart';
import '../../widgets/profile/profile_tab_widget.dart';
import '../dashboard/my_app_controller.dart';
import '../home/home_controller.dart';
import '../settings/setting_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final buzzController = HomeController.instance;
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              // Appbar
              _buildSliverAppBar(size, context),
              //  Tabs
              _buildTabs(buzzController),
            ];
          },
          body: TabBarView(
            children: [
              _buildBuzzSection(context, buzzController),
              _buildDraft(context, buzzController),
              _buildAboutSection(),
            ],
          ),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Size size, BuildContext context) {
    return SliverAppBar(
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
                                backgroundImage: CachedNetworkImageProvider(
                                  controller.currentUser != null
                                      ? controller.currentUser!.imageUrl ??
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
                            GetBuilder<AppController>(builder: (controller) {
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
                              color: Theme.of(context).colorScheme.primary,
                              size: 15,
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                    fontSize: 16, fontStyle: FontStyle.italic
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
    );
  }

  Widget _buildTabs(HomeController buzzController) {
    return SliverPersistentHeader(
      delegate: SliverAppBarDelegate(
        TabBar(
          indicatorColor: Colors.black54,
          labelColor: Colors.black,
          tabs: [
            Tab(
              child: GetX<HomeController>(
                builder: (_) {
                  return Text(
                    'Buzz (${MethodUtils.formatNumber(
                      buzzController.weeBuzzItems
                          .where((buzz) =>
                              buzz.authorId ==
                                  FirebaseAuth.instance.currentUser!.uid &&
                              buzz.isPublished)
                          .length,
                    )})',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            Tab(
              child: GetX<HomeController>(builder: (_) {
                return Text(
                  'Draft (${MethodUtils.formatNumber(
                    buzzController.weeBuzzItems
                        .where((buzz) =>
                            buzz.authorId ==
                                FirebaseAuth.instance.currentUser!.uid &&
                            !buzz.isPublished)
                        .length,
                  )})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }),
            ),
            const Tab(
              child: Text(
                'About',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      pinned: true,
    );
  }

  Widget _buildBuzzSection(
      BuildContext context, HomeController buzzController) {
    return Padding(
      padding: EdgeInsets.only(
        top: 15,
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Obx(
        () {
          final myPost = buzzController.weeBuzzItems
              .where(
                (buzz) =>
                    buzz.authorId == FirebaseAuth.instance.currentUser!.uid &&
                    buzz.isPublished,
              )
              .toList();
          return myPost.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: myPost.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return ReusableCard(
                      normalWebuzz: myPost[index],
                    );
                  },
                )
              : const Center(
                  child: Text(
                    'No Buzz Yet!',
                    style: TextStyle(fontSize: 20),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
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
            GetBuilder<AppController>(
              builder: (controll) {
                if (controll.currentUser != null &&
                    controll.currentUser!.level != null) {
                  return BasicInfoWidget(
                    iconData: FontAwesomeIcons.stairs,
                    subtitle: controll.currentUser!.level ?? 'not set',
                    title: 'Level',
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
            const TitleSetting(title: 'Contact Information'),
            const SizedBox(height: 15),
            GetBuilder<AppController>(
              builder: (controller) {
                if (controller.currentUser != null) {
                  final email = controller.currentUser!.email.length >= 20
                      ? "${controller.currentUser!.email.substring(0, 20)}..."
                      : controller.currentUser!.email;
                  return BasicInfoWidget(
                    iconData: Icons.email,
                    subtitle: email,
                    title: 'Email',
                  );
                } else {
                  return const SizedBox();
                }
              },
            ),
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
                iconData: FluentSystemIcons.ic_fluent_calendar_date_filled,
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
    );
  }

  Widget _buildDraft(BuildContext context, HomeController buzzController) {
    return Padding(
      padding: EdgeInsets.only(
        top: 15,
        left: MediaQuery.of(context).size.width * 0.03,
        right: MediaQuery.of(context).size.width * 0.03,
      ),
      child: Obx(() {
        final myPost = buzzController.weeBuzzItems
            .where((buzz) =>
                buzz.authorId == FirebaseAuth.instance.currentUser!.uid &&
                !buzz.isPublished)
            .toList();
        return myPost.isNotEmpty
            ? ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: myPost.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ReusableCard(
                    normalWebuzz: myPost[index],
                  );
                },
              )
            : const Center(
                child: Text(
                  'No Draft Yet!',
                  style: TextStyle(fontSize: 20),
                ),
              );
      }),
    );
  }
}
