import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../UserSettings/UserSettingsEntity.dart';
import '../userCreatorPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class UserCharacteristicEditScreen extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  UserCharacteristicEditScreen(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<UserCharacteristicEditScreen> createState() =>
      _UserCharacteristicEditScreenState();
}

class _UserCharacteristicEditScreenState
    extends State<UserCharacteristicEditScreen> {
          ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: EdgeInsets.only(left: 40.w, right: 40.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
                flex: 2,
                fit: FlexFit.loose,
                child: Container(
                    child: Text(
                  AppLocalizations.of(context)!.userCharacteristicsInput_quickData,
                  style: GoogleFonts.lato(fontSize: 70.sp),
                ))),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Divider(
                  color: Colors.transparent,
                )),
            Flexible(
              flex: 10,
              fit: FlexFit.loose,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: ListView.builder(
                        itemCount: widget.userCreatorPresentation
                            .getUserCreatorEntity.userCharacteristics.length,
                            controller: scrollController,
                        itemBuilder: (BuildContext context, int index) {
                          return profileCharacteristicUserCreator(
                              widget
                                  .userCreatorPresentation
                                  .getUserCreatorEntity
                                  .userCharacteristics[index],
                              index);
                        }),
                  ),
                ),
              ),
            ),
            Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Divider(
                  color: Colors.transparent,
                )),
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                    Text(
                    "4/8",
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
                          label: Text(AppLocalizations.of(context)!.userCharacteristicsInput_back)),
                      ElevatedButton.icon(
                          onPressed: () => widget.pageController.nextPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut),
                          icon: Icon(Icons.arrow_forward),
                          label: Text(AppLocalizations.of(context)!.userCharacteristicsInput_next)),
                    ],
                  ),
                   ElevatedButton.icon(
                              onPressed: () => widget.userCreatorPresentation.logOut(),
                              icon: Icon(Icons.cancel),
                              label: Text(AppLocalizations.of(context)!.userCharacteristicsInput_exit))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget profileCharacteristicUserCreator(
      UserCharacteristic userCharacteristic, int index) {
    return GestureDetector(
      onTap: () {
        characteristicValuesEditor(
            userCharacteristicsList: widget.userCreatorPresentation
                .getUserCreatorEntity.userCharacteristics,
            index: index);

        /*   Navigator.push(
            context,
            GoToRoute(
                page: ProfileCharacteristicCreatorEditing(
              userCharacteristic: widget.userCreatorPresentation
                  .getUserCreatorEntity.userCharacteristics,
              currentIndex: index,
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
                    child: Icon(userCharacteristic.characteristicIcon)),
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userCharacteristic.characteristicName.call(),
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.bold)),
                        Text(userCharacteristic.characteristicValue.call()),
                      ],
                    ),
                  ),
                ),
                Flexible(
                    flex: 2,
                    fit: FlexFit.tight,
                    child: Icon(
                      Icons.check_box,
                      color: userCharacteristic.characteristicValueIndex > 0
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

  Future characteristicValuesEditor({
    required List<UserCharacteristic> userCharacteristicsList,
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
                          userCharacteristicsList[index].characteristicName.call(),
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
                                    .first),
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
                                  widget.userCreatorPresentation
                                      .updateUserCharacteristicListState(
                                          userCharacteristicsList);

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
                        label: Text(AppLocalizations.of(context)!.userCharacteristicsInput_back)),
                  ),
                ],
              ),
            );
          });
        });
  }
}
