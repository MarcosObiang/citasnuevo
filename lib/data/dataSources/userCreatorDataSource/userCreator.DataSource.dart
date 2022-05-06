import 'dart:async';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/data/Mappers/UserCreatorMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';

abstract class UserCreatorDataSource implements DataSource {
  Future<bool> createUser({required Map<String, dynamic> userData});
  // ignore: close_sinks
  late StreamController<UserCreatorInformationSender> userCreatorDataStream;

  void _initialize();
}

class UserCreatorDataSourceImpl implements UserCreatorDataSource {
  @override
  ApplicationDataSource source;

  @override
  late StreamSubscription sourceStreamSubscription;
  late StreamSubscription userCreatorDataStreamSubscription;

  UserCreatorDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    sourceStreamSubscription.cancel();
    userCreatorDataStream.close();
  }

  @override
  Future<bool> createUser({required Map<String, dynamic> userData}) {
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  void initializeModuleData() async{
   await _initialize();
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }

  @override
  late StreamController<UserCreatorInformationSender> userCreatorDataStream= StreamController.broadcast();

  @override
  Future<void> _initialize() async {
    DateTime dateTime=await _createMinDatetime();
    kUserCreatorMockData["minBirthDate"]=dateTime;

    var result=UserCreatorMapper.fromMap(kUserCreatorMockData);
    userCreatorDataStream.add(result);
  }

  Future<DateTime> _createMinDatetime()async{
    DateTime actualTime=await DateNTP.instance.getTime();
    return actualTime.subtract(const Duration(days: 365*18));
  }
}
