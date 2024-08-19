import 'package:flutter/material.dart';

class CommentView extends StatelessWidget {
  String username;
  String comment;
  CommentView({super.key, required this.username, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            Text(comment),
          ],
        ),
      ),
    );
  }
}
