// ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:hi_tweet/model/user.dart';

// import 'buzz_enum.dart';
// import 'comment.dart';

// class WeBuzz {
//   final String id;
//   final String docId;
//   final String authorId;
//   final String content;
//   final String location;
//   final String source;
//   final int reBuzzCount;
//   final Timestamp createdAt;
//   final List<Comment> comments;
//   final BuzzType buzzType;
//   final List<String> hashtags;

//   final String? imageUrl;
//   final String? qouteBuzzId;
//   final List<Poll>? polls;
//   final List<CampusBuzzUser>? mentions;
//   final List<CampusBuzzUser> views;
//   final List<CampusBuzzUser>? reposts;
//   final List<CampusBuzzUser> likes;
//   final List<CampusBuzzUser>? shares;

//   WeBuzz({
//     required this.id,
//     required this.docId,
//     required this.authorId,
//     required this.content,
//     required this.createdAt,
//     required this.comments,
//     required this.reBuzzCount,
//     required this.buzzType,
//     required this.hashtags,
//     required this.location,
//     required this.source,
//     required this.likes,
//     required this.views,
//     this.imageUrl,
//     this.qouteBuzzId,
//     this.reposts,
//     this.shares,
//     this.mentions,
//     this.polls,
//   });

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'id': id,
//       'docId': docId,
//       'authorId': authorId,
//       'content': content,
//       'location': location,
//       'source': source,
//       'reBuzzCount': reBuzzCount,
//       'createdAt': createdAt,
//       'comments': comments,
//       'buzzType': buzzType.name.toString(),
//       'hashtags': hashtags,
//       'imageUrl': imageUrl,
//       'qouteBuzzId': qouteBuzzId,
//       'polls': polls,
//       'mentions': mentions,
//       'views': views,
//       'reposts': reposts,
//       'likes': likes,
//       'shares': shares,
//     };
//   }

//   factory WeBuzz.fromMap(Map<String, dynamic> map, String docId) {
//     return WeBuzz(
//       id: map['id'] as String,
//       docId: docId,
//       authorId: map['authorId'] as String,
//       content: map['content'] as String,
//       location: map['location'] as String,
//       source: map['source'] as String,
//       reBuzzCount: map['reBuzzCount'] as int,
//       createdAt: map['createdAt'] as Timestamp,
//       comments: List<Comment>.from(
//         (map['comments'] as List<int>).map<Comment>(
//           (x) => Comment.fromMap(x as Map<String, dynamic>),
//         ),
//       ),
//       buzzType: BuzzType.values.firstWhere(
//           (buzz) => buzz.toString() == 'BuzzType.${map['buzzType']}'),
//       hashtags: List<String>.from((map['hashtags'] as List<String>)),
//       imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
//       qouteBuzzId: map['qouteBuzzId'] as String?,
//       polls: map['polls'] != null
//           ? List<Poll>.from(
//               (map['polls'] as List<int>).map<Poll?>(
//                 (x) => Poll.fromMap(x as Map<String, dynamic>),
//               ),
//             )
//           : null,
//       mentions: map['mentions'] != null
//           ? List<CampusBuzzUser>.from(
//               (map['mentions'] as List<int>).map<CampusBuzzUser?>(
//                 (x) => CampusBuzzUser.fromMap(x as Map<String, dynamic>),
//               ),
//             )
//           : null,
//       views: List<CampusBuzzUser>.from(
//         (map['views'] as List<int>).map<CampusBuzzUser?>(
//           (x) => CampusBuzzUser.fromMap(x as Map<String, dynamic>),
//         ),
//       ),
//       reposts: map['reposts'] != null
//           ? List<CampusBuzzUser>.from(
//               (map['reposts'] as List<int>).map<CampusBuzzUser?>(
//                 (x) => CampusBuzzUser.fromMap(x as Map<String, dynamic>),
//               ),
//             )
//           : null,
//       likes: List<CampusBuzzUser>.from(
//         (map['likes'] as List<int>).map<CampusBuzzUser?>(
//           (x) => CampusBuzzUser.fromMap(x as Map<String, dynamic>),
//         ),
//       ),
//       shares: map['shares'] != null
//           ? List<CampusBuzzUser>.from(
//               (map['shares'] as List<int>).map<CampusBuzzUser?>(
//                 (x) => CampusBuzzUser.fromMap(x as Map<String, dynamic>),
//               ),
//             )
//           : null,
//     );
//   }

