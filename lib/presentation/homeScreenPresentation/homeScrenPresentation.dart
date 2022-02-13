import 'package:citasnuevo/core/common/common_widgets.dart/errorWidget.dart';
import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/domain/controller/homeScreenController.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

class HomeScreenPresentation extends ChangeNotifier implements Presentation {
  ProfileListState _profileListState = ProfileListState.empty;
  ReportSendingState _reportSendingState = ReportSendingState.notSended;
  HomeScreenController homeScreenController;

  HomeScreenPresentation({required this.homeScreenController}) {
    getProfiles();
  }
  get profileListState => this._profileListState;
  set profileListState(profileState) {
    _profileListState = profileState;
    notifyListeners();
  }

  get reportSendidnState => this._reportSendingState;
  set reportSendidnState(reportSendidnState) {
    _reportSendingState = reportSendidnState;
    notifyListeners();
  }

  /// Call this method to report any user profile the user may think it violates the norms of the comunity
  /// 

  void sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails}) async {
    reportSendidnState = ReportSendingState.sending;
    var result = await homeScreenController.sendUserReport(
        idReporter: idReporter,
        reportDetails: reportDetails,
        idUserReported: idUserReported);

    result.fold((fail) {
      reportSendidnState = ReportSendingState.error;
      if (fail is NetworkFailure) {
        showNetworkErrorWidget(startKey.currentContext);
      }
    }, (succes) {
      reportSendidnState = ReportSendingState.sended;
    });
  }

  ///Call this method from widgets to send a reaction to a user

  void sendReaction(
      double reactionValue, int listIndex, BoxConstraints constraints) async {
    Profile removedProfile =
        homeScreenController.removeProfileFromList(profileIndex: listIndex);

    HomeAppScreen.profilesKey.currentState?.removeItem(
        listIndex,
        (context, animation) => ProfileWidget(
              profile: removedProfile,
              boxConstraints: constraints,
              listIndex: listIndex,
            ),
        duration: Duration(milliseconds: 300));

    if (homeScreenController.profilesList.isEmpty) {
      profileListState = ProfileListState.empty;
      getProfiles();
    }
    var result = await homeScreenController.sendRating(
        ratingValue: reactionValue, idProfileRated: removedProfile.id);
    result.fold((failure) {
      if (failure is NetworkFailure) {
        showNetworkErrorWidget(startKey.currentContext);
      }
    }, (succes) {
    });
  }

  void getProfiles() async {
    showLoadingDialog();

    var fetchedList = await homeScreenController.fetchProfileList();

    fetchedList.fold((fail) {
      profileListState = ProfileListState.error;
      if (fail is NetworkFailure) {
        showNetworkErrorWidget(startKey.currentContext);
      }
    }, (succes) {
      for (int a = 0; a < homeScreenController.profilesList.length; a++) {
        HomeAppScreen.profilesKey.currentState?.insertItem(a);
      }

      profileListState = ProfileListState.ready;
    });
  }

  void showErrorDialogs(
      {required String errorName,
      required String errorMessage,
      required BuildContext context}) {
    showDialog(context: context, builder: (context) => NetwortErrorWidget());
  }

  @override
  void showLoadingDialog() {
    profileListState = ProfileListState.loading;
  }

  @override
  void showErrorDialog(
      {required String errorLog,
      required String errorName,
      required BuildContext context}) {
  }

  void showNetworkErrorWidget(BuildContext? context) {
    if (context != null) {
      showDialog(context: context, builder: (context) => NetwortErrorWidget());
    }
  }
}
