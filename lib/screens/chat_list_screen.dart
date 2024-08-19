import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media/screens/chat_screen.dart';
import 'package:social_media/utils/header_text.dart';

class ChatListScreen extends StatefulWidget {
  ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  Future<List<Map<String, dynamic>>> fetchMessengers() async {
    List<Map<String, dynamic>> messengers = [];
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection("users").doc(userId).get();
    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;

      for (int i = 0; i < userData["messengers"].length; i++) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userData["messengers"][i])
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> messengerData =
              snapshot.data() as Map<String, dynamic>;

          messengers.add(messengerData);
        }
      }
    }

    return messengers;
  }

  // Future<List<Map<String, dynamic>>> getAllUsers() async {
  //   List<Map<String, dynamic>> users = [];
  //   try {
  //     QuerySnapshot querySnapshot =
  //         await FirebaseFirestore.instance.collection('users').get();

  //     List<Map<String, dynamic>> users = [];

  //     querySnapshot.docs.forEach((documentSnapshot) {
  //       Map<String, dynamic> user =
  //           documentSnapshot.data() as Map<String, dynamic>;
  //       users.add(user);
  //     });

  //     return users;
  //   } catch (e) {
  //     print('Failed to get users: $e');
  //     return [];
  //   }
  // }

  // getMessengerStream() async {
  //   return FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(userId)
  //       .collection("messengers")
  //       .snapshots();
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            HeaderText(givenText: "Chat List"),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchMessengers(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    final messengers = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: messengers.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> messenger = messengers[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => SingleChatScreen(
                                      senderId: userId,
                                      receiverId: messenger["uid"],
                                      user: messenger,
                                    )));
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(messenger["profileImage"]),
                              ),
                              title: Text(messenger["username"]),
                              // Render other messenger details as needed
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              // child: ListView(
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.of(context).push(MaterialPageRoute(
              //             builder: (context) => SingleChatScreen()));
              //       },
              //       child: Card(
              //         shape: RoundedRectangleBorder(
              //             borderRadius: BorderRadius.circular(10)),
              //         child: ListTile(
              //           leading: CircleAvatar(
              //             backgroundImage: NetworkImage(
              //                 "https://media.istockphoto.com/id/1140371751/photo/domestic-cat-sitting-in-grass-phoot-with-blur-background.jpg?s=612x612&w=0&k=20&c=U8PY7ArXns1DF8HL4IKz-E5jchkTxZ9svESenQxJXVY="),
              //             child: Text(""),
              //           ),
              //           title: Text("Hellow "),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
            ),
          ],
        ),
      ),
    );
  }
}
