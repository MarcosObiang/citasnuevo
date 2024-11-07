import '../../../UserSettings/UserSettingsEntity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";
import '../../../../core/dependencies/dependencyCreator.dart';

class ProfileCharacteristicCreatorEditing extends StatefulWidget {
  List<UserCharacteristic> userCharacteristic;
  int currentIndex;
  ProfileCharacteristicCreatorEditing(
      {required this.userCharacteristic, required this.currentIndex});

  @override
  State<ProfileCharacteristicCreatorEditing> createState() =>
      _ProfileCharacteristicEditingCreatorState();
}

class _ProfileCharacteristicEditingCreatorState
    extends State<ProfileCharacteristicCreatorEditing> {
  List<Widget> checkboxList = [];
  List<UserCharacteristic> userCharacteristicsList = [];
  late PageController pageController;
  int characteristicIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: widget.currentIndex);
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

    Dependencies.userCreatorPresentation
        .updateUserCharacteristicListState(userCharacteristicsList);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        height: ScreenUtil().screenHeight,
        color: Colors.white,
        child: Column(
          children: [
            Flexible(
              flex: 10,
              fit: FlexFit.tight,
              child: PageView.builder(
                  controller: pageController,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: userCharacteristicsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    characteristicIndex = index;

                    return Center(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 3,
                          fit: FlexFit.loose,
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(userCharacteristicsList[index]
                                    .characteristicIcon),
                                Text(
                                  userCharacteristicsList[index]
                                      .characteristicName.call(),
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 8,
                          fit: FlexFit.loose,
                          child: Padding(
                            padding: EdgeInsets.only(right: 45.w, left: 45.w),
                            child: Card(
                              child: Container(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      right: 45.w,
                                      left: 45.w,
                                      top: 30.w,
                                      bottom: 30.w),
                                  child: characteristicOptionsList(index),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text("${index + 1}/${userCharacteristicsList.length}",
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        Divider(
                          height: 100.h,
                          color: Colors.transparent,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            index > 0
                                ? ElevatedButton.icon(
                                    onPressed: () {
                                      pageController.previousPage(
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.ease);
                                    },
                                    icon: Icon(LineAwesomeIcons
                                        .alternate_arrow_circle_left),
                                    label: Text("Anterior"))
                                : Container(),
                            index < userCharacteristicsList.length - 1
                                ? ElevatedButton.icon(
                                    onPressed: () {
                                      pageController.nextPage(
                                          duration: Duration(milliseconds: 400),
                                          curve: Curves.ease);
                                    },
                                    icon: Icon(LineAwesomeIcons
                                        .alternate_arrow_circle_right),
                                    label: Text("Siguiente"))
                                : Container()
                          ],
                        ),
                      ],
                    ));
                  }),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(LineAwesomeIcons.window_close),
                  label: Text("Atras")),
            )
          ],
        ),
      ),
    );
  }

  Scrollbar characteristicOptionsList(int index) {
    ScrollController controllerTwo = ScrollController();

    return Scrollbar(
      thumbVisibility: true,
      controller: controllerTwo,
      child: ListView.builder(
          controller: controllerTwo,
          itemCount: userCharacteristicsList[index].valuesList.length,
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
                    userCharacteristicsList[index].characteristicValueIndex,
                onChanged: (value) {
                  userCharacteristicsList[index].userHasValue = value as bool;

                  userCharacteristicsList[index].characteristicValueIndex =
                      indexInside;
                  userCharacteristicsList[index].setCharacteristicName();

                  print(index);

                  setState(() {});
                });
          }),
    );
  }
}

/*class MyWidget extends StatefulWidget {
  int index;
  UserCharacteristic userCharacteristic;
  MyWidget({
    required this.index,required this.userCharacteristic
  });
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final ScrollController controllerTwo = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      controller: controllerTwo,
      child: ListView.builder(
          itemCount:widget.userCharacteristic.valuesList.length,
          itemBuilder: (BuildContext context, int indexInside) {
            return CheckboxListTile(
                title: Text(widget.userCharacteristic
                    .valuesList[indexInside]
                    .values
                    .first),
                value:widget.userCharacteristic
                        .valuesList[indexInside]
                        .keys
                        .first ==
                    userCharacteristicsList[index].characteristicValueIndex,
                onChanged: (value) {
                  userCharacteristicsList[index].userHasValue = value as bool;

                  userCharacteristicsList[index].characteristicValueIndex =
                      indexInside;
                  userCharacteristicsList[index].setCharacteristicName();

                  print(index);

                  setState(() {});
                });
          }),
    );
    ;
  }
}*/
