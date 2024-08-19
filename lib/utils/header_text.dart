import 'package:flutter/material.dart';

class HeaderText extends StatelessWidget {
  String givenText;
  HeaderText({super.key, required this.givenText});

  @override
  Widget build(BuildContext context) {
    return Text(
      givenText,
      style: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
