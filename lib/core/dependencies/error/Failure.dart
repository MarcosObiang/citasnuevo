import 'package:equatable/equatable.dart';
abstract class Failure extends Equatable{
  @override
    const Failure([List properties = const <dynamic>[]]) : super();}
class GenericModuleFailure extends Failure{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();}
class ServerFailure extends Failure{
  @override
  // TODO: implement props
  ServerFailure():super();
  @override
  // TODO: implement props
  List<Object?> get props => [];}
class NetworkFailure extends Failure{
  @override
  // TODO: implement props
  NetworkFailure():super();
  @override
  // TODO: implement props
  List<Object?> get props => [];}
class AuthFailure extends Failure{
  @override
  // TODO: implement props
  AuthFailure():super();
  @override
  // TODO: implement props
  List<Object?> get props => [];}
class ApplicationStateFailure extends Failure{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();}
class FetchUserFailure extends Failure{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();}

  class RatingProfilesFailure extends Failure{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();}
  
   class ReportFailure extends Failure{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();}
  