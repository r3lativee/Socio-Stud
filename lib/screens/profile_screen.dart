import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants/colors.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/screens/edit_profile.dart';
import 'package:social_media/screens/foll_screen.dart';
import 'package:social_media/screens/post_page.dart';

class ProfileScreen extends StatefulWidget {
  bool toggler;
  ProfileScreen({super.key, required this.toggler});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  fetchUserData() async {
    final userId = await FirebaseAuth.instance.currentUser?.uid;

    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userSnapshot.exists) {
        setState(() {
          userData = userSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print("user document does not exist");
      }
    } catch (e) {
      print("Error has occured: $e");
    }
  }

  Stream<QuerySnapshot> getPostStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where("userId", isEqualTo: userData!["uid"])
        .snapshots();
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
                            image: userData!["backgroundImage"] == ""
                                ? NetworkImage(
                                    'https://images.unsplash.com/photo-1566275529824-cca6d008f3da?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cGhvdG98ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=600&q=60')
                                : NetworkImage(userData!['backgroundImage']),
                          ),
                        ),
                        child: Text(""),
                      ),
                      widget.toggler
                          ? Positioned(
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
                            )
                          : Text(""),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: IconButton(
                            onPressed: () {
                              AuthMethods().signOut();
                            },
                            icon: Icon(
                              Icons.logout,
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
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollScreen(
                                                          toggler: false,
                                                          userData:
                                                              userData!)));
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                                "${userData?['followers'].length}"),
                                            Text("followers"),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      FollScreen(
                                                          toggler: true,
                                                          userData:
                                                              userData!)));
                                        },
                                        child: Column(
                                          children: [
                                            Text(
                                                "${userData?['following'].length}"),
                                            Text("Following"),
                                          ],
                                        ),
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
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 3.0,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            minimumSize: Size(120, 45),
                                            backgroundColor: Colors.amber[600],
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        30.0)),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfile(
                                                            userData:
                                                                userData!)));
                                          },
                                          child: Text(
                                            "Manage",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      )
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
