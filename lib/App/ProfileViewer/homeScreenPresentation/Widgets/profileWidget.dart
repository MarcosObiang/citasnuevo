import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../../../ReportUsers/ReportScreen.dart';
import '../../../../core/common/profileCharacteristics.dart';
import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../controllerDef.dart';
import '../../ProfileEntity.dart';
import '../homeScrenPresentation.dart';
import 'ProfileCharacteristicsWidget.dart';
import 'ProfileDescription.dart';
import 'ProfilePicture.dart';

// ignore: must_be_immutable
class ProfileWidget extends StatefulWidget {
  final BoxConstraints boxConstraints;
  int listIndex;
  bool needRatingWidget;
  bool showDistance;

  Profile profile;
  List<Map<dynamic, dynamic>> images = [];
  ProfileWidget({
    required this.profile,
    required this.needRatingWidget,
    required this.boxConstraints,
    required this.listIndex,
    required this.showDistance,
  });

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ProfileWidgetState();
  }
}

enum ScreenRatingType { NONE, MAYBE, PASS, LIKE }

class _ProfileWidgetState extends State<ProfileWidget> {
  ScreenRatingType screenReactionType = ScreenRatingType.NONE;
  List<Widget> widgetList = [];
  double ratingValue = 5;
  bool showAd = true;

