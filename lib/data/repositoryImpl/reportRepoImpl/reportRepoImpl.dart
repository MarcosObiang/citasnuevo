import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/reportDataSource/reportDataSource.dart';
import 'package:citasnuevo/domain/repository/reportRepo/reportRepo.dart';

import '../../../core/dependencies/error/Exceptions.dart';

class ReportRepositoryImpl implements ReportRepository {
  @override
  ReportDataSource reportDataSource;
  ReportRepositoryImpl({
    required this.reportDataSource,
  });

  @override
  Future<Either<Failure, bool>> reportMessages(
      {required String reporterId,
      required String userReportedId,
      required String reportDetails,
      required String messageId}) {
    // TODO: implement reportMessages
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, bool>> sendReport(
      {required String reporterId,
      required String userReportedId,
      required String reportDetails}) async {
    try {
      await reportDataSource.sendReport(
          blockUser: false,
          idReporter: reporterId,
          idUserReported: userReportedId,
          reportDetails: reportDetails);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else if (e is ReportException) {
        return Left(ReportFailure(message: e.toString()));
      } else {
        return Left(ReportFailure(message: e.toString()));
      }
    }
  }
}
