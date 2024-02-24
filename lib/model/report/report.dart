import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  String id; // Report ID
  String reporterUserId; // ID of the user reporting
  String reportedItemId; // ID of the reported post, user, chat, or group chat
  ReportType reportType; // Type of the report (post, user, chat, group chat)
  String description; // Additional description from the reporter
  Timestamp? timestamp; // Time when the report was created
  List<String>
      lastThreeMessages; // Last three messages (only for chat and group chat reports)

  Report({
    required this.id,
    required this.reporterUserId,
    required this.reportedItemId,
    required this.reportType,
    required this.description,
    required this.lastThreeMessages,
    this.timestamp,
  });

  // Convert the Report instance to a Map for Firestore
  Map<String, dynamic> toMap() {
    String reportTypes;
    switch (reportType) {
      case ReportType.buzz:
        reportTypes = ReportType.buzz.name;
        break;
      case ReportType.user:
        reportTypes = ReportType.user.name;
        break;
      case ReportType.chat:
        reportTypes = ReportType.chat.name;
        break;
      case ReportType.groupChat:
        reportTypes = ReportType.groupChat.name;
        break;
      default:
        reportTypes = "";
    }
    return {
      'reporterUserId': reporterUserId,
      'reportedItemId': reportedItemId,
      'reportType': reportTypes,
      'description': description,
      'timestamp': timestamp ?? Timestamp.now(),
      'lastThreeMessages': lastThreeMessages,
    };
  }

  // Create a Report instance from a Firestore document snapshot
  factory Report.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    ReportType reportType;
    List<String> lastThreeMessages = (data['lastThreeMessages'] as List)
        .map((lastThreeMessages) => lastThreeMessages.toString())
        .toList();
    switch (data['reportType']) {
      case 'buzz':
        reportType = ReportType.buzz;

        break;
      case 'user':
        reportType = ReportType.user;

        break;
      case 'chat':
        reportType = ReportType.chat;

        break;
      case 'groupChat':
        reportType = ReportType.groupChat;

        break;
      default:
        reportType = ReportType.unknown;
    }
    return Report(
      id: snapshot.id,
      reporterUserId: data['reporterUserId'],
      reportedItemId: data['reportedItemId'],
      reportType: reportType,
      description: data['description'],
      timestamp: data['timestamp'] as Timestamp,
      lastThreeMessages: lastThreeMessages,
    );
  }
}

// Enum to represent different types of reports
enum ReportType {
  buzz,
  buzzReply,
  user,
  chat,
  groupChat,
  unknown,
}
