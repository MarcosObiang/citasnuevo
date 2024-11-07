import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../DataManager.dart';
import '../ProfileViewer/ProfileEntity.dart';
import '../../core/error/Failure.dart';
import '../../core/streamParser/streamPareser.dart';
import 'MessageEntity.dart';
import 'chatDataSource.dart';

abstract class ChatRepository implements ModuleCleanerRepository, StreamParser {
  late ChatDataSource chatDataSource;
  Future<Either<Failure, bool>> initializeChatListener();
  Future<Either<Failure, bool>> initializeMessageListener();
  Future<Either<Failure, List<Message>>> loadMoreMessages(
      {required String chatId, required String lastMessageId});
   bool get isUserPremium;
  Future<Either<Failure, Profile>> getUserProfile(
      {required String profileId, required String chatId});
  Future<Either<Failure, bool>> deleteChat(
      {required String remitent1,
      required String remitent2,
      required String reportDetails,
      required String chatId});

  Future<Either<Failure, bool>> sendMessages(
      {required Message message,
      required String messageNotificationToken,
      required String remitentId});
  Future<Either<Failure, bool>> messagesSeen({
    required List<Message> messaages,
  });
  Future<Either<Failure, bool>> createBlindDate();
  Future<Either<Failure, Uint8List?>> getImage();
  Future<Either<Failure, bool>> goToAppSettings();
  Future<Either<Failure, bool>> revealBlindDate({required String chatId});

  Future<Either<Failure, bool>> showRewarded();
  StreamController<Map<String, dynamic>> get rewardedStatusListener;
  void closeAdsStreams();
}
