import 'package:get/get.dart';

import '../../widgets/chat/fquser_widget.dart';
import '../../widgets/chat/recent_chat_widget.dart';

class RecentChatController extends GetxController {
  final List<RecentChats> recentChats = [
    const RecentChats(
      date: '1 minutes ago',
      username: 'Amarr',
      subtitle: 'Online now',
      isOnline: true,
    ),
    const RecentChats(
      date: '10 minutes ago',
      username: 'Whit_goose',
      subtitle: 'Last seen 5 min ago',
      isOnline: false,
    ),
     const RecentChats(
      date: 'now',
      username: 'Besty',
      subtitle: 'Haha that\'s I love that 😂',
      isOnline: false,
    ),
   
    const RecentChats(
      date: '12 hours ago',
      username: 'Flash',
      subtitle: 'Last seen min 6 ago',
      isOnline: true,
    ),


    const RecentChats(
      date: 'Yesterday',
      username: 'sadpanda19',
      subtitle: 'OMG this is amazing! 😭',
      isOnline: true,
    ),
    const RecentChats(
      date: 'Jan 12 2023',
      username: 'GreenKoala',
      subtitle: 'Just idea for next time',
      isOnline: true,
    ),
    const RecentChats(
      date: 'Jan 06 2023',
      username: 'Broenfish258',
      subtitle: 'Haha that\'s terrifying😂',
      isOnline: false,
    ),
   
    const RecentChats(
      date: '2 hours ago',
      username: 'Bluesnake',
      subtitle: 'Online now',
      isOnline: true,
    ),
   
    const RecentChats(
      date: '2 hours ago',
      username: 'biteme39',
      subtitle: 'Online now',
      isOnline: true,
    ),
  ];

  final List<FQUsers> fqusers = const [
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
    FQUsers(
      imageUrl: 'assets/images/tay.jpg',
      isOnline: true,
    ),
  ];
}
