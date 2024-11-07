import 'dart:async';
import 'dart:convert';

import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsDataSource.dart';
import 'package:citasnuevo/App/MainDatasource/principalDataSource.dart';
import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/core/services/AuthService.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mockito/annotations.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:mockito/mockito.dart';

import 'ApplicationSettingsDataSource_test.mocks.dart';

@GenerateMocks([
  ApplicationDataSource,
  AuthService,
  NetworkInfoContract,
  Functions,
])
void main() {
  late MockApplicationDataSource mockApplicationDataSource;
  late MockAuthService mockAuthService;
  late MockFunctions mockFunctions;
  late MockNetworkInfoContract mockNetworkInfoContract;
  late ApplicationSettingsDataSource applicationSettingsDataSource;
  var userSettingsMock = {
    "maxDistance": 0,
    "maxAge": 23,
    "minAge": 18,
    "showCentimeters": true,
    "showKilometers": true,
    "showBothSexes": false,
    "showWoman": true,
    "showProfile": true
  };

  setUpAll(() {
    mockApplicationDataSource = MockApplicationDataSource();

    mockAuthService = MockAuthService();

    mockNetworkInfoContract = MockNetworkInfoContract();

    mockFunctions = MockFunctions();
    applicationSettingsDataSource = ApplicationDataSourceImpl(
        authService: mockAuthService,
        source: mockApplicationDataSource,
        networkInfoContract: mockNetworkInfoContract);
  });

  test("Testing the 'initializeModuleData()' function", () {
    when(applicationSettingsDataSource.source.getData)
        .thenReturn({"userSettings": userSettingsMock});
    when(applicationSettingsDataSource.source.dataStream)
        .thenReturn(StreamController.broadcast());

    applicationSettingsDataSource.initializeModuleData();

    expect(applicationSettingsDataSource.sourceStreamSubscription, isNotNull);
    expect(
        applicationSettingsDataSource.listenAppSettingsUpdate
            is StreamController,
        true);
  });
  test("Testing the 'clearModuleData()' function", () {
    applicationSettingsDataSource.clearModuleData();

    expect(applicationSettingsDataSource.sourceStreamSubscription, isNull);
    expect(
        applicationSettingsDataSource.listenAppSettingsUpdate
            is StreamController,
        true);
  });

  group("Testing 'updateAppSettings function", () {
    test("Testing 'updateAppSettings function NetworkException", () async {
      when(mockNetworkInfoContract.isConnected)
          .thenAnswer((value) => Future.value(false));
      when(applicationSettingsDataSource.source.getData)
          .thenReturn({"userSettings": userSettingsMock});

      expect(applicationSettingsDataSource.updateAppSettings(userSettingsMock),
          throwsA(isA<NetworkException>()));
    });

    test("Testing the 'updateAppSettings function api calls return 200 status",
        () async {
      when(mockNetworkInfoContract.isConnected)
          .thenAnswer((value) => Future.value(true));
      when(mockFunctions.createExecution(
              functionId: "appSettingsUpdate",
              body: jsonEncode(userSettingsMock)))
          .thenAnswer((value) => Future.value(Execution(
              $id: "id",
              $createdAt: "createdAt",
              $updatedAt: "updatedAt",
              $permissions: ["a", "b"],
              functionId: "functionId",
              trigger: "trigger",
              status: "status",
              statusCode: 200,
              response: "correct",
              stdout: "stdout",
              stderr: "stderr",
              duration: 2.0)));
      when(applicationSettingsDataSource.source.getData)
          .thenReturn({"userSettings": userSettingsMock});
      var result = await applicationSettingsDataSource
          .updateAppSettings(userSettingsMock);

      expect(result == true, true);
    });
    test(
        "Testing the 'updateAppSettings function api calls return other than the 200 status and send forward previous data via the 'reverseChanges()' method",
        () async {
      when(mockNetworkInfoContract.isConnected)
          .thenAnswer((value) => Future.value(true));
      when(mockFunctions.createExecution(
              functionId: "appSettingsUpdate",
              body: jsonEncode(userSettingsMock)))
          .thenAnswer((value) => Future.value(Execution(
              $id: "id",
              $createdAt: "createdAt",
              $updatedAt: "updatedAt",
              $permissions: ["a", "b"],
              functionId: "functionId",
              trigger: "trigger",
              status: "status",
              statusCode: 201,
              response: "correct",
              stdout: "stdout",
              stderr: "stderr",
              duration: 2.0)));
      when(applicationSettingsDataSource.source.getData)
          .thenReturn({"userSettings": userSettingsMock});
      expect(applicationSettingsDataSource.listenAppSettingsUpdate?.stream,
          emits(userSettingsMock));
      expect(applicationSettingsDataSource.updateAppSettings(userSettingsMock),
          throwsA(isA<AppSettingsException>()));
    });
  });

  group("Testing the 'deleteAccount' method", () {
    test("Testing 'deleteAccount function NetworkException", () async {
      when(mockNetworkInfoContract.isConnected)
          .thenAnswer((value) => Future.value(false));

      expect(applicationSettingsDataSource.deleteAccount(),
          throwsA(isA<NetworkException>()));
    });
  });

  test("Testing succesfull call to api status 200", () async {
    when(mockNetworkInfoContract.isConnected)
        .thenAnswer((value) => Future.value(true));

    when(mockFunctions.createExecution(
            functionId: "deleteUser",
            body: jsonEncode({"userId": GlobalDataContainer.userId})))
        .thenAnswer((_) => Future.value(Execution(
            $id: "id",
            $createdAt: "createdAt",
            $updatedAt: "updatedAt",
            $permissions: ["a", "b"],
            functionId: "functionId",
            trigger: "trigger",
            status: "status",
            statusCode: 200,
            response: "correct",
            stdout: "stdout",
            stderr: "stderr",
            duration: 2.0)));
    var result = await applicationSettingsDataSource.deleteAccount();

    expect(result == true, true);
  });

  test("Testing unsucessfull api calls without 200 statusCode", () async {
    when(mockNetworkInfoContract.isConnected)
        .thenAnswer((value) => Future.value(true));

    when(mockFunctions.createExecution(
            functionId: "deleteUser",
            body: jsonEncode({"userId": GlobalDataContainer.userId})))
        .thenAnswer((_) => Future.value(Execution(
            $id: "id",
            $createdAt: "createdAt",
            $updatedAt: "updatedAt",
            $permissions: ["a", "b"],
            functionId: "functionId",
            trigger: "trigger",
            status: "status",
            statusCode: 201,
            response: "correct",
            stdout: "stdout",
            stderr: "stderr",
            duration: 2.0)));
    expect(applicationSettingsDataSource.deleteAccount(),
        throwsA(isA<AppSettingsException>()));
  });

  group("Testing the 'deleteAccount' method", () {
    test("Testing the succesfull logout", () async {
      when(mockAuthService.logOut())
          .thenAnswer((_) => Future.value({"status": "Ok"}));
      var result = await applicationSettingsDataSource.logOut();
      expect(result == true, true);
    });
  });
}
