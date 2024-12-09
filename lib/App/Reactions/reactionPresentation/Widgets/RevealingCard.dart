import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:citasnuevo/App/controllerDef.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as dev;

import '../../../../Utils/getImageFile.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../../ReactionEntity.dart';
import '../Screens/ReactionScreen.dart';
import '../reactionPresentation.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

class ReactionCard extends StatefulWidget {
  final BoxConstraints boxConstraints;
  final int index;
  final Animation<double> animation;
  final Reaction reaction;
  Uint8List? imageData;

  ReactionCard(
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
  late AnimationController _reactionTypeBadgeAnimationController;
  late final Animation<Color?> colorAnimation;

  bool showCard = false;
  Curve revealingAnimationcurve = Curves.easeInOutBack;
  double _revealingRotationValue = 0;
  RevealingAnimationState revealingAnimationState =
      RevealingAnimationState.notTurning;
  late Future<Uint8List> remitentImageData;
  bool justRevealed = true;

  bool processing = false;

  @override
  void initState() {
    super.initState();
    _revealingAnimation = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000))
      ..addListener(() {
        _revealingRotationValue =
            revealingAnimationcurve.transform(_revealingAnimation.value) * pi;
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
        
            _revealingRotationValue = pi;
            if (widget.reaction.imageUrl["imageData"] != "NOT_AVAILABLE") {
              remitentImageData = ImageFile.getFile(
                  fileId: widget.reaction.imageUrl["imageData"],bucketId: kUserPicturesBucketId);
            }
            showCard = true;
          
        }
      });

    _reactionTypeBadgeAnimationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));

    colorAnimation =
        ColorTween(begin: Colors.transparent, end: Colors.deepPurple.shade800)
            .animate(_reactionTypeBadgeAnimationController);

    _reactionTypeBadgeAnimationController
        .addStatusListener((AnimationStatus animationStatus) {
      if (animationStatus == AnimationStatus.completed) {
        _reactionTypeBadgeAnimationController.repeat(reverse: true);
      }
    });

    if (widget.reaction.reactionRevealigState ==
        ReactionRevealigState.revealed) {
      _revealingRotationValue = pi;
      revealingAnimationState = RevealingAnimationState.turned;
      _reactionTypeBadgeAnimationController.forward();

      if (widget.reaction.imageUrl["imageData"] != "NOT_AVAILABLE") {
        remitentImageData =
            ImageFile.getFile(fileId: widget.reaction.imageUrl["imageData"],bucketId: kUserPicturesBucketId);
      }
      showCard = true;
    } else {
      _revealingRotationValue = 0;
      revealingAnimationState = RevealingAnimationState.notTurning;
      showCard = false;
    }
  }

  @override
  void dispose() {
    _revealingAnimation.dispose();
    _reactionTypeBadgeAnimationController.dispose();
    super.dispose();
  }

  var reactionTimeFormat = new DateFormat("HH:mm:ss");
  var expireTimeFormat = new DateFormat.yMEd().add_Hms();

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
                if (widget.reaction.imageUrl["imageData"] != "NOT_AVAILABLE") {}
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  _revealingAnimation.reset();
                  _revealingAnimation.forward();
                  _reactionTypeBadgeAnimationController.forward();

                  showCard = true;

                  setState(() {});
                });
              }
            }
          }
          if (data.data is ReactionAceptingState) {
            WidgetsBinding.instance.addPostFrameCallback((data) {
              setState(() {});
            });
          }

          return AnimatedBuilder(
              animation: _revealingAnimation,
              builder: (BuildContext context, Widget? child) {
                return SizeTransition(
                  sizeFactor: widget.animation,
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
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            height: widget.boxConstraints.biggest.height -
                                (kBottomNavigationBarHeight),
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

  Widget profileInfo(
      {required String name, required String age, required int reactionValue}) {
    return Container(
        height: kBottomNavigationBarHeight * 1.5,
        width: ReactionScreen.boxConstraints.maxWidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            gradient: LinearGradient(
                colors: [Colors.black54, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
        ));
  }

  StreamBuilder<int> reactionCounter() {
    DateTime reactionExpireTime = DateTime.fromMillisecondsSinceEpoch(
        widget.reaction.reactionExpirationDateInSeconds * 1000);
    return StreamBuilder(
      stream: widget.reaction.secondsRemainingStream.stream,
      initialData: widget.reaction.secondsUntilExpiration,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: widget.boxConstraints.biggest.height,
              width: widget.boxConstraints.biggest.width,
              child: Center(
                  child: widget.reaction.reactionRevealigState !=
                          ReactionRevealigState.revealed
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                                AppLocalizations.of(context)!
                                    .revealing_card_someone_saw_your_profile,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    )),
                            Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: snapshot!.data! > 5
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context).disabledColor,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            snapshot.data! > 5
                                                ? Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        "La oferta termina en",
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge!
                                                            .apply(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary),
                                                      ),
                                                      Text(
                                                        reactionTimeFormat
                                                            .format(DateTime(0,0,0,0,0,snapshot!.data as int)
                                                                ),
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .titleLarge!
                                                            .apply(
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .onPrimary),
                                                      ),
                                                    ],
                                                  )
                                                : Text("La oferta ha caducado"),
                                            ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0), // Adjust the radius here
                                                  ),
                                                ),
                                                onPressed: widget.reaction
                                                            .secondsUntilExpiration >
                                                        5
                                                    ? () {
                                                        if (widget.reaction
                                                                .secondsUntilExpiration >
                                                            5) {
                                                          Dependencies
                                                              .reactionPresentation
                                                              .revealReaction(
                                                            reactionId: widget
                                                                .reaction
                                                                .idReaction,
                                                            showAd: true,
                                                          );
                                                        }
                                                      }
                                                    : null,
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            "Revelar con anuncio"),
                                                        Row(
                                                          children: [
                                                            Text("200"),
                                                            Icon(
                                                                LineAwesomeIcons
                                                                    .coins),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    8.0), // Adjust the radius here
                                              ),
                                            ),
                                            onPressed: () {
                                                    if (widget.reaction
                                                            .secondsUntilExpiration >
                                                        5) {
                                                      Dependencies
                                                          .reactionPresentation
                                                          .revealReaction(
                                                              reactionId: widget
                                                                  .reaction
                                                                  .idReaction,
                                                              showAd: false);
                                                    }
                                                  },
                                              
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text("Revelar sin anuncio"),
                                                    Row(
                                                      children: [
                                                        Text("400"),
                                                        Icon(LineAwesomeIcons
                                                            .coins),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 200.h,
                              child: LoadingIndicator(
                                  indicatorType: Indicator.orbit),
                            ),
                            Text(AppLocalizations.of(context)!
                                .revealing_card_revealing)
                          ],
                        )),
            ),
            widget.reaction.userBlocked == true
                ? Container(
                    height: widget.boxConstraints.biggest.height,
                    width: widget.boxConstraints.biggest.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: EdgeInsets.all(10.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            size: 300.sp,
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .revealing_card_user_blocked,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.apply(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer),
                          ),
                          Divider(
                            color: Colors.transparent,
                            height: 70.h,
                          ),
                          Text(
                            AppLocalizations.of(context)!
                                .revealing_card_user_blocked_description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.apply(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onErrorContainer),
                          ),
                          Divider(
                            color: Colors.transparent,
                            height: 70.h,
                          ),
                          FilledButton(
                              onPressed: () {
                                Dependencies.reactionPresentation
                                    .rejectReaction(
                                        reactionId: widget.reaction.idReaction);
                              },
                              child: Text(AppLocalizations.of(context)!
                                  .revealing_card_delete_reaction))
                        ],
                      ),
                    ))
                : Container(),
          ],
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
          Column(
            children: [
              Flexible(
                flex: 10,
                fit: FlexFit.tight,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: widget.boxConstraints.maxWidth,
                      child: FutureBuilder(
                          future: remitentImageData,
                          builder: (BuildContext context,
                              AsyncSnapshot<Uint8List> imageData) {
                            return imageData.data != null
                                ? Image.memory(
                                    imageData.data!,
                                    fit: BoxFit.cover,
                                  )
                                : Center(
                                    child: Container(
                                        height: 200.h,
                                        width: 200.h,
                                        child: LoadingIndicator(
                                            indicatorType: Indicator.orbit)),
                                  );
                          })),
                ),
              ),
              Flexible(
                  flex: 3,
                  fit: FlexFit.loose,
                  child: revealedSideButtons(
                      reaction.reactionValue, reaction.name)),
            ],
          ),
          profileInfo(
              name: reaction.name,
              age: reaction.age.toString(),
              reactionValue: reaction.reactionValue),
          widget.reaction.getReactionAceptingState ==
                  ReactionAceptingState.inProcessAcepting
              ? Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  width: widget.boxConstraints.maxWidth,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!
                              .revealing_card_creating_conversation,
                          style: Theme.of(context).textTheme.titleMedium?.apply(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer),
                        ),
                        Divider(
                          color: Colors.transparent,
                          height: 50.h,
                        ),
                        Container(
                            height: 100.h,
                            child: LoadingIndicator(
                                indicatorType: Indicator.circleStrokeSpin)),
                      ],
                    ),
                  ),
                )
              : widget.reaction.getReactionAceptingState ==
                      ReactionAceptingState.inProcessDeclining
                  ? Container(
                      width: widget.boxConstraints.maxWidth,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppLocalizations.of(context)!
                                  .revealing_card_deleting_reaction,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                            ),
                            Divider(
                              color: Colors.transparent,
                              height: 50.h,
                            ),
                            Container(
                                height: 100.h,
                                child: LoadingIndicator(
                                  indicatorType: Indicator.circleStrokeSpin,
                                  colors: [
                                    Theme.of(context).colorScheme.primary
                                  ],
                                )),
                          ],
                        ),
                      ),
                    )
                  : Container(),
          reaction.userBlocked
              ? Container(
                  height: widget.boxConstraints.biggest.height,
                  width: widget.boxConstraints.biggest.width,
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 500.sp,
                      ),
                      Text(
                        AppLocalizations.of(context)!
                            .revealing_card_user_blocked_description,
                        style: GoogleFonts.lato(
                            color: Colors.white, fontSize: 70.sp),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Dependencies.reactionPresentation.rejectReaction(
                                reactionId: widget.reaction.idReaction);
                          },
                          child: Text(AppLocalizations.of(context)!
                              .revealing_card_delete_reaction))
                    ],
                  ))
              : Container(),
          justRevealed == true
              ? Container(
                  width: widget.boxConstraints.maxWidth,
                  height: widget.boxConstraints.maxHeight,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Padding(
                    padding: EdgeInsets.only(left: 30.w, right: 30.w),
                    child: Column(
                      children: [
                        Flexible(
                          flex: 4,
                          fit: FlexFit.tight,
                          child: LayoutBuilder(builder: (BuildContext context,
                              BoxConstraints boxConstraints) {
                            return Container(
                              height: boxConstraints.maxHeight,
                              width: boxConstraints.maxHeight,
                              child: CircularPercentIndicator(
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation: true,
                                  animateFromLastPercent: true,
                                  progressColor:
                                      Theme.of(context).colorScheme.primary,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  lineWidth: 50.w,
                                  radius: 250.sp,
                                  startAngle: 360,
                                  percent:
                                      (reaction.reactionValue / 100).toDouble(),
                                  center: Text(
                                    "${(reaction.reactionValue).toDouble().toStringAsFixed(0)}% ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall,
                                  )),
                            );
                          }),
                        ),
                        reaction.reactionValue >= 66
                            ? Flexible(
                                flex: 3,
                                fit: FlexFit.loose,
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!
                                              .revealing_card_likes_you,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium!
                                              .apply(fontWeightDelta: 2),
                                        ),
                                        Container(
                                            child: SvgPicture.asset(
                                                "assets/likeEmojy.svg"))
                                      ],
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .revealing_card_likes_you_description,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              )
                            : reaction.reactionValue >= 33 &&
                                    reaction.reactionValue < 66
                                ? Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .revealing_card_maybe_likes_you,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
                                                  .apply(fontWeightDelta: 2),
                                            ),
                                            SvgPicture.asset(
                                                "assets/maybeEmoji.svg")
                                          ],
                                        ),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .revealing_card_maybe_likes_you_description,
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ],
                                    ),
                                  )
                                : Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .revealing_card_doesnt_like_you,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineMedium!
                                                  .apply(fontWeightDelta: 2),
                                            ),
                                            SvgPicture.asset(
                                                "assets/passEmoji.svg")
                                          ],
                                        ),
                                        Text(
                                            AppLocalizations.of(context)!
                                                .revealing_card_doesnt_like_you_description,
                                            textAlign: TextAlign.left,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge),
                                      ],
                                    ),
                                  ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.loose,
                          child: Container(
                            child: FilledButton(
                                onPressed: () {
                                  justRevealed = false;
                                  setState(() {});
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .revealing_card_view_profile)),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Align revealedSideButtons(
    int reactionValue,
    String name,
  ) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Column(
        children: [
          Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: Row(
                children: [
                  Flexible(
                      flex: 2,
                      fit: FlexFit.loose,
                      child: reactionValue >= 66
                          ? Text(
                              AppLocalizations.of(context)!
                                  .revealing_card_high_chances(
                                      reactionValue.toString()),
                              style: Theme.of(context).textTheme.bodyLarge)
                          : Text(
                              AppLocalizations.of(context)!
                                  .revealing_card_chances(
                                      reactionValue.toString()),
                            ))
                ],
              )),
          Flexible(
            flex: 3,
            fit: FlexFit.loose,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    onPressed: () {
                      Dependencies.reactionPresentation.acceptReaction(
                          reactionId: widget.reaction.idReaction,
                          reactionSenderId: widget.reaction.senderId);
                    },
                    child: Text(
                        AppLocalizations.of(context)!.revealing_card_accept)),
                TextButton(
                    onPressed: () {
                      Dependencies.reactionPresentation.rejectReaction(
                          reactionId: widget.reaction.idReaction);
                    },
                    child: Text(
                        AppLocalizations.of(context)!.revealing_card_reject))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
