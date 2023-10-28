import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RepostScreen extends StatefulWidget {
  final String originalPostId;
  final String userId;

  const RepostScreen(
      {super.key, required this.originalPostId, required this.userId});

  @override
  // ignore: library_private_types_in_public_api
  _RepostScreenState createState() => _RepostScreenState();
}

class _RepostScreenState extends State<RepostScreen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference? previousRepostedPostRef;

  @override
  void initState() {
    super.initState();
    checkPreviousRepost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repost'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Repost'),
          onPressed: () {
            repostPost();
          },
        ),
      ),
    );
  }

  void checkPreviousRepost() async {
    // Check if the user has previously reposted the post
    QuerySnapshot querySnapshot = await firestore
        .collection('posts')
        .where('originalPostId', isEqualTo: widget.originalPostId)
        .where('userId', isEqualTo: widget.userId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the reference to the previous reposted post
      previousRepostedPostRef = querySnapshot.docs.first.reference;
    }
  }

  void repostPost() async {
    // Delete the previous reposted post if it exists
    if (previousRepostedPostRef != null) {
      await previousRepostedPostRef!.delete();
    }

    // Fetch the original post
    DocumentSnapshot originalPostSnapshot =
        await firestore.collection('posts').doc(widget.originalPostId).get();

    if (originalPostSnapshot.exists) {
      // Create a new document for the reposted post
      DocumentReference repostedPostRef = firestore.collection('posts').doc();

      // Get the data from the original post
      Map<String, dynamic> originalPostData =
          originalPostSnapshot.data()! as Map<String, dynamic>;

      // Set the reposted post data
      Map<String, dynamic> repostedPostData = {
        'title': originalPostData['title'],
        'content': originalPostData['content'],
        'repostDate': DateTime.now(),
        'userId': widget.userId,
        'originalPostId': widget.originalPostId,
        // Add any additional fields you want
      };

      // Save the reposted post to Firestore
      await repostedPostRef.set(repostedPostData);

      // Display a success message or navigate to a different screen
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Repost Successful'),
            content: const Text('The post has been reposted.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      // Handle the case where the original post doesn't exist
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('The original post does not exist.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
