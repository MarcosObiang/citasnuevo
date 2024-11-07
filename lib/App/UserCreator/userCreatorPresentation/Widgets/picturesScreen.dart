import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import '../../../UserSettings/UserSettingsEntity.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../userCreatorPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class UserPicturesInput extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  UserPicturesInput(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<UserPicturesInput> createState() => _UserPicturesInputState();
}

class _UserPicturesInputState extends State<UserPicturesInput> {
  late List<UserPicture> userPicturesList = [];
  List<Key> userPicturesListKeys = [];

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
    userPicturesList =
        widget.userCreatorPresentation.getUserCreatorEntity.userPicruresList;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.userCreatorPresentation,
      child: Container(
        height: ScreenUtil().screenHeight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                  child: Container(
                      child: Text(
                AppLocalizations.of(context)!.picturesScreen_addPictures,
                style: GoogleFonts.lato(fontSize: 50.sp),
              ))),
              Flexible(
                flex: 10,
                fit: FlexFit.tight,
                child: Container(child: userPictures()),
              ),
              Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Column(
                    children: [
                        Text(
                        "4/7",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () => widget.pageController.previousPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut),
                              icon: Icon(Icons.arrow_back),
                              label: Text(AppLocalizations.of(context)!.picturesScreen_back)),
                          ElevatedButton.icon(
                              onPressed: () {
                                if (widget.userCreatorPresentation
                                        .pictureChecker() ==
                                    true) {
                                  widget.pageController.nextPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeInOut);
                                }
                              },
                              icon: Icon(Icons.arrow_forward),
                              label: Text(AppLocalizations.of(context)!.picturesScreen_next)),
                        ],
                      ),
                      ElevatedButton.icon(
                              onPressed: () => widget.userCreatorPresentation.logOut(),
                              icon: Icon(Icons.cancel),
                              label: Text(AppLocalizations.of(context)!.picturesScreen_exit))
                    ],
                  ))
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

  Widget pictureBox(Key key, UserPicture userPictureData, int index) {
    return Stack(
      key: key,
      children: [
        userPictureData.getUserPictureBoxstate ==
                UserPicutreBoxState.pictureFromBytes
            ? GestureDetector(
                onTap: () {
                  addPictureFromDevice(
                      index: index,
                      userCreatorPresentation: widget.userCreatorPresentation);
                },
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      image: DecorationImage(
                          image: MemoryImage(userPictureData.getImageFile))),
                ),
              )
            : GestureDetector(
                onTap: () {
                  addPictureFromDevice(
                      index: index,
                      userCreatorPresentation: widget.userCreatorPresentation);
                },
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_a_photo_outlined,
                      ),
                    )),
              ),
        userPictureData.getUserPictureBoxstate != UserPicutreBoxState.empty
            ? Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(181, 244, 67, 54)),
                    height: 100.h,
                    child: IconButton(
                        onPressed: () {
                          deletePicture(
                              index: index,
                              userCreatorPresentation:
                                  widget.userCreatorPresentation);
                        },
                        icon: Icon(Icons.delete_outline_sharp))),
              )
            : Container()
      ],
    );
  }

  void addPictureFromDevice(
      {required int index,
      required UserCreatorPresentation userCreatorPresentation}) async {
    XFile? xfile = await ImagePicker().pickImage(source: ImageSource.gallery);
    CroppedFile? imageFile = await ImageCropper().cropImage(
      sourcePath: xfile!.path,
      maxHeight: 1280,
      maxWidth: 720,
      aspectRatio: CropAspectRatio(ratioX: 2, ratioY: 3),
      compressQuality: 70,
    );
    Uint8List? uint8list = await imageFile!.readAsBytes();

    

    userCreatorPresentation.addPicture(imageData: uint8list, index: index);
    setState(() {});
  }

  void deletePicture(
      {required int index,
      required UserCreatorPresentation userCreatorPresentation}) {
    userCreatorPresentation.deletePircture(index);
    setState(() {});
  }
}
