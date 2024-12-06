import 'dart:convert';

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';

import 'ReactionEntity.dart';

class ReactionMapper implements Mapper<Reaction> {
  Reaction fromMap(Map data) {
    bool revealed = data["reactionRevealed"];

    if (revealed) {
      return Reaction(
          userBlocked: data["userBlocked"],
          revealed: data["reactionRevealed"],
          age: 20,
          reactionExpirationDateInSeconds:
              (data["expirationTimestamp"] ~/ 1000),
          imageHash: "",
          imageUrl: {"imageData":data["userPicture"]},
          name: data["senderName"],
          senderId: data["senderId"],
          idReaction: data["reactionId"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed,
          reactionValue: data["reactionValue"]);
    } else {
      return Reaction(
          userBlocked: data["userBlocked"],
          revealed: data["reactionRevealed"],
          age: 20,
          reactionExpirationDateInSeconds:
              (data["expirationTimestamp"] ~/ 1000),
          imageHash: "",
          imageUrl: {"imageData": kNotAvailable},
          name: "",
          senderId: data["senderId"],
          idReaction: data["reactionId"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed,
          reactionValue: data["reactionValue"]);
    }
  }

  @override
  Map<String, dynamic> toMap(data) {
    // TODO: implement toMap
    throw UnimplementedError();
  }
}
