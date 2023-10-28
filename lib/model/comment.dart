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

  // Create a factory constructor for decoding from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    List<Comment> replies = (json['replies'] as List)
        .map((reply) => Comment.fromJson(reply))
        .toList();

    return Comment(
      id: json['id'],
      authorId: json['authorId'],
      text: json['text'],
      createdAt: json['createdAt'],
      replies: replies,
    );
  }

  // Create a method for encoding to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'text': text,
      'createdAt': createdAt,
      'replies': replies.map((reply) => reply.toJson()).toList(),
    };
  }
}
