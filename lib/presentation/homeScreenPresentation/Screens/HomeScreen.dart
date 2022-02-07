import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_indicator/loading_indicator.dart';

class HomeAppScreen extends ConsumerStatefulWidget {
  static final GlobalKey<AnimatedListState> profilesKey = GlobalKey();
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeAppScreenState();
}

class _HomeAppScreenState extends ConsumerState<HomeAppScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
 

  }

  @override
  Widget build(BuildContext context) {
    var data = ref.watch(Dependencies.homeScreenProvider);
    return Material(
      color: Colors.lightBlue,
      child: SafeArea(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Container(
            color: Colors.black,
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                if (data.profilesList.length > 0) ...[
                  AnimatedList(
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      initialItemCount: data.profilesList.length,
                      key: HomeAppScreen.profilesKey,
                      itemBuilder: (BuildContext context, int index,
                          Animation<double> animation) {
                        return FadeTransition(
                            opacity: animation,
                            child: ProfileWidget(
                              boxConstraints: constraints,
                              profile: data.profilesList[index],
                              listIndex: index,
                            ));
                      })
                ],
                if (data.profilesList.length == 0) ...[
                  Container(
                      height: constraints.maxHeight,
                      width: constraints.maxWidth,
                      color: Colors.deepPurple,
                      child: data.profileListState == ProfileListState.loading
                          ? LoadingIndicator(
                              indicatorType: Indicator.audioEqualizer)
                          : Container()),
                ],
                ElevatedButton(
                  onPressed: () {
                    ref.read(Dependencies.homeScreenProvider).getProfiles();
                  },
                  child: Text("SolicitarPerfiles"),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
