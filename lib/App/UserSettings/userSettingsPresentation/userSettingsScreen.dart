import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../../../Utils/routes.dart';
import '../../../core/dependencies/dependencyCreator.dart';
import '../../../main.dart';
import '../UserSettingsEntity.dart';
import 'userPresentation.dart';

class UserSettingsScreenArgs {}

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen();
  static const routeName = '/UserSettingsScreen';

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen>
    with RouteAware {
  ScrollController scrollController = new ScrollController();
  @override
  void initState() {
    super.initState();
    userPicturesList = Dependencies.userSettingsPresentation
        .userSettingsController.userSettingsEntityUpdate.userPicruresList;

    userPicturesListKeys = [
      Key("a"),
      Key("b"),
      Key("c"),
      Key("d"),
      Key("e"),
      Key("f"),
    ];

    userCharacteristicsList.addAll(Dependencies.userSettingsPresentation
        .userSettingsController.userSettingsEntityUpdate.userCharacteristics);
    userCharacteristicsListEditing.addAll(Dependencies.userSettingsPresentation
        .userSettingsController.userSettingsEntityUpdate.userCharacteristics);
  }

  @override
  void dispose() {
    Dependencies.userSettingsPresentation.userSettingsUpdate();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    print("Change dependencies!!!!");
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    print("Did Push!");
  }

  @override
  void didPopNext() {
    setState(() {});
    print("Did Pop Next");
  }

  @override
  void didPushNext() {
    print("Did Push Next");

    super.didPushNext();
  }

  @override
  void didPop() {
    super.didPop();
  }

  late List<UserPicture> userPicturesList;
  late List<Key> userPicturesListKeys;
  late List<UserCharacteristic> userCharacteristicsList = [];
  late List<UserCharacteristic> userCharacteristicsListEditing = [];

  FocusNode focusNode = new FocusNode();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool exit = true;

        await Future.delayed(Duration(milliseconds: 200));
        if (Dependencies
                .userSettingsPresentation.getUserSettingsScreenUpdateState ==
            UserSettingsScreenUpdateState.done) {
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text( AppLocalizations.of(context!)!.userSettingsScreen_saveChanges),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Dependencies.userSettingsPresentation.saveChanges =
                              false;
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context!)!.no,
                            style: GoogleFonts.lato(color: Colors.black))),
                    ElevatedButton(
                        onPressed: () {
                          Dependencies.userSettingsPresentation.saveChanges =
                              true;
                          Navigator.pop(context);
                        },
                        child: Text(AppLocalizations.of(context!)!.yes)),
                  ],
                );
              });
        }

        return exit;
      },
      child: ChangeNotifierProvider.value(
        value: Dependencies.userSettingsPresentation,
        child: Material(
          child: SafeArea(
            child: Container(
              child: Consumer<UserSettingsPresentation>(
                builder: (BuildContext context,
                    UserSettingsPresentation userSettingsPresentation,
                    Widget? child) {
                  return userSettingsPresentation.userSettingsScreenState ==
                          UserSettingsScreenState.loaded
                      ? Stack(
                          children: [
                            SingleChildScrollView(
                              controller: scrollController,
                              reverse: false,
                              child: Container(
                                  height:
                                      ScreenUtil.defaultSize.height + 3000.h,
                                  child: Column(
                                    children: [
                                      AppBar(
                                        title: Text(AppLocalizations.of(context!)!.settings_editProfile),
                                      ),
                                      Flexible(
                                          flex: 3,
                                          fit: FlexFit.tight,
                                          child: LayoutBuilder(builder:
                                              (BuildContext context,
                                                  BoxConstraints
                                                      boxConstraints) {
                                            return userPictures(boxConstraints);
                                          })),
                                      Flexible(
                                          flex: 3,
                                          fit: FlexFit.tight,
                                          child: userBio()),
                                      Flexible(
                                        flex: 8,
                                        fit: FlexFit.tight,
                                        child: Column(
                                          children: [
                                            Flexible(
                                                flex: 1,
                                                fit: FlexFit.tight,
                                                child: Text(
                                                  AppLocalizations.of(context!)!.userSettingsScreen_filters,
                                                  style: GoogleFonts.lato(
                                                      fontSize: 80.sp),
                                                )),
                                            Flexible(
                                              flex: 8,
                                              fit: FlexFit.tight,
                                              child: Container(
                                                child: ListView.builder(
                                                    itemCount:
                                                        userCharacteristicsList
                                                            .length,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    itemBuilder:
                                                        (BuildContext context,
                                                            int index) {
                                                      return profileCharacteristic(
                                                          index);
                                                    }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )),
                            ),
                            userSettingsPresentation
                                        .getUserSettingsScreenUpdateState ==
                                    UserSettingsScreenUpdateState.loading
                                ? Container(
                                    height: ScreenUtil().screenHeight,
                                    color: Color.fromARGB(139, 0, 0, 0),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                              height: 300.h,
                                              width: 300.h,
                                              child: LoadingIndicator(
                                                  indicatorType:
                                                      Indicator.ballRotate)),
                                          Text(
                                            AppLocalizations.of(context!)!.loading,
                                            style: GoogleFonts.lato(
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                : Container()
                          ],
                        )
                      : userSettingsPresentation.userSettingsScreenState ==
                              UserSettingsScreenState.error
                          ? Center(
                              child: IconButton(
                                  onPressed: () {
                                    userSettingsPresentation.restart();
                                  },
                                  icon: Icon(Icons.restart_alt)),
                            )
                          : Center(
                              child: Container(
                                height: 300.h,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.orbit),
                              ),
                            );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container userPictures(BoxConstraints boxConstraints) {
    return Container(
      height: boxConstraints.biggest.height.h,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReorderableGridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: boxConstraints.biggest.height * 0.03,
            crossAxisSpacing: 20.w,
            crossAxisCount: 3,
            mainAxisExtent: boxConstraints.biggest.height * 0.45,
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
            return pictureBox(userPicturesListKeys[index],
                userPicturesList[index], index, boxConstraints);
          },
        ),
      ),
    );
  }

  Column userBio() {
    TextEditingController textEditingController =
        new TextEditingController.fromValue(TextEditingValue(
            text: Dependencies.userSettingsPresentation.userSettingsController
                .userSettingsEntityUpdate.userBio));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context!)!.sobre_mi),
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
              child: Text(
                Dependencies.userSettingsPresentation.userSettingsController
                    .userSettingsEntityUpdate.userBio,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
        ),
        IconButton(
            onPressed: () =>
                Navigator.push(context, GoToRoute(page: BioEditingScreen())),
            icon: Icon(Icons.edit))
      ],
    );
  }

  Future characteristicValuesEditor({
    required int index,
  }) {
    ScrollController controllerTwo = ScrollController();

    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.all(50.w),
              child: Column(
                children: [
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(userCharacteristicsList[index].characteristicIcon),
                        Text(
                          userCharacteristicsList[index].characteristicName.call(context),
                          style: GoogleFonts.lato(
                              fontSize: 60.sp, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: controllerTwo,
                      child: ListView.builder(
                          controller: controllerTwo,
                          itemCount:
                              userCharacteristicsList[index].valuesList.length,
                          itemBuilder: (BuildContext context, int indexInside) {
                            return CheckboxListTile(
                                title: Text(userCharacteristicsList[index]
                                    .valuesList[indexInside]
                                    .values
                                    .first.call(context)),
                                value: userCharacteristicsList[index]
                                        .valuesList[indexInside]
                                        .keys
                                        .first ==
                                    userCharacteristicsList[index]
                                        .characteristicValueIndex,
                                onChanged: (value) {
                                  userCharacteristicsList[index].userHasValue =
                                      value as bool;

                                  userCharacteristicsList[index]
                                      .characteristicValueIndex = indexInside;
                                  userCharacteristicsList[index]
                                      .setCharacteristicName();
                                  /* widget.userCreatorPresentation
                                      .updateUserCharacteristicListState(
                                          userCharacteristicsList);*/

                                  print(index);

                                  setState(() {});
                                });
                          }),
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back),
                        label: Text(AppLocalizations.of(context!)!.back)),
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget profileCharacteristic(int index) {
    return GestureDetector(
      onTap: () {
        characteristicValuesEditor(index: index);

        /*  userCharacteristicsListEditing
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
                page: ProfileCharacteristicEditing(
              userCharacteristic: userCharacteristicsListEditing,
            )));*/
      },
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(10.h),
          child: Container(
            height: 150.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(Dependencies
                        .userSettingsPresentation
                        .userSettingsController
                        .userSettingsEntityUpdate
                        .userCharacteristics[index]
                        .characteristicIcon)),
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            Dependencies
                                .userSettingsPresentation
                                .userSettingsController
                                .userSettingsEntityUpdate
                                .userCharacteristics[index]
                                .characteristicName.call(context),
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        Text(Dependencies
                            .userSettingsPresentation
                            .userSettingsController
                            .userSettingsEntityUpdate
                            .userCharacteristics[index]
                            .characteristicValue.call(context)),
                      ],
                    ),
                  ),
                ),
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(
                      Icons.check_box,
                      color: Dependencies
                                  .userSettingsPresentation
                                  .userSettingsController
                                  .userSettingsEntityUpdate
                                  .userCharacteristics[index]
                                  .characteristicValueIndex >
                              0
                          ? Colors.green
                          : Colors.transparent,
                    )),
              ],
            ),
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

    Dependencies.userSettingsPresentation
        .addPictureFromDevice(uint8list, index);
    setState(() {});
  }

  void deletePicture(int index) {
    Dependencies.userSettingsPresentation.deletePicture(index);
    setState(() {});
  }

  Widget pictureBox(Key key, UserPicture userPictureData, int index,
      BoxConstraints boxConstraints) {
    return Container(
        height: boxConstraints.biggest.height,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.all(Radius.circular(10))),
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
                        child: Image.memory(
                      userPictureData.getImageFile,
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
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            height: boxConstraints.biggest.height,
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

class BioEditingScreen extends StatefulWidget {
  static const routeName = '/BioEditingScreen';

  const BioEditingScreen({Key? key}) : super(key: key);

  @override
  State<BioEditingScreen> createState() => _BioEditingScreenState();
}

class _BioEditingScreenState extends State<BioEditingScreen> {
  TextEditingController textEditingController =
      new TextEditingController.fromValue(TextEditingValue(
          text: Dependencies
              .userSettingsPresentation.getUserSettingsEntity.userBio));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context!)!.sobre_mi)),
      resizeToAvoidBottomInset: true,
      body: ChangeNotifierProvider.value(
        value: Dependencies.userSettingsPresentation,
        child: SafeArea(child: Consumer<UserSettingsPresentation>(
          builder: (BuildContext context,
              UserSettingsPresentation userSettingsPresentation,
              Widget? child) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 700.h,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        userSettingsPresentation.getUserSettingsEntity.userBio =
                            value;
                      },
                      maxLines: 300,
                    ),
                  ),
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back))
                ],
              ),
            );
          },
        )),
      ),
    );
  }
}
