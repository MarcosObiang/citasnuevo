import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/App/ApplicationSettings/AplicationDataSettingsMapper.dart';
import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsEntity.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsController.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepo.dart';
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepoImpl.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ApplicationSettingsRepo_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<ApplicationSettingsDataSource>(
      onMissingStub: OnMissingStub.throwException),
  MockSpec<Mapper<ApplicationSettingsEntity>>(
      onMissingStub: OnMissingStub.throwException)
])
void main() {
  MockApplicationSettingsDataSource mockApplicationSettingsDataSource =
      MockApplicationSettingsDataSource();
  MockMapper mockMapper = MockMapper();
  AppSettingsRepository mockAppSettingsRepository =
      ApplicationSettingsRepositoryImpl(
          mapper: mockMapper,
          appSettingsDataSource: mockApplicationSettingsDataSource);

  group("Testing the clearModuleData method ", () {
    test("Making sure the method leaves all variables to their default state",
        () {
      var result = mockAppSettingsRepository.clearModuleData();
      expect(result.isRight(), true);
      expect(mockAppSettingsRepository.streamParserSubscription == null, true);
      expect(
          mockAppSettingsRepository.streamParserController is StreamController,
          true);
    });

    test("Testing the exception handling", () {
      when(mockAppSettingsRepository.appSettingsDataSource.clearModuleData())
          .thenThrow(Exception());
      var result = mockAppSettingsRepository.clearModuleData();

      expect(result.isLeft(), true);
    });
  });
  group("Testing the initializeModuleData method", () {
    test("Testing the initializeModuleData method succesfull execution", () {
      when(mockApplicationSettingsDataSource.listenAppSettingsUpdate)
          .thenReturn(StreamController());
      var result = mockAppSettingsRepository.initializeModuleData();

      expect(result.isRight(), true);
    });

    test("Testing the initializeModuleData method unsuccesfull execution", () {
      when(mockApplicationSettingsDataSource.listenAppSettingsUpdate)
          .thenReturn(StreamController());
      when(mockAppSettingsRepository.appSettingsDataSource
              .initializeModuleData())
          .thenThrow(Exception());
      var result = mockAppSettingsRepository.initializeModuleData();

      expect(result.isLeft(), true);
    });
  });

  group("Testing deleteAccount  method", () {
    test("Testing succesful execution", () async {
      when(mockAppSettingsRepository.appSettingsDataSource.deleteAccount())
          .thenAnswer((_) => Future.value(true));
      var result = await mockAppSettingsRepository.deleteAccount();
      expect(result.isRight(), true);
    });
    test("Testing unsuccesfull operation (Network Exception)", () async {
      when(mockAppSettingsRepository.appSettingsDataSource.deleteAccount())
          .thenThrow(NetworkException(message: kNetworkErrorMessage));
      var result = await mockAppSettingsRepository.deleteAccount();
      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(result.isLeft(), true);
      expect(failureType, isA<NetworkFailure>());
    });
    test("Testing unsuccesfull operation (AppSettingsException Exception)",
        () async {
      when(mockAppSettingsRepository.appSettingsDataSource.deleteAccount())
          .thenThrow(AppSettingsException(message: kNetworkErrorMessage));
      var result = await mockAppSettingsRepository.deleteAccount();
      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(result.isLeft(), true);
      expect(failureType, isA<AppSettingsFailure>());
    });
  });
  group("Testing logOut  method", () {
    test("Testing succesful execution", () async {
      when(mockAppSettingsRepository.appSettingsDataSource.logOut())
          .thenAnswer((_) => Future.value(true));
      var result = await mockAppSettingsRepository.logOut();
      expect(result.isRight(), true);
    });
    test("Testing unsuccesfull operation (Network Exception)", () async {
      when(mockAppSettingsRepository.appSettingsDataSource.logOut())
          .thenThrow(NetworkException(message: kNetworkErrorMessage));
      var result = await mockAppSettingsRepository.logOut();
      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(result.isLeft(), true);
      expect(failureType, isA<NetworkFailure>());
    });
    test("Testing unsuccesfull operation (AuthSettings Exception)", () async {
      when(mockAppSettingsRepository.appSettingsDataSource.logOut())
          .thenThrow(AuthException(message: kNetworkErrorMessage));
      var result = await mockAppSettingsRepository.logOut();
      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(result.isLeft(), true);
      expect(failureType, isA<AuthFailure>());
    });
    test("Testing unsuccesfull operation (Server Exception)", () async {
      when(mockAppSettingsRepository.appSettingsDataSource.logOut())
          .thenThrow(AppSettingsException(message: kNetworkErrorMessage));
      var result = await mockAppSettingsRepository.logOut();
      late var failureType;
      result.fold((l) => failureType = l, (r) => null);
      expect(result.isLeft(), true);
      expect(failureType, isA<ServerFailure>());
    });
  });

  group("Testing the parseStreams method", () {
    test("Testing whent the stream from de datasource is null case", () {
      when(mockAppSettingsRepository
              .appSettingsDataSource.listenAppSettingsUpdate)
          .thenReturn(null);
      expect(() => mockAppSettingsRepository.parseStreams(),
          throwsA(isA<AppSettingsException>()));
    });
    test("Testing when there is an error with parsing", () {
      Map<String, dynamic> event = {
        "maxDistance": 0,
        "maxAge": 23,
        "minAge": 18,
        "showCentimeters": true,
        "showKilometers": true,
        "showBothSexes": false,
        "showWoman": true,
        "showProfile": true
      };
      when(mockApplicationSettingsDataSource.listenAppSettingsUpdate != null)
          .thenReturn(true);
      when(mockApplicationSettingsDataSource.listenAppSettingsUpdate)
          .thenReturn(StreamController.broadcast());
      when(mockMapper.fromMap(event)).thenThrow(Exception());
      mockAppSettingsRepository.parseStreams();
      mockApplicationSettingsDataSource.listenAppSettingsUpdate?.add(event);
      expect(mockAppSettingsRepository.streamParserController?.stream,
          emitsError(isA<Exception>()));
    });
    test("Testing when an error comes from the data source", () {
      Map<String, dynamic> event = {
        "maxDistance": 0,
        "maxAge": 23,
        "minAge": 18,
        "showCentimeters": true,
        "showKilometers": true,
        "showBothSexes": false,
        "showWoman": true,
        "showProfile": true
      };
      when(mockApplicationSettingsDataSource.listenAppSettingsUpdate != null)
          .thenReturn(true);
      when(mockApplicationSettingsDataSource.listenAppSettingsUpdate)
          .thenReturn(StreamController.broadcast());
      when(mockMapper.fromMap(event)).thenThrow(Exception());
      mockAppSettingsRepository.parseStreams();
      mockApplicationSettingsDataSource.listenAppSettingsUpdate
          ?.addError(Exception());
      expect(mockAppSettingsRepository.streamParserController?.stream,
          emitsError(isA<Exception>()));
    });
  });

  group("Testing the updateDataFunction", () {
    Map<String, dynamic> event = {
      "maxDistance": 0,
      "maxAge": 23,
      "minAge": 18,
      "showCentimeters": true,
      "showKilometers": true,
      "showBothSexes": false,
      "showWoman": true,
      "showProfile": true
    };
    test("Testing unsuccesfull operation (NetworkFailure)", () async {
      when(mockMapper.toMap(any)).thenReturn(event);
      when(mockApplicationSettingsDataSource.updateAppSettings(event))
          .thenThrow(NetworkException(message: kNetworkErrorMessage));

      late var failureType;
      var result = await mockAppSettingsRepository.updateSettings(
          ApplicationSettingsEntity(
              distance: 2,
              maxAge: 30,
              minAge: 18,
              inCm: true,
              inKm: true,
              showBothSexes: false,
              showWoman: true,
              showProfile: true));
      result.fold((left) => failureType = left, (_) {});

      expect(result.isLeft(), true);
      expect(failureType, isA<NetworkFailure>());
    });
    test("Testing unsuccesfull operation (AppSettingsFailure)", () async {
      when(mockMapper.toMap(any)).thenReturn(event);
      when(mockApplicationSettingsDataSource.updateAppSettings(event))
          .thenThrow(Exception());

      late var failureType;
      var result = await mockAppSettingsRepository.updateSettings(
          ApplicationSettingsEntity(
              distance: 2,
              maxAge: 30,
              minAge: 18,
              inCm: true,
              inKm: true,
              showBothSexes: false,
              showWoman: true,
              showProfile: true));
      result.fold((left) => failureType = left, (_) {});

      expect(result.isLeft(), true);
      expect(failureType, isA<AppSettingsFailure>());
    });
  });
}
