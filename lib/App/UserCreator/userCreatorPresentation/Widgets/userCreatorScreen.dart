import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../Settings/settingsInputScreen.dart';
import '../../../UserSettings/UserSettingsEntity.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../userCreatorPresentation.dart';
import 'picturesScreen.dart';
import 'promotionalCodeScreen.dart';
import 'userBioInput.dart';
import 'userCharacteristicsInput.dart';
import 'userNameInputScreen.dart';
import 'userSexPreferences.dart';
import 'userUnitSystem.dart';


class UserCreatorScreenArgs {
  String userName;
  String email;
  UserCreatorScreenArgs({required this.userName, required this.email});
}

class UserCreatorScreen extends StatefulWidget {
  static const routeName = '/UserCreatorScreen';

  String? userName;

  UserCreatorScreen();

  @override
  State<UserCreatorScreen> createState() => _UserCreatorScreenState();
}

class _UserCreatorScreenState extends State<UserCreatorScreen> {
  PageController _pageController = new PageController();
  int _ageValue = 18;
  late TextEditingController _userNameTextEditingController;
  late List<UserPicture> userPicturesList = [];
  late List<UserCharacteristic> userCharacteristicsListEditing = [];

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
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          PromotionalCodeScreen(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          UserNameInput(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          UserSexPreferences(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          UserCharacteristicEditScreen(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          UserPicturesInput(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          UserBioInput(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          UserUnitSystem(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          ),
                          SettingsSecreenInput(
                            pageController: _pageController,
                            userCreatorPresentation: userCreatorPresentation,
                          )
                        ],
                      )
                    : userCreatorPresentation.getUserCreatorScreenState ==
                            UserCreatorScreenState.LOADING
                        ? Container(
                            child: Column(
                              children: [
                                LoadingIndicator(
                                    indicatorType: Indicator.ballBeat),
                                Text(AppLocalizations.of(context)!.userCreatorScreen_loading),
                              ],
                            ),
                          )
                        : userCreatorPresentation.getUserCreatorScreenState ==
                                UserCreatorScreenState.ERROR
                            ? Container(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(AppLocalizations.of(context)!.userCreatorScreen_createUserError),
                                    ElevatedButton.icon(
                                        onPressed: () {
                                          userCreatorPresentation.createUser();
                                        },
                                        icon: Icon(Icons.warning),
                                        label: Text(AppLocalizations.of(context)!.userCreatorScreen_errors))
                                  ],
                                ),
                              )
                            : Container(
                                child: userCreatorPresentation
                                            .getLocationTypeError ==
                                        LocationErrorType
                                            .LOCATION_PERMISSION_DENIED_FOREVER
                                    ? locationDeniedForeverScreen(
                                        userCreatorPresentation)
                                    : userCreatorPresentation
                                                .getLocationTypeError ==
                                            LocationErrorType
                                                .LOCATION_SERVICE_DISABLED
                                        ? locationserviceDisbledScreen(
                                            userCreatorPresentation)
                                        : userCreatorPresentation
                                                    .getLocationTypeError ==
                                                LocationErrorType
                                                    .LOCATION_PERMISSION_DENIED
                                            ? locationPermissionDeniedScreen(
                                                userCreatorPresentation)
                                            : userCreatorPresentation
                                                        .getLocationTypeError ==
                                                    LocationErrorType
                                                        .UNABLE_TO_DETERMINE_LOCATION_STATUS
                                                ? unableToDetermineLocationStatus(
                                                    userCreatorPresentation)
                                                : Container(),
                              ));
          }),
        ),
      ),
    );
  }

  Widget unableToDetermineLocationStatus(
      UserCreatorPresentation userCreatorPresentation) {
    return Padding(
      padding: EdgeInsets.all(50.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error),
              Text(AppLocalizations.of(context)!.userCreatorScreen_error),
            ],
          ),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationNeeded),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationSettings),
          Divider(
            height: 50.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_hottyPermission),
          Divider(
            height: 50.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_tryAgain),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      userCreatorPresentation.openLocationSettings();
                    },
                    icon: Icon(Icons.settings),
                    label: Text(AppLocalizations.of(context)!.userCreatorScreen_goToSettings)),
                ElevatedButton.icon(
                    onPressed: () {
                      userCreatorPresentation.createUser();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.userCreatorScreen_tryAgain))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget locationPermissionDeniedScreen(
      UserCreatorPresentation userCreatorPresentation) {
    return Padding(
      padding: EdgeInsets.all(50.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error),
              Text(AppLocalizations.of(context)!.userCreatorScreen_error),
            ],
          ),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationNeeded),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_hottyPermissionNeeded),
          ElevatedButton.icon(
              onPressed: () {
                userCreatorPresentation.requestPermission();
              },
              icon: Icon(Icons.location_pin),
              label: Text(AppLocalizations.of(context)!.userCreatorScreen_givePermission))
        ],
      ),
    );
  }

  Widget locationserviceDisbledScreen(
      UserCreatorPresentation userCreatorPresentation) {
    return Padding(
      padding: EdgeInsets.all(50.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error),
              Text(AppLocalizations.of(context)!.userCreatorScreen_error),
            ],
          ),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationNeeded),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationNeededDevice),
          ElevatedButton.icon(
              onPressed: () {
                userCreatorPresentation.openLocationSettings();
              },
              icon: Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)!.userCreatorScreen_activateLocation))
        ],
      ),
    );
  }

  Widget locationDeniedForeverScreen(
      UserCreatorPresentation userCreatorPresentation) {
    return Padding(
      padding: EdgeInsets.all(50.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error),
              Text(AppLocalizations.of(context)!.userCreatorScreen_error),
            ],
          ),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationNeeded),
          Divider(
            height: 100.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_locationSettings),
          Divider(
            height: 50.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_hottyPermission),
          Divider(
            height: 50.h,
            color: Colors.white,
          ),
          Text(AppLocalizations.of(context)!.userCreatorScreen_tryAgain),
          Align(
            alignment: Alignment.center,
            child: Column(
              children: [
                ElevatedButton.icon(
                    onPressed: () {
                      userCreatorPresentation.openLocationSettings();
                    },
                    icon: Icon(Icons.settings),
                    label: Text(AppLocalizations.of(context)!.userCreatorScreen_goToSettings)),
                ElevatedButton.icon(
                    onPressed: () {
                      userCreatorPresentation.createUser();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context)!.userCreatorScreen_tryAgain))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
