import 'package:app/src/model/chat/message.dart';
import 'package:app/src/model/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'chat.g.dart';

@JsonSerializable()
class Chat {
  int id;
  @JsonKey(name: "other_user")
  User contact;
  List<Message> messages;
  @JsonKey(name: "last_message")
  Message lastMessage;

  Chat(this.id, this.contact, this.messages, this.lastMessage);

  factory Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

  Map<String, dynamic> toJson() => _$ChatToJson(this);
}
