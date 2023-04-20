import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../../../core/streamParser/streamPareser.dart';
import '../DataManager.dart';
import 'purchaseSystemDataSource.dart';

abstract class PurchaseSystemRepository
    implements ModuleCleanerRepository, StreamParser {
  late PurchaseSystemDataSource purchaseSystemDataSource;
  Future<Either<Failure, bool>> makePurchase({required String offerId});
  Future<Either<Failure, void>> openSubscriptionMenu();
  Future<Either<Failure, bool>> restorePurchases();
}
