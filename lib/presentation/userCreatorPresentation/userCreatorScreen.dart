import 'dart:io';
import 'dart:typed_data';

import 'package:another_xlider/another_xlider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/presentation/Routes.dart';
import 'package:citasnuevo/presentation/userCreatorPresentation/userCreatorPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../../core/common/profileCharacteristics.dart';
import '../../core/dependencies/dependencyCreator.dart';
import '../../domain/entities/UserSettingsEntity.dart';
import '../../reordableList.dart';
import '../userSettingsPresentation/userSettingsScreen.dart';

class UserCreatorScreenArgs{
  String? userName;
  UserCreatorScreenArgs({required this.userName});

}


class UserCreatorScreen extends StatefulWidget {
    static const routeName = '/UserCreatorScreen';

  String? userName;

  UserCreatorScreen();

  @override
  State<UserCreatorScreen> createState() => _UserCreatorScreenState();
}

class _UserCreatorScreenState extends State<UserCreatorScreen> {

  Future<bool> showGoToMainScreenDialog(BuildContext context) async {

    bool goToMainScreen = false;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Ir a la pantalla principal"),
            actions: [
              TextButton(
                  onPressed: () {
                    goToMainScreen = true;
                    Navigator.pop(context);
                  },
                  child: Text("Si")),
              TextButton(
                  onPressed: () {
                    goToMainScreen = false;
                    Navigator.pop(context);
                  },
                  child: Text("No"))
            ],
          );
        });
    return goToMainScreen;
  }

  @override
  Widget build(BuildContext context) {
    final args=ModalRoute.of(context)!.settings.arguments as UserCreatorScreenArgs;
    widget.userName= args.userName;
    return WillPopScope(
      onWillPop: () async {
        if (Dependencies.userCreatorPresentation.goBackUserCreated==true) {
          return true;
        } else {
          return showGoToMainScreenDialog(context);
        }
      },
      child: ChangeNotifierProvider.value(
        value: Dependencies.userCreatorPresentation,
        child: Material(
          child: SafeArea(
            child: Consumer<UserCreatorPresentation>(builder:
                (BuildContext context,
                    UserCreatorPresentation userCreatorPresentation,
                    Widget? child) {
              return Container(
                  height: ScreenUtil().screenHeight,
                  child: userCreatorPresentation.getUserCreatorScreenState ==
                          UserCreatorScreenState.READY
                      ? Container(
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hola",
                                style: GoogleFonts.roboto(fontSize: 90.sp),
                              ),
                              Text(
                                "Bienvenido a Hotty",
                                style: GoogleFonts.roboto(fontSize: 60.sp),
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        GoToRoute(
                                            page: UserCreatorPages(
                                                userName: widget.userName)));
                                  },
                                  child: Text("Empezar"))
                            ],
                          )),
                        )
                      : userCreatorPresentation.getUserCreatorScreenState ==
                              UserCreatorScreenState.LOADING
                          ? Container(
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingIndicator(
                                      indicatorType: Indicator.ballPulseSync),
                                  Text("Cargando"),
                                ],
                              )),
                            )
                          : ElevatedButton.icon(
                              onPressed: () {
                                
                                userCreatorPresentation.createUser();},
                              icon: Icon(Icons.error),
                              label: Text("Error")));
            }),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ProfileCharacteristicCreatorEditing extends StatefulWidget {
  List<UserCharacteristic> userCharacteristic;
  ProfileCharacteristicCreatorEditing({
    required this.userCharacteristic,
  });

  @override
  State<ProfileCharacteristicCreatorEditing> createState() =>
      _ProfileCharacteristicEditingCreatorState();
}

