import 'dart:async';

import '../../core/dependencies/dependencyCreator.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../controllerDef.dart';
import '../../core/error/Exceptions.dart';
import '../../core/services/AuthService.dart';
import '../../core/globalData.dart';
import '../../core/platform/networkInfo.dart';

abstract class AuthScreenDataSource
    implements
        AuthenticationLogInCapacity,
        AuthenticationUserAlreadySignedInCapacity,
        DataSource,
        ModuleCleanerDataSource {
  StreamController<Map<String, dynamic>>? authStateStream;
}

class AuthScreenDataSourceImpl implements AuthScreenDataSource {
  AuthService authService;

  @override
  StreamController<Map<String, dynamic>>? authStateStream = StreamController();
  @override
  ApplicationDataSource source;

  @override
  StreamSubscription? sourceStreamSubscription;
  AuthScreenDataSourceImpl({required this.authService, required this.source});
  @override
  void clearModuleData() {
    try {
      sourceStreamSubscription?.cancel();
      authStateStream?.close();
      authStateStream = StreamController();
    } catch (e) {
      throw ModuleCleanException(message: e.toString());
    }
  }

  @override
  void initializeModuleData() {
    try {
      subscribeToMainDataSource();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> checkIfUserIsAlreadySignedIn() async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        late Map<String, dynamic> authData;
        authData = await authService.userAlreadySignedIn();

        return authData;
      } catch (e) {
        throw AuthException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<Map<String, dynamic>> logIn(
      {required SignInProviders signInProviders}) async {
    if (await Dependencies.networkInfoContract.isConnected) {
      try {
        late Map<String, dynamic> authData;
        authData = await authService.logUser(signInProviders: signInProviders);

        return authData;
      } catch (e) {
        throw AuthException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  void subscribeToMainDataSource() {
    sourceStreamSubscription = source.dataStream?.stream.listen((event) {
      authStateStream?.add(event);
    });
  }
}
