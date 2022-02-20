import 'dart:async';

import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';

import '../../core/dependencies/error/Failure.dart';

class ChatController {
  ChatRepository chatRepository;
  List<Chat> chatList = [];
  ChatController({
    required this.chatRepository,
  });

  StreamController get chatStream => chatRepository.getChatStream;

  Future<Either<Failure, bool>> initializeChatListener() async {
    _initializeChatListener();
    return await chatRepository.initializeChatListener();
  }

  @protected
  void _initializeChatListener() {
    chatStream.stream.listen((event) {
      if (event is List<Chat>) {
        chatList.addAll(event);
      }
    });
  }

  Future<Either<Failure, bool>> sendMessage(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    return await chatRepository.sendMessages(
        message: message,
        messageNotificationToken: messageNotificationToken,
        remitentId: remitentId);
  }
}
