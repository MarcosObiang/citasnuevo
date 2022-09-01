import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';

class ReactionMapper {
  static Reaction fromMap(Map data) {
    bool revealed = data["revelada"];

    if (revealed) {
      return Reaction(
          userBlocked: data["bloqueado"],
          revealed: data["revelada"],
          age: 20,
          reactionExpirationDateInSeconds: data["caducidad"],
          reactioValue: double.parse(data["Valoracion"].toString()),
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
                  revealed: data["revelada"],

          userBlocked: data["bloqueado"],
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
