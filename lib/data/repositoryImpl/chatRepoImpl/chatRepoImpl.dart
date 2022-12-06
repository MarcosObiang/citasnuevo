import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/error/Exceptions.dart';
import 'package:citasnuevo/core/params_types/params_and_types.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/data/Mappers/ProfilesMapper.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:flutter/foundation.dart';

import '../../../domain/entities/MessageEntity.dart';
import '../../Mappers/ChatConverter.dart';

class ChatRepoImpl implements ChatRepository {
  @override
  ChatDataSource chatDataSource;
  ChatRepoImpl({
    required this.chatDataSource,
  });
  @override
  StreamController? get getStreamParserController => streamParserController;

  @override
  StreamController? streamParserController = StreamController();

  @override
  StreamSubscription? streamParserSubscription;
  @override
  Future<Either<Failure, bool>> initializeChatListener() async {
    try {
      chatDataSource.initializeChatListener();

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
        return Left(NetworkFailure(message: e.toString()));
      } else {
        return Left(ChatFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> initializeMessageListener() async {
    try {
      chatDataSource.listenToMessages();

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
  Future<Either<Failure, bool>> setMessagesOnSeen(
      {required List<String> data}) async {
    try {
      bool value = await chatDataSource.messagesSeen(data: data);

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
  Future<Either<Failure, List<Message>>> loadMoreMessages(
      {required String chatId, required String lastMessageId}) async {
    try {
      List<Message> value = await chatDataSource.loadMoreMessages(
          chatId: chatId, lastMessageId: lastMessageId);

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
  @override
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId}) async {
    try {
      Map<String, dynamic> data =
          await chatDataSource.getUserProfile(profileId: profileId);
     List <Profile> value = await ProfileMapper.fromMap({
        "profilesList": data["profileData"],
        "userData": data["userData"],
        "todayDateTime": data["todayDateTime"]
      });
      return Right(value.first);
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
      bool value = await chatDataSource.deleteChat(
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
  Either<Failure, bool> clearModuleData() {
    try {
      streamParserSubscription?.cancel();
      streamParserSubscription = null;
      streamParserController?.close();
      streamParserController = null;
      streamParserController = StreamController();
      chatDataSource.clearModuleData();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
      } else {
        return Left(ModuleClearFailure(message: e.toString()));
      }
    }
  }

  @override
  Either<Failure, bool> initializeModuleData() {
    try {
      parseStreams();
      chatDataSource.initializeModuleData();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
      } else {
        return Left(ModuleInitializeFailure(message: e.toString()));
      }
    }
  }

  Future<Map<String, dynamic>> _chatParser(Map<String, dynamic> event) async {
    Map<String, dynamic> returnData = Map();

    bool isModified = event["modified"];
    bool isRemoved = event["removed"];
    bool firstQuery = event["firstQuery"];
    bool isAdded = event["added"];
    bool isEmpty = event["chatListIsEmpty"];

    if (firstQuery) {
      List<Map<String, dynamic>> chatDataList = event["chatList"];
      List<Chat> processedChats =
          await compute(ChatConverter.fromMap, chatDataList);
      returnData = {
        "payloadType": "chat",
        "modified": isModified,
        "removed": isRemoved,
        "added": isAdded,
        "chatList": processedChats,
        "chatListIsEmpty": isEmpty,
        "firstQuery": firstQuery
      };
    }
    if (isRemoved) {
      List<Map<String, dynamic>> chatDataList = event["chatList"];
      List<Chat> processedChats = ChatConverter.fromMap(chatDataList);
      returnData = {
        "payloadType": "chat",
        "modified": isModified,
        "removed": isRemoved,
        "added": isAdded,
        "chatList": processedChats,
        "chatListIsEmpty": isEmpty,
        "firstQuery": firstQuery
      };
    }
    if (isModified) {
      List<Map<String, dynamic>> chatDataList = event["chatList"];
      List<Chat> processedChats = ChatConverter.fromMap(chatDataList);
      returnData = {
        "payloadType": "chat",
        "modified": isModified,
        "removed": isRemoved,
        "added": isAdded,
        "chatList": processedChats,
        "chatListIsEmpty": isEmpty,
        "firstQuery": firstQuery
      };
    }
    if (isAdded) {
      List<Map<String, dynamic>> chatDataList = event["chatList"];
      List<Chat> processedChats = ChatConverter.fromMap(chatDataList);
      returnData = {
        "payloadType": "chat",
        "modified": isModified,
        "removed": isRemoved,
        "added": isAdded,
        "chatList": processedChats,
        "chatListIsEmpty": isEmpty,
        "firstQuery": firstQuery
      };
    }
    if (isEmpty) {
      List<Map<String, dynamic>> chatDataList = event["chatList"];
      List<Chat> processedChats = ChatConverter.fromMap(chatDataList);
      returnData = {
        "payloadType": "chat",
        "modified": isModified,
        "removed": isRemoved,
        "added": isAdded,
        "chatList": processedChats,
        "chatListIsEmpty": isEmpty,
        "firstQuery": firstQuery
      };
    }

    return returnData;
  }

  Future<Map<String, dynamic>> _messageParser(
      Map<String, dynamic> event) async {
    Map<String, dynamic> messageData = event["message"];
    bool modified = event["modified"];
    Message message = MessageConverter.fromMap(messageData);

    return {
      "payloadType": "chatMessage",
      "message": message,
      "modified": modified
    };
  }

  @override
  void parseStreams() async {
    if (chatDataSource.chatStream != null && streamParserController != null) {
      streamParserSubscription =
          chatDataSource.chatStream!.stream.listen((event) async {
        String payloadType = event["payloadType"];
        if (payloadType == "chat") {
          Map<String, dynamic> chatData = await _chatParser(event);
          streamParserController?.add(chatData);
        } else {
          Map<String, dynamic> messageData = await _messageParser(event);
          streamParserController?.add(messageData);
        }
      }, onError: (error) {
        streamParserController!.addError(error);
      });
    } else {
      throw Exception(kStreamParserNullError);
    }
  }
}
