import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../ReportUsers/ReportScreen.dart';

class ProfileDescription extends StatelessWidget {
  final String bio;
  final BoxConstraints constraints;
  const ProfileDescription({required this.bio, required this.constraints});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: constraints.maxHeight / 3,
      width: constraints.maxWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(bio),
      ),
    );
  }
}

class ProfileFoot extends StatelessWidget {
  BoxConstraints constraints;
  String profileId;
  ProfileFoot({required this.constraints, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: constraints.maxHeight / 5,
      width: constraints.maxWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: kBottomNavigationBarHeight * 0.5,
          child: TextButton.icon(
              label: Text("Denunciar perfil"),
              onPressed: () {
                goToReportScreen(profileId, context);
              },
              icon: Icon(
                Icons.report,
                size: 100.sp,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  void goToReportScreen(String userId, BuildContext context) {
    Navigator.pushNamed(context, ReportScreen.routeName,
        arguments: ReportScreenArgs(userId: userId));
  }
}
