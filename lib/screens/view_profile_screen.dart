import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/chat_screen.dart';
import 'package:social_media/screens/post_page.dart';

import '../constants/colors.dart';

class ViewProfile extends StatefulWidget {
  String userId;
  ViewProfile({super.key, required this.userId});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  Map<String, dynamic>? userData;
  String curUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isFollowing = false;
  int followers = 0;
  int following = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    isFollowingChecker();
  }

  // setter for rerender on change
  isFollowingChecker() async {
    bool data = await checkFollowingExists();
    setState(() {
      isFollowing = data;
    });
  }

  // checks in firebase whether the provided id is inside the array list in the curuesr
  checkFollowingExists() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .get();

      if (snapshot.exists) {
        List<dynamic> following = snapshot.get('following') ?? [];
        return following.contains(widget.userId);
      }

      return false;
    } catch (e) {
      print('Error checking message existence: $e');
      return false;
    }
  }

  Stream<QuerySnapshot> getPostStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where("userId", isEqualTo: widget.userId)
        .snapshots();
  }

  fetchUserData() async {
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>;
          followers = userData?["followers"].length;
          following = userData?["following"].length;
        });
      } else {
        print("user document does not exist");
      }
    } catch (e) {
      print("Error has occured: $e");
    }
  }

  followFunction() async {
    await FirebaseFirestore.instance.collection("users").doc(curUserId).update({
      "following": FieldValue.arrayUnion([widget.userId])
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .update({
      "followers": FieldValue.arrayUnion([curUserId])
    });
    setState(() {
      isFollowing = true;
      followers += 1;
    });
  }

  unfollowFunction() async {
    await FirebaseFirestore.instance.collection("users").doc(curUserId).update({
      "following": FieldValue.arrayRemove([widget.userId])
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .update({
      "followers": FieldValue.arrayRemove([curUserId])
    });
    setState(() {
      isFollowing = false;
      followers -= 1;
    });
  }

  makeChatRoom() async {
    await FirebaseFirestore.instance.collection("users").doc(curUserId).update({
      "messengers": FieldValue.arrayUnion([widget.userId])
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userId)
        .update({
      "messengers": FieldValue.arrayUnion([curUserId])
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: userData != null
              ? Container(
                  width: double.infinity,
                  child: Column(children: [
                    Stack(children: [
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                                'https://images.unsplash.com/photo-1566275529824-cca6d008f3da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cGhvdG98ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60'),
                          ),
                        ),
                        child: Text(""),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // AuthMethods().signOut();
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 150.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50.0),
                              topRight: Radius.circular(50.0)),
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30.0, vertical: 20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          Text("${followers}"),
                                          Text("Follower"),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 100,
                                      ),
                                      Column(
                                        children: [
                                          Text("${following}"),
                                          Text("Following"),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20),
                                      Text(
                                        userData?["username"],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        userData?["bio"],
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade400
                                                      .withOpacity(0.5),
                                                  blurRadius: 3.0,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(120, 45),
                                                backgroundColor: !isFollowing
                                                    ? Colors.amber[600]
                                                    : shasPrimaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0)),
                                              ),
                                              onPressed: () {
                                                if (isFollowing) {
                                                  unfollowFunction();
                                                } else {
                                                  followFunction();
                                                }
                                              },
                                              child: Text(
                                                !isFollowing
                                                    ? "Follow"
                                                    : "Followed",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30.0),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey.shade500
                                                      .withOpacity(0.5),
                                                  blurRadius: 3.0,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: Size(120, 45),
                                                backgroundColor:
                                                    shasPrimaryColor,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30.0)),
                                              ),
                                              onPressed: () {
                                                makeChatRoom();
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder:
                                                            (context) => SingleChatScreen(
                                                                senderId:
                                                                    curUserId,
                                                                receiverId:
                                                                    widget
                                                                        .userId,
                                                                user:
                                                                    userData!)));
                                              },
                                              child: Text(
                                                "Message",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        top: 110,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: shasBackgroundColor,
                            child: CircleAvatar(
                              radius: 35,
                              child: Text(""),
                              backgroundImage:
                                  NetworkImage(userData?["profileImage"]),
                            ),
                          ),
                        ),
                      ),
                    ]),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50.0),
                            topRight: Radius.circular(50.0)),
                        child: Container(
                          decoration: BoxDecoration(color: shasBackgroundColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 15.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(40.0),
                                  topRight: Radius.circular(40.0)),
                              child: StreamBuilder(
                                stream: getPostStream(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Something went wrong'),
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  final posts = snapshot.data!.docs;

                                  return SizedBox(
                                    height: 400,
                                    child: GridView.builder(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisExtent: 260,
                                              mainAxisSpacing: 20,
                                              crossAxisSpacing: 20),
                                      itemCount: posts.length,
                                      itemBuilder: (context, index) {
                                        final post = posts[index].data()
                                            as Map<String, dynamic>;
                                        final postId =
                                            posts[index].reference.id;
                                        return Container(
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  post['postImage']),
                                            ),
                                          ),
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PostPage(
                                                              post: post,
                                                              postId: postId,
                                                              userData:
                                                                  userData!,
                                                            )));
                                              },
                                              child: Text("")),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
        ));
  }
}
