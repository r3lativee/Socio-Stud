import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants/colors.dart';
import 'package:social_media/screens/profile_screen.dart';
import 'package:social_media/screens/view_profile_screen.dart';
import 'package:social_media/utils/post_view.dart';

class HomeDataScreen extends StatelessWidget {
  const HomeDataScreen({super.key});

  Stream<QuerySnapshot> getPostStream() {
    return FirebaseFirestore.instance.collection('posts').snapshots();
  }

  Stream<QuerySnapshot> getUserStream() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Explore",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: StreamBuilder(
                stream: getUserStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index].data() as Map<String, dynamic>;
                      final userId = users[index].reference.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              if (FirebaseAuth.instance.currentUser!.uid !=
                                  userId) {
                                return ViewProfile(userId: userId);
                              } else {
                                return ProfileScreen(
                                  toggler: true,
                                );
                              }
                            }));
                          },
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: shasPrimaryColor,
                                child: CircleAvatar(
                                  radius: 22,
                                  backgroundImage: NetworkImage(
                                    user['profileImage'],
                                  ),
                                ),
                              ),
                              Text(user["username"]),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              // child: ListView(
              //   scrollDirection: Axis.horizontal,
              //   children: [
              //     Column(
              //       children: [
              //         CircleAvatar(
              //           radius: 25,
              //           backgroundColor: shasPrimaryColor,
              //           child: CircleAvatar(
              //             radius: 22,
              //             backgroundImage: NetworkImage(
              //               'https://w0.peakpx.com/wallpaper/172/772/HD-wallpaper-polina-pretty-girl-model-blonde-beauty-russian.jpg',
              //             ),
              //           ),
              //         ),
              //         Text("Name"),
              //       ],
              //     ),
              //   ],
              // ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: StreamBuilder(
                stream: getPostStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Something went wrong'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index].data() as Map<String, dynamic>;
                      final postId = posts[index].reference.id;
                      return PostView(
                        post: post,
                        postId: postId,
                      );
                    },
                  );
                },
              ),
            ))
          ],
        ),
      ),
    );
  }
}
