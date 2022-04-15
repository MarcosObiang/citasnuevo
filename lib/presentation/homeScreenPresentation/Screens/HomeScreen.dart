import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/NavigationBar.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../../../core/ads_services/Ads.dart';

class HomeAppScreen extends StatefulWidget {
  static final GlobalKey<AnimatedListState> profilesKey = GlobalKey();
    static late final AdvertisingServices advertisingServices;


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomeAppScreenState();
  }
}

class _HomeAppScreenState extends State<HomeAppScreen> {
  @override
  void initState() {
    super.initState();
     HomeAppScreen.advertisingServices = new AdvertisingServices();
    HomeAppScreen.advertisingServices.adsServiceInit();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.homeScreenPresentation,
      child: Consumer<HomeScreenPresentation>(builder: (BuildContext context,
          HomeScreenPresentation homeScreenPresentation, Widget? child) {
        return Material(
          color: Colors.lightBlue,
          child: SafeArea(
            child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: [
                  Container(
                    color: Colors.black,
                    height: constraints.maxHeight,
                    width: constraints.maxWidth,
                    child: Stack(
                      children: [
                        if (homeScreenPresentation
                                .homeScreenController.profilesList.length >
                            0) ...[
                          AnimatedList(
                              scrollDirection: Axis.horizontal,
                              physics: NeverScrollableScrollPhysics(),
                              initialItemCount: homeScreenPresentation
                                  .homeScreenController.profilesList.length,
                              key: HomeAppScreen.profilesKey,
                              itemBuilder: (BuildContext context, int index,
                                  Animation<double> animation) {
                                return FadeTransition(
                                    opacity: animation,
                                    child: ProfileWidget(
                                      boxConstraints: constraints,
                                      profile: homeScreenPresentation
                                          .homeScreenController
                                          .profilesList[index],
                                          needRatingWidget: true,
                                      listIndex: index,
                                    ));
                              })
                        ],
                        if (homeScreenPresentation
                                .homeScreenController.profilesList.length ==
                            0) ...[
                          Container(
                              height: constraints.maxHeight,
                              width: constraints.maxWidth,
                              color: Colors.deepPurple,
                              child: homeScreenPresentation.profileListState ==
                                      ProfileListState.loading
                                  ? LoadingIndicator(
                                      indicatorType: Indicator.audioEqualizer)
                                  : Container()),
                        ],
                        ElevatedButton(
                            onPressed: () =>
                                homeScreenPresentation.getProfiles(),
                            child: Text("Start"))
                      ],
                    ),
                  ),
                  HomeNavigationBar()
                ],
              );
            }),
          ),
        );
      }),
    );
  }
}
