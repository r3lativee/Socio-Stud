import 'package:flutter/material.dart';
import 'package:social_media/constants/colors.dart';

class BubbleText extends StatelessWidget {
  String messageText;
  bool right;
  BubbleText({super.key, required this.messageText, required this.right});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: right
          ? Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(50),
                      bottomLeft: Radius.circular(30))),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: shasPrimaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    messageText,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          : Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Text(
                    messageText,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
    );
  }
}
