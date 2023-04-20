import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import '../DataManager.dart';
import '../../core/streamParser/streamPareser.dart';
import 'settingsDataSource.dart';



abstract class SettingsRepository implements ModuleCleanerRepository,StreamParser{

  late SettingsDataSource settingsDataSource;



  void purchase(String productId);


}