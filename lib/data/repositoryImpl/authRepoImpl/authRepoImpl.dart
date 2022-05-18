import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/authDataSources/authDataSourceImpl.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/params_types/params_and_types.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource authDataSource;
  AuthRepositoryImpl({
    required this.authDataSource,
  });
  @override
  Future<Either<Failure, bool>> logIn(
      {required SignInProviders signInProviders}) async {
    try {
      bool authData =
          await authDataSource.logIn(signInProviders: SignInProviders.GOOGLE);

      return Right(authData);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      }
      if (e is AuthException) {
        return Left(AuthFailure());
      } else {
        return Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, bool>> checkSignedInUser() async {
    try {
      bool authResponseEntity =
          await authDataSource.checkIfUserIsAlreadySignedIn();
      return Right(authResponseEntity);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      }
      if (e is AuthException) {
        return Left(AuthFailure());
      } else {
        return Left(ServerFailure());
      }
    }
  }
}
