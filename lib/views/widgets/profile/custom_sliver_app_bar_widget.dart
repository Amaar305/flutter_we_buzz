import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_icons/fluentui_icons.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../pages/dashboard/my_app_controller.dart';
import '../../pages/settings/setting_page.dart';
import '../../utils/constants.dart';
import '../home/custom_back_button.dart';

class CustomSliverAppBarWidget extends StatelessWidget {
  const CustomSliverAppBarWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: size.height * 0.44,
      floating: false,
      pinned: true,
      titleSpacing: 0,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Get.toNamed(SettingPage.routeName),
            child: const CustomeThingForWidget(
              child: Icon(
                FluentSystemIcons.ic_fluent_settings_regular,
                size: 32,
              ),
            ),
          ),
        ),
      ],
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Profile',
          style: GoogleFonts.pacifico(
            textStyle: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
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
                        GetBuilder<AppController>(
                          builder: (control) {
                            if (control.currentUser == null) {
                              return const SizedBox();
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  control.currentUser == null
                                      ? 'loading..'
                                      : control.currentUser!.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (control.currentUser!.isVerified) ...[
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.verified,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 15,
                                  ),
                                ]
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GetBuilder<AppController>(
                            builder: (controller) {
                              if (controller.currentUser != null) {
                                return Text(
                                  controller.currentUser!.bio,
                                  textAlign: TextAlign.start,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              } else {
                                return const Text(
                                  'loading...',
                                  textAlign: TextAlign.start,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }
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
}
