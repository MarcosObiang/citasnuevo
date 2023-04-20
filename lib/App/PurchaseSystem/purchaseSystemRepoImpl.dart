import 'dart:async';
import 'dart:ffi';

import 'purchaseSystemDataSource.dart';
import 'purchaseSystemMapper.dart';
import 'purchasesystemRepository.dart';

import '../../core/error/Exceptions.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';

import '../../../core/params_types/params_and_types.dart';

class PurchaseSystemRepoImpl implements PurchaseSystemRepository {
  @override
  PurchaseSystemDataSource purchaseSystemDataSource;

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;
  PurchaseSystemRepoImpl({
    required this.purchaseSystemDataSource,
  });

  @override
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserController?.close();
      streamParserController = null;
      streamParserController = StreamController();
      streamParserSubscription?.cancel();
      streamParserSubscription = null;
      purchaseSystemDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  StreamController? get getStreamParserController =>
      this.streamParserController;

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      purchaseSystemDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> makePurchase({required String offerId}) async {
    try {
      bool value =
          await purchaseSystemDataSource.makePurchase(offerId: offerId);
      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(PurchaseSystemFailure(message: e.toString()));
      }
    }
  }

  @override
  void parseStreams() {
    if (purchaseSystemDataSource.purchaseSystemStream != null &&
        streamParserController != null) {
      streamParserSubscription = purchaseSystemDataSource
          .purchaseSystemStream!.stream
          .listen((event) async {
        try {
          String payloadType = event["payloadType"];
          if (payloadType == "purchaseSystemEvent") {
            streamParserController?.add({
              "payloadType": "purchaseSystemEvent",
              "data": PurchaseSystemMapper.fromMap(data: event)
            });
          }
        } catch (e) {
          streamParserController!.addError(e);
        }
      }, onError: (error) {
        streamParserController!.addError(error);
      });
    } else {
      throw Exception(kStreamParserNullError);
    }
  }

  @override
  Future<Either<Failure, void>> openSubscriptionMenu() async {
    try {
      await purchaseSystemDataSource.openSubscriptionMenu();
      return Right(Void);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(PurchaseSystemFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> restorePurchases() async {
    try {
      bool value = await purchaseSystemDataSource.restorePurchases();
      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(PurchaseSystemFailure(message: e.toString()));
      }
    }
  }
}
