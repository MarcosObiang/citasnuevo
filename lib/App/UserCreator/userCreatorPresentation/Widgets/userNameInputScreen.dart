import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../core/globalData.dart';
import '../userCreatorPresentation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class UserNameInput extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  UserNameInput(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<UserNameInput> createState() => _UserNameInputState();
}

class _UserNameInputState extends State<UserNameInput> {
  TextEditingController _userNameTextEditingController =
      new TextEditingController();

  var dateFormat = DateFormat.yMEd();

  @override
  void initState() {
    super.initState();
    if (GlobalDataContainer.userName.length <= 25) {
      _userNameTextEditingController = new TextEditingController.fromValue(
          TextEditingValue(text: GlobalDataContainer.userName));
      widget.userCreatorPresentation.getUserCreatorEntity.userName =
          GlobalDataContainer.userName;
    } else {
      _userNameTextEditingController = new TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.userNameInputScreen_nameAndAge,
                    style: GoogleFonts.lato(fontSize: 90.sp),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: TextField(
                          controller: _userNameTextEditingController,
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            hintText: AppLocalizations.of(context)!.userNameInputScreen_name,
                          ),
                          maxLength: 25,
                          onChanged: (value) {
                            widget.userCreatorPresentation.getUserCreatorEntity
                                .userName = value;
                          },
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    ageInput(context),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context)!.userNameInputScreen_step,
                    style: GoogleFonts.lato(fontSize: 60.sp),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            widget.userCreatorPresentation.logOut();
                          },
                          icon: Icon(Icons.cancel_outlined),
                          label: Text(AppLocalizations.of(context)!.userNameInputScreen_exit)),
                      ElevatedButton.icon(
                          onPressed: () {
                            bool nameResult = widget.userCreatorPresentation
                                .nameChecker(
                                    userName: widget.userCreatorPresentation
                                        .getUserCreatorEntity.userName);
                            bool ageResult = widget.userCreatorPresentation
                                .ageChecker(
                                    userAge: widget
                                        .userCreatorPresentation
                                        .userCreatorController
                                        .userCreatorEntity
                                        .age);
                            if (nameResult && ageResult) {
                              widget.pageController.nextPage(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut);
                            }
                          },
                          icon: Icon(Icons.arrow_forward),
                          label: Text(AppLocalizations.of(context)!.userNameInputScreen_next)),
                    ],
                  ),
                  ElevatedButton.icon(
                      onPressed: () => widget.pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut),
                      icon: Icon(Icons.arrow_back),
                      label: Text(AppLocalizations.of(context)!.userNameInputScreen_back))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ageInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(30.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(AppLocalizations.of(context)!.userNameInputScreen_birthDate),
                  Divider(
                    color: Colors.transparent,
                    height: 20.h,
                  ),
                  widget.userCreatorPresentation.userCreatorController
                              .userCreatorEntity.date !=
                          null
                      ? Text(
                          dateFormat.format(widget
                              .userCreatorPresentation
                              .userCreatorController
                              .userCreatorEntity
                              .date as DateTime),
                          style: GoogleFonts.lato(fontSize: 50.sp),
                        )
                      : Text("   --   /   --   /   ----   "),
                ],
              ),
              Column(
                children: [
                  Text(AppLocalizations.of(context)!.userNameInputScreen_age),
                  Divider(
                    color: Colors.transparent,
                    height: 20.h,
                  ),
                  widget.userCreatorPresentation.userCreatorController
                              .userCreatorEntity.age !=
                          null
                      ? Text(widget.userCreatorPresentation
                          .userCreatorController.userCreatorEntity.age
                          .toString())
                      : Text("--"),
                ],
              ),
              Divider(
                color: Colors.transparent,
                height: 50.h,
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () async {
              await DatePicker.showDatePicker(context,
                      maxTime: widget.userCreatorPresentation
                          .userCreatorController.userCreatorEntity.minBirthDate)
                  .then((value) {
                if (value != null) {
                  widget.userCreatorPresentation.addDate(dateTime: value);
                }
              });
            },
            label: Text(AppLocalizations.of(context)!.userNameInputScreen_chooseBirthDate),
            icon: Icon(LineAwesomeIcons.calendar),
          )
        ],
      ),
    );
  }
}
