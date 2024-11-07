import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../userCreatorPresentation.dart';

// ignore: must_be_immutable
class UserSexPreferences extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  UserSexPreferences(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<UserSexPreferences> createState() => _UserSexPreferencesState();
}

class _UserSexPreferencesState extends State<UserSexPreferences> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppLocalizations.of(context)!.userSexPreferences_yourSex,
              style: GoogleFonts.lato(fontSize: 80.sp),
            ),
            CheckboxListTile(
              value: widget
                  .userCreatorPresentation.getUserCreatorEntity.isUserWoman==false,
              onChanged: (value) {
                if (value != null) {
                  widget.userCreatorPresentation.setUserSex(isUserWoman: false);
                }
              },
              title: Text(AppLocalizations.of(context)!.userSexPreferences_male),
            ),
            CheckboxListTile(
              value: widget.userCreatorPresentation.getUserCreatorEntity
                      .isUserWoman ==
                  true,
              onChanged: (value) {
                if (value != null) {
                  widget.userCreatorPresentation.setUserSex(isUserWoman: true);
                }
              },
              title: Text(AppLocalizations.of(context)!.userSexPreferences_female),
            ),
            Text(
              AppLocalizations.of(context)!.userSexPreferences_meInteresan,
              style: GoogleFonts.lato(fontSize: 60.sp),
            ),
            CheckboxListTile(
              value: widget.userCreatorPresentation.getUserCreatorEntity
                          .showWoman ==
                      false &&
                  widget.userCreatorPresentation.getUserCreatorEntity
                          .showBothSexes ==
                      false,
              onChanged: (value) {
                if (value != null) {
                  widget.userCreatorPresentation.updateUserDatingPreference(
                      showBothSexes: false, showWoman: false);
                }
              },
              title: Text(AppLocalizations.of(context)!.userSexPreferences_hombres),
            ),
            CheckboxListTile(
              value: widget.userCreatorPresentation.getUserCreatorEntity
                          .showWoman ==
                      true &&
                  widget.userCreatorPresentation.getUserCreatorEntity
                          .showBothSexes ==
                      false,
              onChanged: (value) {
                if (value != null) {
                  widget.userCreatorPresentation.updateUserDatingPreference(
                      showBothSexes: false, showWoman: true);
                }
              },
              title: Text(AppLocalizations.of(context)!.userSexPreferences_mujeres),
            ),
            CheckboxListTile(
              value: widget
                  .userCreatorPresentation.getUserCreatorEntity.showBothSexes,
              onChanged: (value) {
                if (value != null) {
                  widget.userCreatorPresentation.updateUserDatingPreference(
                      showBothSexes: true, showWoman: true);
                }
              },
              title: Text(AppLocalizations.of(context)!.userSexPreferences_ambos),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,

              children: [
                Text(
                  "3/8",
                  style: GoogleFonts.lato(fontSize: 60.sp),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                        onPressed: () {
                          widget.pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                        label: Text(AppLocalizations.of(context)!.userSexPreferences_atras)),
                    ElevatedButton.icon(
                        onPressed: () => widget.pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut),
                        icon: Icon(Icons.arrow_forward_ios),
                        label: Text(AppLocalizations.of(context)!.userSexPreferences_siguiente)),
                  ],
                ),
                ElevatedButton.icon(
                              onPressed: () => widget.userCreatorPresentation.logOut(),
                              icon: Icon(Icons.cancel),
                              label: Text(AppLocalizations.of(context)!.userSexPreferences_salir))
              ],
            )
          ],
        ),
      ),
    );
  }
}