class _ProfileCharacteristicEditingCreatorState
    extends State<ProfileCharacteristicCreatorEditing> {
  List<Widget> checkboxList = [];
  List<UserCharacteristic> userCharacteristicsList = [];

  @override
  void initState() {
    super.initState();
    addCheckBoxList();
  }

  void addCheckBoxList() {
    userCharacteristicsList = new List.from(widget.userCharacteristic);
  }

  void changeValue() {}

  @override
  void dispose() {
    print("okiera");
    userCharacteristicsList
        .sort((a, b) => a.positionIndex.compareTo(b.positionIndex));

    Dependencies.userCreatorController.userCreatorEntity.userCharacteristics =
        userCharacteristicsList;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: ScreenUtil().screenHeight,
        color: Colors.white,
        child: SafeArea(
          child: PageView.builder(
              itemCount: userCharacteristicsList.length,
              itemBuilder: (BuildContext context, int index) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(userCharacteristicsList[index].characteristicIcon),
                    Container(
                      height: 700.h,
                      child: ListView.builder(
                          itemCount:
                              userCharacteristicsList[index].valuesList.length,
                          itemBuilder: (BuildContext context, int indexInside) {
                            return CheckboxListTile(
                                title: Text(userCharacteristicsList[index]
                                    .valuesList[indexInside]
                                    .values
                                    .first),
                                value: userCharacteristicsList[index]
                                        .valuesList[indexInside]
                                        .values
                                        .first ==
                                    userCharacteristicsList[index]
                                        .characteristicValue,
                                onChanged: (value) {
                                  userCharacteristicsList[indexInside]
                                      .userHasValue = value as bool;
                                  userCharacteristicsList[index]
                                          .characteristicValue =
                                      userCharacteristicsList[index]
                                          .valuesList[indexInside]
                                          .keys
                                          .first;

                                  userCharacteristicsList[index]
                                      .characteristicValueIndex = indexInside;

                                  setState(() {});
                                });
                          }),
                    )
                  ],
                ));
              }),
        ),
      ),
    );
  }
}

class UserCreatorPages extends StatefulWidget {
  String? userName;

  UserCreatorPages({required this.userName});

  @override
  State<UserCreatorPages> createState() => _UserCreatorPagesState();
}

class _UserCreatorPagesState extends State<UserCreatorPages> {
  PageController _pageController = new PageController();
  int _ageValue = 18;
  late TextEditingController _userNameTextEditingController;
  late List<UserPicture> userPicturesList = [];
  late List<UserCharacteristic> userCharacteristicsListEditing = [];

  List<Key> userPicturesListKeys = [];

  bool checkPicuresArrayLength() {
    bool picturesAdded = false;

    for (int i = 0; i < userPicturesList.length; i++) {
      if (userPicturesList[i].getUserPictureBoxstate !=
          UserPicutreBoxState.empty) {
        picturesAdded = true;
      }
    }
    return picturesAdded;
  }

  @override
  void initState() {
    super.initState();

    userPicturesListKeys = [
      Key("1"),
      Key("2"),
      Key("3"),
      Key("4"),
      Key("5"),
      Key("6"),
    ];
  }

