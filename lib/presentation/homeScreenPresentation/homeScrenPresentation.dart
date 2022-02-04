import 'package:citasnuevo/presentation/homeScreenPresentation/Screens/HomeScreen.dart';
import 'package:flutter/widgets.dart';

import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/usecases/HomeScreenUseCases/homeScreenUseCases.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:citasnuevo/presentation/presentationDef.dart';

class HomeScreenPresentation extends ChangeNotifier implements Presentation {
  FetchProfilesUseCases fetchProfilesUseCases;
  RateProfileUseCases rateProfileUseCases;
  ReportUserUseCase reportUserUseCase;
  ProfileListState _profileListState = ProfileListState.empty;
  ReportSendingState _reportSendingState = ReportSendingState.notSended;

  List<Profile> profilesList = [];
  HomeScreenPresentation({
    required this.reportUserUseCase,
    required this.fetchProfilesUseCases,
    required this.rateProfileUseCases,
  });
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

  void sendReport(
      {required String idReporter,
      required String idUserReported,
      required String reportDetails}) async {
    reportSendidnState = ReportSendingState.sending;
    var result = await reportUserUseCase
        .call(ReportParams(idReporter, idUserReported, reportDetails));

    result.fold((fail) {
      reportSendidnState = ReportSendingState.error;
    }, (succes) {
      reportSendidnState = ReportSendingState.sended;
    });
  }

  void sendReaction(
      double reactionValue, int listIndex, BoxConstraints constraints) async {
    Profile removedProfile = profilesList.removeAt(listIndex);
    HomeAppScreen.profilesKey.currentState?.removeItem(
        listIndex,
        (context, animation) => ProfileWidget(
              profile: removedProfile,
              boxConstraints: constraints,
              listIndex: listIndex,
            ),
        duration: Duration(milliseconds: 300));
    var result = await rateProfileUseCases.call(
        RatingParams(rating: reactionValue, profileId: removedProfile.id));
    result.fold((failure) {
      //Show error
    }, (succes) {
      //do Nothing
    });
    if (profilesList.isEmpty) {
      profileListState = ProfileListState.empty;
    }
  }

  void getProfiles() async {
    showLoadingDialog();

    var fetchedList = await fetchProfilesUseCases
        .call(const GetUserParams(loginType: LoginType.facebook));

    fetchedList.fold((fail) {
      profileListState = ProfileListState.error;
    }, (list) {
      for (int i = 0; i < list.length; i++) {
        profilesList.insert(i, list[i]);
        HomeAppScreen.profilesKey.currentState?.insertItem(i);
      }
      profileListState = ProfileListState.ready;
    });
  }

  @override
  void showErrorDialog(String errorLog) {
    // TODO: implement showErrorDialog
  }
  @override
  void showLoadingDialog() {
    profileListState = ProfileListState.loading;
    // TODO: implement showLoadingDialog
  }
}
