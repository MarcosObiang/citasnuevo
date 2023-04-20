import 'dart:async';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';

import '../DataManager.dart';
import '../../core/error/Failure.dart';
import '../../core/streamParser/streamPareser.dart';
import 'verificationDataSource.dart';



abstract class VerificationRepository implements ModuleCleanerRepository, StreamParser{
late VerificationDataSource verificationDataSource;

Future<Either<Failure,bool>> requestVerificationProcess();
Future<Either<Failure,bool>> submitVerificationPicture({required Uint8List byteData});
}