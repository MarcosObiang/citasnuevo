import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/domain/usecases/HomeScreenUseCases/homeScreenUseCases.dart';
import 'package:citasnuevo/main.dart';
import 'package:citasnuevo/presentation/HomeScreenPresentation/presentationDef.dart';
import 'package:flutter/widgets.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';

class HomeScreenPresentation extends ChangeNotifier implements Presentation {
  FetchProfilesUseCases fetchProfilesUseCases;
  ProfileListState _profileListState = ProfileListState.empty;
  List<Profile> profiles = [];
  HomeScreenPresentation({
    required this.fetchProfilesUseCases,
  });
  get profileListState => this._profileListState;
  set profileListState(profileState) {
    _profileListState = profileState;
    notifyListeners();
  }
  void getProfiles() async {
    var fetchedList = await fetchProfilesUseCases
        .call(const GetUserParams(loginType: LoginType.facebook));
    fetchedList.fold((fail) {
      profileListState = ProfileListState.error;
    }, (list) {
      profiles = list;
      for (int i = 0; i < list.length; i++) {
        profiles.insert(i, list[i]);
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
    // TODO: implement showLoadingDialog
  }}