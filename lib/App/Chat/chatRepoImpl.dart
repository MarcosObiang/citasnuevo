import 'dart:async';
import 'dart:ffi';

import '../ProfileViewer/ProfileEntity.dart';
import '../ProfileViewer/ProfilesMapper.dart';
import '../../core/error/Exceptions.dart';
import '../../core/params_types/params_and_types.dart';
import 'MessajeConverter.dart';
import 'ChatEntity.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/Failure.dart';
import 'chatDataSource.dart';
import 'chatRepo.dart';
import 'package:flutter/foundation.dart';

import 'MessageEntity.dart';
import 'ChatConverter.dart';

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
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
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
      List<Profile> value = await ProfileMapper.fromMap({
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

  @override
  Future<Either<Failure, bool>> messagesSeen(
      {required List<String> messaagesIds}) async {
    try {
      await chatDataSource.messagesSeen(messagesIds: messaagesIds);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
      } else {
        return Left(ChatFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Uint8List?>> getImage() async {
    try {
      var result = await chatDataSource.getImage();
      return Right(result);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
      } else {
        return Left(ChatFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> createBlindDate() async {
    try {
      await chatDataSource.createBlindDate();
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
      } else {
        return Left(LocationServiceFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> goToAppSettings() async {
    try {
      var result = await chatDataSource.goToLocationSettings();
      return Right(result);
    } catch (e) {
      if (e is ChatFailure) {
        return Left(ChatFailure(message: e.toString()));
      } else if (e is LocationServiceException) {
        return Left(LocationServiceFailure(message: e.message));
      } else {
        return Left(ServerFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> revealBlindDate(
      {required String chatId}) async {
    try {
      await chatDataSource.revealBlindDate(chatId: chatId);
      return Right(true);
    } catch (e) {
      if (e is NetworkException) {
        return Left(NetworkFailure(message: e.toString()));
      }
      if (e is ChatException) {
        return Left(ChatFailure(message: e.toString()));
      } else {
        return Left(LocationServiceFailure(message: e.toString()));
      }
    }
  }
}
