import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants/colors.dart';
import 'package:social_media/utils/comment_view.dart';

class PostPage extends StatelessWidget {
  Map<String, dynamic> post;
  String postId;
  Map<String, dynamic> userData;
  TextEditingController _commentController = TextEditingController();

  PostPage(
      {super.key,
      required this.post,
      required this.postId,
      required this.userData});

  addComment(String comment) async {
    String curUserId = await FirebaseAuth.instance.currentUser!.uid;
    try {
      final userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(curUserId)
          .get();

      if (userSnapshot.exists) {
        final curUser = userSnapshot.data() as Map<String, dynamic>;
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection("comments")
            .add({
          "postId": postId,
          "userId": curUserId,
          "username": curUser["username"],
          "content": comment,
        });
      } else {
        print("user document does not exist");
      }
    } catch (e) {
      print("Error has occured: $e");
    }

    _commentController.clear();
  }

  Stream<QuerySnapshot> getCommentStream() {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection("comments")
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0),
              child: Row(
                children: [
                  Container(
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
                  SizedBox(
                    width: 120,
                  ),
                  Text(
                    "Post",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            print("profile");
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
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
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        clipBehavior: Clip.hardEdge,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30.0),
                                  child: Container(
                                      child: Image.network(post["postImage"])),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        post["caption"],
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Comments",
                          style: TextStyle(fontSize: 21),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      StreamBuilder(
                        stream: getCommentStream(),
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

                          final comments = snapshot.data!.docs;

                          return SizedBox(
                            height: 400,
                            child: ListView.builder(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index].data()
                                    as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CommentView(
                                    comment: comment["content"],
                                    username: comment["username"],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade600.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                      ),
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 10.0),
                            fillColor: chatTextFieldColor,
                            filled: true,
                            hintText: "Add a comment...",
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.0, style: BorderStyle.none),
                                borderRadius: BorderRadius.circular(30.0))),
                        controller: _commentController,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade700.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(
                                0, 3), // changes the position of the shadow
                          ),
                        ],
                        color: shasBarColor,
                        borderRadius: BorderRadius.circular(30.0)),
                    child: IconButton(
                      onPressed: () {
                        final message = _commentController.text.trimRight();
                        if (message.isNotEmpty) {
                          addComment(message);
                        }
                        // _commentController.clear();
                      },
                      icon: Icon(
                        Icons.send,
                        color: shasBackgroundColor,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
