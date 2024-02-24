// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:hi_tweet/services/firebase_service.dart';

// import 'we_buzz_poll_model.dart';

class WeBuzz {
  final String id;
  final String docId;
  final String authorId;
  final String originalId;
  final String content;
  final String location;
  final String source;
  final String buzzType;
  final String? imageUrl;

  final Timestamp createdAt;
  // final Timestamp updatedPaid;
  final List<String> hashtags;
  final List<String> links;

  final bool isRebuzz;
  final bool isSuspended;
  final bool isSponsor;
  late bool expired;
  final bool hasPaid;
  final bool isPublished;
  final bool isCampusBuzz;

  final double? amount;
  final String? whatsapp;
  final String? websiteUrl;
  final String? videoUrl;
  final List<String>? images;

  final int reBuzzsCount;
  final int likesCount;
  final int repliesCount;
  final int savedCount;
  final int viewsCount;
  final int reportCount;
  final int? duration;

  final DocumentReference? refrence;

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
    required this.isRebuzz,
    required this.likesCount,
    required this.repliesCount,
    required this.isCampusBuzz,
    required this.links,
    this.savedCount = 0,
    this.reportCount = 0,
    this.viewsCount = 0,
    this.refrence,
    this.isSponsor = false,
    this.hasPaid = false,
    this.expired = false,
    this.images,
    this.amount,
    this.duration,
    this.websiteUrl,
    this.whatsapp,
    this.videoUrl,
  });

  // Create a factory constructor for decoding from JSON
  factory WeBuzz.fromJson(
    Map<String, dynamic> json,
    String docId,
    DocumentReference refrence,
  ) {
    return WeBuzz(
      id: json['id'],
      docId: docId,
      authorId: json['authorId'],
      originalId: json['originalId'],
      content: json['content'],
      location: json['location'],
      source: json['source'],
      createdAt: json['createdAt'],
      buzzType: json['buzzType'],
      hashtags: List<String>.from(json['hashtags']),
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
      isSponsor: json['isSponsor'] as bool,
      links: List<String>.from(json['links']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      amount: json['amount'],
      duration: json['duration'],
      expired: json['expired'],
      hasPaid: json['hasPaid'],
      websiteUrl: json['websiteUrl'],
      whatsapp: json['whatsapp'],
      videoUrl: json['videoUrl'],
      reportCount: json['reportCount'],
    );
  }

  bool validSponsor() {
    DateTime currentDate = DateTime.now();
    bool isValid = false;

    if (hasPaid && isSponsor) {
      DateTime sponsorEndDate =
          createdAt.toDate().add(Duration(days: duration! * 7));

      if (sponsorEndDate.isAfter(currentDate)) {
        isValid = true;
      } else {
        // Sponsorship has expired, update the 'expired' field
        expired = true;
        updateExpiredStatusInFirestore(docId);
      }
    }

    return isValid;
  }

  // Create a factory constructor for decoding from DocumentSnapshot
  factory WeBuzz.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    data['docId'] = doc.id;
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
      'rebuzz': isRebuzz,
      'likesCount': likesCount,
      'repliesCount': repliesCount,
      'imageUrl': imageUrl,
      "isPublished": isPublished,
      "isCampusBuzz": isCampusBuzz,
      "isSuspended": isSuspended,
      "savedCount": savedCount,
      "viewsCount": viewsCount,
      "isSponsor": isSponsor,
      "links": links,
      "images": images,
      "amount": amount,
      "duration": duration,
      "hasPaid": hasPaid,
      "websiteUrl": websiteUrl,
      "whatsapp": whatsapp,
      "videoUrl": videoUrl,
      "expired": expired,
      "reportCount": reportCount,
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
    String? buzzType,
    String? imageUrl,
    Timestamp? createdAt,
    List<String>? hashtags,
    List<String>? links,
    bool? isRebuzz,
    bool? isSuspended,
    bool? isSponsor,
    bool? expired,
    bool? hasPaid,
    bool? isPublished,
    bool? isCampusBuzz,
    double? amount,
    String? whatsapp,
    String? websiteUrl,
    String? videoUrl,
    List<String>? images,
    int? reBuzzsCount,
    int? likesCount,
    int? repliesCount,
    int? savedCount,
    int? viewsCount,
    int? reportCount,
    int? duration,
    DocumentReference? refrence,
  }) {
    return WeBuzz(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      authorId: authorId ?? this.authorId,
      originalId: originalId ?? this.originalId,
      content: content ?? this.content,
      location: location ?? this.location,
      source: source ?? this.source,
      buzzType: buzzType ?? this.buzzType,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      hashtags: hashtags ?? this.hashtags,
      links: links ?? this.links,
      isRebuzz: isRebuzz ?? this.isRebuzz,
      isSuspended: isSuspended ?? this.isSuspended,
      isSponsor: isSponsor ?? this.isSponsor,
      expired: expired ?? this.expired,
      hasPaid: hasPaid ?? this.hasPaid,
      isPublished: isPublished ?? this.isPublished,
      isCampusBuzz: isCampusBuzz ?? this.isCampusBuzz,
      amount: amount ?? this.amount,
      whatsapp: whatsapp ?? this.whatsapp,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      images: images ?? this.images,
      reBuzzsCount: reBuzzsCount ?? this.reBuzzsCount,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      savedCount: savedCount ?? this.savedCount,
      viewsCount: viewsCount ?? this.viewsCount,
      reportCount: reportCount ?? this.reportCount,
      duration: duration ?? this.duration,
      refrence: refrence ?? this.refrence,
    );
  }
}

void updateExpiredStatusInFirestore(String docID) async {
  try {
    await FirebaseService.updateBuzz(docID, {
      "expired": true,
    });
  } catch (e) {
    log("Error tying to update Status");
  }
}
