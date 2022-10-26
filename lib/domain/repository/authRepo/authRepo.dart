import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:dartz/dartz.dart';
abstract class AuthRepository{
  Future<Either<Failure,bool>> logIn({required SignInProviders signInProviders});
  Future<Either<Failure,bool>> checkSignedInUser();}