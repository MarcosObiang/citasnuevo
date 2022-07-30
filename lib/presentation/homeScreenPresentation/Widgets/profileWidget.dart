import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/core/common/profileCharacteristics.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/domain/entities/ProfileCharacteristicsEntity.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/presentation/homeReportScreenPresentation/ReportScreen.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/ProfileCharacteristicsWidget.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/ProfileDescription.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/ProfilePicture.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/homeScrenPresentation.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProfileWidget extends StatefulWidget {
  final BoxConstraints boxConstraints;
  int listIndex;
  bool needRatingWidget;

  Profile profile;
  List<Map<dynamic, dynamic>> images = [];
  ProfileWidget(
      {required this.profile,
      required this.needRatingWidget,
      required this.boxConstraints,
      required this.listIndex});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
return _ProfileWidgetState();  }
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool isRating = false;
  List<Widget> widgetList = [];
  double ratingValue = 5;
  var data;

  @override
  void initState() {
    // TODO: implement initState
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
      child: Consumer<HomeScreenPresentation>(
        builder: (BuildContext context,HomeScreenPresentation homeScreenPresentation,Widget? child) {
          return Container(
              height: widget.boxConstraints.maxHeight,
              width: widget.boxConstraints.maxWidth,
              child: Stack(
                children: [
                  ListView(children: widgetList),
                  profileInfo(
                      name: widget.profile.name, age: widget.profile.age.toString(),distance: widget.profile.distance.toString()),
                  if (isRating) ...[ratingScreen()],
              widget.needRatingWidget?    reactionSlider(homeScreenPresentation):Container()
                ],
              ));
        }
      ),
    );
  }

  Widget profileInfo({required String name, required String age, required String distance}) {
    return Container(
        height: widget.boxConstraints.maxHeight * 0.15,
        width: widget.boxConstraints.maxWidth,
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
                children: [
                  Text(
                    "$distance Km",
                    style:
                        GoogleFonts.lato(color: Colors.white, fontSize: 50.sp),
                  ),
                  IconButton(
                      onPressed: () {
                        goToReportScreen(widget.profile.id);
                      },
                      icon: Icon(
                        Icons.report,
                        size: 100.sp,
                        color: Colors.white,
                      )),
                ],
              )
            ],
          ),
        ));
  }

  Widget ratingScreen() {
    return Container(
      height: widget.boxConstraints.maxHeight,
      width: widget.boxConstraints.maxWidth,
      color: Colors.amberAccent,
    );
  }

  Widget reactionSlider(HomeScreenPresentation homeScreenPresentation) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding:
            const EdgeInsets.only(bottom: kBottomNavigationBarHeight * 1.5),
        child: Container(
          height: 100.h,
          child: SliderTheme(
            data: SliderThemeData(
                trackHeight: ScreenUtil().setHeight(20),
                activeTrackColor: Colors.blue,
                disabledActiveTrackColor: Colors.blue,
                disabledInactiveTrackColor: Colors.blue,
                activeTickMarkColor: Colors.blue,
                inactiveTickMarkColor: Colors.black,
                disabledActiveTickMarkColor: Colors.blue,
                disabledInactiveTickMarkColor: Colors.transparent,
                inactiveTrackColor: Colors.blue,
                disabledThumbColor: Colors.transparent,
                valueIndicatorShape: SliderComponentShape.noOverlay,
                thumbColor: Colors.deepPurple,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: 70.w,
                  elevation: 100.h,
                ),
                overlappingShapeStrokeColor: Colors.blue,
                overlayColor: Colors.pink),
            child: Slider(
              value: ratingValue,
              onChangeStart: (val) {
                isRating = true;
                setState(() {
                  ratingValue = val;
                });
              },
              onChanged: (value) {
                if (this.mounted == true) {
                  setState(() {
                    ratingValue = value;
                  });
                }
              },
              onChangeEnd: (valor) {
                isRating = false;
                if (this.mounted == true) {
                  setState(() {
                    ratingValue = valor;
                    sendReaction(ratingValue,homeScreenPresentation);
                  });
                }
              },
              min: 0,
              max: 10,
            ),
          ),
        ),
      ),
    );
  }

  void sendReaction(double ratingValue,HomeScreenPresentation homeScreenPresentation) {
    try {
    homeScreenPresentation.sendReaction(ratingValue, widget.listIndex, widget.boxConstraints);
    } catch (e) {}
  }

  void generateList() {
    var time1 = DateTime.now().microsecondsSinceEpoch;

    for (int i = 0; i < widget.images.length; i++) {
      dynamic imagen = widget.images[i]["Imagen"];
      if (imagen != "vacio") {
        widgetList.add(ProfilePicture(
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
        widgetList.add(ProfileFoot(constraints: widget.boxConstraints));

    var time2 = DateTime.now().microsecondsSinceEpoch;

    print("${(time2 - time1)} microseconds");
  }

  void goToReportScreen(String userId) {
    Navigator.push(context, GoToRoute(page: ReportScreen(userId)));
  }
}
