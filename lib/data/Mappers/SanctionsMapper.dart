import 'package:citasnuevo/domain/entities/SanctionsEntity.dart';

class SanctionMapper{


  static SanctionsEntity fromMap(Map<String,dynamic> data ){
return   SanctionsEntity(
        sanctionConfirmed: data["sancionado"]["moderado"],
        sanctionTimeStamp: data["sancionado"]["finSancion"],
        isUserSanctioned:data["sancionado"]["usuarioSancionado"]);
  }
}