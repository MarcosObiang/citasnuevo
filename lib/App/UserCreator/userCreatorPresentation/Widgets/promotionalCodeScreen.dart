import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../../core/globalData.dart';
import '../userCreatorPresentation.dart';

class PromotionalCodeScreen extends StatefulWidget {
  PageController pageController;
  UserCreatorPresentation userCreatorPresentation;
  PromotionalCodeScreen(
      {required this.pageController, required this.userCreatorPresentation});
  @override
  State<PromotionalCodeScreen> createState() => _PromotionalCodeScreenState();
}

class _PromotionalCodeScreenState extends State<PromotionalCodeScreen> {
  TextEditingController _userNameTextEditingController =
      new TextEditingController();
  TextEditingController _promotionalCodeTextEditingController =
      new TextEditingController();
  var dateFormat = DateFormat.yMEd();

  @override
  void initState() {
    super.initState();
    if (GlobalDataContainer.userName.length <= 25) {
      _userNameTextEditingController = new TextEditingController.fromValue(
          TextEditingValue(text: GlobalDataContainer.userName));
      widget.userCreatorPresentation.getUserCreatorEntity.userName =
          GlobalDataContainer.userName;
    } else {
      _userNameTextEditingController = new TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().screenHeight,
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Codigo de invitación",
                    style: GoogleFonts.lato(fontSize: 90.sp),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 6,
              fit: FlexFit.tight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Padding(
                        padding: EdgeInsets.all(10.w),
                        child: TextField(
                          controller: _promotionalCodeTextEditingController,
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            hintText: 'Codigo promocional',
                          ),
                          maxLength: 25,
                          onChanged: (value) {
                            widget.userCreatorPresentation.getUserCreatorEntity
                                .promotionalCode = value;
                          },
                          textInputAction: TextInputAction.done,
                        ),
                      ),
                    ),
                    Divider(
                      height: 50.h,
                      color: Colors.transparent,
                    ),
                    Text(
                      "Si tienes un codigo de invitacion te regalamos 5000 creditos gratis",
                      style: GoogleFonts.lato(fontSize: 45.sp),
                    ),
                    Divider(
                      height: 50.h,
                      color: Colors.transparent,
                    ),
                    Text(
                      "Si no tienes uno pulsa siguiente",
                      style: GoogleFonts.lato(fontSize: 45.sp),
                    ),
                    Divider(
                      height: 50.h,
                      color: Colors.transparent,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                          onPressed: () {
                            widget.userCreatorPresentation
                                .showPromotionalCodeInfo();
                          },
                          icon: Icon(Icons.help),
                          label: Text("¿Que es un codigo de invitacion?")),
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "1/7",
                    style: GoogleFonts.lato(fontSize: 60.sp),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                          onPressed: () {
                            widget.userCreatorPresentation.logOut();
                          },
                          icon: Icon(Icons.cancel_outlined),
                          label: Text("Salir")),
                      ElevatedButton.icon(
                          onPressed: () {
                            widget.pageController.nextPage(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut);
                          },
                          icon: Icon(Icons.arrow_forward),
                          label: Text("Siguiente")),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
