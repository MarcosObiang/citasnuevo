import 'dart:math';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ReactionEntity.dart';
import 'package:citasnuevo/presentation/reactionPresentation/reactionPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
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
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      Dependencies.reactionPresentation.initializeValues();
      Dependencies.reactionPresentation.initializeDataReciever();
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
                          Text("${reactionPresentation.getCoins}"),
                          Icon(LineAwesomeIcons.gem)
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: kBottomNavigationBarHeight,
                  width: ScreenUtil.defaultSize.width,
                  child: Text(
                      "Media:${reactionPresentation.getAverage.toStringAsFixed(1)}"),
                ),
                Container(
                  height: kBottomNavigationBarHeight,
                  width: ScreenUtil.defaultSize.width,
                  child: Text(
                      "Reacciones:${reactionPresentation.reactionsController.reactions.length}"),
                ),
                Expanded(
                  child: LayoutBuilder(builder:
                      (BuildContext context, BoxConstraints constraints) {
                    ReactionScreen.boxConstraints = constraints;
                    return Container(
                        height: constraints.biggest.height,
                        width: constraints.biggest.width,
                        child: reactionPresentation
                                    .reactionsController.reactions.length >
                                0
                            ? AnimatedList(
                                key: ReactionScreen.reactionsListKey,
                                initialItemCount: reactionPresentation
                                    .reactionsController.reactions.length,
                                itemBuilder: (BuildContext context, int index,
                                    Animation<double> animation) {
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ReactionCard(
                                        reaction: reactionPresentation
                                            .reactionsController
                                            .reactions[index],
                                        boxConstraints: constraints,
                                        index: index,
                                        animation: animation),
                                  );
                                })
                            : Container());
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

enum RevealingAnimationState { notTurning, turned, turning }

class ReactionCard extends StatefulWidget {
  final BoxConstraints boxConstraints;
  final int index;
  final Animation<double> animation;
  final Reaction reaction;

  const ReactionCard(
      {required this.boxConstraints,
      required this.index,
      required this.animation,
      required this.reaction});

  @override
  _ReactionCardState createState() => _ReactionCardState();
}

class _ReactionCardState extends State<ReactionCard>
    with TickerProviderStateMixin {
  late AnimationController _revealingAnimation;
  bool showCard = false;
  Curve revealingAnimationcurve = Curves.ease;
  double _revealingRotationValue = 0;
  RevealingAnimationState revealingAnimationState =
      RevealingAnimationState.notTurning;

  @override
  void initState() {
    super.initState();
    _revealingAnimation = AnimationController(
        vsync: this, duration: Duration(milliseconds: 500))
      ..addListener(() {
        _revealingRotationValue =
            revealingAnimationcurve.transform(_revealingAnimation.value) * pi;
      })
      ..addStatusListener((status) {});

    if (widget.reaction.reactionRevealigState ==
        ReactionRevealigState.revealed) {
      _revealingRotationValue = pi;
      revealingAnimationState = RevealingAnimationState.turned;
      showCard = true;
    } else {
      _revealingRotationValue = 0;
      revealingAnimationState = RevealingAnimationState.notTurning;
      showCard = false;
    }
  }

  @override
  void didUpdateWidget(covariant ReactionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_revealingAnimation.status == AnimationStatus.forward) {
      revealingAnimationState = RevealingAnimationState.turning;
    }
    if ((_revealingAnimation.status == AnimationStatus.completed ||
            _revealingAnimation.status == AnimationStatus.dismissed) &&
        widget.reaction.reactionRevealigState ==
            ReactionRevealigState.revealed &&
        revealingAnimationState == RevealingAnimationState.turned) {
      _revealingRotationValue = pi;
      showCard = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _revealingAnimation.dispose();
  }

  var reactionTimeFormat = new DateFormat("HH:mm:ss");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ReactionRevealigState>(
        stream: widget.reaction.reactionRevealedStateStream.stream,
        initialData: widget.reaction.reactionRevealigState,
        builder:
            (BuildContext context, AsyncSnapshot<ReactionRevealigState> data) {
          if (widget.reaction.reactionRevealigState ==
                  ReactionRevealigState.revealed &&
              showCard == false) {
            if (_revealingAnimation.isCompleted ||
                _revealingAnimation.isDismissed) {
              WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                _revealingAnimation.reset();
                _revealingAnimation.forward();
                showCard = true;
                setState(() {});
              });
            }

            print("dodsjad");
          }

          return AnimatedBuilder(
              animation: _revealingAnimation,
              builder: (BuildContext context, Widget? child) {
                return FadeTransition(
                  opacity: widget.animation,
                  child: ChangeNotifierProvider.value(
                    value: Dependencies.reactionPresentation,
                    child: Consumer<ReactionPresentation>(builder:
                        (BuildContext context,
                            ReactionPresentation reactionPresentation,
                            Widget? child) {
                      return Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateY(_revealingRotationValue),
                        alignment: FractionalOffset.center,
                        child: Container(
                            color: Colors.deepPurpleAccent,
                            height: widget.boxConstraints.biggest.height,
                            width: widget.boxConstraints.biggest.width,
                            child: _revealingRotationValue < (pi / 2)
                                ? reactionCounter()
                                : Container(
                                    child: Text("Reveladaaaaaa"),
                                  )),
                      );
                    }),
                  ),
                );
              });
        });
  }

  StreamBuilder<int> reactionCounter() {
    return StreamBuilder(
      stream: widget.reaction.secondsRemainingStream.stream,
      initialData: widget.reaction.secondsUntilExpiration,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (widget.reaction.reactionRevealigState ==
            ReactionRevealigState.notRevealed) {
          print("revelando indice${widget.index}");
        }

        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              reactionTimeFormat
                  .format(DateTime(0, 0, 0, 0, 0, snapshot.data as int)),
              style: GoogleFonts.lato(
                  color: Colors.white, fontSize: 90.sp, letterSpacing: 50.w),
            ),
            ElevatedButton(
                onPressed: () {
                  Dependencies.reactionPresentation.reactionRevealed();
                },
                child: Text("Revelar"))
          ],
        ));
      },
    );
  }
}
