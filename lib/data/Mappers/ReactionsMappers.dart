import 'dart:convert';

import 'package:citasnuevo/data/Mappers/ConverterDefinition.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';

class ReactionConverter implements DataSourceConverter<Reaction> {
  @override
  Reaction fromMap(Map data) {
    bool revealed = data["revelada"];

    if (revealed) {
      return Reaction(
          age: 20,
          reactionExpirationDateInSeconds: data["caducidad"],
          reactioValue: data["Valoracion"],
          imageHash: data["hash"],
          imageUrl: data["Imagen Usuario"],
          name: data["Nombre Usuario"],
          idReaction: data["id valoracion"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed);
    } else {
      return Reaction(
          age: 20,
          reactionExpirationDateInSeconds: data["caducidad"],
          reactioValue: 0,
          imageHash: "NOT_AVAILABLE",
          imageUrl: "NOT_AVAILABLE",
          name: "NOT_AVAILABLE",
          idReaction: data["id valoracion"],
          reactionRevealigState: revealed
              ? ReactionRevealigState.revealed
              : ReactionRevealigState.notRevealed);
    }
  }

  @override
  Map<String, dynamic> toMap(Reaction data) {
    throw UnimplementedError();
  }
}
