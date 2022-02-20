import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/daraSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';

import '../../../domain/entities/MessageEntity.dart';

class ChatRepoImpl implements ChatRepository {
  @override
  ChatDataSource chatDataSource;
  ChatRepoImpl({
    required this.chatDataSource,
  });

  @override
  StreamController get getChatStream => chatDataSource.chatStream;

  @override
  Future<Either<Failure, bool>> initializeChatListener() async {
    try {
      chatDataSource.initializeChatListener();

      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ChatFailure());
      }
    }
  }

  @override
  Future<Either<Failure, bool>> sendMessages(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    try {
      await chatDataSource.sendMessages(
          message: MessageConverter.toMap(message),
          messageNotificationToken: messageNotificationToken,
          remitentId: remitentId);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ChatFailure());
      }
    }
  }
}