import 'dart:async';

import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsController.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepo.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepoImpl.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/error/Failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ApplicationSettingsController_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ApplicationSettingsDataSource>(),
  MockSpec<ApplicationDataSourceImpl>(),
  MockSpec<AppSettingsRepository>(),
  MockSpec<ApplicationSettingsRepositoryImpl>(),
  MockSpec<AppSettingsController>(),
  MockSpec<AppSettingsControllerImpl>()
])
void main() {
  MockAppSettingsRepository mockAppSettingsRepository =
      MockAppSettingsRepository();
  AppSettingsController appSettingsController = AppSettingsControllerImpl(
      appSettingsRepository: mockAppSettingsRepository,
      settingsToAppSettingsControllerBridge:
          Dependencies.settingsControllerBridge);
  ApplicationSettingsEntity applicationSettingsEntity =
      ApplicationSettingsEntity(
          distance: 2,
          maxAge: 30,
          minAge: 18,
          inCm: true,
          inKm: true,
          showBothSexes: false,
          showWoman: true,
          showProfile: true);

  group("Testing the 'initializeListener()' method", () {
    test(
        "Testing  the link between the controller and the repositoyr via streamParserController",
        () {
      when(mockAppSettingsRepository.getStreamParserController)
          .thenReturn(StreamController.broadcast());

      appSettingsController.initializeListener();
    });
    test("Testing the reception of the entity", () async {
      when(mockAppSettingsRepository.getStreamParserController)
          .thenReturn(StreamController.broadcast());

      appSettingsController.initializeListener();

      mockAppSettingsRepository.getStreamParserController?.add({
        "payloadType": "applicationSettingsEntity",
        "payload": applicationSettingsEntity
      });

      await Future.delayed(Duration(seconds: 1));

      expect(appSettingsController.applicationSettingsEntity, isNotNull);
      expect(appSettingsController.applicationSettingsEntity,
          isA<ApplicationSettingsEntity>());
    });
    test(
        "Testing errorHandling inside the subscription to 'getStresmParseSubscription",
        () async {
      when(mockAppSettingsRepository.getStreamParserController)
          .thenReturn(StreamController());

      appSettingsController.initializeListener();
      await Future.delayed(Duration(seconds: 1));

      mockAppSettingsRepository.getStreamParserController?.add({
        "payloadType": "applicationSettingsEntity",
        "payload": StreamController()
      });
      expect(appSettingsController.updateDataController?.stream,
          emitsError(isA<Exception>()));
    });
  });

  group("Testing the 'updateAppSettings' function", () {
    test("Error handling", () async {
      when((mockAppSettingsRepository.updateSettings(any))).thenAnswer(
          (_) => Future.value(Left(AppSettingsFailure(message: "message"))));

      var result = await appSettingsController
          .updateAppSettings(applicationSettingsEntity);

      late var failureType;

      result.fold((l) => failureType = l, (r) => null);

      expect(failureType, isA<AppSettingsFailure>());
    });

    test("Error handling (Network)", () async {
      when((mockAppSettingsRepository.updateSettings(any))).thenAnswer(
          (_) => Future.value(Left(NetworkFailure(message: "message"))));

      var result = await appSettingsController
          .updateAppSettings(applicationSettingsEntity);

      late var failureType;

      result.fold((l) => failureType = l, (r) => null);

      expect(failureType, isA<NetworkFailure>());
    });
  });
  group("Testing the 'deleteAccount' function", () {
    test("Error handling", () async {
      when((mockAppSettingsRepository.deleteAccount())).thenAnswer(
          (_) => Future.value(Left(AppSettingsFailure(message: "message"))));

      var result = await appSettingsController.deleteAccount();

      late var failureType;

      result.fold((l) => failureType = l, (r) => null);

      expect(failureType, isA<AppSettingsFailure>());
    });

    test("Error handling (Network)", () async {
      when((mockAppSettingsRepository.deleteAccount())).thenAnswer(
          (_) => Future.value(Left(NetworkFailure(message: "message"))));

      var result = await appSettingsController.deleteAccount();

      late var failureType;

      result.fold((l) => failureType = l, (r) => null);

      expect(failureType, isA<NetworkFailure>());
    });
  });

  group("Testing the 'deleteAccount' function", () {
    test("Error handling", () async {
      when((mockAppSettingsRepository.logOut())).thenAnswer(
          (_) => Future.value(Left(AppSettingsFailure(message: "message"))));

      var result = await appSettingsController.logOut();

      late var failureType;

      result.fold((l) => failureType = l, (r) => null);

      expect(failureType, isA<AppSettingsFailure>());
    });
  });

  group("Testing the cloearModuleFunction", () {
    test("Asserting all variables are set to default", () {
      appSettingsController.clearModuleData();

      expect(appSettingsController.streamParserSubscription, isNull);
      expect(appSettingsController.updateDataController, isNotNull);

      verify(mockAppSettingsRepository.clearModuleData()).called(1);
    });

    test(
        "Testing error handling (Exception during variable being set to default)",
        () async {
      when(mockAppSettingsRepository.clearModuleData()).thenThrow(Exception());

      var result = appSettingsController.clearModuleData();

      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(failureType, isA<ModuleClearFailure>());
    });
    test("Testing error handling (Exception when calling to repository)",
        () async {
      when(mockAppSettingsRepository.clearModuleData())
          .thenReturn(Left(ModuleClearFailure(message: "Error")));

      var result = appSettingsController.clearModuleData();

      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(failureType, isA<ModuleClearFailure>());
    });
  });

  group("Testing the initializeModuleData", () {
    test("Asserting all variables are set to default", () {
      appSettingsController.initializeModuleData();

      verify(mockAppSettingsRepository.initializeModuleData()).called(1);
    });

    test(
        "Testing error handling (Exception during variable being set to default)",
        () async {
      when(mockAppSettingsRepository.initializeModuleData())
          .thenThrow(Exception());

      var result = appSettingsController.initializeModuleData();

      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(failureType, isA<ModuleInitializeFailure>());
    });
    test("Testing error handling (Exception when calling to repository)",
        () async {
      when(mockAppSettingsRepository.initializeModuleData())
          .thenReturn(Left(ModuleInitializeFailure(message: "Error")));

      var result = appSettingsController.initializeModuleData();

      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(failureType, isA<ModuleInitializeFailure>());
    });
  });
}
