// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'we_buzz_poll_model.dart';

class WeBuzz {
  late String id;
  late String docId;
  late String authorId;
  late String originalId;
  late String content;
  late String location;
  late String source;
  late Timestamp createdAt;
  late String buzzType;
  late List<String> hashtags;
  late List<String> replies;
  late List<String> likes;
  late List<String> views;
  late List<String> rebuzzs;
  late String? imageUrl;
  late bool isRebuzz;
  final bool isSuspended;

  int reBuzzsCount;
  int likesCount;
  int repliesCount;
  int savedCount;
  int reportCount;
  int viewsCount;
  late bool isPublished;
  late bool isCampusBuzz;
  late DocumentReference? refrence;

  WeBuzz({
    required this.id,
    required this.docId,
    required this.authorId,
    required this.content,
    required this.location,
    required this.source,
    required this.reBuzzsCount,
    required this.createdAt,
    required this.buzzType,
    required this.hashtags,
    this.isPublished = true,
    this.isSuspended = false,
    this.imageUrl,
    required this.originalId,
    required this.replies,
    required this.rebuzzs,
    required this.likes,
    required this.views,
    required this.isRebuzz,
    required this.likesCount,
    required this.repliesCount,
    required this.isCampusBuzz,
    this.savedCount = 0,
    this.reportCount = 0,
    this.viewsCount = 0,
    this.refrence,
  });

  // Create a factory constructor for decoding from JSON
  factory WeBuzz.fromJson(
    Map<String, dynamic> json,
    String docId,
    DocumentReference refrence,
  ) {
    return WeBuzz(
      id: json['id'],
      docId: json['docId'],
      authorId: json['authorId'],
      originalId: json['originalId'],
      content: json['content'],
      location: json['location'],
      source: json['source'],
      createdAt: json['createdAt'],
      buzzType: json['buzzType'],
      hashtags: List<String>.from(json['hashtags']),
      replies: List<String>.from(json['replies']),
      rebuzzs: List<String>.from(json['rebuzzs']),
      likes: List<String>.from(json['likes']),
      views: List<String>.from(json['views']),
      imageUrl: json['imageUrl'],
      isRebuzz: json['rebuzz'],
      reBuzzsCount: json['reBuzzsCount'],
      likesCount: json['likesCount'],
      repliesCount: json['repliesCount'],
      viewsCount: json['viewsCount'],
      isPublished: json['isPublished'],
      isSuspended: json['isSuspended'],
      savedCount: json['savedCount'],
      refrence: refrence,
      isCampusBuzz: json['isCampusBuzz'],
    );
  }

  // Create a factory constructor for decoding from DocumentSnapshot
  factory WeBuzz.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['docId'] = doc.id;
    // doc.reference
    final refrence = doc.reference;
    return WeBuzz.fromJson(data, doc.id, refrence);
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
      'reBuzzsCount': reBuzzsCount,
      'createdAt': createdAt,
      'buzzType': buzzType,
      'hashtags': hashtags,
      'originalId': originalId,
      'replies': replies,
      'rebuzzs': rebuzzs,
      'likes': likes,
      'views': views,
      'rebuzz': isRebuzz,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'imageUrl': imageUrl,
      "isPublished": isPublished,
      "isCampusBuzz": isCampusBuzz,
      "isSuspended": isSuspended,
      "savedCount": savedCount,
      "viewsCount": viewsCount,
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
    Timestamp? createdAt,
    String? buzzType,
    List<String>? hashtags,
    List<String>? views,
    List<String>? replies,
    List<String>? rebuzzs,
    List<String>? likes,
    String? imageUrl,
    bool? rebuzz,
    bool? isSuspended,
    int? reBuzzsCount,
    int? likesCount,
    int? viewsCount,
    int? repliesCount,
    int? savedCount,
    int? reportCount,
    bool? isPublished,
    bool? isCampusBuzz,
  }) {
    return WeBuzz(
      id: id ?? this.id,
      savedCount: savedCount ?? this.savedCount,
      viewsCount: viewsCount ?? this.viewsCount,
      reportCount: reportCount ?? this.reportCount,
      isPublished: isPublished ?? this.isPublished,
      isCampusBuzz: isCampusBuzz ?? this.isCampusBuzz,
      isSuspended: isSuspended ?? this.isSuspended,
      docId: docId ?? this.docId,
      authorId: authorId ?? this.authorId,
      originalId: originalId ?? this.originalId,
      content: content ?? this.content,
      location: location ?? this.location,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      buzzType: buzzType ?? this.buzzType,
      hashtags: hashtags ?? this.hashtags,
      replies: replies ?? this.replies,
      views: views ?? this.views,
      rebuzzs: rebuzzs ?? this.rebuzzs,
      likes: likes ?? this.likes,
      imageUrl: imageUrl ?? this.imageUrl,
      isRebuzz: rebuzz ?? isRebuzz,
      reBuzzsCount: reBuzzsCount ?? this.reBuzzsCount,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
    );
  }
}
