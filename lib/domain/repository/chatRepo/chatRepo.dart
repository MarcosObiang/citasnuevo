import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:dartz/dartz.dart';

import '../../entities/ProfileEntity.dart';

abstract class ChatRepository {
  late ChatDataSource chatDataSource;
  Future<Either<Failure, bool>> initializeChatListener();
  Future<Either<Failure, bool>> initializeMessageListener();
  Future<Either<Failure, bool>> setMessagesOnSeen({required List<String> data});
  Future<Either<Failure,List<Message>>>loadMoreMessages({required String chatId,required String lastMessageId});
  Future<Either<Failure, Profile>> getUserProfile({required String profileId,required String chatId});
  Either<Failure,bool> clearData();
   Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  Future<Either<Failure, bool>> sendMessages(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId});
  StreamController<dynamic> get getChatStream;
  StreamController<Map<String, dynamic>> get getMessageStream;
}
