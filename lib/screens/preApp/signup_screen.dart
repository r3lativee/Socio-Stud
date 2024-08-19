import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media/constants/colors.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/utils/text_input.dart';
import 'package:social_media/utils/utils.dart';
import 'package:uuid/uuid.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback showLoginPage;
  SignUpScreen({super.key, required this.showLoginPage});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  XFile? image;
  Uint8List? _image;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passController.dispose();
    _bioController.dispose();
  }

  bool passwordConfirmed() {
    if (_passController.text.trim() == _confirmPassController.text.trim()) {
      return true;
    } else {
      return false;
    }
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
      String uniqueId = Uuid().v4();
      var imageFile = File(image!.path);

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

  Future<void> signup() async {
    try {
      if (passwordConfirmed()) {
        String image_url = await uploadImage();
        print(image_url);
        AuthMethods().signUpUser(
          email: _emailController.text,
          password: _passController.text,
          username: _usernameController.text,
          bio: _bioController.text,
          image: image_url,
        );
        // final UserCredential currentUser =
        //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
        //   email: emailController.text.trim(),
        //   password: passwordController.text.trim(),
        // );
        // After successful sign up
        // Navigator.pushReplacementNamed(context, '/create_profile');
        // addUserDetails(
        //   fullnameController.text.trim(),
        //   phNumberController.text.trim(),
        //   passwordController.text.trim(),
        //   emailController.text.trim(),
        //   currentUser.user!.uid,
        // );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('  Password Not Matched'),
            );
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text('Password is Week, Choose Stronger one'),
            );
          },
        );
      } else if (e.code == 'email-already-in-use') {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(
                    'Oops ! Account for this email already exits, please LOGIN instead'),
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Social Stud",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 21),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Become a SOCIO STUD member",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
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
                TextInput(
                  textEditingController: _usernameController,
                  hintText: "Enter Username",
                  textInputType: TextInputType.text,
                  labelText: "Username:",
                ),
                const SizedBox(
                  height: 24,
                ),
                TextInput(
                  textEditingController: _bioController,
                  hintText: "Enter bio",
                  textInputType: TextInputType.text,
                  labelText: "Bio:",
                ),
                const SizedBox(
                  height: 24,
                ),
                TextInput(
                  textEditingController: _emailController,
                  hintText: "Enter Email",
                  textInputType: TextInputType.text,
                  labelText: "Email:",
                ),
                const SizedBox(
                  height: 24,
                ),
                TextInput(
                  textEditingController: _passController,
                  hintText: "Enter Password",
                  textInputType: TextInputType.text,
                  isPass: true,
                  labelText: "Password: ",
                ),
                const SizedBox(
                  height: 24,
                ),
                TextInput(
                  textEditingController: _confirmPassController,
                  hintText: "Confirm Password",
                  textInputType: TextInputType.text,
                  isPass: true,
                  labelText: "Confirm Password: ",
                ),
                const SizedBox(height: 40),
                InkWell(
                  onTap: () {
                    signup();
                  },
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: const Text(
                        "Join Me",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    width: double.infinity,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        ),
                      ),
                      color: shasPrimaryColor,
                    ),
                  ),
                ),
                // Flexible(
                //   flex: 1,
                //   child: Container(),
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: const Text("I have an Account. "),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    GestureDetector(
                      onTap: widget.showLoginPage,
                      child: Container(
                        child: const Text(
                          "Log In",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
