import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/error/Failure.dart';
import 'SettingsEntity.dart';
import 'SettingsMapper.dart';
import 'SettingsRepository.dart';
import 'settingsDataSource.dart';

class SettingsRepoImpl implements SettingsRepository {
  @override
  SettingsDataSource settingsDataSource;
  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;

  @override
  StreamController? get getStreamParserController => streamParserController;
  SettingsRepoImpl({
    required this.settingsDataSource,
  });

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      settingsDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserController?.close();
      streamParserSubscription?.cancel();
      streamParserController = null;
      streamParserSubscription = null;
      settingsDataSource.clearModuleData();
      streamParserController= StreamController();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  void purchase(String productId) {
    settingsDataSource.purchaseSubscription(productId);
  }
    


  @override
  void parseStreams() {
    if (this.settingsDataSource.onUserSettingsUpdate != null &&
        streamParserController != null) {
      streamParserSubscription =
          settingsDataSource.onUserSettingsUpdate!.stream.listen((event) {
        try {
          SettingsEntity settingsEntity = SettingsMapper.fromMap(event);
          streamParserController!.add(
              {"payloadType": "settingsEntity", "payload": settingsEntity});
        } catch (e) {
          streamParserController!.addError(e);
        }
      }, onError: (error) {
        streamParserController!.addError(error);
      });
    }
  }
}
