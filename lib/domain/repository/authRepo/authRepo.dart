import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:dartz/dartz.dart';
abstract class AuthRepository{
  Future<Either<Failure,AuthResponseEntity>> logIn({required LoginParams params});
  Future<Either<Failure,AuthResponseEntity>> logOut();
  Future<Either<Failure,AuthResponseEntity>> checkSignedInUser();}