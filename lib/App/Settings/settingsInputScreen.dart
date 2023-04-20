import 'package:another_xlider/another_xlider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../UserCreator/userCreatorPresentation/userCreatorPresentation.dart';

class SettingsSecreenInput extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  SettingsSecreenInput(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<SettingsSecreenInput> createState() => _SettingsSecreenInputState();
}

class _SettingsSecreenInputState extends State<SettingsSecreenInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          reverse: false,
          child: Container(
            height: ScreenUtil().screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 300.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Distancia",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Slider(
                            divisions: 14,
                            value: widget
                                .userCreatorPresentation
                                .userCreatorController
                                .userCreatorEntity
                                .maxDistanceForSearching
                                .toDouble(),
                            onChanged: (value) {
                              widget
                                  .userCreatorPresentation
                                  .userCreatorController
                                  .userCreatorEntity
                                  .maxDistanceForSearching = value.toInt();
                              setState(() {});
                            },
                            min: 10,
                            max: 150,
                          ),
                          Text(widget.userCreatorPresentation
                              .getUserCreatorEntity.maxDistanceForSearching
                              .toStringAsFixed(0)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 300.h,
                  child: Column(
                    children: [
                      Text(
                        "Edad",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                      Row(
                        children: [
                          Flexible(
                            flex: 8,
                            fit: FlexFit.tight,
                            child: Container(
                              height: 200.h,
                              child: FlutterSlider(
                                rangeSlider: true,
                                values: [
                                  widget
                                      .userCreatorPresentation
                                      .userCreatorController
                                      .userCreatorEntity
                                      .minRangeSearchingAge
                                      .toDouble(),
                                  widget
                                      .userCreatorPresentation
                                      .userCreatorController
                                      .userCreatorEntity
                                      .maxRangeSearchingAge
                                      .toDouble()
                                ],
                                max: 70,
                                min: 18,
                                onDragging: (index, minValue, maxValue) {
                                  double min = minValue;
                                  double max = maxValue;

                                  widget
                                      .userCreatorPresentation
                                      .userCreatorController
                                      .userCreatorEntity
                                      .minRangeSearchingAge = min.toInt();
                                  widget
                                      .userCreatorPresentation
                                      .userCreatorController
                                      .userCreatorEntity
                                      .maxRangeSearchingAge = max.toInt();
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            fit: FlexFit.tight,
                            child: Container(
                              child: Text(
                                  "${widget.userCreatorPresentation.userCreatorController.userCreatorEntity.minRangeSearchingAge.toStringAsFixed(0)} - ${widget.userCreatorPresentation.userCreatorController.userCreatorEntity.maxRangeSearchingAge.toStringAsFixed(0)}"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "8/8",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                              onPressed: () => widget.pageController
                                  .previousPage(
                                      duration: Duration(milliseconds: 300),
                                      curve: Curves.easeIn),
                              icon: Icon(Icons.arrow_forward),
                              label: Text("Atras")),
                          ElevatedButton.icon(
                              onPressed: () =>
                                  widget.userCreatorPresentation.createUser(),
                              icon: Icon(Icons.arrow_forward),
                              label: Text("Siguiente")),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
