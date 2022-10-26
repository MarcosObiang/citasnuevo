import 'dart:async';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/data/dataSources/reactionDataSources/reactionDataSource.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

abstract class ReactionRepository implements ModuleCleanerRepository,StreamParser {
  late ReactionDataSource reactionDataSource;





  ///Get first addidional values (gems and reaction average)
  Either<Failure, Map> getAdditionalValues();

  Future<Either<Failure, void>> revealReaction({required String reactionId});

  Future<Either<Failure, bool>> acceptReaction({
    required String reactionId,
    required String reactionSenderId,
  });

  Future<Either<Failure, bool>> rejectReaction({required String reactionId});


}
