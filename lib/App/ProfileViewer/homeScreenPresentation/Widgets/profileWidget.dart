import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../../../../core/dependencies/dependencyCreator.dart';
import '../../../controllerDef.dart';
import '../../ProfileEntity.dart';
import '../homeScrenPresentation.dart';
import 'ProfileCharacteristicsWidget.dart';
import 'ProfileDescription.dart';
import 'ProfilePicture.dart';
import "package:flutter_gen/gen_l10n/app_localizations.dart";

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
  double ratingValue = 50;
  bool showAd = true;
  bool showRatingWall = false;
  bool showRatingSlider=false;

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

  setScreenReactionType(ScreenRatingType screenReactionType) {
    this.screenReactionType = screenReactionType;
  }

  void onSelecionChanged(Set<ScreenRatingType> selected) {
    if (screenReactionType == ScreenRatingType.NONE) {}
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
                child: Column(
                  children: [
                    Flexible(
                      flex: 25,
                      fit: FlexFit.tight,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outlineVariant)),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
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
                              age: widget.profile.age.toStringAsFixed(0),
                              distance:
                                  widget.profile.distance.toStringAsFixed(0),
                              showDistance: widget.showDistance),
                          showRatingWall == true
                              ? maybeRatingScreen(homeScreenPresentation)
                              : Container(),
                        ],
                      ),
                    ),
                   widget.needRatingWidget==true? Flexible(
                      flex: 4,
                      fit: FlexFit.loose,
                      child: Center(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: SvgPicture.asset(
                              "assets/passEmoji.svg",
                              height: 150.sp,
                              width: 150.sp,
                            ),
                          ),
                          Flexible(
                            flex: 10,
                            fit: FlexFit.tight,
                            child: Slider.adaptive(
                                onChangeStart: (value) {
                                  showRatingWall = true;
                                  setState(() {});
                                },
                                max: 100,
                                min: 1,
                                value: ratingValue,
                                onChanged: (value) {
                                  ratingValue = value;
                                  setState(() {});
                                }),
                          ),
                          Flexible(
                            flex: 2,
                            fit: FlexFit.loose,
                            child: Icon(
                              LineAwesomeIcons.heart_1,
                              size: 150.sp,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      )),
                    ):Container()
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
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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

  Widget maybeRatingScreen(HomeScreenPresentation homeScreenPresentation) {
    return Container(
      height: widget.boxConstraints.maxHeight,
      width: widget.boxConstraints.maxWidth,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withAlpha(200),
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: EdgeInsets.all(40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularPercentIndicator(
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                lineWidth: 50.w,
                radius: 250.sp,
                startAngle: 360,
                percent: ratingValue / 100,
                center: Text(
                  "${ratingValue.toStringAsFixed(0)}% ",
                  style: Theme.of(context).textTheme.displaySmall,
                )),
            /*  Container(
              height: 200.h,
              width: 200.h,
              child: SvgPicture.asset("assets/maybeEmoji.svg"),
            ),*/
            ratingValue <= 33
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.rating_dislike,
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall!
                                .apply(fontWeightDelta: 2),
                          ),
                          SvgPicture.asset("assets/passEmoji.svg")
                        ],
                      ),
                      Text(
                        AppLocalizations.of(context)!.rating_dislike_description,
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  )
                : ratingValue > 33 && ratingValue <= 66
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                               AppLocalizations.of(context)!.rating_maybe,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .apply(fontWeightDelta: 2),
                              ),
                              SvgPicture.asset("assets/maybeEmoji.svg")
                            ],
                          ),
                          Text(
                            AppLocalizations.of(context)!.rating_maybe_description,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.rating_like,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall!
                                    .apply(fontWeightDelta: 2),
                              ),
                              SvgPicture.asset("assets/likeEmojy.svg")
                            ],
                          ),
                          Text(
                            AppLocalizations.of(context)!.rating_like_description,
                            textAlign: TextAlign.left,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
            Divider(
              height: 100.h,
              color: Colors.transparent,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () {
                    showRatingWall = false;
                    setState(() {});
                  },
                  child: Text(AppLocalizations.of(context)!.rating_go_back_to_profile_button),
                ),
                FilledButton(
                  onPressed: () {
                    rateWithMaybe(homeScreenPresentation);
                    ratingValue = 50;
                  },
                  child: Text(AppLocalizations.of(context)!.rating_send_rating_and_continue_button),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void rateWithLike(HomeScreenPresentation homeScreenPresentation) {
    homeScreenPresentation.sendReaction(
        ratingValue.toInt(), widget.listIndex, widget.boxConstraints);
  }

  void rateWithMaybe(HomeScreenPresentation homeScreenPresentation) {
    homeScreenPresentation.sendReaction(
        ratingValue.toInt(), widget.listIndex, widget.boxConstraints);
  }

  void rateWithPass(HomeScreenPresentation homeScreenPresentation) {
    homeScreenPresentation.sendReaction(
        ratingValue.toInt(), widget.listIndex, widget.boxConstraints);
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
      dynamic imagen = widget.images[i]["imageData"];
      if (imagen != null&&imagen!=kNotAvailable) {
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
