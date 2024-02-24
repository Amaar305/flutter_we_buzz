import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_enum_type.dart';

class MessageModel {
  final String docID;
  final String senderID;
  final String content;
  final String read;
  final String sentTime;

  final MessageType type;
  final MessageStatus status;

  MessageModel({
    required this.docID,
    required this.senderID,
    required this.content,
    required this.type,
    required this.status,
    required this.sentTime,
    required this.read,
  });

  Map<String, dynamic> toMap() {
    String messageType;
    String messageStatus;
    switch (type) {
      case MessageType.text:
        messageType = "text";
        break;
      case MessageType.image:
        messageType = "image";
        break;
      case MessageType.audio:
        messageType = "audio";
        break;
      case MessageType.video:
        messageType = "video";
        break;
      default:
        messageType = "";
    }

    switch (status) {
      case MessageStatus.notSent:
        messageStatus = "notSent";
        break;
      case MessageStatus.notView:
        messageStatus = "notView";
        break;
      case MessageStatus.viewed:
        messageStatus = "viewed";
        break;

      default:
        messageStatus = "";
    }
    return <String, dynamic>{
      'senderID': senderID,
      'content': content,
      'type': messageType,
      'status': messageStatus,
      'sentTime': sentTime,
      'docID': docID,
      'read': read,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json, String docID) {
    MessageType messageType;
    MessageStatus messageStatus;
    switch (json['type']) {
      case "text":
        messageType = MessageType.text;
        break;
      case "image":
        messageType = MessageType.image;
        break;
      case "audio":
        messageType = MessageType.audio;
        break;
      case "video":
        messageType = MessageType.video;
        break;
      default:
        messageType = MessageType.unknown;
    }

    switch (json['status']) {
      case "notSent":
        messageStatus = MessageStatus.notSent;
        break;
      case "notView":
        messageStatus = MessageStatus.notView;
        break;
      case "viewed":
        messageStatus = MessageStatus.viewed;
        break;

      default:
        messageStatus = MessageStatus.unknown;
    }
    return MessageModel(
      senderID: json['senderID'] as String,
      content: json['content'] as String,
      type: messageType,
      status: messageStatus,
      sentTime: json['sentTime'] as String,
      docID: docID,
      read: json['read'] as String,
    );
  }

  factory MessageModel.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    Map<String, dynamic> json = documentSnapshot.data() as Map<String, dynamic>;
    final docID = documentSnapshot.id;
    return MessageModel.fromJson(json, docID);
  }
}
