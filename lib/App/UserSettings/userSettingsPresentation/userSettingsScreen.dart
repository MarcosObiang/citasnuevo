import 'dart:io';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

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
  final storage = Storage(Dependencies.serverAPi.client!);

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
                  title: Text("¿Guardar cambios?"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Dependencies.userSettingsPresentation.saveChanges =
                              false;
                          Navigator.pop(context);
                        },
                        child: Text("No",
                            style: GoogleFonts.lato(color: Colors.black))),
                    ElevatedButton(
                        onPressed: () {
                          Dependencies.userSettingsPresentation.saveChanges =
                              true;
                          Navigator.pop(context);
                        },
                        child: Text("Si")),
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
                                      AppBar(title: Text(" Editar perfil"),),
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
                                                  "Filtros",
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
                                                          userCharacteristicsList[
                                                              index],
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
                                            "Guardando cambios, porfavor espere...",
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

  Widget profileCharacteristic(
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
                page: ProfileCharacteristicEditing(
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

    Dependencies.userSettingsPresentation
        .addPictureFromDevice(uint8list, index);
    setState(() {});
  }

  void deletePicture(int index) {
    Dependencies.userSettingsPresentation.deletePicture(index);
    setState(() {});
  }

  Future<Uint8List> _getImageData(String imageId) async {
    Uint8List? imageData;

    try {
      imageData = await storage.getFileDownload(
        bucketId: '63712fd65399f32a5414',
        fileId: imageId,
      );
      return imageData;
    } catch (e) {
      if (e is AppwriteException) {
        throw Exception();
      } else {
        throw Exception();
      }
    }
  }

  Widget pictureBox(Key key, UserPicture userPictureData, int index,
      BoxConstraints boxConstraints) {
    return Container(
        height: boxConstraints.biggest.height,
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
class ProfileCharacteristicEditing extends StatefulWidget {
  List<UserCharacteristic> userCharacteristic;
  ProfileCharacteristicEditing({
    required this.userCharacteristic,
  });
  static const routeName = '/ProfileCharacteristicEditing';

  @override
  State<ProfileCharacteristicEditing> createState() =>
      _ProfileCharacteristicEditingState();
}

class _ProfileCharacteristicEditingState
    extends State<ProfileCharacteristicEditing> {
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
    userCharacteristicsList
        .sort((a, b) => a.positionIndex.compareTo(b.positionIndex));

    Dependencies.userSettingsPresentation.userSettingsController
        .userSettingsEntityUpdate.userCharacteristics = userCharacteristicsList;

    super.dispose();
  }

  Text title({required int listBuilderIndex, required int pageViewIndex}) {
    return Text(userCharacteristicsList[pageViewIndex]
        .valuesList[listBuilderIndex]
        .values
        .first);
  }

  bool? value({required int listViewIndex, required int pageViewIndex}) {
    return userCharacteristicsList[pageViewIndex]
                .valuesList[listViewIndex]
                .entries
                .first
                .key ==
            userCharacteristicsList[pageViewIndex].characteristicValue ||
        (listViewIndex == 0 &&
            userCharacteristicsList[pageViewIndex].characteristicValueIndex ==
                0);
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
              itemBuilder: (BuildContext context, int pageViewIndex) {
                return Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(userCharacteristicsList[pageViewIndex]
                        .characteristicIcon),
                    Container(
                      height: 700.h,
                      child: ListView.builder(
                          itemCount: userCharacteristicsList[pageViewIndex]
                              .valuesList
                              .length,
                          itemBuilder:
                              (BuildContext context, int listViewIndex) {
                            return CheckboxListTile(
                                title: title(
                                    listBuilderIndex: listViewIndex,
                                    pageViewIndex: pageViewIndex),
                                value: value(
                                    listViewIndex: listViewIndex,
                                    pageViewIndex: pageViewIndex),
                                onChanged: (value) {
                                  userCharacteristicsList[listViewIndex]
                                      .userHasValue = value as bool;
                                  userCharacteristicsList[pageViewIndex]
                                          .characteristicValue =
                                     "";

                                  userCharacteristicsList[pageViewIndex]
                                      .characteristicValueIndex = listViewIndex;

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
      appBar: AppBar(title: Text("Descripcion")),
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
