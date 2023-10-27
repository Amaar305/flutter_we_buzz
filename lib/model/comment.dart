// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String authorId;
  final String text;
  final Timestamp createdAt;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.replies,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'authorId': authorId,
      'text': text,
      'createdAt': createdAt,
      'replies': replies.map((x) => x.toMap()).toList(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      authorId: map['authorId'] as String,
      text: map['text'] as String,
      createdAt: map['createdAt'] as Timestamp,
      replies: List<Comment>.from((map['replies'] as List<int>).map<Comment>((x) => Comment.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) => Comment.fromMap(json.decode(source) as Map<String, dynamic>);
}
