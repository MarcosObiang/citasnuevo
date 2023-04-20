import 'dart:async';

import 'package:dartz/dartz.dart';

import '../DataManager.dart';
import '../../core/error/Failure.dart';
import '../../core/streamParser/streamPareser.dart';
import 'reactionDataSource.dart';

abstract class ReactionRepository
    implements ModuleCleanerRepository, StreamParser {
  late ReactionDataSource reactionDataSource;

  ///Get first addidional values (gems and reaction average)
  Either<Failure, Map> getAdditionalValues();

  Future<Either<Failure, void>> revealReaction({required String reactionId});

  Future<Either<Failure, bool>> showInterstitial();
  Future<Either<Failure, bool>> showRewarded();
  StreamController<Map<String, dynamic>> get rewardedStatusListener;
  StreamController<Map<String, dynamic>> get interstitialRewardedListener;

  Future<Either<Failure, bool>> acceptReaction({
    required String reactionId,
    required String reactionSenderId,
  });

  Future<Either<Failure, bool>> rejectReaction({required String reactionId});
  void closeAdsStreams();
}
