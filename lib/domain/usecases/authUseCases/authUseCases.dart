import 'dart:async';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/usecases/usecases.dart';

import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:dartz/dartz.dart';
class LogInUseCase implements UseCase<AuthResponseEntity, LoginParams> {
  final AuthStateRepository authStateRepository;
  LogInUseCase({required this.authStateRepository});
  @override
  Future<Either<Failure, AuthResponseEntity>> call(LoginParams params) async {
    return await authStateRepository.logIn(params: params);
  }}
class CheckSignedInUserUseCase
    implements UseCase<AuthResponseEntity, LoginParams> {
  final AuthStateRepository authStateRepository;
  CheckSignedInUserUseCase({required this.authStateRepository});
  @override
  Future<Either<Failure, AuthResponseEntity>> call(LoginParams params) async {
    return await authStateRepository.checkSignedInUser();
  }}