import 'package:dartz/dartz.dart';

import '../controllerDef.dart';
import '../../core/error/Failure.dart';
abstract class AuthRepository{
  Future<Either<Failure, Map<String,dynamic>>> logIn({required SignInProviders signInProviders});
  Future<Either<Failure, Map<String,dynamic>>> checkSignedInUser();}