import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:citasnuevo/core/common/commonUtils/getUserImage.dart';
import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';

import '../../../core/globalData.dart';
import '../../../domain/controller/controllerDef.dart';

abstract class UserSettingsDataSource implements DataSource {
  // ignore: close_sinks
  late StreamController<UserSettingsInformationSender> listenAppSettingsUpdate;

  Future<bool> updateAppSettings(Map<String, dynamic> data);
  Future<bool> revertChanges();

}

class UserSettingsDataSourceImpl implements UserSettingsDataSource {
  @override
  late StreamController<UserSettingsInformationSender> listenAppSettingsUpdate =
      StreamController.broadcast();

  @override
  ApplicationDataSource source;

  @override
  late StreamSubscription sourceStreamSubscription;
  UserSettingsDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    sourceStreamSubscription.cancel();
    listenAppSettingsUpdate.close();
    listenAppSettingsUpdate = new StreamController.broadcast();
  }

  @override
  void initializeModuleData() {
    subscribeToMainDataSource();
  }

  @override
  void subscribeToMainDataSource() async {
    Map<String, dynamic> userFilters = source.getData["filtros usuario"];
    bool firstInitialized = true;

    listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(source.getData));

    source.dataStream.stream.listen((event) async {
      try {
        bool shouldUpdate = false;

        Map<String, dynamic> userFiltersUpdated = event["filtros usuario"];

        userFilters.forEach((key, value) {
          if (userFiltersUpdated[key] != value) {
            shouldUpdate = true;
          }
        });

        if (shouldUpdate == true) {
          listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(event));
          userFilters = userFiltersUpdated;
        }
        if (firstInitialized == true) {
          listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(event));
          userFilters = userFiltersUpdated;
          firstInitialized = false;
        }
      } catch (e) {
        listenAppSettingsUpdate.addError(e);
      }
    });
  }

  @override
  Future<bool> updateAppSettings(Map<String, dynamic> data) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        List<Map<String, dynamic>> pictureData = data["images"];
        Map<String, dynamic> userCharacteristicsData = data["userFilters"];
        String userBio = data["userBio"];

        List<Map<String, dynamic>> parsedImages = [];

        Map<String, dynamic> dataToCloud = Map();

        for (int i = 0; i < pictureData.length; i++) {
          UserPicutreBoxState userPicutreBoxState = pictureData[i]["type"];
          String pictureIndex = pictureData[i]["index"];
          String pictureName = "IMAGENPERFIL$pictureIndex";

          if (userPicutreBoxState == UserPicutreBoxState.pictureFromBytes) {
            final storageRef = FirebaseStorage.instance.ref();

            Uint8List imageFile = pictureData[i]["data"];
            String pictureHash = pictureData[i]["hash"];
            String image =
                "${GlobalDataContainer.userId}/Perfil/imagenes/Image$pictureIndex.jpg";
            Reference referenciaImagen = storageRef.child(image);
            // File file = new File.fromRawPath(imageFile);

            await referenciaImagen.putData(imageFile);

            String downloadUrl = await referenciaImagen.getDownloadURL();

            parsedImages.add({
              "Imagen": downloadUrl,
              "hash": pictureHash,
              "index": pictureIndex,
              "pictureName": pictureName,
              "removed": false,
            });
          }

          if (userPicutreBoxState == UserPicutreBoxState.pictureFromNetwork) {
       final storageRef = FirebaseStorage.instance.ref();

            Uint8List imageFile = pictureData[i]["data"];
            String pictureHash = pictureData[i]["hash"];
            String image =
                "${GlobalDataContainer.userId}/Perfil/imagenes/Image$pictureIndex.jpg";
            Reference referenciaImagen = storageRef.child(image);
            // File file = new File.fromRawPath(imageFile);

            await referenciaImagen.putData(imageFile);

            String downloadUrl = await referenciaImagen.getDownloadURL();

            parsedImages.add({
              "Imagen": downloadUrl,
              "hash": pictureHash,
              "index": pictureIndex,
              "pictureName": pictureName,
              "removed": false,
            });
          }
          if (userPicutreBoxState == UserPicutreBoxState.empty) {
            final storageRef = FirebaseStorage.instance.ref();

            String image =
                "${GlobalDataContainer.userId}/Perfil/imagenes/Image$pictureIndex.jpg";
            Reference referenciaImagen = storageRef.child(image);
         //   await referenciaImagen.delete();

            parsedImages.add({
              "Imagen": "downloadUrl",
              "hash": "pictureHash",
              "index": pictureIndex,
              "pictureName": pictureName,
              "removed": true,
            });
          }
        }
        dataToCloud["imagenes"] = parsedImages;
        dataToCloud["descripcion"] = userBio;
        dataToCloud["filtros usuario"] = userCharacteristicsData;
        HttpsCallable fetchProfilesCloudFunction =
            FirebaseFunctions.instance.httpsCallable("editUser");

        HttpsCallableResult httpsCallableResult =
            await fetchProfilesCloudFunction.call(dataToCloud);

        if (httpsCallableResult.data["estado"] == "correcto") {
          return true;
        } else {
          listenAppSettingsUpdate
              .add(await UserSettingsMapper.fromMap(source.getData));

          throw UserSettingsException(message: "function_error");
        }
      } catch (e) {
        listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(source.getData));
        throw UserSettingsException(message: e.toString());
      }
    } else {
      listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(source.getData));
      throw NetworkException();
    }
  }

  @override
 Future <bool> revertChanges() async{
    listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(source.getData));
    return true;
  }
}
