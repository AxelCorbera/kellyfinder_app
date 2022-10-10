import 'package:app/src/model/chat/message.dart';
import 'package:app/src/model/support/conversion.dart';
import 'package:app/src/model/user.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'message_outgoing.g.dart';

enum MessageOutgoingStatus { NEW, SENT, FAILED }

@JsonSerializable()
class MessageOutgoing extends Message {
  MessageOutgoingStatus status;

  MessageOutgoing({
    @required int id,
    @required String text,
    @required String date,
    @required User user,
    MessageOutgoingStatus status = MessageOutgoingStatus.NEW,
    bool hasBeenRead,
  })  : this.status = status,
        super(
          id: id,
          text: text,
          date: date,
          user: user,
          hasBeenRead: hasBeenRead,
        );

  MessageOutgoing.copy(MessageOutgoing original)
      : this.status = original.status,
        super(
          id: original.id,
          text: original.text,
          date: original.date,
        );

  factory MessageOutgoing.fromJson(Map<String, dynamic> json) =>
      _$MessageOutgoingFromJson(json);

  Map<String, dynamic> toJson() => _$MessageOutgoingToJson(this);
}
