import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../../../core/dependencies/dependencyCreator.dart';
import '../../../domain/entities/ReactionEntity.dart';
import '../Screens/ReactionScreen.dart';
import '../reactionPresentation.dart';

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
  Curve revealingAnimationcurve = Curves.easeInOutBack;
  double _revealingRotationValue = 0;
  RevealingAnimationState revealingAnimationState =
      RevealingAnimationState.notTurning;

  bool processing = false;

  @override
  void initState() {
    super.initState();
    _revealingAnimation = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500))
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
    return StreamBuilder<dynamic>(
        stream: widget.reaction.reactionRevealedStateStream.stream,
        initialData: widget.reaction.reactionRevealigState,
        builder: (BuildContext context, AsyncSnapshot<dynamic> data) {
          if (data.data is ReactionRevealigState) {
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
            }
          }
          if (data.data is ReactionAceptingState) {
            WidgetsBinding.instance?.addPostFrameCallback((data) {
              setState(() {});
            });
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
                                : revealedSide(widget.reaction)),
                      );
                    }),
                  ),
                );
              });
        });
  }

  Widget profileInfo({required String name, required String age}) {
    return Container(
        height: kBottomNavigationBarHeight * 1.5,
        width: ReactionScreen.boxConstraints.maxWidth,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                        GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                  ),
                  Text(
                    age,
                    style:
                        GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [],
              )
            ],
          ),
        ));
  }

  StreamBuilder<int> reactionCounter() {
    return StreamBuilder(
      stream: widget.reaction.secondsRemainingStream.stream,
      initialData: widget.reaction.secondsUntilExpiration,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        return Container(
          color: Color.fromARGB(255, 61, 12, 194),
          height: widget.boxConstraints.biggest.height,
          width: widget.boxConstraints.biggest.width,
          child: Center(
              child: widget.reaction.reactionRevealigState !=
                      ReactionRevealigState.revealing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          reactionTimeFormat.format(
                              DateTime(0, 0, 0, 0, 0, snapshot.data as int)),
                          style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 90.sp,
                              letterSpacing: 50.w),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              Dependencies.reactionPresentation.revealReaction(
                                  reactionId: widget.reaction.idReaction);
                            },
                            child: Text("Revelar"))
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingIndicator(
                            indicatorType: Indicator.ballPulseRise),
                        Text("Revelando")
                      ],
                    )),
        );
      },
    );
  }

  Transform revealedSide(Reaction reaction) {
    return Transform(
      transform: Matrix4.identity()..rotateY(pi),
      alignment: FractionalOffset.center,
      child: Stack(
        children: [
          Container(
              width: widget.boxConstraints.maxWidth,
              child: OctoImage(
                fadeInDuration: Duration(milliseconds: 50),
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(reaction.imageUrl),
                placeholderBuilder: OctoPlaceholder.blurHash(reaction.imageHash,
                    fit: BoxFit.cover),
              )),
          profileInfo(name: reaction.name, age: 20.toString()),
          revealedSideButtons(),
          widget.reaction.getReactionAceptingState ==
                  ReactionAceptingState.inProcessAcepting
              ? Container(
                  width: widget.boxConstraints.maxWidth,
                  color: Colors.black,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Creando conversacion",
                          style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 50.sp,
                              letterSpacing: 10.w),
                        ),
                        Container(
                            height: 200.h,
                            child: LoadingIndicator(
                                indicatorType: Indicator.ballPulse)),
                      ],
                    ),
                  ),
                )
              : widget.reaction.getReactionAceptingState ==
                      ReactionAceptingState.inProcessDeclining
                  ? Container(
                      width: widget.boxConstraints.maxWidth,
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Eliminacion reacción",
                              style: GoogleFonts.lato(
                                  color: Colors.white,
                                  fontSize: 50.sp,
                                  letterSpacing: 10.w),
                            ),
                            Container(
                                height: 200.h,
                                child: LoadingIndicator(
                                    indicatorType: Indicator.ballPulse)),
                          ],
                        ),
                      ),
                    )
                  : Container()
        ],
      ),
    );
  }

  Align revealedSideButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
              onPressed: () {
                Dependencies.reactionPresentation.acceptReaction(
                    reactionId: widget.reaction.idReaction,
                    reactionSenderId: widget.reaction.senderId);
              },
              child: Text("Aceptar")),
          ElevatedButton(
              onPressed: () {
                Dependencies.reactionPresentation
                    .rejectReaction(reactionId: widget.reaction.idReaction);
              },
              child: Text("Rechazar"))
        ],
      ),
    );
  }
}