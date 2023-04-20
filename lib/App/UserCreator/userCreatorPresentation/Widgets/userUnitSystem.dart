import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../userCreatorPresentation.dart';

class UserUnitSystem extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  UserUnitSystem(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<UserUnitSystem> createState() => _UserUnitSystemState();
}

class _UserUnitSystemState extends State<UserUnitSystem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
                child: Container(
                    child: Center(
                      child: Text(
                                  "Selecciona tus unidades",
                                  style: GoogleFonts.lato(fontSize: 50.sp),
                                ),
                    ))),
            Flexible(
              flex: 8,
              fit: FlexFit.tight,
              child: Container(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      child: Text(
                    "Mostrar altura en:",
                    style: GoogleFonts.lato(fontSize: 50.sp),
                  )),
                  CheckboxListTile(
                    value: widget.userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMeters,
                    onChanged: (value) {
                      widget.userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMeters = true;
                      setState(() {});
                    },
                    title: Text("Mostrar altura en cm"),
                  ),
                  CheckboxListTile(
                    value: widget.userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMeters==false,
                    onChanged: (value) {
                      widget.userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMeters = false;
                      setState(() {});
                    },
                    title: Text("Mostrar altura en pies"),
                  ),
                  Container(
                      child: Text(
                    "Mostrar distancia en:",
                    style: GoogleFonts.lato(fontSize: 50.sp),
                  )),
                  CheckboxListTile(
                    value: widget.userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMiles,
                    onChanged: (value) {
                     widget. userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMiles = true;
                      setState(() {});
                    },
                    title: Text("Mostrar distancia en millas"),
                  ),
                  CheckboxListTile(
                    value: widget.userCreatorPresentation
                        .userCreatorController.userCreatorEntity.useMiles==false,
                    onChanged: (value) {
                      widget.userCreatorPresentation.userCreatorController
                          .userCreatorEntity.useMiles = false;
                      setState(() {});
                    },
                    title: Text("Mostrar distancia en kilometros"),
                  ),
                  Divider(
                    height: 150.h,
                    color: Colors.white,
                  ),
                  Container(
                      child: Text(
                    "Se puede modificar luego en los ajustes",
                    style: GoogleFonts.lato(fontSize: 50.sp),
                  )),
                ],
              )),
            ),
            Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Column(
                  children: [
                     Text(
                        "7/8",
                        style: GoogleFonts.lato(fontSize: 60.sp),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                         ElevatedButton.icon(
                            onPressed: () => widget.pageController.previousPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut),
                            icon: Icon(Icons.arrow_back),
                            label: Text("Atras")),
                        ElevatedButton.icon(
                            onPressed: () => widget.pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut),
                            icon: Icon(Icons.arrow_forward),
                            label: Text("Siguiente")),
                      ],
                    ),
                     ElevatedButton.icon(
                              onPressed: () => widget.userCreatorPresentation.logOut(),
                              icon: Icon(Icons.cancel),
                              label: Text("Salir"))
                  ],
                ))
          ],
        ),
      ),
    );
  }
}