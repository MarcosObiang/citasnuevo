// Mocks generated by Mockito 5.4.4 from annotations
// in citasnuevo/test/ApplicationSettingsTest/ApplicationSettingsRepo_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsDataSource.dart'
    as _i6;
import 'package:citasnuevo/App/ApplicationSettings/ApplicationSettingsEntity.dart'
    as _i5;
import 'package:citasnuevo/App/MainDatasource/principalDataSource.dart' as _i2;
import 'package:citasnuevo/core/platform/networkInfo.dart' as _i4;
import 'package:citasnuevo/core/services/AuthService.dart' as _i3;
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

class _FakeApplicationSettingsEntity_3 extends _i1.SmartFake
    implements _i5.ApplicationSettingsEntity {
  _FakeApplicationSettingsEntity_3(
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
    implements _i6.ApplicationSettingsDataSource {
  MockApplicationSettingsDataSource() {
    _i1.throwOnMissingStub(this);
  }

  @override
  set listenAppSettingsUpdate(
          _i7.StreamController<Map<String, dynamic>>?
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
          _i7.StreamSubscription<dynamic>? _sourceStreamSubscription) =>
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
  _i7.Future<bool> updateAppSettings(Map<String, dynamic>? data) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateAppSettings,
          [data],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  void revertChanges() => super.noSuchMethod(
        Invocation.method(
          #revertChanges,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i7.Future<bool> deleteAccount() => (super.noSuchMethod(
        Invocation.method(
          #deleteAccount,
          [],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

  @override
  void subscribeToMainDataSource() => super.noSuchMethod(
        Invocation.method(
          #subscribeToMainDataSource,
          [],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i7.Future<bool> logOut() => (super.noSuchMethod(
        Invocation.method(
          #logOut,
          [],
        ),
        returnValue: _i7.Future<bool>.value(false),
      ) as _i7.Future<bool>);

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

/// A class which mocks [Mapper].
///
/// See the documentation for Mockito's code generation for more information.
class MockMapper extends _i1.Mock
    implements _i4.Mapper<_i5.ApplicationSettingsEntity> {
  MockMapper() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.ApplicationSettingsEntity fromMap(Map<String, dynamic>? data) =>
      (super.noSuchMethod(
        Invocation.method(
          #fromMap,
          [data],
        ),
        returnValue: _FakeApplicationSettingsEntity_3(
          this,
          Invocation.method(
            #fromMap,
            [data],
          ),
        ),
      ) as _i5.ApplicationSettingsEntity);

  @override
  Map<String, dynamic> toMap(_i5.ApplicationSettingsEntity? data) =>
      (super.noSuchMethod(
        Invocation.method(
          #toMap,
          [data],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
}