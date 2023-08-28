import 'dart:math';
import 'dart:typed_data';

import 'package:appwrite/appwrite.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/App/controllerDef.dart';
import 'package:citasnuevo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../../../../Utils/getImageFile.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../../ReactionEntity.dart';
import '../Screens/ReactionScreen.dart';
import '../reactionPresentation.dart';

class ReactionCard extends StatefulWidget {
  final BoxConstraints boxConstraints;
  final int index;
  final Animation<double> animation;
  final Reaction reaction;
  final storage = Storage(Dependencies.serverAPi.client!);
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
      ..addStatusListener((status) {});

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

      if (widget.reaction.imageUrl["imageId"] != "empty") {
        remitentImageData =
            ImageFile.getFile(fileId: widget.reaction.imageUrl["imageId"]);
      }
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
      if (widget.reaction.imageUrl["imageId"] != "empty") {
        remitentImageData =
            ImageFile.getFile(fileId: widget.reaction.imageUrl["imageId"]);
      }
      showCard = true;
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
                if (widget.reaction.imageUrl["imageId"] != "empty") {
                  remitentImageData = ImageFile.getFile(
                      fileId: widget.reaction.imageUrl["imageId"]);
                }
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
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
      {required String name,
      required String age,
      required String reactionType}) {
    return Container(
        height: kBottomNavigationBarHeight * 1.5,
        width: ReactionScreen.boxConstraints.maxWidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
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
              reactionType == ReactionType.LIKE.name
                  ? AnimatedBuilder(
                      animation: _reactionTypeBadgeAnimationController,
                      builder: (BuildContext context, Widget? widget) {
                        return Container(
                            decoration: BoxDecoration(
                                color: colorAnimation.value,
                                shape: BoxShape.circle),
                            height: 200.h,
                            width: 200.h,
                            child: SvgPicture.asset(
                              "assets/likeEmojy.svg",
                              fit: BoxFit.cover,
                            ));
                      })
                  : reactionType == ReactionType.MAYBE.name
                      ? AnimatedBuilder(
                          animation: _reactionTypeBadgeAnimationController,
                          builder: (BuildContext context, Widget? widget) {
                            return Container(
                                decoration: BoxDecoration(
                                    color: colorAnimation.value,
                                    shape: BoxShape.circle),
                                height: 200.h,
                                width: 200.h,
                                child: SvgPicture.asset(
                                  "assets/maybeEmoji.svg",
                                  fit: BoxFit.cover,
                                ));
                          })
                      : AnimatedBuilder(
                          animation: _reactionTypeBadgeAnimationController,
                          builder: (BuildContext context, Widget? widget) {
                            return Container(
                                decoration: BoxDecoration(
                                    color: colorAnimation.value,
                                    shape: BoxShape.circle),
                                height: 200.h,
                                width: 200.h,
                                child: SvgPicture.asset(
                                  "assets/passEmoji.svg",
                                  fit: BoxFit.cover,
                                ));
                          })
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
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              height: widget.boxConstraints.biggest.height,
              width: widget.boxConstraints.biggest.width,
              child: Center(
                  child: widget.reaction.reactionRevealigState !=
                          ReactionRevealigState.revealed
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("Alguien ha visto tu perfil",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                    )),
                            Text(
                              reactionTimeFormat.format(DateTime(
                                  0, 0, 0, 0, 0, snapshot.data as int)),
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.apply(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      fontWeightDelta: 2),
                            ),
                            Text(
                                "Averigua quien es antes de que se acabe el tiempo",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.apply(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                        fontWeightDelta: 1)),
                            widget.reaction.secondsUntilExpiration >= 5
                                ? FilledButton(
                                    onPressed: () {
                                      if (widget
                                              .reaction.secondsUntilExpiration >
                                          5) {
                                        Dependencies.reactionPresentation
                                            .revealReaction(
                                                reactionId:
                                                    widget.reaction.idReaction);
                                      }
                                    },
                                    child: Text("Revelar"))
                                : Container(),
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
                            Text("Revelando")
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
                            "Usuario bloqueado",
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
                            "El usuario ha sido bloqueado por infringir normas de la comunidad",
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
                              child: Text("Eliminar reaccion"))
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
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
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
          profileInfo(
              name: reaction.name,
              age: reaction.age.toString(),
              reactionType: reaction.reactionType),
          revealedSideButtons(),
          widget.reaction.getReactionAceptingState ==
                  ReactionAceptingState.inProcessAcepting
              ? Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  width: widget.boxConstraints.maxWidth,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Creando conversación",
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
                          borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Eliminando reacción",
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
                        "Usuario bloqueado",
                        style: GoogleFonts.lato(
                            color: Colors.white, fontSize: 70.sp),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Dependencies.reactionPresentation.rejectReaction(
                                reactionId: widget.reaction.idReaction);
                          },
                          child: Text("Eliminar reaccion"))
                    ],
                  ))
              : Container(),
          justRevealed == true
              ? Container(
                  width: widget.boxConstraints.maxWidth,
                  height: widget.boxConstraints.maxHeight,
                  decoration: BoxDecoration(
                      color: reaction.reactionType == ReactionType.LIKE.name
                          ? Colors.green
                          : reaction.reactionType == ReactionType.MAYBE.name
                              ? Colors.amber
                              : Colors.red,
                      borderRadius: BorderRadius.all(Radius.circular(20))),
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
                              child: reaction.reactionType ==
                                      ReactionType.LIKE.name
                                  ? SvgPicture.asset("assets/likeEmojy.svg")
                                  : reaction.reactionType ==
                                          ReactionType.MAYBE.name
                                      ? SvgPicture.asset(
                                          "assets/maybeEmoji.svg")
                                      : SvgPicture.asset(
                                          "assets/passEmoji.svg"),
                            );
                          }),
                        ),
                        reaction.reactionType == ReactionType.LIKE.name
                            ? Flexible(
                                flex: 3,
                                fit: FlexFit.loose,
                                child: Column(
                                  children: [
                                    Text(
                                      "Le gustas",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall!
                                          .apply(fontWeightDelta: 2),
                                    ),
                                    Text(
                                      "Parece que le gustas mucho, empieza a chatear y disfrutar",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : reaction.reactionType == ReactionType.MAYBE.name
                                ? Flexible(
                                    flex: 3,
                                    fit: FlexFit.loose,
                                    child: Column(
                                      children: [
                                        Text(
                                          "Quizas le gustes",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge!
                                              .apply(fontWeightDelta: 2),
                                        ),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        Text(
                                            "Cree que puedes llegar a gustarle pero no esta seguro, suerte....",
                                            textAlign: TextAlign.center,
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
                                        Text(
                                          "No le gustas",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineLarge!
                                              .apply(fontWeightDelta: 2),
                                        ),
                                        Text(
                                            "Que pena, animos y sigue intentandolo",
                                            textAlign: TextAlign.center,
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
                                child: Text("Ver perfil")),
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
