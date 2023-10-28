// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:hi_tweet/model/comment.dart';

import 'we_buzz_poll_model.dart';

class WeBuzz {
  final String id;
  final String docId;
  final String authorId;
  final String originalId;
  final String content;
  final String location;
  final String source;
  int reBuzzCount;
  // final bool rebuzz;
  final Timestamp createdAt;
  final List<Comment> comments;
  final String buzzType;
  final List<String> hashtags;

  final String? imageUrl;
  final String? quoteBuzzId;
  final List<Poll>? polls;
  final List<String>? mentions;
  final List<String> views;
  final List<String> reposts;
  final List<String> likes;
  final List<String>? shares;

  WeBuzz({
    required this.id,
    required this.docId,
    required this.authorId,
    required this.content,
    required this.location,
    required this.source,
    required this.reBuzzCount,
    required this.createdAt,
    required this.comments,
    required this.buzzType,
    required this.hashtags,
    this.imageUrl,
    required this.originalId,
    this.quoteBuzzId,
    this.polls,
    this.mentions,
    required this.views,
    required this.reposts,
    required this.likes,
    this.shares,
    
  });

  // Create a factory constructor for decoding from JSON
  factory WeBuzz.fromJson(Map<String, dynamic> json, String docId) {
    // Parse lists and objects as needed
    List<Comment> comments = (json['comments'] as List)
        .map((comment) => Comment.fromJson(comment))
        .toList();

    List<String> hashtags = (json['hashtags'] as List)
        .map((hashtag) => hashtag.toString())
        .toList();

    List<Poll>? polls = json['polls'] != null
        ? (json['polls'] as List).map((poll) => Poll.fromJson(poll)).toList()
        : null;

    // List<String>? mentions = json['mentions'] != null
    //     ? (json['mentions'] as List)
    //         .map((mention) => WeBuzzUser.fromJson(mention))
    //         .toList()
    //     : null;

    // List<String>? mentions = json['polls'] !=
    //     null(json['mentions'] as List)
    //         .map((hashtag) => hashtag.toString())
    //         .toList();

    // List<WeBuzzUser> views = (json['views'] as List)
    //     .map((view) => WeBuzzUser.fromJson(view))
    //     .toList();

    // List<WeBuzzUser>? reposts = json['reposts'] != null
    //     ? (json['reposts'] as List)
    //         .map((repost) => WeBuzzUser.fromJson(repost))
    //         .toList()
    //     : null;

    // List<CampusBuzzUser> likes = (json['likes'] as List)
    //     .map((like) => CampusBuzzUser.fromJson(like))
    //     .toList();

    // List<WeBuzzUser>? shares = json['shares'] != null
    //     ? (json['shares'] as List)
    //         .map((share) => WeBuzzUser.fromJson(share))
    //         .toList()
    //     : null;

    return WeBuzz(
      id: json['id'],
      docId: docId,
      authorId: json['authorId'],
      content: json['content'],
      location: json['location'],
      source: json['source'],
      reBuzzCount: json['reBuzzCount'],
      createdAt: json['createdAt'],
      comments: comments,
      buzzType: json['buzzType'],
      hashtags: hashtags,
      imageUrl: json['imageUrl'],
      originalId: json['repostId'],
      quoteBuzzId: json['quoteBuzzId'],
      polls: polls,
      mentions: json['mentions'] != null
          ? (json['mentions'] as List<dynamic>).cast<String>()
          : null,
      views: (json['views'] as List<dynamic>).cast<String>(),
      reposts: (json['reposts'] as List<dynamic>).cast<String>(),
      likes: (json['likes'] as List<dynamic>).cast<String>(),
      shares: json['shares'] != null
          ? (json['shares'] as List<dynamic>).cast<String>()
          : null,
    );
  }

  // Create a factory constructor for decoding from DocumentSnapshot
  factory WeBuzz.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['docId'] = doc.id;
    return WeBuzz.fromJson(data, doc.id);
  }

  // Create a method for encoding to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'docId': docId,
      'authorId': authorId,
      'content': content,
      'location': location,
      'source': source,
      'reBuzzCount': reBuzzCount,
      'createdAt': createdAt,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'buzzType': buzzType,
      'hashtags': hashtags,
      'imageUrl': imageUrl,
      'repostId': originalId,
      'quoteBuzzId': quoteBuzzId,
      'polls': polls?.map((poll) => poll.toJson()).toList(),
      'mentions': mentions,
      'views': views,
      'reposts': reposts,
      // 'reposts': reposts.map((repost) => repost.toJson()).toList(),
      'likes': likes,
      'shares': shares,
    };
  }

  WeBuzz copyWith({
    String? id,
    String? docId,
    String? authorId,
    String? originalId,
    String? content,
    String? location,
    String? source,
    int? reBuzzCount,
    Timestamp? createdAt,
    List<Comment>? comments,
    String? buzzType,
    List<String>? hashtags,
    String? imageUrl,
    String? quoteBuzzId,
    List<Poll>? polls,
    List<String>? mentions,
    List<String>? views,
    List<String>? reposts,
    List<String>? likes,
    List<String>? shares,
  }) {
    return WeBuzz(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      authorId: authorId ?? this.authorId,
      originalId: originalId ?? this.originalId,
      content: content ?? this.content,
      location: location ?? this.location,
      source: source ?? this.source,
      reBuzzCount: reBuzzCount ?? this.reBuzzCount,
      createdAt: createdAt ?? this.createdAt,
      comments: comments ?? this.comments,
      buzzType: buzzType ?? this.buzzType,
      hashtags: hashtags ?? this.hashtags,
      imageUrl: imageUrl ?? this.imageUrl,
      quoteBuzzId: quoteBuzzId ?? this.quoteBuzzId,
      polls: polls ?? this.polls,
      mentions: mentions ?? this.mentions,
      views: views ?? this.views,
      reposts: reposts ?? this.reposts,
      likes: likes ?? this.likes,
      shares: shares ?? this.shares,
    );
  }
}
