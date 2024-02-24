import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id; // You can use this to uniquely identify each notification
  final NotificationType type; // "Post creation", "Post liking", etc.
  final String senderId; // ID of the user who triggered the notification
  final String
      recipientId; // ID of the user who should receive the notification
  final String postOrUserReference; // Reference to the relevant post or user
  final DateTime timestamp; // Time when the notification was created
  bool isRead; // To track whether the notification has been read by the user

  NotificationModel({
    required this.id,
    required this.type,
    required this.senderId,
    required this.recipientId,
    required this.postOrUserReference,
    required this.timestamp,
    this.isRead = false,
  });

  // Factory method to create a NotificationModel from Firestore document data
  factory NotificationModel.fromJson(
    Map<String, dynamic> data,
    String documentId,
  ) {
    NotificationType notificationType;
    switch (data['type']) {
      case 'postCreation':
        notificationType = NotificationType.postComment;
        break;
      case 'postLiking':
        notificationType = NotificationType.postLiking;
        break;
      case 'postComment':
        notificationType = NotificationType.postComment;
        break;
      case 'postSaved':
        notificationType = NotificationType.postSaved;
        break;
      case 'userFollows':
        notificationType = NotificationType.userFollows;
        break;
      case 'groupChat':
        notificationType = NotificationType.groupChat;
        break;
      case 'chat':
        notificationType = NotificationType.chat;
        break;
      default:
        notificationType = NotificationType.unknown;
    }

    return NotificationModel(
      id: documentId,
      type: notificationType,
      senderId: data['senderId'],
      recipientId: data['recipientId'],
      postOrUserReference: data['postOrUserReference'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }
  factory NotificationModel.fromDocument(DocumentSnapshot documentSnapshot) {
    final data = documentSnapshot.data() as Map<String, dynamic>;
    return NotificationModel.fromJson(data, documentSnapshot.id);
  }

  // Method to convert the NotificationModel to a Map for Firestore
  Map<String, dynamic> toMap() {
    String notificationType;

    switch (type) {
      case NotificationType.postCreation:
        notificationType = 'postCreation';
        break;
      case NotificationType.postLiking:
        notificationType = 'postLiking';
        break;
      case NotificationType.postComment:
        notificationType = 'postComment';
        break;
      case NotificationType.postSaved:
        notificationType = 'postSaved';
        break;
      case NotificationType.userFollows:
        notificationType = 'userFollows';
        break;
      case NotificationType.groupChat:
        notificationType = 'groupChat';
        break;
      case NotificationType.chat:
        notificationType = 'chat';
        break;
      default:
        notificationType = '';
    }
    return {
      'type': notificationType,
      'senderId': senderId,
      'recipientId': recipientId,
      'postOrUserReference': postOrUserReference,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}

enum NotificationType {
  postCreation,
  postLiking,
  postComment,
  postSaved,
  userFollows,
  groupChat,
  chat,
  staff,
  classRep,
  unknown
}
