import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../domain/repository/DataManager.dart';
import '../principalDataSource/principalDataSource.dart';

abstract class VerificationDataSource
    implements DataSource, ModuleCleanerDataSource {
  Future<void> submitVerificationData({required Uint8List pictureBytes});
  Future<void> requestVerificationProcess();
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
      _checkVerificationStatus();
    } catch (e) {
      throw ModuleInitializeException(message: e.toString());
    }
  }

  @override
  Future<void> submitVerificationData({required Uint8List pictureBytes}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        HttpsCallable setVerificationPicture =
            FirebaseFunctions.instance.httpsCallable("setVerificationPicture");
        final storageRef = FirebaseStorage.instance.ref();

        String image =
            "${GlobalDataContainer.userId}/Perfil/verificationImages/Image.jpg";
        Reference referenciaImagen = storageRef.child(image);
        await referenciaImagen.putData(pictureBytes);

        String downloadUrl = await referenciaImagen.getDownloadURL();
        HttpsCallableResult httpsCallableResult = await setVerificationPicture
            .call({"userId": GlobalDataContainer.userId, "url": downloadUrl});

        if (httpsCallableResult.data["estado"] == "error") {
          throw VerificationException(message: "SERVER_ERROR");
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
      UserSettingsException(message: kStreamParserNullError);
    }
  }

  void _checkVerificationStatus() {
    if(userId!=null){
 FirebaseFirestore.instance
        .collection("verificationDataCollection")
        .doc(userId)
        .snapshots()
        .listen((event) {
      if (event != null) {
        _addData( data: event.data());
      }
    });
    }
    else{
      throw UserSettingsException(message: kUserIdNullError);
    }
   
  }

  @override
  void subscribeToMainDataSource() {
  userId=source.userId;
  }

  @override
  Future<void> requestVerificationProcess() async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      HttpsCallable askVerificationProcess = FirebaseFunctions.instance
          .httpsCallable("requestNewVerificationProcess");

      HttpsCallableResult httpsCallableResult =
          await askVerificationProcess.call();

      if (httpsCallableResult.data["esstado"] != "correcto") {
        throw VerificationException(message: "ERROR");
      }
    }
    if (await NetworkInfoImpl.networkInstance.isConnected == false) {
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }
}
