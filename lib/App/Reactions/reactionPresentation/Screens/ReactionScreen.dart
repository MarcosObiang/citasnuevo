import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../Widgets/RevealingCard.dart';
import '../reactionPresentation.dart';

class ReactionScreen extends StatefulWidget {
  static const routeName = '/ReactionScreen';

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
        return SafeArea(
            child: Stack(
          children: [
            Container(
              child: Column(
                children: [
                  Center(
                    child: Container(
                      height: kBottomNavigationBarHeight * 1.5,
                      width: ScreenUtil.defaultSize.width,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 6,
                            fit: FlexFit.loose,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Ultimas reacciones   ${(reactionPresentation.getAverage.toStringAsFixed(0))} %",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.apply(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface),
                                  ),
                                  LinearPercentIndicator(
                                    lineHeight: 70.h,
                                    percent:
                                        reactionPresentation.getAverage / 100,
                                    animation: true,
                                    progressColor:
                                        reactionPresentation.getAverage < 33
                                            ? Colors.red
                                            : reactionPresentation.getAverage >
                                                        33 &&
                                                    reactionPresentation
                                                            .getAverage <
                                                        66
                                                ? Colors.amber
                                                : Colors.green,
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .surfaceVariant,
                                    barRadius: Radius.circular(10),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.loose,
                            child: Container(
                              height: 200.h,
                              width: 200.h,
                              child: reactionPresentation.getAverage < 33
                                  ? SvgPicture.asset(
                                      "assets/passEmoji.svg",
                                      fit: BoxFit.fill,
                                    )
                                  : reactionPresentation.getAverage > 33 &&
                                          reactionPresentation.getAverage < 66
                                      ? SvgPicture.asset(
                                          "assets/maybeEmoji.svg",
                                          fit: BoxFit.fill,
                                        )
                                      : SvgPicture.asset(
                                          "assets/likeEmojy.svg",
                                          fit: BoxFit.fill,
                                        ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: kBottomNavigationBarHeight,
                    width: ScreenUtil.defaultSize.width,
                    child: Center(
                      child: Text(
                        "Reacciones   ${reactionPresentation.reactionsController.reactions.length}",
                        style: Theme.of(context).textTheme.titleMedium?.apply(
                            color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(builder:
                        (BuildContext context, BoxConstraints constraints) {
                      ReactionScreen.boxConstraints = constraints;
                      return Stack(
                        children: [
                          Container(
                              height: constraints.biggest.height,
                              width: constraints.biggest.width,
                              child: reactionPresentation
                                          .getReactionListState ==
                                      ReactionListState.ready
                                  ? AnimatedList(
                                      physics: NeverScrollableScrollPhysics(),
                                      key: ReactionScreen.reactionsListKey,
                                      initialItemCount: reactionPresentation
                                          .reactionsController.reactions.length,
                                      itemBuilder: (BuildContext context,
                                          int index,
                                          Animation<double> animation) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 100.h,
                                              left: 50.w,
                                              right: 50.w,
                                              top: 50.h),
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
                                                width: 200.h,
                                                child: LoadingIndicator(
                                                    colors: [
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primary
                                                    ],
                                                    indicatorType: Indicator
                                                        .circleStrokeSpin),
                                              ),
                                              Text("Cargando",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.apply(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface))
                                            ],
                                          ),
                                        )
                                      : reactionPresentation
                                                  .getReactionListState ==
                                              ReactionListState.error
                                          ? Container(
                                              height: 300.h,
                                              width: 300.h,
                                              child: Padding(
                                                padding: EdgeInsets.all(60.w),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons.error,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error,
                                                        ),
                                                        Text(
                                                          "Error",
                                                          style: Theme.of(
                                                                  context)
                                                              .textTheme
                                                              .headlineSmall
                                                              ?.apply(
                                                                  fontWeightDelta:
                                                                      1),
                                                        ),
                                                      ],
                                                    ),
                                                    Text(
                                                      "No se han podido cargar tus reacciones, intentalo de nuevo y si el problema continua contacta con nosotros",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.apply(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onSurface),
                                                    ),
                                                    Divider(
                                                      color: Colors.transparent,
                                                      height: 100.h,
                                                    ),
                                                    FilledButton(
                                                        onPressed: () {
                                                          reactionPresentation
                                                              .restart();
                                                        },
                                                        child: Text(
                                                            "Intentar de nuevo")),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : GestureDetector(
                                              onTap: () {
                                                reactionPresentation
                                                    .revealReaction(
                                                        reactionId:
                                                            "reactionId");
                                              },
                                              child: Container(
                                                child: Center(
                                                    child: Text(
                                                  "Lista vacia",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.apply(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface),
                                                )),
                                              ),
                                            )),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
            reactionPresentation.getAdShowingState == AdShowingState.adLoading
                ? Container(
                    width: ScreenUtil().screenWidth,
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withAlpha(240),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        Container(
                          height: 200.h,
                          width: 200.h,
                          child: LoadingIndicator(
                              indicatorType: Indicator.circleStrokeSpin,
                              colors: [
                                Theme.of(context).colorScheme.onSecondary
                              ]),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 50.h,
                        ),
                        Text(
                          "Cargando anuncio",
                          style: Theme.of(context).textTheme.bodyMedium?.apply(
                              color: Theme.of(context).colorScheme.onSecondary),
                        )
                      ],
                    ),
                  )
                : reactionPresentation.getAdShowingState ==
                        AdShowingState.errorLoadingAd
                    ? Container(
                        width: ScreenUtil().screenWidth,
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.errorContainer,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                Text(
                                  "Error al cargar el auncio",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.apply(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onErrorContainer),
                                ),
                              ],
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 50.h,
                            ),
                            ElevatedButton(
                                onPressed: () =>
                                    reactionPresentation.setAdShowingState =
                                        AdShowingState.adNotshowing,
                                child: Text(
                                  "Continuar",
                                ))
                          ],
                        ),
                      )
                    : Container(),
          ],
        ));
      }),
    );
  }
}
