import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/utils/header_text.dart';

class FollScreen extends StatefulWidget {
  bool toggler;
  Map<String, dynamic> userData;
  FollScreen({super.key, required this.userData, required this.toggler});

  @override
  State<FollScreen> createState() => _FollScreenState();
}

class _FollScreenState extends State<FollScreen> {
  Future<List<Map<String, dynamic>>> fetchFollowers() async {
    String hold = "";
    if (widget.toggler) {
      hold = "following";
    } else {
      hold = "followers";
    }
    List<Map<String, dynamic>> followers = [];

    for (int i = 0; i < widget.userData[hold].length; i++) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userData[hold][i])
          .get();

      if (snapshot.exists) {
        Map<String, dynamic> followerData =
            snapshot.data() as Map<String, dynamic>;
        followers.add(followerData);
      }
    }

    return followers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(children: [
            widget.toggler
                ? HeaderText(givenText: "Following ")
                : HeaderText(givenText: "Followers "),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchFollowers(),
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
                    final followers = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: followers.length,
                      itemBuilder: (BuildContext context, int index) {
                        Map<String, dynamic> follower = followers[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(follower["profileImage"]),
                            ),
                            title: Text(follower["username"]),
                            // Render other follower details as needed
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ]),
        ),
      ),
    );
  }
}
