import 'package:flutter/material.dart';

void handleSnackBar(GlobalKey<ScaffoldState> key, String content) {
  key.currentState.showSnackBar(SnackBar(content: Text(content)));
}
