import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/domain/repository/reportRepo/reportRepo.dart';

import '../../core/dependencies/error/Failure.dart';

class ReportController implements Controller  {
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
  void clearModuleData() {
    // TODO: implement clearModuleData
    throw UnimplementedError();
  }

  @override
  void initializeModuleData() {
    // TODO: implement initializeModuleData
  }
}
