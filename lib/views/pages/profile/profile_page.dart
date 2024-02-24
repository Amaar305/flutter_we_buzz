import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../widgets/profile/about_section_widget.dart';
import '../../widgets/profile/buzz_section_widget.dart';
import '../../widgets/profile/custom_sliver_app_bar_widget.dart';
import '../../widgets/profile/profile_tabs.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final userId = FirebaseAuth.instance.currentUser != null
        ? FirebaseAuth.instance.currentUser!.uid
        : '';
    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              // Appbar
              CustomSliverAppBarWidget(size: size),
              //  Tabs
              ProfileTabs(userId: userId)
            ];
          },
          body: TabBarView(
            children: [
              BuzzSectionWidget(userId: userId),
              BuzzSectionWidget(isDraft: true, userId: userId),
              const AbouSectionWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
