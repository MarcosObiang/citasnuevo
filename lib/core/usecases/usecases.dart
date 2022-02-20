import 'package:citasnuevo/core/dependencies/error/Failure.dart';
import 'package:dartz/dartz.dart';
abstract class UseCase<Type,Params>{
   Future<Either<Failure, Type>> call(Params params);}