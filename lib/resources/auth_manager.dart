import 'package:flutter/material.dart';
import 'package:social_media/resources/auth_methods.dart';
import 'package:social_media/resources/auth_page.dart';
import 'package:social_media/screens/home_screen.dart';

class AuthManager extends StatefulWidget {
  static const routeName = '/authManager';
  const AuthManager({Key? key}) : super(key: key);

  @override
  State<AuthManager> createState() => _AuthManagerState();
}

class _AuthManagerState extends State<AuthManager> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthMethods().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return AuthPage();
        }
      },
    );
  }
}
