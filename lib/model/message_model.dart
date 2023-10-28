import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hi_tweet/model/message_enum_type.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class Message {
  late final String told;
  late final String message;
  late final String read;
  late final String fromId;
  late final String sent;
  late final MessageType type;
  Message({
    required this.told,
    required this.message,
    required this.read,
    required this.type,
    required this.fromId,
    required this.sent,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'told': told,
      'message': message,
      'read': read,
      'type': type.name,
      'fromId': fromId,
      'sent': sent,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      told: map['told'] as String,
      message: map['message'] as String,
      read: map['read'] as String,
      type: map['type'] as String == MessageType.image.name
          ? MessageType.image
          : map['type'].toString() == MessageType.video.name
              ? MessageType.video
              : map['type'].toString() == MessageType.audio.name
                  ? MessageType.audio
                  : MessageType.text,
      fromId: map['fromId'] as String,
      sent: map['sent'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Message.fromDocument(DocumentSnapshot snapshot) =>
      Message.fromMap(snapshot.data() as Map<String, dynamic>);

  Message copyWith({
     String? told,
     String? message,
     String? read,
     String? fromId,
     String? sent,
     MessageType? type,
  }) {
    return Message(
      told: told ?? this.told,
      message: message ?? this.message,
      read: read ?? this.read,
      fromId: fromId ?? this.fromId,
      sent: sent ?? this.sent,
      type: type ?? this.type,
    );
  }
}
