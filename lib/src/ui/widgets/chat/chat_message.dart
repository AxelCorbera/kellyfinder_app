import 'package:app/src/model/chat/message.dart';
import 'package:flutter/material.dart';

abstract class ChatMessage extends Widget {
  Message get message;
  AnimationController get animationController;
}
