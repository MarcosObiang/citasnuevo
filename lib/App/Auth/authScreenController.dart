import '../../core/error/Failure.dart';
import '../../core/params_types/params_and_types.dart';
import '../controllerDef.dart';
import 'AuthScreenEntity.dart';
import '../DataManager.dart';
import 'authRepo.dart';
import 'package:dartz/dartz.dart';

class AuthScreenController implements ModuleCleanerController {
  final AuthRepository authRepository;

  AuthScreenController({required this.authRepository});

  Future<Either<Failure, Map<String, dynamic>>>
      checkIfUserIsAlreadySignedUp() async {
    return authRepository.checkSignedInUser();
  }

  Future<Either<Failure, Map<String, dynamic>>>
      signInWithGoogleAccount() async {
    return authRepository.logIn(signInProviders: SignInProviders.GOOGLE);
  }

  @override
  Either<Failure, bool> clearModuleData() {
    throw UnimplementedError();
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    throw UnimplementedError();
  }
}
