import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/core/common/commonUtils/DateNTP.dart';
import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/core/firebase_services/firebase_auth.dart';
import 'package:citasnuevo/core/location_services/locatio_service.dart';
import 'package:citasnuevo/core/platform/networkInfo.dart';
import 'package:citasnuevo/data/Mappers/UserCreatorMapper.dart';
import 'package:citasnuevo/data/dataSources/principalDataSource/principalDataSource.dart';
import 'package:citasnuevo/domain/controller/controllerDef.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/globalData.dart';

abstract class UserCreatorDataSource
    implements DataSource, AuthenticationSignOutCapacity {
  Future<bool> createUser({required Map<String, dynamic> userData});
  // ignore: close_sinks
  late StreamController<UserCreatorInformationSender> userCreatorDataStream;

  void _initialize();
}

class UserCreatorDataSourceImpl implements UserCreatorDataSource {
  @override
  ApplicationDataSource source;

  @override
   StreamSubscription? sourceStreamSubscription;
   StreamSubscription? userCreatorDataStreamSubscription;

  UserCreatorDataSourceImpl({required this.source, required this.authService});

  @override
  void clearModuleData() {
    sourceStreamSubscription?.cancel();
    userCreatorDataStream.close();
  }

  @override
  Future<bool> createUser({required Map<String, dynamic> userData}) async {
    if (await NetworkInfoImpl.networkInstance.isConnected == true) {
      try {
        List<Map<String, dynamic>> userPictureList = userData["images"];
        List<Map<String, dynamic>> parsedImages = [];
        Map<String, dynamic> dataToCloud = Map();

        String userBio = userData["userBio"];
        Map<String, dynamic> userFilters = userData["userFilters"];
        String userName = userData["userName"];
        int userAgeMills = userData["userAgeMills"];
        int userAge = userData["userAge"];
        bool showWoman = userData["showWoman"];
        bool userPrefersBothSexes = userData["userPreferesBothSexes"];
        bool userIsWoman = userData["isUserWoman"];
        int maxDistance = userData["maxDistance"];
        int minAge = userData["minAge"];
        int maxAge = userData["maxAge"];
        bool useMeters = userData["useMeters"];
        bool useMilles = userData["useMilles"];
        Map<String, num> locationData =
            await LocationService.instance.determinePosition();
        for (int i = 0; i < userPictureList.length; i++) {
          UserPicutreBoxState userPicutreBoxState = userPictureList[i]["type"];
          String pictureIndex = userPictureList[i]["index"];
          String pictureName = "IMAGENPERFIL$pictureIndex";

          if (userPicutreBoxState == UserPicutreBoxState.pictureFromBytes) {
            final storageRef = FirebaseStorage.instance.ref();

            Uint8List imageFile = userPictureList[i]["data"];
            String pictureHash = userPictureList[i]["hash"];
            String image =
                "${GlobalDataContainer.userId}/Perfil/imagenes/Image$pictureIndex.jpg";
            Reference referenciaImagen = storageRef.child(image);
            // File file = new File.fromRawPath(imageFile);

            await referenciaImagen.putData(imageFile);

            String downloadUrl = await referenciaImagen.getDownloadURL();

            dataToCloud[pictureName] = {
              "Imagen": downloadUrl,
              "hash": pictureHash,
              "index": pictureIndex,
              "pictureName": pictureName,
              "removed": true,
            };
          }

          if (userPicutreBoxState == UserPicutreBoxState.empty) {
            final storageRef = FirebaseStorage.instance.ref();

            String image =
                "${GlobalDataContainer.userId}/Perfil/imagenes/Image$pictureIndex.jpg";
            Reference referenciaImagen = storageRef.child(image);
            //   await referenciaImagen.delete();

          }
        }

        dataToCloud["Edad"] = userAge;
        dataToCloud["nombre"] = userName;
        dataToCloud["Sexo"] = userIsWoman;
        dataToCloud["fechaNacimiento"] = userAgeMills;
        dataToCloud["Descripcion"] = userBio;
        dataToCloud["longitud"] = locationData["lon"];
        dataToCloud["latitud"] = locationData["lat"];
        dataToCloud["Filtros usuario"] = userFilters;
        dataToCloud["Ajustes"] = {
          "distanciaMaxima": maxDistance,
          "edadFinal": maxAge,
          "edadInicial": minAge,
          "enCm": useMeters,
          "enMillas": useMilles,
          "mostrarAmbosSexos": userPrefersBothSexes,
          "mostrarMujeres": showWoman,
          "mostrarPerfil": true
        };

        print("object");
        HttpsCallable fetchProfilesCloudFunction =
            FirebaseFunctions.instance.httpsCallable("crearUsuario");
        HttpsCallableResult httpsCallableResult =
            await fetchProfilesCloudFunction.call(dataToCloud);

        if (httpsCallableResult.data["estado"] == "correcto") {
          return true;
        }
      } catch (e) {
        UserCreatorException(message: e.toString());
      }
    } else {
      throw NetworkException(message:kNetworkErrorMessage );
    }
    // TODO: implement createUser
    throw UnimplementedError();
  }

  @override
  void initializeModuleData() async {
    await _initialize();
  }

  @override
  void subscribeToMainDataSource() {
    // TODO: implement subscribeToMainDataSource
  }

  @override
  late StreamController<UserCreatorInformationSender> userCreatorDataStream =
      StreamController.broadcast();

  @override
  Future<void> _initialize() async {
    DateTime dateTime = await _createMinDatetime();
    kUserCreatorMockData["minBirthDate"] = dateTime;

    var result = UserCreatorMapper.fromMap(kUserCreatorMockData);
    userCreatorDataStream.add(result);
  }

  Future<DateTime> _createMinDatetime() async {
    DateTime actualTime = await DateNTP.instance.getTime();
    return actualTime.subtract(const Duration(days: 365 * 18));
  }

  @override
  AuthService authService;

  @override
  Future<bool> logOut() async {
    try {
      Map<String, dynamic> userData = await authService.logOut();
      return true;
    } catch (e, s) {
      print(s);
      throw e;
    }
  }
}
