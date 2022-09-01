import 'dart:async';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';
import '../DataManager.dart';

abstract class UserCreatorRepo  implements ModuleCleanerRepository{

  Future<Either<Failure,bool>>createUser({required Map<String,dynamic>userData});
   StreamController<UserCreatorInformationSender> get getUserCreatorDataStream;
   Future<Either<Failure,bool>>logOut();


}