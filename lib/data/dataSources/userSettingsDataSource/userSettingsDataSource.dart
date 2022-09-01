import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:citasnuevo/core/common/commonUtils/idGenerator.dart';
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
import '../../../domain/repository/DataManager.dart';

abstract class UserSettingsDataSource
    implements DataSource, ModuleCleanerDataSource {
  // ignore: close_sinks
  late StreamController<UserSettingsInformationSender> listenAppSettingsUpdate;

  Future<bool> updateAppSettings(UserSettingsEntity userSettingsEntity);
  Future<bool> revertChanges();
}

class UserSettingsDataSourceImpl implements UserSettingsDataSource {
  @override
  StreamController<UserSettingsInformationSender> listenAppSettingsUpdate =
      StreamController.broadcast();

  @override
  ApplicationDataSource source;

  @override
  StreamSubscription? sourceStreamSubscription;
  UserSettingsDataSourceImpl({
    required this.source,
  });

  @override
  void clearModuleData() {
    try {
      sourceStreamSubscription?.cancel();
      listenAppSettingsUpdate.close();
      listenAppSettingsUpdate = new StreamController.broadcast();
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
  void subscribeToMainDataSource() async {
    bool firstInitialized = true;
    Map<String, dynamic> oldData = source.getData;

    listenAppSettingsUpdate
        .add(await UserSettingsMapper.fromMap(source.getData));

    sourceStreamSubscription = source.dataStream.stream.listen((event) async {
      try {
        bool shouldUpdate = shouldUpdateUserSettings(event, oldData);

        if (shouldUpdate == true) {
          listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(event));
          oldData = event;
        }
        if (firstInitialized == true) {
          listenAppSettingsUpdate.add(await UserSettingsMapper.fromMap(event));
          firstInitialized = false;
        }
      } catch (e) {
        listenAppSettingsUpdate.addError(e);
      }
    });
  }

  bool shouldUpdateUserSettings(
      Map<String, dynamic> newData, Map<String, dynamic> oldData) {
    bool shouldUpdate = false;
    Map<String, dynamic> userFiltersUpdated = newData["filtros usuario"];
    Map<String, dynamic> oldUserFilters = oldData["filtros usuario"];

    String? newImage1 = newData["IMAGENPERFIL1"]!["Imagen"];
    String? newImage2 = newData["IMAGENPERFIL2"]!["Imagen"];
    String? newImage3 = newData["IMAGENPERFIL3"]!["Imagen"];
    String? newImage4 = newData["IMAGENPERFIL4"]!["Imagen"];
    String? newImage5 = newData["IMAGENPERFIL5"]!["Imagen"];
    String? newImage6 = newData["IMAGENPERFIL6"]!["Imagen"];
    String? oldImage1 = oldData["IMAGENPERFIL1"]!["Imagen"];
    String? oldImage2 = oldData["IMAGENPERFIL2"]!["Imagen"];
    String? oldImage3 = oldData["IMAGENPERFIL3"]!["Imagen"];
    String? oldImage4 = oldData["IMAGENPERFIL4"]!["Imagen"];
    String? oldImage5 = oldData["IMAGENPERFIL5"]!["Imagen"];
    String? oldImage6 = oldData["IMAGENPERFIL6"]!["Imagen"];
    List<String?> newImageDataList = [
      newImage1,
      newImage2,
      newImage3,
      newImage4,
      newImage5,
      newImage6
    ];
    List<String?> oldImageDataList = [
      oldImage1,
      oldImage2,
      oldImage3,
      oldImage4,
      oldImage5,
      oldImage6
    ];

    for (int i = 0; i < newImageDataList.length; i++) {
      if (newImageDataList[i] != null && oldImageDataList[i] != null) {
        if (newImageDataList[i] == oldImageDataList[i]) {
        } else {
          shouldUpdate = true;
        }
      }
    }
    oldUserFilters.forEach((key, value) {
      if (userFiltersUpdated[key] != value) {
        shouldUpdate = true;
      }
    });
    return shouldUpdate;
  }

  @override
  Future<bool> updateAppSettings(UserSettingsEntity userSettingsEntity) async {
    if (await NetworkInfoImpl.networkInstance.isConnected) {
      try {
        var data = await UserSettingsMapper.toMap(userSettingsEntity);

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
                "${GlobalDataContainer.userId}/Perfil/imagenes/${IdGenerator.instancia.createId()}_Image$pictureIndex.jpg";
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
                "${GlobalDataContainer.userId}/Perfil/imagenes/${IdGenerator.instancia.createId()}_Image$pictureIndex.jpg";
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
            parsedImages.add({
              "Imagen": "vacio",
              "hash": "vacio",
              "index": pictureIndex,
              "pictureName": pictureName,
              "removed": true,
            });
          }
        }

        print(parsedImages);
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
        listenAppSettingsUpdate
            .add(await UserSettingsMapper.fromMap(source.getData));
        throw UserSettingsException(message: e.toString());
      }
    } else {
      listenAppSettingsUpdate
          .add(await UserSettingsMapper.fromMap(source.getData));
      throw NetworkException(message: kNetworkErrorMessage);
    }
  }

  @override
  Future<bool> revertChanges() async {
    listenAppSettingsUpdate
        .add(await UserSettingsMapper.fromMap(source.getData));
    return true;
  }
}
