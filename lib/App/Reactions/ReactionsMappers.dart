import 'dart:convert';

import 'ReactionEntity.dart';


class ReactionMapper {
  static Reaction fromMap(Map data) {
    bool revealed = data["reactionRevealed"];

    if (revealed) {
      return Reaction(
          userBlocked: data["userBlocked"],
          revealed: data["reactionRevealed"],
          age: 20,
          reactionExpirationDateInSeconds:
              (data["expirationTimestamp"] ~/ 1000),
          reactioValue: data["reactionValue"],
          imageHash: "",
          imageUrl: jsonDecode(data["userPicture"]),
          name: data["senderName"],
          senderId: data["senderId"],
          idReaction: data["reactionId"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed);
    } else {
      return Reaction(
          userBlocked: data["userBlocked"],
          revealed: data["reactionRevealed"],
          age: 20,
          reactionExpirationDateInSeconds:
              (data["expirationTimestamp"] ~/ 1000),
          reactioValue: 0,
          imageHash: "",
          imageUrl: {"imageId": null},
          name: "",
          senderId: "",
          idReaction: data["reactionId"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed);
    }
  }
}
