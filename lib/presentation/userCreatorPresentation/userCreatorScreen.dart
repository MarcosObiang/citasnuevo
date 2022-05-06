import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';
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

class UserCreatorScreen extends StatefulWidget {
  String? userName;
  UserCreatorScreen({required this.userName});

  @override
  State<UserCreatorScreen> createState() => _UserCreatorScreenState();
}

class _UserCreatorScreenState extends State<UserCreatorScreen> {
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
                          userNameInput(),
                          userAgeInput(userCreatorPresentation),
                          userSexPreferenceInput(),
                          userFastData(),
                          userPictuerInpit(),
                          userBioInput(),
                        ],
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
                            onPressed: () {},
                            icon: Icon(Icons.error),
                            label: Text("Error")));
          }),
        ),
      ),
    );
  }

  Container userBioInput() {
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
                  child: userBio(),
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
                          maxTime: Dependencies
                              .userCreatorPresentation
                              .userCreatorController
                              .userCreatorEntity
                              .minBirthDate)
                      .then((value) {
                    if (value != null) {
                      Dependencies.userCreatorPresentation
                          .addDate(dateTime: value);
                    }
                  });
                },
                child: Text("Añadir fecha")),
            Text(
              "Debes tener más de 18 años para usar Hotty",
              style: GoogleFonts.lato(fontSize: 50.sp),
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

  Container userNameInput() {
    if (widget.userName != null) {
      _userNameTextEditingController = new TextEditingController.fromValue(
          TextEditingValue(text: widget.userName as String));
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
              maxLength: 15,
              onChanged: (value) {
                Dependencies.userCreatorController.userCreatorEntity.userName =
                    value;
              },
              textInputAction: TextInputAction.done,
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

  Column userBio() {
    TextEditingController textEditingController =
        new TextEditingController.fromValue(TextEditingValue(
            text:
                Dependencies.userCreatorController.userCreatorEntity.userBio));
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
                )),
          ),
        ),
        IconButton(
            onPressed: () =>
                Navigator.push(context, GoToRoute(page: BioEditingScreen())),
            icon: Icon(Icons.edit))
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
    File? imageFile = await ImageCropper().cropImage(
        sourcePath: xfile!.path,
        maxHeight: 1280,
        maxWidth: 720,
        aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
        compressQuality: 70,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Recortar imagen',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
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
