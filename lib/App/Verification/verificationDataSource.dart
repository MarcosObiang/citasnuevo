import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../core/dependencies/dependencyCreator.dart';
import '../DataManager.dart';
import '../MainDatasource/principalDataSource.dart';
import '../../core/error/Exceptions.dart';
import '../../core/globalData.dart';
import '../../core/params_types/params_and_types.dart';
import '../../core/platform/networkInfo.dart';

abstract class VerificationDataSource
    implements DataSource, ModuleCleanerDataSource {
  Future<bool> submitVerificationData({required Uint8List pictureBytes});
  Future<bool> requestVerificationProcess();
  // ignore: close_sinks
  StreamController<Map<String, dynamic>?>? dataStream;
}

class VerificationDataSourceImpl implements VerificationDataSource {
  @override
  ApplicationDataSource source;
  @override
  StreamController<Map<String, dynamic>?>? dataStream =
      StreamController<Map<String, dynamic>?>();
  @override
  StreamSubscription? sourceStreamSubscription;
  String? userId;
  VerificationDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    try {
      sourceStreamSubscription?.cancel();
      dataStream?.close();
      dataStream = null;
      dataStream = StreamController<Map<String, dynamic>>();
      sourceStreamSubscription = null;
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
  Future<bool> submitVerificationData({required Uint8List pictureBytes}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        Storage appwriteStorage = Storage(Dependencies.serverAPi.client!);
        Functions functions = Functions(Dependencies.serverAPi.client!);
        File result = await appwriteStorage.createFile(
            bucketId: "63712fd65399f32a5414",
            fileId: "${GlobalDataContainer.userId}_verification",
            file: InputFile.fromBytes(
                bytes: pictureBytes,
                filename:
                    "${GlobalDataContainer.userId}_verification.jpg"));

        String downloadUrl = result.$id;
        Execution execution = await functions.createExecution(
            functionId: "initVerificationProcess",
            data: jsonEncode({"imageLink": downloadUrl}));
        int status = jsonDecode(execution.response)["status"];
        String message = jsonDecode(execution.response)["message"];
        if (status == 200) {
          return true;
        } else {
          throw VerificationException(message: message);
        }
      } catch (e) {
        throw VerificationException(message: e.toString());
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  void _addData({required dynamic data}) {
    if (dataStream != null) {
      dataStream?.add(data);
    } else {
      throw VerificationException(message: kStreamParserNullError);
    }
  }

  @override
  void subscribeToMainDataSource() {
    _addData(data: source.getData);
    sourceStreamSubscription = source.dataStream?.stream.listen((event) {
      _addData(data: event);
    });
  }

  @override
  Future<bool> requestVerificationProcess() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      Functions functions = Functions(Dependencies.serverAPi.client!);

      Execution execution = await functions.createExecution(
          functionId: "createNewVerificationInstance");
      int status = jsonDecode(execution.response)["status"];
      String message = jsonDecode(execution.response)["message"];

      if (status == 200) {
        return true;
      } else {
        throw VerificationException(message: message);
      }
    } else {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
