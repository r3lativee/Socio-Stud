import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/post_page.dart';
import 'package:social_media/screens/profile_screen.dart';
import 'package:social_media/screens/view_profile_screen.dart';

class PostView extends StatefulWidget {
  final Map<String, dynamic> post;
  final String postId;
  PostView({super.key, required this.post, required this.postId});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  Map<String, dynamic>? userData;
  int commentNumber = 0;
  @override
  void initState() {
    super.initState();
    getUserData();
    getCommentCount(widget.postId);
  }

  Future<void> getCommentCount(String postId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .get();

    setState(() {
      commentNumber = snapshot.size;
    });
  }

  getUserData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.post["userId"])
        .get();
    if (userSnapshot.exists) {
      setState(() {
        userData = userSnapshot.data() as Map<String, dynamic>;
      });
    } else {
      print("User document does not exist");
    }
  }

  increaseLike(postId) async {
    await FirebaseFirestore.instance.collection("posts").doc(postId).update({
      "likes": widget.post["likes"] + 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userData == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    if (FirebaseAuth.instance.currentUser!.uid !=
                        widget.post["userId"]) {
                      return ViewProfile(userId: widget.post["userId"]);
                    } else {
                      return ProfileScreen(
                        toggler: true,
                      );
                    }
                  }));
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                          userData?["profileImage"],
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          userData?["username"],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "@${userData?['powername']}",
                          style: TextStyle(fontSize: 14),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostPage(
                        post: widget.post,
                        postId: widget.postId,
                        userData: userData!)));
              },
              child: Card(
                clipBehavior: Clip.hardEdge,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                              child: Image.network(widget.post["postImage"])),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 0,
                      child: Container(
                        height: 80,
                        width: 390,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20.0),
                            bottomRight: Radius.circular(20.0),
                          ),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    increaseLike(widget.postId);
                                    print("LIke");
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(Icons.thumb_up),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("${widget.post['likes']}"),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(Icons.comment),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text("${commentNumber}")
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    }
  }
}
