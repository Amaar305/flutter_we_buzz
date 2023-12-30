import 'package:flutter/material.dart';

import '../../../../../model/we_buzz_user_model.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/rounded_image_network.dart';
import '../../add_users_page/components/user_online_condition.dart';

class MemberListWidget extends StatelessWidget {
  const MemberListWidget({
    super.key,
    required this.isAdmin,
    required this.member,
    required this.height,
    this.onTap,
    this.canShowDeleteAction = false,
    this.onPressed,
  });
  final WeBuzzUser member;
  final bool isAdmin;
  final bool canShowDeleteAction;
  final double height;

  final void Function()? onTap;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.all(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: ListTile(
          minVerticalPadding: height * 0.20,
          leading: RoundedImageNetworkWithStatusIndicator(
            onlineStatus: shouldDisplayOnlineStatus(member),
            key: UniqueKey(),
            size: height / 2,
            imageUrl: member.imageUrl != null
                ? member.imageUrl!
                : defaultProfileImage,
            isOnline: member.isOnline,
          ),
          title: Text(
            member.username,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: isAdmin
              ? const Text(
                  'Admin',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
                )
              : null,
          trailing: !isAdmin && canShowDeleteAction
              ? IconButton(
                  onPressed: onPressed,
                  icon: const Icon(Icons.delete),
                )
              : null,
        ),
      ),
    );
  }
}
