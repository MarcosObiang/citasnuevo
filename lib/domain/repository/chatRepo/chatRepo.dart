import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  late ChatDataSource chatDataSource;
  Future<Either<Failure, bool>> initializeChatListener();
  Future<Either<Failure, bool>> initializeMessageListener();
  Future<Either<Failure, bool>> setMessagesOnSeen({required List<String> data});

  Future<Either<Failure, bool>> sendMessages(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId});
  StreamController<dynamic> get getChatStream;
  StreamController<Map<String, dynamic>> get getMessageStream;
}