  bool isWoman = true;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.userCreatorPresentation,
      child: Consumer<UserCreatorPresentation>(builder: (BuildContext context,
          UserCreatorPresentation userCreatorPresentation, Widget? child) {
        return SafeArea(
          child: Material(
              child: userCreatorPresentation.getUserCreationProcessState ==
                      UserCreationProcessState.NOT_STARTED
                  ? PageView(
                      controller: _pageController,
                      children: [
                        Container(
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Hola",
                                style: GoogleFonts.lato(fontSize: 90.sp),
                              ),
                              Text(
                                "Bienvenido a Hotty",
                                style: GoogleFonts.lato(fontSize: 60.sp),
                              ),
                              ElevatedButton.icon(
                                  onPressed: () => _pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut),
                                  icon: Icon(Icons.skip_next),
                                  label: Text("Siguiente"))
                            ],
                          )),
                        ),
                        userNameInput(userCreatorPresentation),
                        userAgeInput(userCreatorPresentation),
                        userSexPreferenceInput(),
                        userFastData(),
                        userPictuerInpit(),
                        userBioInput(userCreatorPresentation),
                        userUnitsSystem(
                            userCreatorPresentation: userCreatorPresentation),
                        userSearchInput(userCreatorPresentation)
                      ],
                    )
                  : userCreatorPresentation.getUserCreationProcessState ==
                          UserCreationProcessState.LOADING
                      ? Container(
                          child: Column(
                            children: [
                              LoadingIndicator(
                                  indicatorType: Indicator.ballBeat),
                              Text("Cargando"),
                            ],
                          ),
                        )
                      : Container(
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                  onPressed: () {userCreatorPresentation.createUser();},
                                  icon: Icon(Icons.warning),
                                  label: Text("Errores"))
                            ],
                          ),
                        )),
        );
      }),
    );
  }

  Container userBioInput(UserCreatorPresentation userCreatorPresentation) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          reverse: false,
          child: Container(
            height: ScreenUtil().screenHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: userBio(userCreatorPresentation),
                ),
                ElevatedButton.icon(
                    onPressed: () => _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    icon: Icon(Icons.arrow_forward),
                    label: Text("Siguiente"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container userSearchInput(UserCreatorPresentation userCreatorPresentation) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          reverse: false,
          child: Container(
            height: ScreenUtil().screenHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 300.h,
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Text("Distancia"),
                          Slider(
                            divisions: 14,
                            value: userCreatorPresentation.userCreatorController
                                .userCreatorEntity.maxDistanceForSearching
                                .toDouble(),
                            onChanged: (value) {
                              userCreatorPresentation
                                  .userCreatorController
                                  .userCreatorEntity
                                  .maxDistanceForSearching = value.toInt();
                              setState(() {});
                            },
                            min: 10,
                            max: 150,
                          ),
                        ],
                      ),
                      Text(userCreatorPresentation.userCreatorController
                          .userCreatorEntity.maxDistanceForSearching
                          .toStringAsFixed(0)),
                    ],
                  ),
                ),
                Container(
                  height: 300.h,
                  child: Row(
                    children: [
                      Flexible(
                        flex: 8,
                        fit: FlexFit.tight,
                        child: Container(
                          height: 200.h,
                          child: FlutterSlider(
                            rangeSlider: true,
                            values: [
                              userCreatorPresentation.userCreatorController
                                  .userCreatorEntity.minRangeSearchingAge
                                  .toDouble(),
                              userCreatorPresentation.userCreatorController
                                  .userCreatorEntity.maxRangeSearchingAge
                                  .toDouble()
                            ],
                            max: 70,
                            min: 18,
                            onDragging: (index, minValue, maxValue) {
                              double min = minValue;
                              double max = maxValue;

                              userCreatorPresentation
                                  .userCreatorController
                                  .userCreatorEntity
                                  .minRangeSearchingAge = min.toInt();
                              userCreatorPresentation
                                  .userCreatorController
                                  .userCreatorEntity
                                  .maxRangeSearchingAge = max.toInt();
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        fit: FlexFit.tight,
                        child: Container(
                          child: Text(
                              "${userCreatorPresentation.userCreatorController.userCreatorEntity.minRangeSearchingAge.toStringAsFixed(0)} - ${userCreatorPresentation.userCreatorController.userCreatorEntity.maxRangeSearchingAge.toStringAsFixed(0)}"),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: () => userCreatorPresentation.createUser(),
                    icon: Icon(Icons.arrow_forward),
                    label: Text("Siguiente"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container userAdsConsentInput(
      UserCreatorPresentation userCreatorPresentation) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          reverse: false,
          child: Container(
            height: ScreenUtil().screenHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Text(
                          "Para poder darte todas las ventajas de Hotty que son:"),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Text("-30000 gemas por registrarte"),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Text(
                          "-600 gemas gratis cada 24h siempre y cuando tengas menos de 600 gemas"),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Text("-5000 gemas por verificar tu perfil"),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                      Text(
                          "-5000 gemas por compartir la aplicacion con un amigo"),
                      Divider(
                        color: Colors.white,
                        height: 100.h,
                      ),
                    ],
                  ),
                ),
                Dependencies.advertisingServices.consentFormShowed
                    ? ElevatedButton.icon(
                        onPressed: () => _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut),
                        icon: Icon(Icons.arrow_forward),
                        label: Text("Siguiente"))
                    : ElevatedButton.icon(
                        onPressed: () => _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut),
                        icon: Icon(Icons.arrow_forward),
                        label: Text("De acuerdo"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container userUnitsSystem(
      {required UserCreatorPresentation userCreatorPresentation}) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                child: Container(
                    child: Text(
              "Selecciona tus unidades",
              style: GoogleFonts.lato(fontSize: 50.sp),
            ))),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Text(
                    "Mostrar altura en:",
                    style: GoogleFonts.lato(fontSize: 50.sp),
                  )),
                  CheckboxListTile(
                    value: userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMeters,
                    onChanged: (value) {
                      userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMeters = true;
                      setState(() {});
                    },
                    title: Text("Mostrar altura en cm"),
                  ),
                  CheckboxListTile(
                    value: !userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMeters,
                    onChanged: (value) {
                      userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMeters = false;
                      setState(() {});
                    },
                    title: Text("Mostrar altura en pies"),
                  ),
                  Container(
                      child: Text(
                    "Mostrar distancia en:",
                    style: GoogleFonts.lato(fontSize: 50.sp),
                  )),
                  CheckboxListTile(
                    value: userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMiles,
                    onChanged: (value) {
                      userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMiles = true;
                      setState(() {});
                    },
                    title: Text("Mostrar distancia en millas"),
                  ),
                  CheckboxListTile(
                    value: !userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMiles,
                    onChanged: (value) {
                      userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMiles = false;
                      setState(() {});
                    },
                    title: Text("Mostrar distancia en kilometros"),
                  ),
                  Divider(
                    height: 150.h,
                    color: Colors.white,
                  ),
                  Container(
                      child: Text(
                    "Se puede modificar luego en los ajustes",
                    style: GoogleFonts.lato(fontSize: 50.sp),
                  )),
                ],
              )),
            ),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: ElevatedButton.icon(
                    onPressed: () => _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                    icon: Icon(Icons.skip_next),
                    label: Text("Siguiente")))
          ],
        ),
      ),
    );
  }

  Container userPictuerInpit() {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
                child: Container(
                    child: Text(
              "Añade tus fotos",
              style: GoogleFonts.lato(fontSize: 50.sp),
            ))),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Container(child: userPictures()),
            ),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: checkPicuresArrayLength()
                    ? ElevatedButton.icon(
                        onPressed: () => _pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut),
                        icon: Icon(Icons.skip_next),
                        label: Text("Siguiente"))
                    : Text("Es obligatorio que añadas al menos una foto"))
          ],
        ),
      ),
    );
  }

  Container userFastData() {
    userCharacteristicsListEditing = Dependencies.userCreatorPresentation
        .userCreatorController.userCreatorEntity.userCharacteristics;
    userPicturesList = Dependencies.userCreatorPresentation
        .userCreatorController.userCreatorEntity.userPicruresList;
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
                child: Container(
                    child: Text(
              "Datos rapidos",
              style: GoogleFonts.lato(fontSize: 50.sp),
            ))),
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: Container(
                child: ListView.builder(
                    itemCount: userCharacteristicsListEditing.length,
                    itemBuilder: (BuildContext context, int index) {
                      return profileCharacteristicUserCreator(
                          userCharacteristicsListEditing[index], index);
                    }),
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: ElevatedButton.icon(
                  onPressed: () => _pageController.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut),
                  icon: Icon(Icons.skip_next),
                  label: Text("Siguiente")),
            )
          ],
        ),
      ),
    );
  }

  Container userSexPreferenceInput() {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tu sexo",
              style: GoogleFonts.lato(fontSize: 90.sp),
            ),
            CheckboxListTile(
              value: isWoman == false,
              onChanged: (value) {
                if (value != null) {
                  isWoman = false;
                  Dependencies.userCreatorController.userCreatorEntity
                      .isUserWoman = isWoman;
                  setState(() {});
                }
              },
              title: Text("Masculino"),
            ),
            CheckboxListTile(
              value: isWoman == true,
              onChanged: (value) {
                if (value != null) {
                  isWoman = true;
                  Dependencies.userCreatorController.userCreatorEntity
                      .isUserWoman = isWoman;

                  setState(() {});
                }
              },
              title: Text("Femenino"),
            ),
            Text(
              "Me interesan",
              style: GoogleFonts.lato(fontSize: 90.sp),
            ),
            CheckboxListTile(
              value: Dependencies
                          .userCreatorController.userCreatorEntity.showWoman ==
                      false &&
                  Dependencies.userCreatorController.userCreatorEntity
                          .showBothSexes ==
                      false,
              onChanged: (value) {
                if (value != null) {
                  Dependencies.userCreatorController.userCreatorEntity
                      .showWoman = false;
                  Dependencies.userCreatorController.userCreatorEntity
                      .showBothSexes = false;

                  setState(() {});
                }
              },
              title: Text("Hombres"),
            ),
            CheckboxListTile(
              value: Dependencies
                          .userCreatorController.userCreatorEntity.showWoman ==
                      true &&
                  Dependencies.userCreatorController.userCreatorEntity
                          .showBothSexes ==
                      false,
              onChanged: (value) {
                if (value != null) {
                  Dependencies
                      .userCreatorController.userCreatorEntity.showWoman = true;
                  Dependencies.userCreatorController.userCreatorEntity
                      .showBothSexes = false;

                  setState(() {});
                }
              },
              title: Text("Mujeres"),
            ),
            CheckboxListTile(
              value: Dependencies
                  .userCreatorController.userCreatorEntity.showBothSexes,
              onChanged: (value) {
                if (value != null) {
                  Dependencies.userCreatorController.userCreatorEntity
                      .showBothSexes = true;

                  setState(() {});
                }
              },
              title: Text("Ambos"),
            ),
            ElevatedButton.icon(
                onPressed: () => _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut),
                icon: Icon(Icons.skip_next),
                label: Text("Siguiente"))
          ],
        ),
      ),
    );
  }

  Container userAgeInput(UserCreatorPresentation userCreatorPresentation) {
    var dateFormat = DateFormat.yMEd();
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "¿Cuantos años tienes?",
              style: GoogleFonts.lato(fontSize: 90.sp),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                userCreatorPresentation
                            .userCreatorController.userCreatorEntity.date !=
                        null
                    ? Text(
                        dateFormat.format(userCreatorPresentation
                            .userCreatorController
                            .userCreatorEntity
                            .date as DateTime),
                        style: GoogleFonts.lato(fontSize: 50.sp),
                      )
                    : Text(""),
                userCreatorPresentation
                            .userCreatorController.userCreatorEntity.age !=
                        null
                    ? Text(userCreatorPresentation
                        .userCreatorController.userCreatorEntity.age
                        .toString())
                    : Text("")
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  await DatePicker.showDatePicker(context,
                          maxTime: userCreatorPresentation.userCreatorController
                              .userCreatorEntity.minBirthDate)
                      .then((value) {
                    if (value != null) {
                      userCreatorPresentation.addDate(dateTime: value);
                    }
                  });
                },
                child: Text("Añadir fecha")),
            Text(
              "Debes tener más de 18 años para usar Hotty",
              style: GoogleFonts.lato(fontSize: 40.sp),
            ),
            userCreatorPresentation.getUserCreatorEntity.age == null
                ? Text("Debes especificar tu edad")
                : Container(
                    child:
                        userCreatorPresentation.getUserCreatorEntity.age! >= 18
                            ? ElevatedButton.icon(
                                onPressed: () => _pageController.nextPage(
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeInOut),
                                icon: Icon(Icons.skip_next),
                                label: Text("Siguiente"))
                            : Container())
          ],
        ),
      ),
    );
  }

  void showNameErrorDialog(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("El nombre debe contener mas de 1 caracter"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Entendido"))
            ],
          );
        });
  }

  Container userNameInput(UserCreatorPresentation userCreatorPresentation) {
    if (widget.userName != null) {
      if (widget.userName!.length <= 25) {
        _userNameTextEditingController = new TextEditingController.fromValue(
            TextEditingValue(text: widget.userName as String));
        userCreatorPresentation.getUserCreatorEntity.userName =
            widget.userName as String;
      } else {
        _userNameTextEditingController = new TextEditingController();
      }
    } else {
      _userNameTextEditingController = new TextEditingController();
    }
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Divider(
              height: 300.h,
            ),
            Text(
              "Dinos tu nombre",
              style: GoogleFonts.lato(fontSize: 90.sp),
            ),
            TextField(
              controller: _userNameTextEditingController,
              maxLength: 25,
              onChanged: (value) {
                userCreatorPresentation.getUserCreatorEntity.userName = value;
              },
              textInputAction: TextInputAction.done,
            ),
            ElevatedButton.icon(
                onPressed: () {
                  if (userCreatorPresentation.getUserCreatorEntity.userName
                          .trim()
                          .length >
                      2) {
                    _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  } else {
                    showNameErrorDialog(context);
                  }
                },
                icon: Icon(Icons.skip_next),
                label: Text("Siguiente"))
          ],
        ),
      ),
    );
  }

  Column userBio(UserCreatorPresentation userCreatorPresentation) {
    TextEditingController textEditingController =
        new TextEditingController.fromValue(TextEditingValue(
            text: userCreatorPresentation.getUserCreatorEntity.userBio));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Descripcion"),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.all(Radius.circular(10))),
            height: 500.h,
            width: ScreenUtil().screenWidth,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: textEditingController,
                  maxLength: 300,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {
                    userCreatorPresentation.getUserCreatorEntity.userBio =
                        value;
                  },
                )),
          ),
        ),
      ],
    );
  }

  Widget profileCharacteristicUserCreator(
      UserCharacteristic userCharacteristic, int index) {
    return GestureDetector(
      onTap: () {
        userCharacteristicsListEditing
            .sort((a, b) => a.positionIndex.compareTo(b.positionIndex));

        UserCharacteristic characteristic =
            userCharacteristicsListEditing[index];
        UserCharacteristic characteristicToMove =
            userCharacteristicsListEditing.first;
        userCharacteristicsListEditing.first = characteristic;
        userCharacteristicsListEditing[index] = characteristicToMove;
        Navigator.push(
            context,
            GoToRoute(
                page: ProfileCharacteristicCreatorEditing(
              userCharacteristic: userCharacteristicsListEditing,
            )));
      },
      child: Card(
        child: Container(
          height: 150.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Icon(userCharacteristic.characteristicIcon)),
              Flexible(
                flex: 10,
                fit: FlexFit.tight,
                child: Container(
                  color: Colors.red,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(userCharacteristic.characteristicName),
                        Text(userCharacteristic.characteristicValue),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container userPictures() {
    return Container(
      height: 900.h,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReorderableGridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 2.h / 3.h,
            mainAxisSpacing: 20.h,
            crossAxisSpacing: 20.w,
            crossAxisCount: 3,
          ),
          onReorder: (oldIndex, newIndex) {
            UserPicture oldPicture = userPicturesList[oldIndex];
            UserPicture newPicture = userPicturesList[newIndex];

            newPicture.index = oldIndex;
            oldPicture.index = newIndex;

            userPicturesList[oldIndex] = newPicture;
            userPicturesList[newIndex] = oldPicture;
            setState(() {});
          },
          physics: NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) {
            return pictureBox(
                userPicturesListKeys[index], userPicturesList[index], index);
          },
        ),
      ),
    );
  }

  Widget profileCharacteristicCreator(
      UserCharacteristic userCharacteristic, int index) {
    return GestureDetector(
      onTap: () {
        userCharacteristicsListEditing
            .sort((a, b) => a.positionIndex.compareTo(b.positionIndex));

        UserCharacteristic characteristic =
            userCharacteristicsListEditing[index];
        UserCharacteristic characteristicToMove =
            userCharacteristicsListEditing.first;
        userCharacteristicsListEditing.first = characteristic;
        userCharacteristicsListEditing[index] = characteristicToMove;
        Navigator.push(
            context,
            GoToRoute(
                page: ProfileCharacteristicCreatorEditing(
              userCharacteristic: userCharacteristicsListEditing,
            )));
      },
      child: Card(
        child: Container(
          height: 200.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: Icon(userCharacteristic.characteristicIcon)),
              Flexible(
                flex: 10,
                fit: FlexFit.tight,
                child: Container(
                  color: Colors.red,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(userCharacteristic.characteristicName),
                        Text(userCharacteristic.characteristicValue),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addPictureFromDevice(int index) async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    CroppedFile? imageFile = await ImageCropper().cropImage(
        sourcePath: xfile!.path,
        maxHeight: 1280,
        maxWidth: 720,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
        compressQuality: 70,
        
      );
    Uint8List? uint8list = await imageFile!.readAsBytes();

    Dependencies.userCreatorPresentation
        .addPicture(imageData: uint8list, index: index);
    setState(() {});
  }

  void deletePicture(int index) {
    Dependencies.userCreatorPresentation.deletePircture(index);
    setState(() {});
  }

  Widget pictureBox(Key key, UserPicture userPictureData, int index) {
    return Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.black)),
        key: key,
        child: Stack(
          children: [
            userPictureData.getUserPictureBoxstate ==
                    UserPicutreBoxState.pictureFromNetwork
                ? GestureDetector(
                    onTap: () {
                      addPictureFromDevice(index);
                    },
                    child: Container(
                        child: OctoImage(
                      fadeInDuration: Duration(milliseconds: 50),
                      fit: BoxFit.cover,
                      image: CachedNetworkImageProvider(
                          userPictureData.getPictureUrl),
                      placeholderBuilder: OctoPlaceholder.blurHash(
                          userPictureData.getPictureHash,
                          fit: BoxFit.cover),
                    )),
                  )
                : userPictureData.getUserPictureBoxstate ==
                        UserPicutreBoxState.pictureFromBytes
                    ? GestureDetector(
                        onTap: () {
                          addPictureFromDevice(index);
                        },
                        child: Container(
                            child: Image.memory(userPictureData.getImageFile)),
                      )
                    : GestureDetector(
                        onTap: () {
                          addPictureFromDevice(index);
                        },
                        child: Container(
                            color: Color.fromARGB(124, 158, 158, 158),
                            child: Center(
                              child: Icon(
                                Icons.add_a_photo_outlined,
                              ),
                              heightFactor: 10.h,
                            )),
                      ),
            userPictureData.getUserPictureBoxstate != UserPicutreBoxState.empty
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index != 0
                                ? Color.fromARGB(181, 244, 67, 54)
                                : Colors.grey),
                        height: 100.h,
                        child: IconButton(
                            onPressed: () {
                              if (index != 0) {
                                deletePicture(index);
                              }
                            },
                            icon: Icon(Icons.delete_outline_sharp))),
                  )
                : Container()
          ],
        ));
  }
}
