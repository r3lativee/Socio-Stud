import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/utils/header_text.dart';
import 'package:uuid/uuid.dart';

import '../constants/colors.dart';
import '../utils/utils.dart';

class EditProfile extends StatefulWidget {
  Map<String, dynamic> userData;
  EditProfile({super.key, required this.userData});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _bioController = TextEditingController();

  XFile? image;
  XFile? backgroundImage;

  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    fetchUserCredentials();
  }

  fetchUserCredentials() {
    setState(() {
      _usernameController.text = widget.userData["username"] ?? '';
      _bioController.text = widget.userData["bio"] ?? '';
    });
  }

  Future<void> updatePost() async {
    String userId = await FirebaseAuth.instance.currentUser!.uid;
    String image_url = await uploadImage(image!);
    print(image_url);
    String background_url = await uploadImage(backgroundImage!);
    print(background_url);
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      "backgroundImage": background_url,
      "profileImage": image_url,
      "username": _usernameController.text,
      "bio": _bioController.text
    });
    setState(() {
      _image == null;
    });
  }

  void selectImage() async {
    var im = await pickImage(ImageSource.gallery);

    setState(() {
      image = im[0];
      _image = im[1];
    });
  }

  getImage() async {
    var holder = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      backgroundImage = holder;
    });
  }

  uploadImage(XFile image) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              HeaderText(givenText: "Edit Profile"),
              SizedBox(height: 40.0),
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
              SizedBox(height: 40.0),
              TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    fillColor: chatTextFieldColor,
                    filled: true,
                    labelText: "username",
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.0, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10.0))),
                controller: _usernameController,
              ),
              SizedBox(height: 40.0),
              TextField(
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10.0),
                    fillColor: chatTextFieldColor,
                    filled: true,
                    labelText: "bio",
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.0, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(10.0))),
                controller: _bioController,
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: shasPrimaryColor),
                child: IconButton(
                  iconSize: 40,
                  onPressed: () {
                    getImage();
                  },
                  icon: Icon(Icons.add_a_photo),
                ),
              ),
              Text("Pick"),
              Expanded(child: Text("")),
              ElevatedButton(
                onPressed: () {
                  updatePost();
                },
                child: Text("Edit"),
                style: ElevatedButton.styleFrom(
                  primary: shasPrimaryColor,
                  minimumSize: const Size.fromHeight(50),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
