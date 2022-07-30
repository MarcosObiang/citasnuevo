
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/presentation/reactionPresentation/Widgets/RevealingCard.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';

class ReactionScreen extends StatefulWidget {
  static final GlobalKey<AnimatedListState> reactionsListKey = GlobalKey();
  static late BoxConstraints boxConstraints;

  @override
  State<StatefulWidget> createState() {
    return _ReactionScreenState();
  }
}

class _ReactionScreenState extends State<ReactionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Dependencies.reactionPresentation.initializeValues();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.reactionPresentation,
      child: Consumer<ReactionPresentation>(builder: (BuildContext context,
          ReactionPresentation reactionPresentation, Widget? child) {
        return Material(
          child: SafeArea(
              child: Container(
            color: Colors.white,
            child: Column(
              children: [
                AppBar(
                  elevation: 0,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Reacciones"),
                      Row(
                        children: [
                        reactionPresentation.isPremium==false?  Text("${reactionPresentation.getCoins}"):Icon(LineAwesomeIcons.infinity),
                          Icon(LineAwesomeIcons.gem)
                        ],
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    height: kBottomNavigationBarHeight,
                    width: ScreenUtil.defaultSize.width,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                          "Exito: ${(reactionPresentation.getAverage.toStringAsFixed(0))} %",style: GoogleFonts.lato(fontSize:50.sp,fontWeight: FontWeight.bold),),
                    ),
                  ),
                ),
                Container(
                  height: kBottomNavigationBarHeight,
                  width: ScreenUtil.defaultSize.width,
                  child: Center(
                    child: Text(
                        "Reacciones:${reactionPresentation.reactionsController.reactions.length}",style: GoogleFonts.lato(fontSize:60.sp,fontWeight: FontWeight.bold),),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    ReactionScreen.boxConstraints = constraints;
                    return Container(
                        height: constraints.biggest.height,
                        width: constraints.biggest.width,
                        child: reactionPresentation.getReactionListState ==
                                ReactionListState.ready
                            ? AnimatedList(
                              physics: NeverScrollableScrollPhysics(),
                                key: ReactionScreen.reactionsListKey,
                                initialItemCount: reactionPresentation
                                    .reactionsController.reactions.length,
                                itemBuilder: (BuildContext context, int index,
                                    Animation<double> animation) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 100.h,left:50.w,right:50.w,top:50.h),
                                    child: ReactionCard(
                                        reaction: reactionPresentation
                                            .reactionsController
                                            .reactions[index],
                                        boxConstraints: constraints,
                                        index: index,
                                        animation: animation),
                                  );
                                })
                            : reactionPresentation.getReactionListState ==
                                    ReactionListState.loading
                                ? Container(
                                    height: 300.h,
                                    width: 300.h,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 200.h,
                                          width: 200.w,
                                          child: LoadingIndicator(
                                              indicatorType:
                                                  Indicator.semiCircleSpin),
                                        ),
                                        Text("Cargando")
                                      ],
                                    ),
                                  )
                                : reactionPresentation.getReactionListState ==
                                        ReactionListState.error
                                    ? Container(
                                        height: 300.h,
                                        width: 300.h,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  reactionPresentation
                                                      .restart();
                                                },
                                                child: Text("Cargar de nuevo")),
                                            Text("Error")
                                          ],
                                        ),
                                      )
                                    : Container(
                                        child:
                                            Center(child: Text("Lista vacia")),
                                      ));
                  }),
                ),
              ],
            ),
          )),
        );
      }),
    );
  }
}



