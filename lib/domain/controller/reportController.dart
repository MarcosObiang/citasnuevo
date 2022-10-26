import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/domain/repository/reportRepo/reportRepo.dart';

import '../../core/error/Failure.dart';

class ReportController implements ModuleCleanerController {
  ReportRepository reportRepository;
  ReportController({
    required this.reportRepository,
  });

  Future<Either<Failure, bool>> sendUserReport(
      {required String idUserReported,
      required String idReporter,
      required String reportDetails}) async {
    return await reportRepository.sendReport(
        reporterId: idReporter,
        userReportedId: idUserReported,
        reportDetails: reportDetails);
  }

  @override
  Either<Failure, bool> clearModuleData() {
    throw UnimplementedError();
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    throw UnimplementedError();
  }
}
