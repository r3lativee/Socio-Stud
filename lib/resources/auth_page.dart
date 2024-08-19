import 'package:flutter/material.dart';
import 'package:social_media/screens/preApp/login_screen.dart';
import 'package:social_media/screens/preApp/signup_screen.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(showRegisterPage: toggleScreens);
    } else {
      return SignUpScreen(showLoginPage: toggleScreens);
    }
  }
}
