import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String poll;
  final List<String> choices;
  final Timestamp createdAt;

  Poll({
    required this.poll,
    required this.choices,
    required this.createdAt,
  });

  // Create a factory constructor for decoding from JSON
  factory Poll.fromJson(Map<String, dynamic> json) {
    List<String> choices =
        (json['choices'] as List).map((choice) => choice.toString()).toList();

    return Poll(
      poll: json['poll'],
      choices: choices,
      createdAt: json['createdAt'],
    );
  }

  // Create a method for encoding to JSON
  Map<String, dynamic> toJson() {
    return {
      'poll': poll,
      'choices': choices,
      'createdAt': createdAt,
    };
  }
}
