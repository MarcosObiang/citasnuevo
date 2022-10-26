import 'dart:async';

import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';

abstract class UserCreatorRepo  implements ModuleCleanerRepository{

  Future<Either<Failure,bool>>createUser({required Map<String,dynamic>userData});
   Future<Either<Failure,bool>>logOut();


}