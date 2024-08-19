import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required String image,
  }) async {
    String res = "Some Fault has Occured";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          username.isNotEmpty ||
          bio.isNotEmpty ||
          image.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        _firestore.collection('users').doc(cred.user!.uid).set({
          'profileImage': image,
          'backgroundImage': "",
          'username': username,
          'powername': username,
          'uid': cred.user!.uid,
          'email': email,
          'password': password,
          'bio': bio,
          'followers': [],
          'following': [],
          'messengers': []
        });
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
