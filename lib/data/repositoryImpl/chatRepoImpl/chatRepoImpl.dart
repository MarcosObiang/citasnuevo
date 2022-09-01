import 'dart:async';
import 'dart:ffi';

import 'package:citasnuevo/core/dependencies/error/Exceptions.dart';
import 'package:citasnuevo/data/Mappers/MessajeConverter.dart';
import 'package:citasnuevo/data/Mappers/ProfilesMapper.dart';
import 'package:citasnuevo/domain/entities/ChatEntity.dart';
import 'package:citasnuevo/domain/entities/ProfileEntity.dart';
import 'package:dartz/dartz.dart';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/domain/repository/chatRepo/chatRepo.dart';
import 'package:flutter/foundation.dart';

import '../../Mappers/ChatConverter.dart';

class ChatRepoImpl implements ChatRepository {
  @override
  ChatDataSource chatDataSource;
  ChatRepoImpl({
    required this.chatDataSource,
  });

  @override
  StreamController? get getChatStream => chatDataSource.chatStream;
  StreamSubscription? streamSubscriptionChat;

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
  StreamController<Map<String, dynamic>> get getMessageStream =>
      chatDataSource.messageStream;



  @override
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId}) async {
    try {
      Map<String,dynamic> value = await chatDataSource.getUserProfile(profileId: profileId);
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
      streamSubscriptionChat?.cancel();
      streamSubscriptionChat = null;
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
      chatStream();

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

  @override
  Stream? chatStream() async* {
    if (chatDataSource.chatStream != null) {
      await for (final event in chatDataSource.chatStream!.stream) {
 if(event is Exception){
          yield Exception();
        }
        else{
        bool isModified = event["modified"];
        bool isRemoved = event["removed"];
        bool firstQuery = event["firstQuery"];
        bool isAdded = event["added"];
        bool isEmpty=event["chatListIsEmpty"];

        if (firstQuery) {
          List<Map<String, dynamic>> chatDataList = event["chatDataList"];
          List<Chat> processedChats =
              await compute(ChatConverter.fromMap, chatDataList);
          yield {
            "modified": isModified,
            "removed": isRemoved,
            "added": isAdded,
            "chatDataList": processedChats,
            "chatListIsEmpty":isEmpty,
            "firstQuery": firstQuery
          };
        }
        if (isRemoved) {
          List<Map<String, dynamic>> chatDataList = event["chatDataList"];
          List<Chat> processedChats =
              ChatConverter.fromMap(chatDataList);
           yield {
            "modified": isModified,
            "removed": isRemoved,
            "added": isAdded,
            "chatDataList": processedChats,
            "chatListIsEmpty":isEmpty,
            "firstQuery": firstQuery
          };
        }
        if (isModified) {
          List<Map<String, dynamic>> chatDataList = event["chatDataList"];
          List<Chat> processedChats =
              ChatConverter.fromMap(chatDataList);
           yield {
            "modified": isModified,
            "removed": isRemoved,
            "added": isAdded,
            "chatDataList": processedChats,
            "chatListIsEmpty":isEmpty,
            "firstQuery": firstQuery
          };
        }
        if (isAdded) {
          List<Map<String, dynamic>> chatDataList = event["chatDataList"];
      List<Chat> processedChats =
              ChatConverter.fromMap(chatDataList);
           yield {
            "modified": isModified,
            "removed": isRemoved,
            "added": isAdded,
            "chatDataList": processedChats,
            "chatListIsEmpty":isEmpty,
            "firstQuery": firstQuery
          };
        }
         if (isEmpty) {
          List<Map<String, dynamic>> chatDataList = event["chatDataList"];
      List<Chat> processedChats =
              ChatConverter.fromMap(chatDataList);
            yield {
            "modified": isModified,
            "removed": isRemoved,
            "added": isAdded,
            "chatDataList": processedChats,
            "chatListIsEmpty":isEmpty,
            "firstQuery": firstQuery
          };
        }
        }



       
      }
    }
  }
  

}
