import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/authDataSources/authDataSourceImpl.dart';
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
  Future<Either<Failure, AuthResponseEntity>> logIn(
      {required LoginParams params}) async {
    try {
      AuthResponseEntity authData =
          await authDataSource.signInWithGoogle(params: params);

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
  Future<Either<Failure, AuthResponseEntity>> logOut() async {
    try {
      AuthResponseEntity authData = await authDataSource.signOut();

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
  Future<Either<Failure, AuthResponseEntity>> checkSignedInUser() async {
    try {
      AuthResponseEntity authResponseEntity =
          await authDataSource.checkIfIsSignedIn();
      if (authResponseEntity.authState == AuthState.succes) {
        return Right(authResponseEntity);
      } else {
        return Right(authResponseEntity);
      }
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
