import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media/constants/colors.dart';
import 'package:social_media/utils/bubble_text.dart';
import 'package:social_media/utils/header_text.dart';

class SingleChatScreen extends StatefulWidget {
  String senderId;
  String receiverId;
  Map<String, dynamic> user;
  SingleChatScreen(
      {super.key,
      required this.senderId,
      required this.receiverId,
      required this.user});

  @override
  State<SingleChatScreen> createState() => _SingleChatScreenState();
}

class _SingleChatScreenState extends State<SingleChatScreen> {
  TextEditingController _chatController = TextEditingController();
  String curUser = "";

  Stream<QuerySnapshot> getChatRoomMessages() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.senderId)
        .collection('messages')
        .where("userId", isEqualTo: widget.receiverId)
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Send a message to a chat room
  Future<void> sendMessage(String message) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.senderId)
          .collection('messages')
          .add({
        'position': "right",
        'userId': widget.receiverId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Message sent successfully!');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.receiverId)
          .collection("messages")
          .add({
        'position': "left",
        'userId': widget.senderId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Message received Successfully');
    } catch (e) {
      print('Failed to send message: $e');
    }

    _chatController.clear();
  }

  // Stream<QuerySnapshot> getChatRoomMessages(String roomId) {
  //   return FirebaseFirestore.instance
  //       .collection('users')
  //       .doc()
  //       .collection('messages')
  //       .orderBy('timestamp', descending: true)
  //       .snapshots();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(width: 1, color: Colors.black12))),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.user["profileImage"]),
                          child: Text("")),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.user["username"],
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Expanded(child: Text("")),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40)),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                stream: getChatRoomMessages(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return Text('No messages found.');
                  }

                  final messages = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message =
                          messages[index].data() as Map<String, dynamic>;
                      final position = message['position'];
                      final messageText = message['message'];
                      // return ListTile(
                      //   title: Text(senderId),
                      //   subtitle: Text(messageText),
                      // );
                      return Align(
                          alignment: position == "right"
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: position == "right"
                              ? BubbleText(
                                  right: true, messageText: messageText)
                              : BubbleText(
                                  messageText: messageText, right: false));
                    },
                  );
                },
              )),
              Row(
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
                            hintText: "Send a message",
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 0.0, style: BorderStyle.none),
                                borderRadius: BorderRadius.circular(30.0))),
                        controller: _chatController,
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
                        sendMessage(_chatController.text);
                      },
                      icon: Icon(
                        Icons.send,
                        color: shasBackgroundColor,
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
