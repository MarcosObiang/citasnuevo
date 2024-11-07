import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../../ApplicationSettings/appSettingsPresentation/appSettingsScreen.dart';
import '../../../../Utils/routes.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../../core/params_types/params_and_types.dart';
import '../Widgets/profileWidget.dart';
import '../homeScrenPresentation.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class HomeAppScreen extends StatefulWidget {
  static const routeName = '/HomeAppScreen';

  static final GlobalKey<AnimatedListState> profilesKey = GlobalKey();
  static BoxConstraints boxConstraintsProfileWidget = BoxConstraints();
  @override
  State<StatefulWidget> createState() {
    return _HomeAppScreenState();
  }
}

class _HomeAppScreenState extends State<HomeAppScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  AppLifecycleState appLifecycleState = AppLifecycleState.resumed;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.homeScreenPresentation,
      child: Consumer<HomeScreenPresentation>(builder: (BuildContext context,
          HomeScreenPresentation homeScreenPresentation, Widget? child) {
        return LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          HomeAppScreen.boxConstraintsProfileWidget = constraints;
          return Stack(
            children: [
              Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(10),
                          topLeft: Radius.circular(10))),
                  height: constraints.maxHeight,
                  width: constraints.maxWidth,
                  child: homeScreenPresentation.profileListState ==
                          ProfileListState.error
                      ? serverError(homeScreenPresentation)
                      : homeScreenPresentation.profileListState ==
                              ProfileListState.ready
                          ? profileListLoaded(
                              homeScreenPresentation, constraints)
                          : homeScreenPresentation.profileListState ==
                                  ProfileListState.loading
                              ? loadingProfiles()
                              : homeScreenPresentation.profileListState ==
                                      ProfileListState.location_denied
                                  ? locationDeniedDialog(homeScreenPresentation)
                                  : homeScreenPresentation.profileListState ==
                                          ProfileListState
                                              .location_forever_denied
                                      ? locationDeniedForeverDialog(
                                          homeScreenPresentation)
                                      : homeScreenPresentation
                                                  .profileListState ==
                                              ProfileListState.location_disabled
                                          ? locationServicesDisabledDialog(
                                              homeScreenPresentation)
                                          : homeScreenPresentation
                                                      .profileListState ==
                                                  ProfileListState
                                                      .profile_not_visible
                                              ? invisibleProfileDialog(
                                                  homeScreenPresentation,
                                                  context)
                                              : homeScreenPresentation
                                                          .profileListState ==
                                                      ProfileListState
                                                          .location_status_unknown
                                                  ? unableToDetermineLocationStatus(
                                                      homeScreenPresentation)
                                                  : noMoreProfilesDialog(
                                                      homeScreenPresentation,
                                                      context)),
            ],
          );
        });
      }),
    );
  }

  Container locationDeniedDialog(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.my_location_outlined,
            color: Theme.of(context).colorScheme.tertiary,
            size: 90.sp,
          ),
          Text(
            AppLocalizations.of(context)!.home_screen_location_acess_message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          FilledButton(
              onPressed: () {
                homeScreenPresentation.requestPermission();
              },
              child: Text(AppLocalizations.of(context)!
                  .home_screen_location_grant_permission))
        ],
      ),
    ));
  }

  Container locationDeniedForeverDialog(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!
                .home_screen_location_denied_message_go_to_settings_to_give_permission,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.openLocationSettings();
              },
              icon: Icon(Icons.settings),
              label: Text(AppLocalizations.of(context)!
                  .home_screen_location_go_to_settings_button)),
          Text(
            AppLocalizations.of(context)!
                .home_screen_location_message_if_permission_given_try_again,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.try_again))
        ],
      ),
    ));
  }

  Container unableToDetermineLocationStatus(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!
                .home_screen_location_message_could_not_deterine_location_settings,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          FilledButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.try_again))
        ],
      ),
    ));
  }

  Container locationServicesDisabledDialog(
      HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.home_screen_location_services_disabled,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        ElevatedButton(
            onPressed: () {
              Geolocator.openLocationSettings();
            },
            child: Text(AppLocalizations.of(context)!
                .home_screen_enable__location_button)),
        Text(
          AppLocalizations.of(context)!
              .home_screen_location_try_if_location_is_enabled,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        ElevatedButton.icon(
            onPressed: () {
              homeScreenPresentation.getProfiles();
            },
            icon: Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.try_again))
      ],
    ));
  }

  Container noMoreProfilesDialog(
      HomeScreenPresentation homeScreenPresentation, BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.home_screen_no_profiles_found_message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          FilledButton(
              onPressed: () {
                Navigator.push(context, GoToRoute(page: AppSettingsScreen()));
              },
              child: Text(AppLocalizations.of(context)!
                  .home_screen_change_filters_button_text)),
          TextButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.try_again))
        ],
      ),
    ));
  }

  Container invisibleProfileDialog(
      HomeScreenPresentation homeScreenPresentation, BuildContext context) {
    return Container(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.my_location_outlined,
            color: Colors.white,
            size: 90.sp,
          ),
          Text(
            AppLocalizations.of(context)!.home_screen_invisible_profile_dialog,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ElevatedButton(
              onPressed: () {
                homeScreenPresentation.restart();

                Navigator.push(context, GoToRoute(page: AppSettingsScreen()));
              },
              child: Text(AppLocalizations.of(context)!
                  .home_screen_location_go_to_settings_button)),
          Text(
            AppLocalizations.of(context)!
                .home_screen_invisible_profile_dialog_try_again,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ElevatedButton.icon(
              onPressed: () {
                homeScreenPresentation.getProfiles();
              },
              icon: Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context)!.try_again))
        ],
      ),
    ));
  }

  Container serverError(HomeScreenPresentation homeScreenPresentation) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.home_screen_server_error,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        FilledButton.icon(
            style: ButtonStyle(),
            onPressed: () async {
              homeScreenPresentation.restart();
            },
            icon: Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.try_again))
      ],
    ));
  }

  Column loadingProfiles() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 200.h,
          width: 200.h,
          child: LoadingIndicator(indicatorType: Indicator.circleStrokeSpin),
        ),
        Text(AppLocalizations.of(context)!.loading)
      ],
    );
  }

  Widget profileListLoaded(HomeScreenPresentation homeScreenPresentation,
      BoxConstraints constraints) {
    return AnimatedList(
        scrollDirection: Axis.horizontal,
        physics: NeverScrollableScrollPhysics(),
        initialItemCount:
            homeScreenPresentation.homeScreenController.profilesList.length,
        key: HomeAppScreen.profilesKey,
        itemBuilder:
            (BuildContext context, int index, Animation<double> animation) {
          return FadeTransition(
              opacity: animation,
              child: ProfileWidget(
                boxConstraints: constraints,
                profile: homeScreenPresentation
                    .homeScreenController.profilesList[index],
                needRatingWidget: true,
                showDistance: true,
                listIndex: index,
              ));
        });
  }
}
