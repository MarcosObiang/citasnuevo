import 'dart:async';
import 'dart:typed_data';

import 'package:citasnuevo/core/streamParser/streamPareser.dart';
import 'package:citasnuevo/data/Mappers/VerificationTicketMapper.dart';
import 'package:citasnuevo/data/dataSources/verificationDataSource/verificationDataSource.dart';
import 'package:citasnuevo/domain/repository/DataManager.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/Failure.dart';
import '../../entities/VerificationTicketEntity.dart';

abstract class VerificationRepository implements ModuleCleanerRepository, StreamParser{
late VerificationDataSource verificationDataSource;

Future<Either<Failure,bool>> requestVerificationProcess();
Future<Either<Failure,bool>> submitVerificationPicture({required Uint8List byteData});
}