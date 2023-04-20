import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../userCreatorPresentation.dart';


// ignore: must_be_immutable
class UserBioInput extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  UserBioInput(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<UserBioInput> createState() => _UserBioInputState();
}

class _UserBioInputState extends State<UserBioInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: ScreenUtil().screenHeight,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 4,
                fit: FlexFit.tight,
                child: Container(
                  child: Center(child: Text("Escribe algo sobre ti",style: GoogleFonts.lato(fontSize: 60.sp,fontWeight: FontWeight.bold),)),
                ),
              ),
              Flexible(
                flex: 6,
                fit: FlexFit.tight,
                child: Container(
                  child: userBio(widget.userCreatorPresentation),
                ),
              ),
              Flexible(
                  flex: 4,
                fit: FlexFit.tight,
                child: Column(
                  children: [
                      Text(
                        "6/8",
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget userBio(UserCreatorPresentation userCreatorPresentation) {
    TextEditingController textEditingController =
        new TextEditingController.fromValue(TextEditingValue(
            text: userCreatorPresentation.getUserCreatorEntity.userBio));
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.all(Radius.circular(10))),
        width: ScreenUtil().screenWidth,
        child: Padding(
          padding: EdgeInsets.all(45.w),
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(border: InputBorder.none,
    hintText: 'Algo sobre ti',),
            expands: true,
            maxLines: null,
            maxLength: 300,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              userCreatorPresentation.getUserCreatorEntity.userBio = value;
            },
          ),
        ),
      ),
    );
  }
}
