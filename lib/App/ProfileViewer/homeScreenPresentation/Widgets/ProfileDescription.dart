import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../ReportUsers/ReportScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileDescription extends StatefulWidget {
  final String bio;
  final BoxConstraints constraints;
  const ProfileDescription({required this.bio, required this.constraints});

  @override
  State<ProfileDescription> createState() => _ProfileDescriptionState();
}

class _ProfileDescriptionState extends State<ProfileDescription> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.constraints.maxWidth,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.sobre_mi,
              style: Theme.of(context).textTheme.bodyLarge?.apply(
                  fontWeightDelta: 2,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            Container(
              width: widget.constraints.maxWidth,
              child: Padding(
                padding: EdgeInsets.all(10.h),
                child: Text(
                  widget.bio,
                  style: Theme.of(context).textTheme.bodyLarge?.apply(
                      color: Theme.of(context).colorScheme.onPrimaryContainer),),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ProfileFoot extends StatelessWidget {
  final BoxConstraints constraints;
  final String profileId;
  ProfileFoot({required this.constraints, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: constraints.maxHeight / 3,
      width: constraints.maxWidth,
      child: Center(
        child: FilledButton.icon(
            label: Text(AppLocalizations.of(context)!.report_user),
            onPressed: () {
              goToReportScreen(profileId, context);
            },
            icon: Icon(
              Icons.report,
              size: 100.sp,
            )),
      ),
    );
  }

  void goToReportScreen(String userId, BuildContext context) {
    Navigator.pushNamed(context, ReportScreen.routeName,
        arguments: ReportScreenArgs(userId: userId));
  }
}
