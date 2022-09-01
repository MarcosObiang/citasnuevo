import 'dart:async';

import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:citasnuevo/data/dataSources/chatDataSource/chatDataSource.dart';
import 'package:citasnuevo/domain/entities/MessageEntity.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../entities/ProfileEntity.dart';

abstract class ChatRepository implements ModuleCleanerRepository {
  late ChatDataSource chatDataSource;
  Future<Either<Failure, bool>> initializeChatListener();
  Future<Either<Failure, Profile>> getUserProfile({required String profileId,required String chatId});
   Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  StreamController<dynamic>? get getChatStream;
  Stream<dynamic>? chatStream();
  StreamController<Map<String, dynamic>> get getMessageStream;
}
