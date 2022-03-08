import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
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

  @override
  StreamController<Map<String, dynamic>> get getMessageStream =>
      chatDataSource.messageStream;

  @override
  Future<Either<Failure, bool>> initializeMessageListener() async {
    try {
      chatDataSource.listenToMessages();

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
  Future<Either<Failure, bool>> setMessagesOnSeen(
      {required List<String> data}) async {
    try {
      bool value = await chatDataSource.messagesSeen(data: data);

      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ChatFailure());
      }
    }
  }

  @override
  Future<Either<Failure, List<Message>>> loadMoreMessages(
      {required String chatId, required String lastMessageId}) async {
    try {
      List<Message> value = await chatDataSource.loadMoreMessages(
          chatId: chatId, lastMessageId: lastMessageId);

      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ChatFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId}) async {
    try {
      Profile value = await chatDataSource.getUserProfile(profileId: profileId);

      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ChatFailure());
      }
    }
  }

  @override
  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId}) async {
    try {
      bool value = await chatDataSource.deleteChat(
          chatId: chatId,
          remitent1: remitent1,
          remitent2: remitent2,
          reportDetails: reportDetails);

      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure());
      } else {
        return Left(ChatFailure());
      }
    }
  }

  @override
  Either<Failure, bool> clearData() {
    try {
      bool value = chatDataSource.clearData();
      return Right(value);
    } catch (e) {
      return Left(ChatFailure());
    }
  }
}
