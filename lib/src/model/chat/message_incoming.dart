import 'package:app/src/model/chat/message.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:app/src/model/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'message_incoming.g.dart';

@JsonSerializable()
class MessageIncoming extends Message {
  MessageIncoming({
    @required int id,
    @required String text,
    @required String date,
    @required User user,
    @required bool hasBeenRead,
  }) : super(
          id: id,
          text: text,
          date: date,
          user: user,
          hasBeenRead: hasBeenRead,
        );

  MessageIncoming.copy(MessageIncoming original)
      : super(
          id: original.id,
          text: original.text,
          date: original.date,
        );

  factory MessageIncoming.fromJson(Map<String, dynamic> json) =>
      _$MessageIncomingFromJson(json);

  Map<String, dynamic> toJson() => _$MessageIncomingToJson(this);
}
