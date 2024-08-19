import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/constants/colors.dart';
import 'package:uuid/uuid.dart';

import '../utils/utils.dart';

class PostCreation extends StatefulWidget {
  PostCreation({super.key});

  @override
  State<PostCreation> createState() => _PostCreationState();
}

class _PostCreationState extends State<PostCreation> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _captionController = TextEditingController();

  XFile? image;

  Uint8List? _image;

  Future<void> addPost() async {
    final User? user = auth.currentUser;
    String image_url = await uploadImage();
    await FirebaseFirestore.instance.collection('posts').add({
      'userId': user?.uid,
      'likes': 0,
      'comments': [],
      'postImage': image_url,
      'caption': _captionController.text,
    });
    setState(() {
      _image == null;
    });
  }

  void selectImage() async {
    var im = await pickImage(ImageSource.gallery);

    print(im);
    setState(() {
      image = im[0];
      _image = im[1];
    });
  }

  uploadImage() async {
    String image_url = "";
    if (image != null) {
      var imageFile = File(image!.path);
      String uniqueId = Uuid().v4();

      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child("Image-" + uniqueId);

      UploadTask uploadTask = ref.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        var url = await ref.getDownloadURL();
        image_url = url.toString();
      }).catchError((onError) {
        print(onError);
      });
    }
    return image_url;
  }

  getImage() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                _image != null
                    ? CircleAvatar(
                        radius: 64, backgroundImage: MemoryImage(_image!))
                    : CircleAvatar(
                        radius: 64,
                        backgroundImage: NetworkImage(
                            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvrfi6fs9h09rEEkSRPckTTuw7bnu7h8eMYA&usqp=CAU'),
                      ),
                Positioned(
                  left: 80,
                  bottom: -10,
                  child: IconButton(
                    onPressed: selectImage,
                    icon: Icon(
                      Icons.add_a_photo,
                      color: Colors.black87,
                    ),
                  ),
                )
              ],
            ),
            // Container(
            //   height: 200,
            //   alignment: Alignment.center,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.red,
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(20.0),
            //     child: IconButton(
            //         iconSize: 100,
            //         onPressed: () {
            //           getImage();
            //         },
            //         icon: Icon(
            //           Icons.photo_camera_outlined,
            //         )),
            //   ),
            // ),
            SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 10.0),
                  fillColor: chatTextFieldColor,
                  filled: true,
                  hintText: "Write Something...",
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(width: 0.0, style: BorderStyle.none),
                      borderRadius: BorderRadius.circular(10.0))),
              controller: _captionController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  addPost();
                },
                child: Text("Add Post")),
          ],
        ),
      ),
    );
  }
}
