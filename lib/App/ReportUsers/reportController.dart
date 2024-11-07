import 'package:citasnuevo/App/ControllerBridges/HomeScreenCotrollerBridge.dart';
import 'package:citasnuevo/App/ProfileViewer/homeScreenController.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';
import 'reportRepo.dart';

abstract class ReportController implements ModuleCleanerController {
  late ReportRepository reportRepository;
  late HomeScreenControllerBridge homeScreenControllerBridge;
  Future<Either<Failure, bool>> sendUserReport(
      {required String idUserReported,
      required String idReporter,
      required String reportDetails});
}

class ReportControllerImpl implements ReportController {
  @override
  HomeScreenControllerBridge homeScreenControllerBridge;
  ReportRepository reportRepository;
  ReportControllerImpl(
      {required this.reportRepository,
      required this.homeScreenControllerBridge});

  Future<Either<Failure, bool>> sendUserReport(
      {required String idUserReported,
      required String idReporter,
      required String reportDetails}) async {
    final result = await reportRepository.sendReport(
        reporterId: idReporter,
        userReportedId: idUserReported,
        reportDetails: reportDetails);

    if (result.isRight()) {
      homeScreenControllerBridge.addInformation(
          information: {"data": idUserReported, "header": "user_reported"});
    }

    return result;
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
