import '../../core/error/Failure.dart';
import '../controllerDef.dart';
import '../DataManager.dart';
import 'authRepo.dart';
import 'package:dartz/dartz.dart';

abstract class AuthScreenController implements ModuleCleanerController {
  late AuthRepository authRepository;
  Future<Either<Failure, Map<String, dynamic>>> signIn(
      {required SignInProviders signInProviders});
  Future<Either<Failure, Map<String, dynamic>>> checkIfUserIsAlreadySignedUp();
}

class AuthScreenControllerImpl implements AuthScreenController {
  AuthScreenControllerImpl({required this.authRepository});

  Future<Either<Failure, Map<String, dynamic>>>
      checkIfUserIsAlreadySignedUp() async {
    return authRepository.checkSignedInUser();
  }

  Future<Either<Failure, Map<String, dynamic>>> signIn(
      {required SignInProviders signInProviders}) async {
    return authRepository.logIn(signInProviders: signInProviders);
  }

  @override
  Either<Failure, bool> clearModuleData() {
    throw UnimplementedError();
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    throw UnimplementedError();
  }

  @override
  AuthRepository authRepository;
}
