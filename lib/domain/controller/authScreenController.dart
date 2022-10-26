import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:dartz/dartz.dart';

class AuthScreenController implements ModuleCleanerController {
  final AuthRepository authRepository;

  AuthScreenController({required this.authRepository});

  Future<Either<Failure, bool>> checkIfUserIsAlreadySignedUp() async {
    return authRepository.checkSignedInUser();
  }

  Future<Either<Failure, bool>> signInWithGoogleAccount() async {
    return authRepository.logIn(signInProviders: SignInProviders.GOOGLE);
  }

  

  @override
  Either<Failure,bool> clearModuleData() {
throw UnimplementedError();  }

  @override
   Either<Failure,bool> initializeModuleData() {
throw UnimplementedError();  }
}
