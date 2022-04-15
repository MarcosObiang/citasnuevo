
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';

class ReactionConverter {
  static Reaction fromMap(Map data) {
    bool revealed = data["revelada"];

    if (revealed) {
      return Reaction(
          age: 20,
          reactionExpirationDateInSeconds: data["caducidad"],
          reactioValue: data["Valoracion"],
          imageHash: data["hash"],
          imageUrl: data["Imagen Usuario"],
          name: data["Nombe emisor"],
          senderId: data["Id emisor"],
          idReaction: data["id valoracion"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed);
    } else {
      return Reaction(
          age: 20,
          reactionExpirationDateInSeconds: data["caducidad"],
          senderId: data["idEmisor"],
          reactioValue: 0,
          imageHash: kNotAvailable,
          imageUrl: kNotAvailable,
          name: kNotAvailable,
          idReaction: data["id valoracion"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed);
    }
  }


}
