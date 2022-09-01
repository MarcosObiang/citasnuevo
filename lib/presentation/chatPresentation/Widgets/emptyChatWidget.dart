import 'package:cached_network_image/cached_network_image.dart';
import 'package:citasnuevo/presentation/MessagesScreenPresentation/chatScreen.dart';
import 'package:citasnuevo/presentation/routes.dart';
import 'package:flutter/material.dart';

import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:octo_image/octo_image.dart';

class EmptyChatWidget extends StatefulWidget {
  final Chat chat;
  final Animation<double> animation;
  final int index;

  EmptyChatWidget(
      {required this.chat, required this.animation, required this.index});

  @override
  _EmptyChatWidgetState createState() => _EmptyChatWidgetState();
}

class _EmptyChatWidgetState extends State<EmptyChatWidget> {
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: widget.animation,
      child: GestureDetector(
        onTap: () {

          Navigator.push(
              context,
              GoToRoute(
                  page: ChatMessagesScreen(
                chatId: widget.chat.chatId,
                userBlocked: widget.chat.userBlocked,
                imageHash: widget.chat.remitentPictureHash,
                imageUrl: widget.chat.remitenrPicture,
                remitentName: widget.chat.remitentName,
                messageTokenNotification: widget.chat.notificationToken,
                remitentId: widget.chat.remitentId,
              )));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              Container(
                width: 400.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: Center(
                    child: OctoImage(
                  fadeInDuration: Duration(milliseconds: 50),
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(widget.chat.remitenrPicture),
                  placeholderBuilder: OctoPlaceholder.blurHash(
                      widget.chat.remitentPictureHash,
                      fit: BoxFit.cover),
                )),
              ),
          widget.chat.userBlocked?    Container(
                width: 400.w,
                color: Colors.black,
                
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock,color: Colors.white,),
                        Text("Usuario bloqueado",style: GoogleFonts.lato(color: Colors.white,fontSize: 50.sp),textAlign: TextAlign.center,),

                        ElevatedButton(onPressed: (){}, child: Text("Eliminar"))
                      ],
                    )),
              ):Container(),
            ],
          ),
        ),
      ),
    );
  }
}