  @override
  void initState() {
    super.initState();

    widget.images.addAll([
      widget.profile.profileImage1,
      widget.profile.profileImage2,
      widget.profile.profileImage3,
      widget.profile.profileImage4,
      widget.profile.profileImage5,
      widget.profile.profileImage6
    ]);
    generateList();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: Dependencies.homeScreenPresentation,
      child: Consumer<HomeScreenPresentation>(builder: (BuildContext context,
          HomeScreenPresentation homeScreenPresentation, Widget? child) {
        return showAd == true
            ? Container(
                height: widget.boxConstraints.maxHeight,
                width: widget.boxConstraints.maxWidth,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Container(
                          color: Theme.of(context).colorScheme.surface,
                          child: ListView(
                              addAutomaticKeepAlives: true,
                              children: widgetList),
                        ),
                      ),
                    ),
                    profileInfo(
                        name: widget.profile.name,
                        age: widget.profile.age.toString(),
                        distance: widget.profile.distance.toString(),
                        showDistance: widget.showDistance),
                    screenReactionType == ScreenRatingType.MAYBE
                        ? maybeRatingScreen(homeScreenPresentation)
                        : screenReactionType == ScreenRatingType.LIKE
                            ? likeRatingScreen(homeScreenPresentation)
                            : screenReactionType == ScreenRatingType.PASS
                                ? passRatingScreen(homeScreenPresentation)
                                : Container(),
                    widget.needRatingWidget
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 30.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showRatingScreen(ReactionType.PASS,
                                          homeScreenPresentation);
                                    },
                                    child: Container(
                                      height: 150.h,
                                      width: 150.h,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              spreadRadius: 5.h,
                                              blurRadius: 5.h,
                                              blurStyle: BlurStyle.normal)
                                        ],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/passEmoji.svg",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showRatingScreen(ReactionType.MAYBE,
                                          homeScreenPresentation);
                                    },
                                    child: Container(
                                      height: 150.h,
                                      width: 150.h,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              spreadRadius: 5.h,
                                              blurRadius: 5.h,
                                              blurStyle: BlurStyle.normal)
                                        ],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/maybeEmoji.svg",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showRatingScreen(ReactionType.LIKE,
                                          homeScreenPresentation);
                                    },
                                    child: Container(
                                      height: 150.h,
                                      width: 150.h,
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary,
                                              spreadRadius: 5.h,
                                              blurRadius: 5.h,
                                              blurStyle: BlurStyle.normal)
                                        ],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: SvgPicture.asset(
                                        "assets/likeEmojy.svg",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container()
                  ],
                ))
            : Center(
                child: Container(
                    child: Center(
                        child: AppodealBanner(
                            adSize: AppodealBannerSize.MEDIUM_RECTANGLE,
                            placement: "default"))),
              );
      }),
    );
  }

  Widget profileInfo(
      {required String name,
      required String age,
      required String distance,
      required bool showDistance}) {
    return Container(
        height: widget.boxConstraints.maxHeight * 0.15,
        width: widget.boxConstraints.maxWidth,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Padding(
          padding: EdgeInsets.only(top: 40.h, left: 40.h, right: 40.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    age,
                    style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 50.sp,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  showDistance
                      ? Text(
                          "$distance Km",
                          style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold),
                        )
                      : Container(),
                ],
              )
            ],
          ),
        ));
  }

  Widget likeRatingScreen(HomeScreenPresentation homeScreenPresentation) {
    return Container(
      height: widget.boxConstraints.maxHeight,
      width: widget.boxConstraints.maxWidth,
      decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          children: [
            Container(
              height: 400.h,
              width: 400.h,
              child: SvgPicture.asset("assets/likeEmojy.svg"),
            ),
            Text(
              "Te gusta",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .apply(fontWeightDelta: 2),
            ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            Text(
              "Te gusta mucho....... ¿El anillo pa cuando?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            FilledButton(
              onPressed: () {
                rateWithLike(homeScreenPresentation);
              },
              child: Text("Continuar"),
            )
          ],
        ),
      ),
    );
  }

  Widget passRatingScreen(HomeScreenPresentation homeScreenPresentation) {
    return Container(
      height: widget.boxConstraints.maxHeight,
      width: widget.boxConstraints.maxWidth,
      decoration: BoxDecoration(
          color: Colors.red.shade800,
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          children: [
            Container(
              height: 400.h,
              width: 400.h,
              child: SvgPicture.asset("assets/passEmoji.svg"),
            ),
            Text(
              "No te gusta",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .apply(fontWeightDelta: 2),
            ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            Text(
              "No es tu tipo",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            FilledButton(
              onPressed: () {
                rateWithMaybe(homeScreenPresentation);
              },
              child: Text("Continuar"),
            )
          ],
        ),
      ),
    );
  }

  Widget maybeRatingScreen(HomeScreenPresentation homeScreenPresentation) {
    return Container(
      height: widget.boxConstraints.maxHeight,
      width: widget.boxConstraints.maxWidth,
      decoration: BoxDecoration(
          color: Colors.amber.withAlpha(255),
          borderRadius: BorderRadius.all(Radius.circular(30))),
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          children: [
            Container(
              height: 400.h,
              width: 400.h,
              child: SvgPicture.asset("assets/maybeEmoji.svg"),
            ),
            Text(
              "Quizas te guste",
              style: Theme.of(context)
                  .textTheme
                  .displayMedium!
                  .apply(fontWeightDelta: 2),
            ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            Text(
              "No lo tienes claro y quieres ver si pasa algo o no",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            FilledButton(
              onPressed: () {
                rateWithMaybe(homeScreenPresentation);
              },
              child: Text("Continuar"),
            )
          ],
        ),
      ),
    );
  }

  void rateWithLike(HomeScreenPresentation homeScreenPresentation) {
    homeScreenPresentation.sendReaction(
        ReactionType.LIKE, widget.listIndex, widget.boxConstraints);
  }

  void rateWithMaybe(HomeScreenPresentation homeScreenPresentation) {
    homeScreenPresentation.sendReaction(
        ReactionType.MAYBE, widget.listIndex, widget.boxConstraints);
  }

  void rateWithPass(HomeScreenPresentation homeScreenPresentation) {
    homeScreenPresentation.sendReaction(
        ReactionType.PASS, widget.listIndex, widget.boxConstraints);
    screenReactionType = ScreenRatingType.NONE;
    setState(() {});
  }

  void showRatingScreen(ReactionType reactionType,
      HomeScreenPresentation homeScreenPresentation) {
    try {
      if (reactionType == ReactionType.LIKE) {
        screenReactionType = ScreenRatingType.LIKE;
        setState(() {});
      }
      if (reactionType == ReactionType.MAYBE) {
        screenReactionType = ScreenRatingType.MAYBE;
        setState(() {});
      }
      if (reactionType == ReactionType.PASS) {
        screenReactionType = ScreenRatingType.PASS;
        setState(() {});
      }
    } catch (e) {}
  }

  void generateList() {
    for (int i = 0; i < widget.images.length; i++) {
      dynamic imagen = widget.images[i]["imageId"];
      if (imagen != "empty") {
        widgetList.add(ProfilePicture(
          isFirstPicture: i == 0 ? true : false,
          profilePicture: widget.images[i],
          boxConstraints: widget.boxConstraints,
        ));
      }
    }

    widgetList.insert(
        1,
        ProfileDescription(
          bio: widget.profile.bio,
          constraints: widget.boxConstraints,
        ));
    widgetList.insert(
        2,
        ProfileCharateristicsWidget(
          profileCharateristicsData: widget.profile.profileCharacteristics,
          constraints: widget.boxConstraints,
        ));

    widgetList.add(ProfileFoot(
        constraints: widget.boxConstraints, profileId: widget.profile.id));
  }
}
