import 'package:citasnuevo/data/daraSources/reportDataSource/reportDataSource.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';

abstract class ReportRepository {
    late ReportDataSource reportDataSource;

  Future<Either<Failure, bool>> sendReport(
      {required String reporterId,
      required String userReportedId,
      required String reportDetails});
  Future<Either<Failure, bool>> reportMessages(
      {required String reporterId,
      required String userReportedId,
      required String reportDetails,
      required String messageId});
}