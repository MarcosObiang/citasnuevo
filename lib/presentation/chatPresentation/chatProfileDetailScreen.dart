// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:citasnuevo/presentation/homeScreenPresentation/Widgets/profileWidget.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:giphy_get/giphy_get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import 'package:citasnuevo/core/dependencies/dependencyCreator.dart';
import 'package:citasnuevo/core/globalData.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/presentation/chatPresentation/chatPresentation.dart';

import '../../main.dart';




class ChatProfileDetailsScreen extends StatefulWidget {
  String remitentId;
  ChatProfileDetailsScreen({
    required this.remitentId,
  });

  @override
  _ChatProfileDetailsScreenState createState() =>
      _ChatProfileDetailsScreenState();
}

class _ChatProfileDetailsScreenState extends State<ChatProfileDetailsScreen> {
  Profile? userProfile;

  @override
  void initState() {
    super.initState();
    searchChatObject();
  }

  void searchChatObject() {
    for (int i = 0;
        i < Dependencies.chatPresentation.chatController.chatList.length;
        i++) {
      if (Dependencies.chatPresentation.chatController.chatList[i].remitentId ==
          widget.remitentId) {
        if (Dependencies
                .chatPresentation.chatController.chatList[i].senderProfile ==
            null) {
          Dependencies.chatPresentation
              .getChatRemitentProfile(profileId: widget.remitentId);
        } else {
          userProfile = Dependencies
              .chatPresentation.chatController.chatList[i].senderProfile;

              print("object");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
          child: Container(
        color: Colors.amberAccent,
        child: LayoutBuilder(
          builder: (context,constraints) {
            return ProfileWidget(profile: userProfile as Profile, boxConstraints: constraints, listIndex: 0,needRatingWidget: false,);
          }
        ),
      )),
    );
  }
}
