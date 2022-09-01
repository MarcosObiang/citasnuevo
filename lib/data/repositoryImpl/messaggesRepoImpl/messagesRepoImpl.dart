import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/MessaagesDataSource/MessagesDataSource.dart';
import 'package:citasnuevo/domain/repository/messagesRepo/messagesRepo.dart';
import 'package:flutter/foundation.dart';

import '../../../core/dependencies/error/Exceptions.dart';
import '../../../domain/entities/MessageEntity.dart';
import '../../../domain/entities/ProfileEntity.dart';
import '../../Mappers/ProfilesMapper.dart';

class MessagesRepoImpl implements MessagesRepo {
  @override
  MessagesDataSource messagesDataSource;
  MessagesRepoImpl({
    required this.messagesDataSource,
  });
  @override
  Either<Failure, bool> clearModuleData() {
    try {
      messagesDataSource.clearModuleData();

      return Right(true);
    } catch (e) {
      return Left(ModuleClearFailure(message: e.toString()));
    }
  }
  @override
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId}) async {
    try {
      Map<String,dynamic> value = await messagesDataSource.getUserProfile(profileId: profileId);
      Profile profile= ProfileMapper.fromMap(value).first;

      return Right(profile);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(ChatFailure(message: e.toString()));
      }
    }
  }
    @override
  Future<Either<Failure, bool>> sendMessages(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId}) async {
    try {
      await messagesDataSource.sendMessages(
          message: MessageConverter.toMap(message),
          messageNotificationToken: messageNotificationToken,
          remitentId: remitentId);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(ChatFailure(message: e.toString()));
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
      bool value = await messagesDataSource.deleteChat(
          chatId: chatId,
          remitent1: remitent1,
          remitent2: remitent2,
          reportDetails: reportDetails);

      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(ChatFailure(message: e.toString()));
      }
    }
  }

     @override
  Future<Either<Failure, bool>> setMessagesOnSeen(
      {required List<String> data}) async {
    try {
      bool value = await messagesDataSource.messagesSeen(data: data);
      return Right(value);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: kNetworkErrorMessage));
      } else {
        return Left(ChatFailure(message: e.toString()));
      }
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      messagesDataSource.initializeModuleData();

      return Right(true);
    } catch (e) {
      return Left(ModuleInitializeFailure(message: e.toString()));
    }
  }

  @override
  Stream messagesStream() async* {
    await for (final event in messagesDataSource.messageStream!.stream) {
      if (event["dataType"] == "conversationData") {
        // ignore: unused_local_variable
        List<MessagesGroup> chatData = await compute(
            MessageConverter.chatDataConverter,
            event["data"] as List<Map<String, dynamic>>);

        yield {"eventType": "addConversationData", "data": chatData};
      }
      if (event["eventType"] == "addNewMessageData") {
              bool isModified=event["modified"];

        Message message = MessageConverter.fromMap(event["data"]);

        yield {"eventType": "addNewMessageData", "data": message,"modified":isModified};
      }
    }
  }
}
