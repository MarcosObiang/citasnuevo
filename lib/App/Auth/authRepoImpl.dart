import 'package:dartz/dartz.dart';

import '../controllerDef.dart';
import '../../core/error/Exceptions.dart';
import '../../core/error/Failure.dart';
import 'authDataSourceImpl.dart';
import 'authRepo.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthScreenDataSource authDataSource;
  AuthRepositoryImpl({
    required this.authDataSource,
  });
  @override
  Future<Either<Failure, Map<String, dynamic>>> logIn(
      {required SignInProviders signInProviders}) async {
    try {
      Map<String, dynamic> authData =
          await authDataSource.logIn(signInProviders: signInProviders);

      return Right(authData);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is AuthException) {
        return Left(AuthFailure(message: e.toString()));
      } else {
        return Left(ServerFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> checkSignedInUser() async {
    try {
      Map<String, dynamic> authResponseEntity =
          await authDataSource.checkIfUserIsAlreadySignedIn();
      return Right(authResponseEntity);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is AuthException) {
        return Left(AuthFailure(message: e.toString()));
      } else {
        return Left(ServerFailure(message: e.toString()));
      }
    }
  }
}
