import 'dart:async';

import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserCreatorEntity.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../DataManager.dart';

abstract class UserCreatorRepo  implements ModuleCleanerRepository, StreamParser{

  Future<Either<Failure,bool>>createUser({required Map<String,dynamic>userData});
   Future<Either<Failure,bool>>logOut();


}