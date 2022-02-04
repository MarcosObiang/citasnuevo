import 'package:firebase_core/firebase_core.dart';
class FirebaseApplication{
  static late FirebaseApplication instance;
  late FirebaseApp firebaseApp;
  Future<void> firebaseInitialize()async{
    firebaseApp= await Firebase.initializeApp();
  }}