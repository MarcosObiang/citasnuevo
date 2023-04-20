import 'rewardScreenPresentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';



// ignore: must_be_immutable
class ShareCodeRewardCard extends StatefulWidget {
  RewardScreenPresentation rewardScreenPresentation;
  ShareCodeRewardCard({
    required this.rewardScreenPresentation,
  });

  @override
  State<ShareCodeRewardCard> createState() => _ShareCodeRewardCardState();
}

class _ShareCodeRewardCardState extends State<ShareCodeRewardCard>
    with SingleTickerProviderStateMixin {
  

  @override
  void initState() {
    super.initState();

   
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10.h)],
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: EdgeInsets.all(30.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Invita a un amigo y gana",
                    style: GoogleFonts.roboto(
                        color: Colors.black, fontSize: 60.sp)),
                Divider(
                  color: Colors.transparent,
                  height: 50.h,
                ),
                Text(
                    "Invita a un amigo y gana 3000 monedas cuando se registre en Hotty",
                    style: GoogleFonts.roboto(
                      color: Colors.black,
                    )),
                Divider(
                  color: Colors.transparent,
                  height: 50.h,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Comparte este codigo con tus amigos"),
                    Divider(
                      color: Colors.transparent,
                      height: 50.h,
                    ),
                    SelectableText(
                      widget.rewardScreenPresentation.sharingLink as String,
                    ),
                    Divider(
                      color: Colors.transparent,
                      height: 50.h,
                    ),
                    TextButton(
                        onPressed: () {
                          Clipboard.setData(new ClipboardData(
                              text: widget.rewardScreenPresentation.sharingLink
                                  as String));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Padding(
                            padding: EdgeInsets.all(40.h),
                            child: Text(
                              'Copiar',
                              style: GoogleFonts.roboto(
                                  color: Colors.white, fontSize: 45.sp),
                            ),
                          ),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
