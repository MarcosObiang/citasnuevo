import 'params_types/params_and_types.dart';

class GlobalDataContainer {
  static String userId = kNotAvailable;
  static String userName = kNotAvailable;
  static String userEmail = kNotAvailable;
  static int? userBirthDateInMilliseconds;

 static void clearGlobalDataContainer() {
    userId = kNotAvailable;
    userName = kNotAvailable;
    userEmail = kNotAvailable;
    userBirthDateInMilliseconds = null;
  }
}