//   String toJson() => json.encode(toMap());

//   factory WeBuzz.fromJson(String source) =>
//       WeBuzz.fromMap(json.decode(source) as Map<String, dynamic>, '');

//   factory WeBuzz.fromDocument(DocumentSnapshot source) =>
//       WeBuzz.fromMap(source.data() as Map<String, dynamic>, source.id);

//   @override
//   String toString() {
//     return 'TweetBuzz(id: $id, docId: $docId, authorId: $authorId, content: $content, location: $location, source: $source, reBuzzCount: $reBuzzCount, createdAt: $createdAt, comments: $comments, buzzType: $buzzType, hashtags: $hashtags, imageUrl: $imageUrl, qouteBuzzId: $qouteBuzzId, polls: $polls, mentions: $mentions, views: $views, reposts: $reposts, likes: $likes, shares: $shares)';
//   }

//   factory WeBuzz.fromDoc(Map<String, dynamic> data, String docId) {
//     return WeBuzz(
//       id: data['id'],
//       docId: docId,
//       authorId: data['authorId'],
//       content: data['content'],
//       location: data['location'],
//       source: data['source'],
//       reBuzzCount: data['reBuzzCount'],
//       createdAt: data['createdAt'],
//       comments: List<Comment>.from(data['comments']),
//       buzzType: BuzzType.values.firstWhere(
//         (e) => e.toString() == data['buzzType'],
//         orElse: () => BuzzType.origianl, // Set a default value if needed
//       ),
//       hashtags: List<String>.from(data['hashtags']),
//       imageUrl: data['imageUrl'],
//       qouteBuzzId: data['qouteBuzzId'],
//       polls: data['polls'] != null
//           ? List<Poll>.from(
//               data['polls'].map((poll) => Poll.fromDocument(poll)))
//           : null,
//       mentions: data['mentions'] != null
//           ? List<CampusBuzzUser>.from(data['mentions']
//               .map((mention) => CampusBuzzUser.fromDocument(mention)))
//           : null,
//       views: List<CampusBuzzUser>.from(
//         data['views'].map(
//           (view) => CampusBuzzUser.fromDocument(view),
//         ),
//       ),
//       reposts: data['reposts'] != null
//           ? List<CampusBuzzUser>.from(data['reposts']
//               .map((repost) => CampusBuzzUser.fromDocument(repost)))
//           : null,
//       likes: List<CampusBuzzUser>.from(
//         data['likes'].map(
//           (view) => CampusBuzzUser.fromDocument(view),
//         ),
//       ),
//       shares: data['shares'] != null
//           ? List<CampusBuzzUser>.from(
//               data['shares'].map((share) => CampusBuzzUser.fromDocument(share)))
//           : null,
//     );
//   }

//   factory WeBuzz.fromSnaption(DocumentSnapshot snapshot) =>
//       WeBuzz.fromDoc(snapshot.data() as Map<String, dynamic>, snapshot.id);
// }



// class Poll {
//   String poll;
//   List<String> choices;
//   Timestamp createdAt;
//   Poll({
//     required this.poll,
//     required this.choices,
//     required this.createdAt,
//   });

//   Map<String, dynamic> toMap() {
//     return <String, dynamic>{
//       'poll': poll,
//       'choices': choices,
//       'createdAt': createdAt,
//     };
//   }

//   factory Poll.fromMap(Map<String, dynamic> map) {
//     return Poll(
//       poll: map['poll'] as String,
//       choices: (map['choices'] as List<dynamic>).cast<String>(),
//       createdAt: map['createdAt'] as Timestamp,
//     );
//   }
//   factory Poll.fromDocument(DocumentSnapshot snapshot) {
//     final source = snapshot.data() as Map<String, dynamic>;
//     return Poll.fromMap(source);
//   }

//   String toJson() => json.encode(toMap());

//   factory Poll.fromJson(String source) =>
//       Poll.fromMap(json.decode(source) as Map<String, dynamic>);
// }


