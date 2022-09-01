import 'package:citasnuevo/data/dataSources/MessaagesDataSource/MessagesDataSource.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../../core/dependencies/error/Failure.dart';
import '../../entities/MessageEntity.dart';
import '../../entities/ProfileEntity.dart';

abstract class MessagesRepo implements ModuleCleanerRepository {
  late MessagesDataSource messagesDataSource;
  Stream<dynamic> messagesStream();
    Future<Either<Failure, bool>> setMessagesOnSeen(
      {required List<String> data}) ;
  Future<Either<Failure, bool>> sendMessages(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId});
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId});
  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});
}
