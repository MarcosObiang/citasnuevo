import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/data/Mappers/UserSettingsMapper.dart';
import 'package:citasnuevo/presentation/chatPresentation/Widgets/chatTilesScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/UserSettingsEntity.dart';
import 'package:citasnuevo/presentation/userSettingsPresentation/userPresentation.dart';

import '../../reordableList.dart';

class UserSettingsScreen extends StatefulWidget {
  const UserSettingsScreen();

  @override
  State<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends State<UserSettingsScreen> {
  ScrollController scrollController= new ScrollController();
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
    //  Dependencies.userSettingsPresentation.userSettingsUpdate();
    super.dispose();
  }

  late List<UserPicture> userPicturesList;
  late List<Key> userPicturesListKeys;
  late List<UserCharacteristic> userCharacteristicsList = [];
  late List<UserCharacteristic> userCharacteristicsListEditing = [];

  FocusNode focusNode = new FocusNode();
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.userSettingsPresentation,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Material(
          child: SafeArea(
            child: Container(
              child: Consumer<UserSettingsPresentation>(
                builder: (BuildContext context,
                    UserSettingsPresentation userSettingsPresentation,
                    Widget? child) {
                  return userSettingsPresentation.userSettingsScreenState ==
                          UserSettingsScreenState.loaded
                      ? SingleChildScrollView(
                        controller: scrollController,
                          reverse: true,
                          child: Container(
                            height: ScreenUtil.defaultSize.height + 2000.h,
                            child: Column(
                              children: [
                                userPictures(),
                                userBio(),
                                Divider(
                                  color: Colors.white,
                                  height: 100.h,
                                ),
                                Container(
                                  height: 2000.h,
                                  child: ListView.builder(
                                      itemCount: userCharacteristicsList.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return profileCharacteristic(
                                            userCharacteristicsList[index],
                                            index);
                                      }),
                                )
                              ],
                            ),
                          ),
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
                                    indicatorType: Indicator.ballPulse),
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
            child: TextField(
              focusNode: focusNode,
              textInputAction: TextInputAction.done,
              controller: textEditingController,
              onChanged: (value) {
                Dependencies.userSettingsPresentation.getUserSettingsEntity
                    .userBio = value;
              },
              style: GoogleFonts.lato(fontSize: 45.sp),
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide(color: Colors.white),
                      gapPadding: 10)),
              maxLines: 6,
              maxLength: 300,
            )),
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

    Dependencies.userSettingsPresentation
        .addPictureFromDevice(uint8list, index);
    setState(() {});
  }

  void deletePicture(int index) {
    Dependencies.userSettingsPresentation.deletePicture(index);
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
                            color: index!=0? Color.fromARGB(181, 244, 67, 54):Colors.grey),
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
class ProfileCharacteristicEditing extends StatefulWidget {
  List<UserCharacteristic> userCharacteristic;
  ProfileCharacteristicEditing({
    required this.userCharacteristic,
  });

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
    print("okiera");
    userCharacteristicsList
        .sort((a, b) => a.positionIndex.compareTo(b.positionIndex));

    Dependencies.userSettingsPresentation.userSettingsController
        .userSettingsEntityUpdate.userCharacteristics = userCharacteristicsList;

    print("okiera");
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
                                        .keys
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
