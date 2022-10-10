import 'package:flutter/material.dart';

class CustomLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/logo.png",
      width: 120,
      height: 120,
    );
  }
}
