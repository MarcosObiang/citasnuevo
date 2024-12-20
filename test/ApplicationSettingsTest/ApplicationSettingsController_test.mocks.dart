// Mocks generated by Mockito 5.4.4 from annotations
// in citasnuevo/test/ApplicationSettingsTest/ApplicationSettingsController_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i8;

import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsDataSource.dart'
    as _i5;
import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsEntity.dart'
    as _i9;
import 'package:citasnuevo/App/ApplicationSettings/appSettingsController.dart'
    as _i12;
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepo.dart' as _i7;
import 'package:citasnuevo/App/ApplicationSettings/appSettingsRepoImpl.dart'
    as _i11;
import 'package:citasnuevo/App/MainDatasource/principalDataSource.dart' as _i2;
import 'package:citasnuevo/App/Settings/SettingsToAppSettingsControllerBridge.dart'
    as _i13;
import 'package:citasnuevo/core/error/Failure.dart' as _i10;
import 'package:citasnuevo/core/platform/networkInfo.dart' as _i4;
import 'package:citasnuevo/core/services/AuthService.dart' as _i3;
import 'package:dartz/dartz.dart' as _i6;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeApplicationDataSource_0 extends _i1.SmartFake
    implements _i2.ApplicationDataSource {
  _FakeApplicationDataSource_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAuthService_1 extends _i1.SmartFake implements _i3.AuthService {
  _FakeAuthService_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeNetworkInfoContract_2 extends _i1.SmartFake
    implements _i4.NetworkInfoContract {
  _FakeNetworkInfoContract_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeApplicationSettingsDataSource_3 extends _i1.SmartFake
    implements _i5.ApplicationSettingsDataSource {
  _FakeApplicationSettingsDataSource_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMapper_4<T> extends _i1.SmartFake implements _i4.Mapper<T> {
  _FakeMapper_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEither_5<L, R> extends _i1.SmartFake implements _i6.Either<L, R> {
  _FakeEither_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAppSettingsRepository_6 extends _i1.SmartFake
    implements _i7.AppSettingsRepository {
  _FakeAppSettingsRepository_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [ApplicationSettingsDataSource].
///
/// See the documentation for Mockito's code generation for more information.
class MockApplicationSettingsDataSource extends _i1.Mock
    implements _i5.ApplicationSettingsDataSource {
  @override
  set listenAppSettingsUpdate(
          _i8.StreamController<Map<String, dynamic>>?
              _listenAppSettingsUpdate) =>
      super.noSuchMethod(
        Invocation.setter(
          #listenAppSettingsUpdate,
          _listenAppSettingsUpdate,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i2.ApplicationDataSource get source => (super.noSuchMethod(
        Invocation.getter(#source),
        returnValue: _FakeApplicationDataSource_0(
          this,
          Invocation.getter(#source),
        ),
        returnValueForMissingStub: _FakeApplicationDataSource_0(
          this,
          Invocation.getter(#source),
        ),
      ) as _i2.ApplicationDataSource);

  @override
  set source(_i2.ApplicationDataSource? _source) => super.noSuchMethod(
        Invocation.setter(
          #source,
          _source,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set sourceStreamSubscription(
          _i8.StreamSubscription<dynamic>? _sourceStreamSubscription) =>
      super.noSuchMethod(
        Invocation.setter(
          #sourceStreamSubscription,
          _sourceStreamSubscription,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.AuthService get authService => (super.noSuchMethod(
        Invocation.getter(#authService),
        returnValue: _FakeAuthService_1(
          this,
          Invocation.getter(#authService),
        ),
        returnValueForMissingStub: _FakeAuthService_1(
          this,
          Invocation.getter(#authService),
        ),
      ) as _i3.AuthService);

  @override
  set authService(_i3.AuthService? _authService) => super.noSuchMethod(
        Invocation.setter(
          #authService,
          _authService,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.NetworkInfoContract get networkInfoContract => (super.noSuchMethod(
        Invocation.getter(#networkInfoContract),
        returnValue: _FakeNetworkInfoContract_2(
          this,
          Invocation.getter(#networkInfoContract),
        ),
        returnValueForMissingStub: _FakeNetworkInfoContract_2(
          this,
          Invocation.getter(#networkInfoContract),
        ),
      ) as _i4.NetworkInfoContract);

  @override
  set networkInfoContract(_i4.NetworkInfoContract? _networkInfoContract) =>
      super.noSuchMethod(
        Invocation.setter(
          #networkInfoContract,
          _networkInfoContract,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> updateAppSettings(Map<String, dynamic>? data) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateAppSettings,
          [data],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  void revertChanges() => super.noSuchMethod(
        Invocation.method(
          #revertChanges,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> deleteAccount() => (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  void subscribeToMainDataSource() => super.noSuchMethod(
        Invocation.method(
          #subscribeToMainDataSource,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  void clearModuleData() => super.noSuchMethod(
        Invocation.method(
          #clearModuleData,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void initializeModuleData() => super.noSuchMethod(
        Invocation.method(
          #initializeModuleData,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [ApplicationDataSourceImpl].
///
/// See the documentation for Mockito's code generation for more information.
class MockApplicationDataSourceImpl extends _i1.Mock
    implements _i5.ApplicationDataSourceImpl {
  @override
  _i2.ApplicationDataSource get source => (super.noSuchMethod(
        Invocation.getter(#source),
        returnValue: _FakeApplicationDataSource_0(
          this,
          Invocation.getter(#source),
        ),
        returnValueForMissingStub: _FakeApplicationDataSource_0(
          this,
          Invocation.getter(#source),
        ),
      ) as _i2.ApplicationDataSource);

  @override
  set source(_i2.ApplicationDataSource? _source) => super.noSuchMethod(
        Invocation.setter(
          #source,
          _source,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i3.AuthService get authService => (super.noSuchMethod(
        Invocation.getter(#authService),
        returnValue: _FakeAuthService_1(
          this,
          Invocation.getter(#authService),
        ),
        returnValueForMissingStub: _FakeAuthService_1(
          this,
          Invocation.getter(#authService),
        ),
      ) as _i3.AuthService);

  @override
  set authService(_i3.AuthService? _authService) => super.noSuchMethod(
        Invocation.setter(
          #authService,
          _authService,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set listenAppSettingsUpdate(
          _i8.StreamController<Map<String, dynamic>>?
              _listenAppSettingsUpdate) =>
      super.noSuchMethod(
        Invocation.setter(
          #listenAppSettingsUpdate,
          _listenAppSettingsUpdate,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set sourceStreamSubscription(
          _i8.StreamSubscription<dynamic>? _sourceStreamSubscription) =>
      super.noSuchMethod(
        Invocation.setter(
          #sourceStreamSubscription,
          _sourceStreamSubscription,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.NetworkInfoContract get networkInfoContract => (super.noSuchMethod(
        Invocation.getter(#networkInfoContract),
        returnValue: _FakeNetworkInfoContract_2(
          this,
          Invocation.getter(#networkInfoContract),
        ),
        returnValueForMissingStub: _FakeNetworkInfoContract_2(
          this,
          Invocation.getter(#networkInfoContract),
        ),
      ) as _i4.NetworkInfoContract);

  @override
  set networkInfoContract(_i4.NetworkInfoContract? _networkInfoContract) =>
      super.noSuchMethod(
        Invocation.setter(
          #networkInfoContract,
          _networkInfoContract,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void clearModuleData() => super.noSuchMethod(
        Invocation.method(
          #clearModuleData,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void initializeModuleData() => super.noSuchMethod(
        Invocation.method(
          #initializeModuleData,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void subscribeToMainDataSource() => super.noSuchMethod(
        Invocation.method(
          #subscribeToMainDataSource,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> updateAppSettings(Map<String, dynamic>? data) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateAppSettings,
          [data],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  void revertChanges() => super.noSuchMethod(
        Invocation.method(
          #revertChanges,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<bool> deleteAccount() => (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);

  @override
  _i8.Future<bool> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i8.Future<bool>.value(false),
        returnValueForMissingStub: _i8.Future<bool>.value(false),
      ) as _i8.Future<bool>);
}

/// A class which mocks [AppSettingsRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSettingsRepository extends _i1.Mock
    implements _i7.AppSettingsRepository {
  @override
  _i5.ApplicationSettingsDataSource get appSettingsDataSource =>
      (super.noSuchMethod(
        Invocation.getter(#appSettingsDataSource),
        returnValue: _FakeApplicationSettingsDataSource_3(
          this,
          Invocation.getter(#appSettingsDataSource),
        ),
        returnValueForMissingStub: _FakeApplicationSettingsDataSource_3(
          this,
          Invocation.getter(#appSettingsDataSource),
        ),
      ) as _i5.ApplicationSettingsDataSource);

  @override
  set appSettingsDataSource(
          _i5.ApplicationSettingsDataSource? _appSettingsDataSource) =>
      super.noSuchMethod(
        Invocation.setter(
          #appSettingsDataSource,
          _appSettingsDataSource,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set streamParserController(
          _i8.StreamController<dynamic>? _streamParserController) =>
      super.noSuchMethod(
        Invocation.setter(
          #streamParserController,
          _streamParserController,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set streamParserSubscription(
          _i8.StreamSubscription<dynamic>? _streamParserSubscription) =>
      super.noSuchMethod(
        Invocation.setter(
          #streamParserSubscription,
          _streamParserSubscription,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Mapper<_i9.ApplicationSettingsEntity> get mapper => (super.noSuchMethod(
        Invocation.getter(#mapper),
        returnValue: _FakeMapper_4<_i9.ApplicationSettingsEntity>(
          this,
          Invocation.getter(#mapper),
        ),
        returnValueForMissingStub: _FakeMapper_4<_i9.ApplicationSettingsEntity>(
          this,
          Invocation.getter(#mapper),
        ),
      ) as _i4.Mapper<_i9.ApplicationSettingsEntity>);

  @override
  set mapper(_i4.Mapper<_i9.ApplicationSettingsEntity>? _mapper) =>
      super.noSuchMethod(
        Invocation.setter(
          #mapper,
          _mapper,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> updateSettings(
          _i9.ApplicationSettingsEntity? applicationSettingsEntity) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateSettings,
          [applicationSettingsEntity],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateSettings,
            [applicationSettingsEntity],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateSettings,
            [applicationSettingsEntity],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> deleteAccount() =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i6.Either<_i10.Failure, bool> clearModuleData() => (super.noSuchMethod(
        Invocation.method(
          #clearModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  _i6.Either<_i10.Failure, bool> initializeModuleData() => (super.noSuchMethod(
        Invocation.method(
          #initializeModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  void parseStreams() => super.noSuchMethod(
        Invocation.method(
          #parseStreams,
          [],
        ),
        returnValueForMissingStub: null,
      );
}

/// A class which mocks [ApplicationSettingsRepositoryImpl].
///
/// See the documentation for Mockito's code generation for more information.
class MockApplicationSettingsRepositoryImpl extends _i1.Mock
    implements _i11.ApplicationSettingsRepositoryImpl {
  @override
  _i5.ApplicationSettingsDataSource get appSettingsDataSource =>
      (super.noSuchMethod(
        Invocation.getter(#appSettingsDataSource),
        returnValue: _FakeApplicationSettingsDataSource_3(
          this,
          Invocation.getter(#appSettingsDataSource),
        ),
        returnValueForMissingStub: _FakeApplicationSettingsDataSource_3(
          this,
          Invocation.getter(#appSettingsDataSource),
        ),
      ) as _i5.ApplicationSettingsDataSource);

  @override
  set appSettingsDataSource(
          _i5.ApplicationSettingsDataSource? _appSettingsDataSource) =>
      super.noSuchMethod(
        Invocation.setter(
          #appSettingsDataSource,
          _appSettingsDataSource,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i4.Mapper<_i9.ApplicationSettingsEntity> get mapper => (super.noSuchMethod(
        Invocation.getter(#mapper),
        returnValue: _FakeMapper_4<_i9.ApplicationSettingsEntity>(
          this,
          Invocation.getter(#mapper),
        ),
        returnValueForMissingStub: _FakeMapper_4<_i9.ApplicationSettingsEntity>(
          this,
          Invocation.getter(#mapper),
        ),
      ) as _i4.Mapper<_i9.ApplicationSettingsEntity>);

  @override
  set mapper(_i4.Mapper<_i9.ApplicationSettingsEntity>? _mapper) =>
      super.noSuchMethod(
        Invocation.setter(
          #mapper,
          _mapper,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set streamParserController(
          _i8.StreamController<dynamic>? _streamParserController) =>
      super.noSuchMethod(
        Invocation.setter(
          #streamParserController,
          _streamParserController,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set streamParserSubscription(
          _i8.StreamSubscription<dynamic>? _streamParserSubscription) =>
      super.noSuchMethod(
        Invocation.setter(
          #streamParserSubscription,
          _streamParserSubscription,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void parseStreams() => super.noSuchMethod(
        Invocation.method(
          #parseStreams,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i6.Either<_i10.Failure, bool> clearModuleData() => (super.noSuchMethod(
        Invocation.method(
          #clearModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  _i6.Either<_i10.Failure, bool> initializeModuleData() => (super.noSuchMethod(
        Invocation.method(
          #initializeModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> updateSettings(
          _i9.ApplicationSettingsEntity? applicationSettingsEntity) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateSettings,
          [applicationSettingsEntity],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateSettings,
            [applicationSettingsEntity],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateSettings,
            [applicationSettingsEntity],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> deleteAccount() =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);
}

/// A class which mocks [AppSettingsController].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSettingsController extends _i1.Mock
    implements _i12.AppSettingsController {
  @override
  _i7.AppSettingsRepository get appSettingsRepository => (super.noSuchMethod(
        Invocation.getter(#appSettingsRepository),
        returnValue: _FakeAppSettingsRepository_6(
          this,
          Invocation.getter(#appSettingsRepository),
        ),
        returnValueForMissingStub: _FakeAppSettingsRepository_6(
          this,
          Invocation.getter(#appSettingsRepository),
        ),
      ) as _i7.AppSettingsRepository);

  @override
  set appSettingsRepository(
          _i7.AppSettingsRepository? _appSettingsRepository) =>
      super.noSuchMethod(
        Invocation.setter(
          #appSettingsRepository,
          _appSettingsRepository,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set applicationSettingsEntity(
          _i9.ApplicationSettingsEntity? _applicationSettingsEntity) =>
      super.noSuchMethod(
        Invocation.setter(
          #applicationSettingsEntity,
          _applicationSettingsEntity,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set settingsToAppSettingsControllerBridge(
          _i13.AppSettingsToSettingsControllerBridge<dynamic>?
              _settingsToAppSettingsControllerBridge) =>
      super.noSuchMethod(
        Invocation.setter(
          #settingsToAppSettingsControllerBridge,
          _settingsToAppSettingsControllerBridge,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set streamParserSubscription(
          _i8.StreamSubscription<dynamic>? _streamParserSubscription) =>
      super.noSuchMethod(
        Invocation.setter(
          #streamParserSubscription,
          _streamParserSubscription,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set updateDataController(
          _i8.StreamController<dynamic>? _updateDataController) =>
      super.noSuchMethod(
        Invocation.setter(
          #updateDataController,
          _updateDataController,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void initializeListener() => super.noSuchMethod(
        Invocation.method(
          #initializeListener,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> updateAppSettings(
          _i9.ApplicationSettingsEntity? applicationSettingsEntity) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateAppSettings,
          [applicationSettingsEntity],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateAppSettings,
            [applicationSettingsEntity],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateAppSettings,
            [applicationSettingsEntity],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> deleteAccount() =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i6.Either<_i10.Failure, bool> clearModuleData() => (super.noSuchMethod(
        Invocation.method(
          #clearModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  _i6.Either<_i10.Failure, bool> initializeModuleData() => (super.noSuchMethod(
        Invocation.method(
          #initializeModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);
}

/// A class which mocks [AppSettingsControllerImpl].
///
/// See the documentation for Mockito's code generation for more information.
class MockAppSettingsControllerImpl extends _i1.Mock
    implements _i12.AppSettingsControllerImpl {
  @override
  _i7.AppSettingsRepository get appSettingsRepository => (super.noSuchMethod(
        Invocation.getter(#appSettingsRepository),
        returnValue: _FakeAppSettingsRepository_6(
          this,
          Invocation.getter(#appSettingsRepository),
        ),
        returnValueForMissingStub: _FakeAppSettingsRepository_6(
          this,
          Invocation.getter(#appSettingsRepository),
        ),
      ) as _i7.AppSettingsRepository);

  @override
  set appSettingsRepository(
          _i7.AppSettingsRepository? _appSettingsRepository) =>
      super.noSuchMethod(
        Invocation.setter(
          #appSettingsRepository,
          _appSettingsRepository,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set applicationSettingsEntity(
          _i9.ApplicationSettingsEntity? _applicationSettingsEntity) =>
      super.noSuchMethod(
        Invocation.setter(
          #applicationSettingsEntity,
          _applicationSettingsEntity,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set settingsToAppSettingsControllerBridge(
          _i13.AppSettingsToSettingsControllerBridge<dynamic>?
              _settingsToAppSettingsControllerBridge) =>
      super.noSuchMethod(
        Invocation.setter(
          #settingsToAppSettingsControllerBridge,
          _settingsToAppSettingsControllerBridge,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set streamParserSubscription(
          _i8.StreamSubscription<dynamic>? _streamParserSubscription) =>
      super.noSuchMethod(
        Invocation.setter(
          #streamParserSubscription,
          _streamParserSubscription,
        ),
        returnValueForMissingStub: null,
      );

  @override
  set updateDataController(
          _i8.StreamController<dynamic>? _updateDataController) =>
      super.noSuchMethod(
        Invocation.setter(
          #updateDataController,
          _updateDataController,
        ),
        returnValueForMissingStub: null,
      );

  @override
  void initializeListener() => super.noSuchMethod(
        Invocation.method(
          #initializeListener,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> updateAppSettings(
          _i9.ApplicationSettingsEntity? applicationSettingsEntity) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateAppSettings,
          [applicationSettingsEntity],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateAppSettings,
            [applicationSettingsEntity],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #updateAppSettings,
            [applicationSettingsEntity],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> deleteAccount() =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #deleteAccount,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i8.Future<_i6.Either<_i10.Failure, bool>> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
            _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
        returnValueForMissingStub:
            _i8.Future<_i6.Either<_i10.Failure, bool>>.value(
                _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #logOut,
            [],
          ),
        )),
      ) as _i8.Future<_i6.Either<_i10.Failure, bool>>);

  @override
  _i6.Either<_i10.Failure, bool> clearModuleData() => (super.noSuchMethod(
        Invocation.method(
          #clearModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #clearModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  _i6.Either<_i10.Failure, bool> initializeModuleData() => (super.noSuchMethod(
        Invocation.method(
          #initializeModuleData,
          [],
        ),
        returnValue: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
        returnValueForMissingStub: _FakeEither_5<_i10.Failure, bool>(
          this,
          Invocation.method(
            #initializeModuleData,
            [],
          ),
        ),
      ) as _i6.Either<_i10.Failure, bool>);

  @override
  void sendInfo({required bool? updatingSettings}) => super.noSuchMethod(
        Invocation.method(
          #sendInfo,
          [],
          {#updatingSettings: updatingSettings},
        ),
        returnValueForMissingStub: null,
      );
}
