import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final String labelText;
  const TextInput(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      required this.textInputType,
      required this.labelText,
      this.isPass = false});

  @override
  Widget build(BuildContext context) {
    final inputBorder =
        OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText),
        SizedBox(
          height: 10,
        ),
        TextField(
          controller: textEditingController,
          decoration: InputDecoration(
              hintText: hintText,
              border: inputBorder,
              focusedBorder: inputBorder,
              enabledBorder: inputBorder,
              filled: true,
              contentPadding: const EdgeInsets.all(8)),
          keyboardType: textInputType,
          obscureText: isPass,
        ),
      ],
    );
  }
}
