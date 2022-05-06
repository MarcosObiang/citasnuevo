import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/AuthScreenEntity.dart';
import 'package:citasnuevo/domain/repository/authRepo/authRepo.dart';
import 'package:dartz/dartz.dart';

class AuthScreenController implements Controller {
  final AuthRepository authRepository;

  AuthScreenController({required this.authRepository});

  Future<Either<Failure, AuthResponseEntity>>
      checkIfUserIsAlreadySignedUp() async {
    return authRepository.checkSignedInUser();
  }

  Future<Either<Failure, AuthResponseEntity>> signInWithGoogleAccount() async {
    return authRepository.logIn(
        params: const LoginParams(loginType: LoginType.google));
  }

    Future<Either<Failure, AuthResponseEntity>> logOut() async {
    return authRepository.logOut(
        );
  }

  @override
  void clearModuleData() {
    // TODO: implement clearModuleData
    throw UnimplementedError();
  }

  @override
  void initializeModuleData() {
    // TODO: implement initializeModuleData
  }
}
