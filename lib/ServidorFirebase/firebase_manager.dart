


class FirebaseManager {
  static String UID;

  Future<String> getCurrentUserId(dynamic auth) async {
    String usercode = await auth.user.uid;

    if (usercode != null) {
      String userId = usercode;
      UID = userId;
      print(userId);
    }
  }


}
