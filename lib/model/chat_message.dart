// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'message_enum_type.dart';

class ChatMessage {
  final String docID;
  final String senderID;
  final String content;
  final String read;

  final MessageType type;
  final DateTime sentTime;

  ChatMessage({
    required this.senderID,
    required this.content,
    required this.type,
    required this.sentTime,
    required this.docID,
    required this.read,
  });

  Map<String, dynamic> toMap() {
    String messageType;
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
    return <String, dynamic>{
      'senderID': senderID,
      'content': content,
      'type': messageType,
      'sentTime': Timestamp.fromDate(sentTime),
      'docID': docID,
      'read': read,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json, String docID) {
    MessageType messageType;
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
    return ChatMessage(
      senderID: json['senderID'] as String,
      content: json['content'] as String,
      type: messageType,
      sentTime: json['sentTime'].toDate(),
      docID: docID,
      read: json['read'],
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage.fromJson(data, doc.id);
  }
}
