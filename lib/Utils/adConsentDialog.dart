import 'package:citasnuevo/Utils/routes.dart';
import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';

enum AdConsentformState { LOADING, ERROR, READY, DONE }

class AdConsentform extends StatefulWidget {
  AdConsentformState adConsentformState = AdConsentformState.READY;
  bool consent = false;
  AdConsentform();

  @override
  State<AdConsentform> createState() => _AdConsentformState();
}

class _AdConsentformState extends State<AdConsentform> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(50.w),
          child: Stack(
            children: [
              widget.adConsentformState == AdConsentformState.LOADING
                  ? Container(
                      child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppLocalizations.of(context!)!.adConsentform_pleaseWait),
                              Container(
                                  height: 200.h,
                                  width: 200.h,
                                  child: LoadingIndicator(
                                      indicatorType: Indicator.orbit))
                            ]),
                      ),
                    )
                  : widget.adConsentformState == AdConsentformState.ERROR
                      ? Container(
                          child: Center(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(AppLocalizations.of(context!)!.adConsentform_unexpectedError),
                                  Column(
                                    children: [
                                      TextButton.icon(
                                          onPressed: () async {
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.LOADING;
                                            });
                                            bool result = await Dependencies
                                                .advertisingServices
                                                .setConsentStatus(
                                                    consentPersonalizedAds:
                                                        widget.consent);
                                            if (result) {
                                              setState(() {
                                                widget.adConsentformState =
                                                    AdConsentformState.DONE;
                                              });
                                            } else {
                                              setState(() {
                                                widget.adConsentformState =
                                                    AdConsentformState.ERROR;
                                              });
                                            }
                                          },
                                          icon: Icon(Icons.refresh),
                                          label: Text(AppLocalizations.of(context!)!.adConsentform_tryAgain)),
                                      TextButton.icon(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          icon: Icon(Icons.refresh),
                                          label: Text(AppLocalizations.of(context!)!.adConsentform_tryLater))
                                    ],
                                  )
                                ]),
                          ),
                        )
                      : widget.adConsentformState == AdConsentformState.DONE
                          ? Container(
                              child: Center(
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(AppLocalizations.of(context!)!.adConsentform_thanks),
                                      Column(
                                        children: [
                                          TextButton.icon(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Dependencies
                                                    .clearDependenciesOnly();
                                                Dependencies
                                                    .initializeDependencies();
                                              },
                                              icon: Icon(Icons.refresh),
                                              label: Text(AppLocalizations.of(context!)!.adConsentform_continue)),
                                        ],
                                      )
                                    ]),
                              ),
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(30.h),
                                    child: ListView(
                                      children: [
                                        Text(
                                          AppLocalizations.of(context!)!.adConsentform_personalizeYourExperience,
                                          style: GoogleFonts.lato(
                                              color: Colors.black,
                                              fontSize: 50.sp),
                                          softWrap: true,
                                        ),
                                        Divider(
                                          height: 100.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                              AppLocalizations.of(context!)!.adConsentform_storageAndAccessToInformation,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            collapsed: Text(
                                              "",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              maxLines: 1,
                                            ),
                                            expanded: Text(
                                              AppLocalizations.of(context!)!.adConsentform_storageAndAccessToInformationDescription,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              softWrap: true,
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                              AppLocalizations.of(context!)!.adConsentform_personalization,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            collapsed: Text(
                                              "",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              maxLines: 1,
                                            ),
                                            expanded: Text(
                                              AppLocalizations.of(context!)!.adConsentform_personalizationDescription,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              softWrap: true,
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                              AppLocalizations.of(context!)!.adConsentform_adSelectionDeliveryReporting,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            collapsed: Text(
                                              "",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              maxLines: 1,
                                            ),
                                            expanded: Text(
                                              AppLocalizations.of(context!)!.adConsentform_adSelectionDeliveryReportingDescription,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              softWrap: true,
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                              AppLocalizations.of(context!)!.adConsentform_contentSelectionDeliveryReporting,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            collapsed: Text(
                                              "",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              maxLines: 1,
                                            ),
                                            expanded: Text(
                                              AppLocalizations.of(context!)!.adConsentform_contentSelectionDeliveryReportingDescription,
                                              softWrap: true,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                              AppLocalizations.of(context!)!.adConsentform_measurement,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Text(
                                              AppLocalizations.of(context!)!.adConsentform_measurementDescription,
                                              softWrap: true,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            )),
                                        Divider(
                                          height: 100.h,
                                          color: Colors.transparent,
                                        ),
                                        Text(
                                          AppLocalizations.of(context!)!.adConsentform_partners,
                                          style: GoogleFonts.lato(
                                              color: Colors.black,
                                              fontSize: 70.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Divider(
                                          height: 100.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_appodealInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_appodealIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://appodeal.com/privacy-policy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_bidMachineInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_bidMachineIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://bidmachine.io/privacy-policy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,

                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_adColonyInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              maxLines: 1,
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_adColonyIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://adcolony.com/privacy-policy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_googleLLC,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_googleLLCDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://policies.google.com/privacy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_amazon,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_amazonDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://amazon.com/privacy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_appLovin,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_appLovinDescription,

                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://applovin.com/privacy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                         AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text( AppLocalizations.of(context!)!.adConsentform_chartboostInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                 AppLocalizations.of(context!)!.adConsentform_chartboostInc,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://answers.chartboost.com/en-us/articles/200780269"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_metaInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_metaIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://www.facebook.com/privacy/policy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_inMobiPteLtd,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                 AppLocalizations.of(context!)!.adConsentform_inMobiPteLtdDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://www.inmobi.com/privacy-policy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                              AppLocalizations.of(context!)!.adConsentform_ironSourceLtd,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_ironSourceLtdDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://www.is.com/privacy-policy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(
                                                AppLocalizations.of(context!)!.adConsentform_mobVistaInternationalTechnologyLimited,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                 AppLocalizations.of(context!)!.adConsentform_mobVistaInternationalTechnologyLimitedDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://www.mobvista.com/en/privacy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_mycomBVDescription,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_mycomBVDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://legal.my.com/us/mytarget/privacy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_oguryLtd,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_oguryLtdDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://ogury.com/privacy-policy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_smaatoInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_smaatoIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://www.smaato.com/privacy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_startAppInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                AppLocalizations.of(context!)!.adConsentform_startAppIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://www.start.io/policy/privacy-policy-site/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_tapjoyInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                              maxLines: 1,
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  "",
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://dev.tapjoy.com/en/legal/Privacy-Policy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_unityTechnologies,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_unityTechnologiesDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://unity.com/legal/game-player-and-app-user-privacy-policy"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_vungleInc,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context!)!.adConsentform_vungleIncDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://vungle.com/privacy/"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                        Divider(
                                          height: 50.h,
                                          color: Colors.transparent,
                                        ),
                                        ExpandablePanel(
                                            header: Text(AppLocalizations.of(context!)!.adConsentform_yandexLLC,
                                                style: GoogleFonts.lato(
                                                    color: Colors.black,
                                                    fontSize: 50.sp,
                                                    fontWeight: FontWeight.bold)),
                                            collapsed: Text(
                                              "",
                                              maxLines: 1,
                                              style: GoogleFonts.lato(
                                                  color: Colors.black,
                                                  fontSize: 50.sp),
                                            ),
                                            expanded: Column(
                                              children: [
                                                Text(AppLocalizations.of(context!)!.adConsentform_yandexLLCDescription,
                                                  style: GoogleFonts.lato(
                                                      color: Colors.black,
                                                      fontSize: 50.sp),
                                                ),
                                                TextButton(
                                                    onPressed: () {
                                                      launchUrl(
                                                        Uri.parse(
                                                            "https://yandex.com/legal/confidential/index.html"),
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      );
                                                    },
                                                    child: Text(
                                                        AppLocalizations.of(context!)!.adConsentform_viewPartnersPrivacyPolicies))
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  height: kToolbarHeight * 2,
                                  child: Column(
                                    children: [
                                      ElevatedButton(
                                          onPressed: () async {
                                            widget.consent = true;
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.LOADING;
                                            });
                                            bool result = await Dependencies
                                                .advertisingServices
                                                .setConsentStatus(
                                                    consentPersonalizedAds:
                                                        widget.consent);
                                            if (result) {
                                              setState(() {
                                                widget.adConsentformState =
                                                    AdConsentformState.DONE;
                                              });
                                            } else {
                                              setState(() {
                                                widget.adConsentformState =
                                                    AdConsentformState.ERROR;
                                              });
                                            }
                                          },
                                          child: Text(
                                              AppLocalizations.of(context!)!.adConsentform_seePersonalizedAds)),
                                      TextButton(
                                          onPressed: () async {
                                            widget.consent = false;
      
                                            setState(() {
                                              widget.adConsentformState =
                                                  AdConsentformState.LOADING;
                                            });
                                            bool result = await Dependencies
                                                .advertisingServices
                                                .setConsentStatus(
                                                    consentPersonalizedAds:
                                                        widget.consent);
                                            if (result) {
                                              setState(() {
                                                widget.adConsentformState =
                                                    AdConsentformState.DONE;
                                              });
                                            } else {
                                              setState(() {
                                                widget.adConsentformState =
                                                    AdConsentformState.ERROR;
                                              });
                                            }
                                          },
                                          child: Text(
                                              AppLocalizations.of(context!)!.adConsentform_dontSeePersonalizedAds))
                                    ],
                                  ),
                                )
                              ],
                            ),
            ],
          ),
        ),
      ),
    );
  }
}




