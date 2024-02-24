import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../../../services/firebase_constants.dart';
import '../../../services/firebase_service.dart';
import '../../utils/method_utils.dart';
import 'profile_tab_widget.dart';

class ProfileTabs extends StatelessWidget {
  const ProfileTabs({
    super.key,
    required this.userId,
    this.isProfilePage = true,
  });
  final String userId;
  final bool isProfilePage;
  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      delegate: SliverAppBarDelegate(
        TabBar(
          indicatorColor: Colors.black54,
          labelColor: Colors.black,
          tabs: [
            Tab(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseService.firebaseFirestore
                    .collection(firebaseWeBuzzCollection)
                    .where('authorId', isEqualTo: userId)
                    .where('isSuspended', isEqualTo: false)
                    .where('isPublished', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.hasError) {
                    return const Text('0');
                  }
                  return Text(
                    snapshot.data!.docs.isNotEmpty
                        ? MethodUtils.formatNumber(snapshot.data!.docs.length)
                        : 'No buzz',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            if (isProfilePage)
              // If page is a current user's page
              // show draft tab
              Tab(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseService.firebaseFirestore
                      .collection(firebaseWeBuzzCollection)
                      .where('authorId', isEqualTo: userId)
                      .where('isSuspended', isEqualTo: false)
                      .where('isPublished', isEqualTo: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.hasError) {
                      return const Text('Draft 0');
                    }
                    return Text(
                      'Draft ${MethodUtils.formatNumber(snapshot.data!.docs.length)}',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
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
}
