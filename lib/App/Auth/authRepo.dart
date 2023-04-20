import 'package:dartz/dartz.dart';

import '../controllerDef.dart';
import '../../core/error/Failure.dart';
import '../../core/params_types/params_and_types.dart';
import 'AuthScreenEntity.dart';
abstract class AuthRepository{
  Future<Either<Failure, Map<String,dynamic>>> logIn({required SignInProviders signInProviders});
  Future<Either<Failure, Map<String,dynamic>>> checkSignedInUser();}